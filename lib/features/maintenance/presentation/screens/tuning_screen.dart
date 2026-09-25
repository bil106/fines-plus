import 'package:auto_route/auto_route.dart';

import 'package:core_localization/generated/l10n.dart';
import 'package:core_utils/formatters/decimal_input_formatter.dart';
import 'package:core_utils/formatters/thousands_separator_formatter.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:design_system/widget/app_back_button.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/extensions/date_picker_card.dart';
import 'package:fines_plus/core/extensions/service_list.dart';
import 'package:fines_plus/features/maintenance/domain/nearby_service_ranking.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/service_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/widgets/dashed_add_button.dart';
import 'package:fines_plus/features/maintenance/presentation/widgets/mileage_card.dart';
import 'package:fines_plus/features/maintenance/presentation/widgets/nearby_services_sheet.dart';
import 'package:fines_plus/features/maintenance/presentation/widgets/planned_services_list.dart';
import 'package:fines_plus/features/reminders/domain/planned_service.dart';
import 'package:fines_plus/features/reminders/presentation/cubit/reminder_cubit.dart';
import '../../../../../env/env.dart';
import 'package:fines_plus/features/expenses/data/models/tuning_record.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/service_map_screen.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/unit_stream.dart';
import 'package:fines_plus/features/maintenance/presentation/mixins/location_prompt_mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

@RoutePage()
class TuningScreen extends StatefulWidget {
  final VoidCallback? onBack;

  /// When true, renders just the form (no Scaffold/AppBar) for use inside
  /// [AppBottomSheet] - the dashboard's quick-add flow. Full-screen use
  /// (Maintenance tab, its FAB) leaves this false and is unaffected.
  final bool embedded;

  /// When set, a date after today books the works as reminders (no cost
  /// needed, no expense created) instead of saving them as done.
  final ReminderCubit? reminderCubit;

  /// Category of this sheet's planned works.
  static const plannedCategory = 'Tuning';

  const TuningScreen({super.key, this.onBack, this.embedded = false, this.reminderCubit});

  @override
  State<TuningScreen> createState() => TuningScreenState();
}

class _TuningWork {
  final name = TextEditingController();
  final price = TextEditingController();
  final focus = FocusNode();
  double priceUah = 0;

  void dispose() {
    name.dispose();
    price.dispose();
    focus.dispose();
  }
}

