

import 'package:core_cubit/cubit/support_cubit.dart';
import 'package:core_cubit/cubit/support_state.dart';
import 'package:core_localization/localization/generated/l10n.dart';
import 'package:fines_plus/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';





class SupportScreen extends StatelessWidget {
  final AppConfig config;

  const SupportScreen({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SupportCubit, SupportState>(
      listener: (context, state) {
        if (state is SupportActionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(S.of(context).support)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(S.of(context).contact_us, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(S.of(context).email),
              subtitle: Text(config.supportEmail),
              onTap: () => context.read<SupportCubit>().sendEmail(config.supportEmail),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(S.of(context).phone),
              subtitle: Text(config.phoneNumber),
              onTap: () => context.read<SupportCubit>().callPhone(config.phoneNumber),
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble),
              title: Text(S.of(context).write_viber),
              subtitle: Text(config.viberNumber),
              onTap: () => context.read<SupportCubit>().openViber(config.viberNumber),
            ),
          ],
        ),
      ),
    );
  }
}
