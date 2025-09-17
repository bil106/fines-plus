import 'package:core_localization/generated/l10n.dart';
import 'package:flutter/material.dart';

class UnauthorizedDialog extends StatelessWidget {
  final VoidCallback onLogin;
  const UnauthorizedDialog({super.key, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:  Text(S.of(context).not_auth),
      content:  Text(S.of(context).please_log_in),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Закрыть')),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onLogin();
          },
          child:  Text(S.of(context).login),
        ),
      ],
    );
  }
}
