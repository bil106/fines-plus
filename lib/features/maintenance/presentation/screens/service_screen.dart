import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:design_system/widget/app_back_button.dart';
import 'package:fines_plus/core/extensions/date_picker_card.dart';
import 'package:fines_plus/core/extensions/service_list.dart';
import 'package:fines_plus/env/env.dart';
import 'package:fines_plus/features/expenses/data/models/service_record.dart';
import 'package:fines_plus/features/maintenance/domain/nearby_service_ranking.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/service_map_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/widgets/dashed_add_button.dart';
import 'package:fines_plus/features/maintenance/presentation/widgets/mileage_card.dart';
import 'package:fines_plus/features/maintenance/presentation/widgets/nearby_services_sheet.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

@RoutePage()
class ServiceScreen extends StatefulWidget {
  final VoidCallback? onBack;

  /// Embedded forms save directly; pushed forms return records to their caller.
  final bool embedded;
  final ValueChanged<double>? onTotalChanged;

  /// Narrows the work-list autocomplete to [ServiceList.namesByCategory]
  /// for this labelKey (e.g. 'Oil', 'Battery', 'Tires') instead of the
  /// full catalog - lets Oil/Battery/Tires quick-add reuse this exact
  /// screen (station picker, work rows, total) with a smaller picklist.
  /// Null (the default, used by the standalone "ТО" entry point) keeps
  /// the full catalog.
  final String? category;

  const ServiceScreen({
    super.key,
    this.onBack,
    this.embedded = false,
    this.onTotalChanged,
    this.category,
  });

  @override
  State<ServiceScreen> createState() => ServiceScreenState();
}

class _ServiceWork {
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

class ServiceScreenState extends State<ServiceScreen> {
  final _works = [_ServiceWork()];
  final mileageController = TextEditingController();
  final _mileageFocusNode = FocusNode();
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> _stations = [];
  LatLng? _currentPosition;
  bool _loadingStations = true;
  bool _locationUnavailable = false;
  bool _stationLoadFailed = false;
  bool _saving = false;

  double get _totalUah => _works
      .where((work) => work.name.text.trim().isNotEmpty)
      .fold(0, (sum, work) => sum + work.priceUah);

  /// [widget.category]'s curated names when set, else the full catalog -
  /// see [ServiceScreen.category].
  List<String> get _catalogNames => widget.category == null
      ? ServiceList.names
      : (ServiceList.namesByCategory[widget.category] ?? ServiceList.names);

