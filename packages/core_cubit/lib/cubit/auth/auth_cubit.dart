import 'package:bloc/bloc.dart';
import 'package:core/config/app_urls.dart';
import 'package:url_launcher/url_launcher_string.dart';


class AuthCubit extends Cubit<void> {
  AuthCubit() : super(null);

  Future<void> openGoogleAuth() async {
    await launchUrlString(AppUrls.auth, mode: LaunchMode.externalApplication);
  }
}
