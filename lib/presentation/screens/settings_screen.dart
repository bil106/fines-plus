import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@RoutePage()
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool finesCheck = true;
  bool reminders = true;
  bool pushNotifications = true;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 26),
                Text(
                  S.of(context).settings,
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 36),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  height: screenHeight * 0.36,
                  width: double.infinity,
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildSettingRow(
                            title: S.of(context).checking_fines,
                            value: finesCheck,
                            onChanged: (val) => setState(() => finesCheck = val),
                          ),
                          const SizedBox(height: 16),
                          Divider(thickness: 3, color: Colors.grey.shade50),
                          const SizedBox(height: 16),
                          _buildSettingRow(
                            title: S.of(context).reminder,
                            value: reminders,
                            onChanged: (val) => setState(() => reminders = val),
                          ),
                          const SizedBox(height: 16),
                          Divider(thickness: 3, color: Colors.grey.shade50),
                          const SizedBox(height: 16),
                          _buildSettingRow(
                            title: S.of(context).push_notifications,
                            value: pushNotifications,
                            onChanged: (val) => setState(() => pushNotifications = val),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRow({required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 28, color: Colors.black87, fontWeight: FontWeight.w500),
        ),
        Switch(value: value, onChanged: onChanged, activeColor: Colors.white, activeTrackColor: Colors.blue),
      ],
    );
  }
}
