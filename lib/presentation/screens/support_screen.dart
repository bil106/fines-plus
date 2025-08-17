import 'package:auto_route/auto_route.dart';
import 'package:core_cubit/cubit/support_cubit.dart';
import 'package:core_cubit/cubit/support_state.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:fines_plus/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class SupportScreen extends StatefulWidget {
  final AppConfig config;

  const SupportScreen({super.key, required this.config});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
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
            AppSpacers.verticalMediumLarge,
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(S.of(context).email),
              subtitle: Text(widget.config.supportEmail),
              onTap: () => context.read<SupportCubit>().sendEmail(widget.config.supportEmail),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(S.of(context).phone),
              subtitle: Text(widget.config.phoneNumber),
              onTap: () => context.read<SupportCubit>().callPhone(widget.config.phoneNumber),
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble),
              title: Text(S.of(context).write_viber),
              subtitle: Text(widget.config.viberNumber),
              onTap: () => context.read<SupportCubit>().openViber(widget.config.viberNumber),
            ),
          ],
        ),
      ),
    );
  }
}
