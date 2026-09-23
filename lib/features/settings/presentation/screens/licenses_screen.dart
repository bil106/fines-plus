import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:design_system/widget/app_page_app_bar.dart';
import 'package:fines_plus/app/router/app_router.dart';
import 'package:fines_plus/core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class LicensesScreen extends StatelessWidget {
  const LicensesScreen({super.key, this.applicationVersion = ''});

  final String applicationVersion;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      backgroundColor: context.brandTheme.surfaceBg,
      appBar: AppPageAppBar(title: s.licenses_and_sources),
      body: SafeArea(
        top: false,
        child: ListView(
          children: [
            AppSpacers.verticalMediumLarge,
            ListTile(
              title: Text(s.vehicle_data),
              subtitle: Text(s.vehicle_data_credit),
            ),
            ListTile(
              title: Text(s.vehicle_data_terms),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.router.push(const VehicleDataLicenseRoute()),
            ),
            Divider(color: context.brandTheme.divider),
            ListTile(
              title: Text(s.app_libraries),
              subtitle: Text(s.app_libraries_description),
            ),
            ListTile(
              title: Text(s.view_licenses),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.router.push(
                LibraryLicensesRoute(applicationVersion: applicationVersion),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@RoutePage()
class VehicleDataLicenseScreen extends StatefulWidget {
  const VehicleDataLicenseScreen({super.key});

  @override
  State<VehicleDataLicenseScreen> createState() =>
      _VehicleDataLicenseScreenState();
}

class _VehicleDataLicenseScreenState extends State<VehicleDataLicenseScreen> {
  late final Future<String> _license = rootBundle.loadString(
    'assets/licenses/vehiclesdb.txt',
  );

  // Same as Settings' privacy policy link: a device without a browser
  // shouldn't turn a tap into an unhandled error.
  Future<void> _openVehiclesDb() async {
    try {
      await launchUrl(
        Uri.parse('https://vehiclesdb.com'),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      backgroundColor: context.brandTheme.surfaceBg,
      appBar: AppPageAppBar(title: s.vehicle_data_terms),
      body: SafeArea(
        top: false,
        child: FutureBuilder<String>(
          future: _license,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text(s.licenses_load_error));
            }
            if (!snapshot.hasData) {
              return const Center(child: AppLoaders.medium);
            }
            return SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacers.horizontalMediumLarge,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton(
                          onPressed: _openVehiclesDb,
                          child: Text(s.vehicle_data_credit),
                        ),
                        AppSpacers.verticalMedium,
                        SelectableText(snapshot.data!),
                        AppSpacers.verticalMediumLarge,
                      ],
                    ),
                  ),
                  AppSpacers.horizontalMediumLarge,
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

@RoutePage()
class LibraryLicensesScreen extends StatelessWidget {
  const LibraryLicensesScreen({super.key, this.applicationVersion = ''});

  final String applicationVersion;

  @override
  Widget build(BuildContext context) => LicensePage(
    applicationName: context.read<AppConfig>().brandName,
    applicationVersion: applicationVersion,
  );
}
