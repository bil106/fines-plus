// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Enter VIN`
  String get enter_vin {
    return Intl.message('Enter VIN', name: 'enter_vin', desc: '', args: []);
  }

  /// `Auto`
  String get auto {
    return Intl.message('Auto', name: 'auto', desc: '', args: []);
  }

  /// `Fines`
  String get fines {
    return Intl.message('Fines', name: 'fines', desc: '', args: []);
  }

  /// `Reminder`
  String get reminder {
    return Intl.message('Reminder', name: 'reminder', desc: '', args: []);
  }

  /// `No reminders`
  String get no_reminders {
    return Intl.message(
      'No reminders',
      name: 'no_reminders',
      desc: '',
      args: [],
    );
  }

  /// `Support`
  String get support {
    return Intl.message('Support', name: 'support', desc: '', args: []);
  }

  /// `Contact us:`
  String get contact_us {
    return Intl.message('Contact us:', name: 'contact_us', desc: '', args: []);
  }

  /// `Phone`
  String get phone {
    return Intl.message('Phone', name: 'phone', desc: '', args: []);
  }

  /// `Write to Viber`
  String get write_viber {
    return Intl.message(
      'Write to Viber',
      name: 'write_viber',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Adding a car`
  String get addition_cars {
    return Intl.message(
      'Adding a car',
      name: 'addition_cars',
      desc: '',
      args: [],
    );
  }

  /// `Add a car`
  String get add_cars {
    return Intl.message('Add a car', name: 'add_cars', desc: '', args: []);
  }

  /// `Car number`
  String get car_number {
    return Intl.message('Car number', name: 'car_number', desc: '', args: []);
  }

  /// `Technical passport number`
  String get reg_number {
    return Intl.message(
      'Technical passport number',
      name: 'reg_number',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `Checking the fine`
  String get check_fine_title {
    return Intl.message(
      'Checking the fine',
      name: 'check_fine_title',
      desc: '',
      args: [],
    );
  }

  /// `Check fines`
  String get check_fines {
    return Intl.message('Check fines', name: 'check_fines', desc: '', args: []);
  }

  /// `Checking fines`
  String get checking_fines {
    return Intl.message(
      'Checking fines',
      name: 'checking_fines',
      desc: '',
      args: [],
    );
  }

  /// `There are no fines for you`
  String get no_fines {
    return Intl.message(
      'There are no fines for you',
      name: 'no_fines',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Push notifications`
  String get push_notifications {
    return Intl.message(
      'Push notifications',
      name: 'push_notifications',
      desc: '',
      args: [],
    );
  }

  /// `Pay`
  String get pay {
    return Intl.message('Pay', name: 'pay', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'uk'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
