import 'package:bloc/bloc.dart';

import 'support_state.dart';
import 'package:url_launcher/url_launcher.dart';


class SupportCubit extends Cubit<SupportState> {
  SupportCubit() : super(SupportInitial());

Future<void> sendEmail(String email) async {
    final subject = Uri.encodeComponent('Support');
    final body = Uri.encodeComponent('Good afternoon, I have a question regarding...');
    final uri = Uri.parse('mailto:$email?subject=$subject&body=$body');

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      emit(SupportActionSuccess());
    } catch (e) {
      emit(SupportActionFailure('Failed to open mail client'));
    }
  }



Future<void> callPhone(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      emit(SupportActionSuccess());
    } catch (e) {
      emit(SupportActionFailure('Failed to open number'));
    }
  }


Future<void> openViber(String phoneNumber) async {
    final sanitized = phoneNumber.replaceAll('+', '').replaceAll(' ', '');
    final uri = Uri.parse('viber://chat?number=%2B$sanitized');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
  
      final fallbackUri = Uri.parse('https://help.viber.com/hc/en-us/articles/8843920458653-Solutions-for-Rakuten-Viber-activation-and-registration-Issues?utm_campaign=version_unknown&utm_medium=Android&utm_source=Viber+App#sysid=1');
      await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
    }
  }

Future<void> openWhatsApp(String phoneNumber) async {
    final sanitized = phoneNumber.replaceAll('+', '').replaceAll(' ', '');
    final uri = Uri.parse("https://wa.me/$sanitized");

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      emit(SupportActionSuccess());
    } catch (e) {
      emit(SupportActionFailure('Failed to open WhatsApp'));
    }
  }

}