class TuningScreenState extends State<TuningScreen>
    with LocationPromptMixin<TuningScreen> {
  final _works = [_TuningWork()];

  final TextEditingController mileageController = TextEditingController();
  final FocusNode _mileageFocusNode = FocusNode();

  LatLng? _currentPosition;
  List<Map<String, dynamic>> _nearbyStations = [];
  Map<String, dynamic>? _bestStation;
  bool _isLoadingBestStation = true;
  bool _locationUnavailable = false;
  bool _loadFailed = false;
  DateTime? selectedDate = DateTime.now();

  double get _totalUah => _works
      .where((work) => work.name.text.trim().isNotEmpty)
      .fold(0, (sum, work) => sum + work.priceUah);

  @override
  void initState() {
    super.initState();
    _initLocationAndService();
    _prefillLastMileage();
  }

  void _prefillLastMileage() {
    final lastMileageKm = context.read<MaintenanceCubit>().getLastKnownMileage();
    if (lastMileageKm != null) {
      final settingsCubit = context.read<SettingsCubit>();
      final displayValue = UnitStream(settingsCubit).convert(lastMileageKm.toDouble()).round();
      mileageController.text = formatThousands(displayValue);
    }
  }

  /// Inverse of [UnitStream.convert]: the field shows the active unit, but
  /// the stored record always keeps km.
  int _mileageToKm(int displayValue) {
    final unit = context.read<SettingsCubit>().state.unit;
    return unit == 'mil' ? (displayValue / 0.621371).round() : displayValue;
  }

  /// A distance in km, converted to the active unit and paired with its
  /// label - for the "X.X km/mi away" nearby-station text.
  (String value, String unit) _distanceParts(double km) {
    final settingsCubit = context.read<SettingsCubit>();
    final converted = UnitStream(settingsCubit).convert(km);
    final unit = settingsCubit.state.unit == 'mil' ? 'mi' : S.of(context).km;
    return (converted.toStringAsFixed(1), unit);
  }

  String _stationDistanceLabel(Map<String, dynamic>? station) {
    final s = S.of(context);
    if (station == null) return s.service_retry;
    final (value, unit) = _distanceParts(serviceDistanceKm(station, _currentPosition!));
    return ((station['rating'] as num?) ?? 0) > 0
        ? s.service_best_rating_distance(value, unit)
        : s.distance_km_short(value, unit);
  }

  @override
  void dispose() {
    for (final work in _works) {
      work.dispose();
    }
    mileageController.dispose();
    _mileageFocusNode.dispose();
    super.dispose();
  }

  void _updateTotal() => setState(() {});

  void _onDateSelected(DateTime date) {
    setState(() => selectedDate = date);
    _mileageFocusNode.requestFocus();
  }

  Future<void> _initLocationAndService() async {
    setState(() {
      _isLoadingBestStation = true;
      _locationUnavailable = false;
      _loadFailed = false;
    });
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (!serviceEnabled ||
          permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _locationUnavailable = true;
            _isLoadingBestStation = false;
          });
        }
        return;
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
            .timeout(const Duration(seconds: 5));
      } catch (e) {
        // No fresh fix in time (e.g. indoors): the last known one is still
        // the user's real area, unlike any hardcoded default.
        if (kDebugMode) print("Error getting position: $e");
        position = await Geolocator.getLastKnownPosition();
      }
      if (position == null) {
        if (mounted) setState(() => _isLoadingBestStation = false);
        return;
      }
      await _loadNearbyStationsFrom(LatLng(position.latitude, position.longitude));
    } catch (e) {
      if (kDebugMode) print("Error getting position: $e");
      if (mounted) setState(() => _isLoadingBestStation = false);
    }
  }

  @override
  bool get locationUnavailable => _locationUnavailable;

  @override
  void retryLocation() => _initLocationAndService();

  Future<void> _loadNearbyStationsFrom(LatLng current) async {
    _currentPosition = current;
    try {
      final stations = await fetchNearbyServices(current, Env.mapApiKey);
      if (!mounted) return;
      setState(() {
        _nearbyStations = rankNearbyServices(stations, current);
        _bestStation = _nearbyStations.isEmpty ? null : _nearbyStations.first;
        _isLoadingBestStation = false;
      });
    } catch (e) {
      if (kDebugMode) print("Error fetching stations: $e");
      if (!mounted) return;
      setState(() {
        _loadFailed = true;
        _isLoadingBestStation = false;
      });
    }
  }

  Future<void> _openStations() async {
    if (_currentPosition == null || _nearbyStations.isEmpty) return;
    FocusScope.of(context).unfocus();
    final station = await showNearbyServicesSheet(
      context,
      currentPosition: _currentPosition!,
      stations: _nearbyStations,
    );
    if (station == null || !mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ServiceMapScreen(
          focusPosition: LatLng(
            (station['lat'] as num).toDouble(),
            (station['lng'] as num).toDouble(),
          ),
          focusName: station['name'] as String,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final settingsCubit = context.watch<SettingsCubit>();

    if (widget.embedded) {
      return _buildForm(textTheme, settingsCubit);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.energyBlue50,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: context.brandTheme.surfaceBg,
        appBar: AppBar(
          backgroundColor: context.brandTheme.surfaceBg,
          elevation: 0,
          leading: AppBackButton(onPressed: widget.onBack),
          actions: [
            IconButton(
              icon: Icon(Icons.check, color: Theme.of(context).colorScheme.primary, size: 50),
              onPressed: save,
            ),
          ],
        ),
        body: _buildForm(textTheme, settingsCubit),
      ),
    );
  }

  Widget _buildForm(TextTheme textTheme, SettingsCubit settingsCubit) {
    return SingleChildScrollView(
      padding: widget.embedded ? EdgeInsets.zero : const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.embedded)
            Text(S.of(context).tuning, style: textTheme.title),
          if (!widget.embedded) AppSpacers.verticalMedium,
          _buildStationCard(),
          AppSpacers.verticalSmall,
          _buildDateAndMileageRow(textTheme),
          Text(
            S.of(context).service_completed_work,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
          ),
          AppSpacers.verticalSmall,
          for (final work in _works) _buildWorkRow(work, settingsCubit),
          AppSpacers.verticalSmall,
          DashedAddButton(
            label: S.of(context).service_add_work,
            onPressed: () {
              final work = _TuningWork();
              setState(() => _works.add(work));
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) work.focus.requestFocus();
              });
            },
          ),
          if (widget.reminderCubit != null)
            PlannedServicesList(cubit: widget.reminderCubit!, category: TuningScreen.plannedCategory),
          AppSpacers.verticalMediumLarge,
          ServiceTotal(totalUah: _totalUah),
        ],
      ),
    );
  }

  Widget _buildStationCard() {
    final s = S.of(context);
    final title = _locationUnavailable
        ? s.service_location_unavailable
        : _loadFailed
        ? s.service_load_failed
        : _bestStation == null
        ? s.service_no_nearby
        : [_bestStation!['name'], _bestStation!['vicinity']]
              .where((value) => value != null && value.toString().isNotEmpty)
              .join(' — ');
    return Material(
      color: AppColors.neutreBlanc,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.brandTheme.surfaceBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _isLoadingBestStation
            ? null
            : _locationUnavailable
            ? enableLocation
            : _bestStation == null
            ? _initLocationAndService
            : _openStations,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: _isLoadingBestStation
              ? const Center(
                  child: SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Row(
                  children: [
                    Icon(
                      Icons.settings,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.ink),
                          ),
                          const SizedBox(height: 2),
                          Text(_stationDistanceLabel(_bestStation), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Icon(
                      _bestStation == null ? Icons.refresh : Icons.chevron_right,
                      color: AppColors.catOther,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildDateAndMileageRow(TextTheme textTheme) {
    return Row(
      children: [
        Expanded(
          child: DatePickerCard(selectedDate: selectedDate, onDateSelected: _onDateSelected),
        ),
        AppSpacers.horizontalMediumLarge,
        Expanded(
          child: MileageCard(
            textTheme: textTheme,
            controller: mileageController,
            focusNode: _mileageFocusNode,
            unitLabel: context.watch<SettingsCubit>().state.unit == 'mil' ? 'mil' : S.of(context).km,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkRow(_TuningWork work, SettingsCubit settings) {
    return Container(
      key: ObjectKey(work),
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.neutreBlanc,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: context.brandTheme.surfaceBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Autocomplete<String>(
                  textEditingController: work.name,
                  focusNode: work.focus,
                  optionsMaxHeight: 180,
                  optionsBuilder: (value) => ServiceList.tuningItems
                      .map((e) => e.name)
                      .where((name) => name.toLowerCase().contains(value.text.toLowerCase())),
                  onSelected: (name) {
                    final item = ServiceList.tuningItems.firstWhere(
                      (item) => item.name == name,
                      orElse: () => ServiceItem(name: name, priceUSD: 0),
                    );
                    work.priceUah = settings.currencyService.convert(
                      item.priceUSD,
                      'UAH',
                      fromCurrency: 'USD',
                    );
                    work.price.text = settings
                        .convertFromUAH(work.priceUah)
                        .round()
                        .toString();
                    _updateTotal();
                  },
                  fieldViewBuilder: (context, controller, focusNode, onSubmitted) =>
                      TextField(
                        controller: controller,
                        focusNode: focusNode,
                        style: const TextStyle(fontSize: 13.5, color: AppColors.ink),
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: S.of(context).select_a_service,
                          hintStyle: const TextStyle(fontSize: 13.5, color: AppColors.neutreGrey),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onChanged: (_) => _updateTotal(),
                        onSubmitted: (_) => onSubmitted(),
                      ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: work.price,
                  textAlign: TextAlign.end,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: const [DecimalInputFormatter()],
                  style: const TextStyle().merge(context.brandTheme.moneyTextStyle).copyWith(fontSize: 13.5, color: AppColors.ink),
                  decoration: InputDecoration(
                    hintText: '0',
                    suffixText: ' ${settings.state.currency}',
                    suffixStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (value) {
                    final amount = double.tryParse(value.replaceAll(',', '.')) ?? 0;
                    work.priceUah = settings.convertToUAH(amount);
                    _updateTotal();
                  },
                ),
              ),
              IconButton(
                tooltip: S.of(context).delete,
                icon: const Icon(
                  Icons.close,
                  color: AppColors.catOther,
                  size: 14,
                ),
                onPressed: () {
                  work.focus.unfocus();
                  setState(() => _works.remove(work));
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => work.dispose(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Validates and saves the current form, then closes/reports as
  /// appropriate for how this screen was presented. Shared by the AppBar
  /// check action (full-screen mode) and the pinned Save button in
  /// [AppBottomSheet] (embedded mode).
  Future<void> save() async {
    final works = _works.where((work) => work.name.text.trim().isNotEmpty).toList();
    if (selectedDate == null || works.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(backgroundColor: AppColors.blue700, content: Text(S.of(context).select_service)));
      return;
    }

    final reminderCubit = widget.reminderCubit;
    if (reminderCubit != null && PlannedService.isPlannedDate(selectedDate!, DateTime.now())) {
      try {
        await reminderCubit.addPlannedServices(
          names: [for (final work in works) work.name.text.trim()],
          date: selectedDate!,
          category: TuningScreen.plannedCategory,
        );
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.of(context).request_error)));
        return;
      }
      if (!mounted) return;
      Navigator.of(context).pop(<TuningRecord>[]);
      return;
    }

    final mileage = _mileageToKm(int.tryParse(stripThousandsSeparator(mileageController.text)) ?? 0);

    final records = works
        .map(
          (work) => TuningRecord(
            tuningName: work.name.text.trim(),
            cost: work.priceUah,
            date: selectedDate!,
            mileage: mileage,
            currency: 'UAH',
          ),
        )
        .toList();

    // This screen is reached as a pushed route (Maintenance FAB), as a
    // static PageView page (main "Тюнінг" tile), and embedded in a bottom
    // sheet (dashboard quick-add) - none of those reliably have a caller
    // awaiting a popped value, so it must save the records itself.
    context.read<MaintenanceCubit>().addTuningRecordsList(records);

    if (widget.embedded) {
      Navigator.of(context).pop(records);
    } else if (widget.onBack != null) {
      widget.onBack!();
    } else if (context.router.canPop()) {
      context.router.pop(records);
    } else {
      Navigator.of(context).maybePop(records);
    }
  }
}
