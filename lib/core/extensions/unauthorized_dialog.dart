import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/app/router/app_router.dart';
import 'package:flutter/material.dart';



class UnauthorizedDialog extends StatelessWidget {
  final VoidCallback onLogin;
  const UnauthorizedDialog({super.key, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      title: Text(S.of(context).not_auth, style: textTheme.headingAccent),
      content: Text(S.of(context).please_log_in, style: textTheme.bodyStrong),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.current.close, style: textTheme.statusAccent),
        ),
    TextButton(
  onPressed: () {
    Navigator.of(context).pop();  
    context.router.push(RegistrationRoute()); 
  },
  child: Text(S.of(context).login),
),


      ],
    );
  }
}