  @override
  void initState() {
    super.initState();
    final mileage = context.read<MaintenanceCubit>().getLastKnownMileage();
    if (mileage != null) mileageController.text = mileage.toString();
    _initLocationAndService();
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

  void _updateTotal() {
    setState(() {});
    widget.onTotalChanged?.call(_totalUah);
  }

  Future<void> _initLocationAndService() async {
    setState(() {
      _loadingStations = true;
      _locationUnavailable = false;
      _stationLoadFailed = false;
    });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted) setState(() => _locationUnavailable = true);
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _locationUnavailable = true);
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      final current = LatLng(position.latitude, position.longitude);
      final stations = await fetchNearbyServices(
        current,
        Env.mapApiKey,
      ).timeout(const Duration(seconds: 15));
      if (!mounted) return;
      setState(() {
        _currentPosition = current;
        _stations = rankNearbyServices(stations, current);
      });
    } catch (_) {
      if (mounted) setState(() => _stationLoadFailed = true);
    } finally {
      if (mounted) setState(() => _loadingStations = false);
    }
  }

  Future<void> _openStations() async {
    FocusScope.of(context).unfocus();
    final station = await showNearbyServicesSheet(
      context,
      currentPosition: _currentPosition!,
      stations: _stations,
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
    final settings = context.watch<SettingsCubit>();
    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStationCard(),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DatePickerCard(
                selectedDate: selectedDate,
                onDateSelected: (date) {
                  setState(() => selectedDate = date);
                  _mileageFocusNode.requestFocus();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MileageCard(
                textTheme: Theme.of(context).textTheme,
                controller: mileageController,
                focusNode: _mileageFocusNode,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          S.of(context).service_completed_work,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.grey700,
          ),
        ),
        const SizedBox(height: 8),
        for (final work in _works) _buildWorkRow(work, settings),
        DashedAddButton(
          label: S.of(context).service_add_work,
          onPressed: () {
            final work = _ServiceWork();
            setState(() => _works.add(work));
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) work.focus.requestFocus();
            });
          },
        ),
      ],
    );
    if (widget.embedded) return form;
    return Scaffold(
      backgroundColor: context.brandTheme.surfaceBg,
      appBar: AppBar(
        backgroundColor: context.brandTheme.surfaceBg,
        leading: AppBackButton(onPressed: widget.onBack),
        title: Text(S.of(context).maintenance),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: form,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ServiceTotal(totalUah: _totalUah),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : save,
                  child: Text(S.of(context).save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStationCard() {
    final station = _stations.isEmpty ? null : _stations.first;
    final textTheme = Theme.of(context).textTheme;
    final s = S.of(context);
    final title = _locationUnavailable
        ? s.service_location_unavailable
        : _stationLoadFailed
        ? s.service_load_failed
        : station == null
        ? s.service_no_nearby
        : [station['name'], station['vicinity']]
              .where((value) => value != null && value.toString().isNotEmpty)
              .join(' — ');
    return Material(
      color: AppColors.neutreBlanc,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.brandTheme.surfaceBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _loadingStations
            ? null
            : station == null
            ? _initLocationAndService
            : _openStations,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: _loadingStations
              ? const Center(
                  child: SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Row(
                  children: [
                    const Icon(
                      Icons.build_outlined,
                      color: AppColors.blueAccent,
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
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            station == null
                                ? s.service_retry
                                : ((station['rating'] as num?) ?? 0) > 0
                                ? s.service_best_rating_distance(
                                    serviceDistanceKm(
                                      station,
                                      _currentPosition!,
                                    ).toStringAsFixed(1),
                                  )
                                : s.distance_km_short(
                                    serviceDistanceKm(
                                      station,
                                      _currentPosition!,
                                    ).toStringAsFixed(1),
                                  ),
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.grey700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      station == null ? Icons.refresh : Icons.chevron_right,
                      color: AppColors.grey700,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildWorkRow(_ServiceWork work, SettingsCubit settings) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      key: ObjectKey(work),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        color: AppColors.neutreBlanc,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.brandTheme.surfaceBorder),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Autocomplete<String>(
              textEditingController: work.name,
              focusNode: work.focus,
              optionsMaxHeight: 180,
              optionsBuilder: (value) => _catalogNames.where(
                (name) => name.toLowerCase().contains(value.text.toLowerCase()),
              ),
              onSelected: (name) {
                final item = [
                  ...ServiceList.serviceItems,
                  ...ServiceList.tuningItems,
                ].firstWhere((item) => item.name == name);
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
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.black87,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: S.of(context).select_a_service,
                      hintStyle: textTheme.bodyMedium?.copyWith(
                        color: AppColors.neutreGrey,
                      ),
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
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(7),
              ],
              style: textTheme.bodyMedium
                  ?.merge(context.brandTheme.moneyTextStyle)
                  .copyWith(fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: '0',
                semanticCounterText: S.of(context).price,
                suffixText: ' ${settings.state.currency}',
                suffixStyle: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
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
              color: AppColors.neutreGrey,
              size: 18,
            ),
            onPressed: () {
              work.focus.unfocus();
              setState(() => _works.remove(work));
              widget.onTotalChanged?.call(_totalUah);
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => work.dispose(),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> save() async {
    if (_saving) return;
    final works = _works
        .where((work) => work.name.text.trim().isNotEmpty)
        .toList();
    if (works.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).select_service)));
      return;
    }
    if (works.any(
      (work) => double.tryParse(work.price.text.replaceAll(',', '.')) == null,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).service_invalid_price)),
      );
      return;
    }
    final records = works
        .map(
          (work) => ServiceRecord(
            serviceName: work.name.text.trim(),
            cost: work.priceUah,
            date:
                '${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
            mileage: int.tryParse(mileageController.text) ?? 0,
            currency: 'UAH',
          ),
        )
        .toList();
    if (widget.embedded || widget.onBack != null) {
      setState(() => _saving = true);
      try {
        await context.read<MaintenanceCubit>().addServiceRecords(records);
      } catch (_) {
        if (mounted) setState(() => _saving = false);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(S.of(context).request_error)));
        }
        return;
      }
      if (!mounted) return;
    }
    if (widget.onBack != null && !widget.embedded) {
      widget.onBack!();
    } else {
      Navigator.of(context).pop(records);
    }
  }
}

class ServiceTotal extends StatelessWidget {
  final double totalUah;
  const ServiceTotal({super.key, required this.totalUah});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>();
    final textTheme = Theme.of(context).textTheme;
    final total = settings.convertFromUAH(totalUah);
    return Column(
      children: [
        Divider(color: context.brandTheme.surfaceBorder),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  S.of(context).total,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  '${total.round()} ${settings.state.currency}',
                  textAlign: TextAlign.end,
                  style: textTheme.titleLarge?.merge(
                    context.brandTheme.moneyTextStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
