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

  /// `Verification history`
  String get verification_history {
    return Intl.message(
      'Verification history',
      name: 'verification_history',
      desc: '',
      args: [],
    );
  }

  /// `Registration`
  String get registration {
    return Intl.message(
      'Registration',
      name: 'registration',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Registration successful`
  String get successfully_registration {
    return Intl.message(
      'Registration successful',
      name: 'successfully_registration',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get register {
    return Intl.message('Register', name: 'register', desc: '', args: []);
  }

  /// `Subscription successfully completed`
  String get successfully_subscription {
    return Intl.message(
      'Subscription successfully completed',
      name: 'successfully_subscription',
      desc: '',
      args: [],
    );
  }

  /// `Buy subscription`
  String get buy_subscription {
    return Intl.message(
      'Buy subscription',
      name: 'buy_subscription',
      desc: '',
      args: [],
    );
  }

  /// `Maintenance`
  String get maintenance {
    return Intl.message('Maintenance', name: 'maintenance', desc: '', args: []);
  }

  /// `Analytics`
  String get analitics {
    return Intl.message('Analytics', name: 'analitics', desc: '', args: []);
  }

  /// `Export`
  String get export {
    return Intl.message('Export', name: 'export', desc: '', args: []);
  }

  /// `Statistics`
  String get statistics {
    return Intl.message('Statistics', name: 'statistics', desc: '', args: []);
  }

  /// `History`
  String get history {
    return Intl.message('History', name: 'history', desc: '', args: []);
  }

  /// `Schedule`
  String get schedule {
    return Intl.message('Schedule', name: 'schedule', desc: '', args: []);
  }

  /// `Export history`
  String get export_history {
    return Intl.message(
      'Export history',
      name: 'export_history',
      desc: '',
      args: [],
    );
  }

  /// `PDF`
  String get pdf {
    return Intl.message('PDF', name: 'pdf', desc: '', args: []);
  }

  /// `CSV`
  String get csv {
    return Intl.message('CSV', name: 'csv', desc: '', args: []);
  }

  /// `LOGO`
  String get logo {
    return Intl.message('LOGO', name: 'logo', desc: '', args: []);
  }

  /// `You are here`
  String get my_position {
    return Intl.message(
      'You are here',
      name: 'my_position',
      desc: '',
      args: [],
    );
  }

  /// `Gas stations nearby`
  String get gas_station_nearby {
    return Intl.message(
      'Gas stations nearby',
      name: 'gas_station_nearby',
      desc: '',
      args: [],
    );
  }

  /// `Fill in date, mileage and fuel amount`
  String get fill_date {
    return Intl.message(
      'Fill in date, mileage and fuel amount',
      name: 'fill_date',
      desc: '',
      args: [],
    );
  }

  /// `Filling up`
  String get fuel_up {
    return Intl.message('Filling up', name: 'fuel_up', desc: '', args: []);
  }

  /// `Fuel`
  String get fuel {
    return Intl.message('Fuel', name: 'fuel', desc: '', args: []);
  }

  /// `Total fines: `
  String get total_fines {
    return Intl.message(
      'Total fines: ',
      name: 'total_fines',
      desc: '',
      args: [],
    );
  }

  /// `Technical data sheet:`
  String get technical_data {
    return Intl.message(
      'Technical data sheet:',
      name: 'technical_data',
      desc: '',
      args: [],
    );
  }

  /// `Fines:`
  String get fines_length {
    return Intl.message('Fines:', name: 'fines_length', desc: '', args: []);
  }

  /// `Verification date:`
  String get verif_date {
    return Intl.message(
      'Verification date:',
      name: 'verif_date',
      desc: '',
      args: [],
    );
  }

  /// `Technical maintenance`
  String get tech_service {
    return Intl.message(
      'Technical maintenance',
      name: 'tech_service',
      desc: '',
      args: [],
    );
  }

  /// `Service`
  String get service {
    return Intl.message('Service', name: 'service', desc: '', args: []);
  }

  /// `Calendar`
  String get calendar {
    return Intl.message('Calendar', name: 'calendar', desc: '', args: []);
  }

  /// `Selected service station`
  String get selected_service_station {
    return Intl.message(
      'Selected service station',
      name: 'selected_service_station',
      desc: '',
      args: [],
    );
  }

  /// `Service station nearby`
  String get service_station_nearby {
    return Intl.message(
      'Service station nearby',
      name: 'service_station_nearby',
      desc: '',
      args: [],
    );
  }

  /// `Select a date and at least one service`
  String get select_service {
    return Intl.message(
      'Select a date and at least one service',
      name: 'select_service',
      desc: '',
      args: [],
    );
  }

  /// `Service station`
  String get service_station {
    return Intl.message(
      'Service station',
      name: 'service_station',
      desc: '',
      args: [],
    );
  }

  /// `Service options`
  String get selecting_service {
    return Intl.message(
      'Service options',
      name: 'selecting_service',
      desc: '',
      args: [],
    );
  }

  /// `Cost of work:`
  String get cost_of_work {
    return Intl.message(
      'Cost of work:',
      name: 'cost_of_work',
      desc: '',
      args: [],
    );
  }

  /// `Total amount:`
  String get total_amount {
    return Intl.message(
      'Total amount:',
      name: 'total_amount',
      desc: '',
      args: [],
    );
  }

  /// `Mileage statistics`
  String get mileage_statistics {
    return Intl.message(
      'Mileage statistics',
      name: 'mileage_statistics',
      desc: '',
      args: [],
    );
  }

  /// `average/year`
  String get period {
    return Intl.message('average/year', name: 'period', desc: '', args: []);
  }

  /// `Month`
  String get month {
    return Intl.message('Month', name: 'month', desc: '', args: []);
  }

  /// `Average`
  String get average {
    return Intl.message('Average', name: 'average', desc: '', args: []);
  }

  /// `Resource:`
  String get resource {
    return Intl.message('Resource:', name: 'resource', desc: '', args: []);
  }

  /// `To be performed:`
  String get to_be_performed {
    return Intl.message(
      'To be performed:',
      name: 'to_be_performed',
      desc: '',
      args: [],
    );
  }

  /// `Periodicity:`
  String get periodicity {
    return Intl.message(
      'Periodicity:',
      name: 'periodicity',
      desc: '',
      args: [],
    );
  }

  /// `Configure action`
  String get configure_action {
    return Intl.message(
      'Configure action',
      name: 'configure_action',
      desc: '',
      args: [],
    );
  }

  /// `Add mileage`
  String get add_mileage {
    return Intl.message('Add mileage', name: 'add_mileage', desc: '', args: []);
  }

  /// `Odometer at the beginning of the month`
  String get odometer_beginning {
    return Intl.message(
      'Odometer at the beginning of the month',
      name: 'odometer_beginning',
      desc: '',
      args: [],
    );
  }

  /// `Odometer today`
  String get odometer_today {
    return Intl.message(
      'Odometer today',
      name: 'odometer_today',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Date`
  String get date {
    return Intl.message('Date', name: 'date', desc: '', args: []);
  }

  /// `Select date`
  String get select_date {
    return Intl.message('Select date', name: 'select_date', desc: '', args: []);
  }

  /// `Cost statistics`
  String get cost_statistics {
    return Intl.message(
      'Cost statistics',
      name: 'cost_statistics',
      desc: '',
      args: [],
    );
  }

  /// `Open statistics`
  String get open_statistics {
    return Intl.message(
      'Open statistics',
      name: 'open_statistics',
      desc: '',
      args: [],
    );
  }

  /// `Repair`
  String get repair {
    return Intl.message('Repair', name: 'repair', desc: '', args: []);
  }

  /// `Tuning`
  String get tuning {
    return Intl.message('Tuning', name: 'tuning', desc: '', args: []);
  }

  /// `Other`
  String get other {
    return Intl.message('Other', name: 'other', desc: '', args: []);
  }

  /// `Amount:`
  String get sum {
    return Intl.message('Amount:', name: 'sum', desc: '', args: []);
  }

  /// `Price per 1 liter:`
  String get price_liter {
    return Intl.message(
      'Price per 1 liter:',
      name: 'price_liter',
      desc: '',
      args: [],
    );
  }

  /// `days`
  String get days {
    return Intl.message('days', name: 'days', desc: '', args: []);
  }

  /// `Mileage`
  String get mileage {
    return Intl.message('Mileage', name: 'mileage', desc: '', args: []);
  }

  /// `Enter mileage`
  String get enter_mileage {
    return Intl.message(
      'Enter mileage',
      name: 'enter_mileage',
      desc: '',
      args: [],
    );
  }

  /// `km`
  String get km {
    return Intl.message('km', name: 'km', desc: '', args: []);
  }

  /// `grn`
  String get grn {
    return Intl.message('grn', name: 'grn', desc: '', args: []);
  }

  /// `New reminder`
  String get new_reminder {
    return Intl.message(
      'New reminder',
      name: 'new_reminder',
      desc: '',
      args: [],
    );
  }

  /// `Edit reminder`
  String get edit_reminder {
    return Intl.message(
      'Edit reminder',
      name: 'edit_reminder',
      desc: '',
      args: [],
    );
  }

  /// `Title`
  String get title {
    return Intl.message('Title', name: 'title', desc: '', args: []);
  }

  /// `Description`
  String get description {
    return Intl.message('Description', name: 'description', desc: '', args: []);
  }

  /// `Select a service`
  String get select_a_service {
    return Intl.message(
      'Select a service',
      name: 'select_a_service',
      desc: '',
      args: [],
    );
  }

  /// `Item removed`
  String get item_removed {
    return Intl.message(
      'Item removed',
      name: 'item_removed',
      desc: '',
      args: [],
    );
  }

  /// `History is empty`
  String get history_empty {
    return Intl.message(
      'History is empty',
      name: 'history_empty',
      desc: '',
      args: [],
    );
  }

  /// `Error:`
  String get error {
    return Intl.message('Error:', name: 'error', desc: '', args: []);
  }

  /// `АН0000НА`
  String get hint_auto_num {
    return Intl.message('АН0000НА', name: 'hint_auto_num', desc: '', args: []);
  }

  /// `ХЕE128436`
  String get hint_tech_data_num {
    return Intl.message(
      'ХЕE128436',
      name: 'hint_tech_data_num',
      desc: '',
      args: [],
    );
  }

  /// `AI-98`
  String get fuel_ai98 {
    return Intl.message('AI-98', name: 'fuel_ai98', desc: '', args: []);
  }

  /// `AI-95+`
  String get fuel_ai95_plus {
    return Intl.message('AI-95+', name: 'fuel_ai95_plus', desc: '', args: []);
  }

  /// `AI-95`
  String get fuel_ai95 {
    return Intl.message('AI-95', name: 'fuel_ai95', desc: '', args: []);
  }

  /// `AI-92`
  String get fuel_ai92 {
    return Intl.message('AI-92', name: 'fuel_ai92', desc: '', args: []);
  }

  /// `Gas LPG`
  String get fuel_gas_lpg {
    return Intl.message('Gas LPG', name: 'fuel_gas_lpg', desc: '', args: []);
  }

  /// `Previous maintenance date`
  String get date_previous_maintenance {
    return Intl.message(
      'Previous maintenance date',
      name: 'date_previous_maintenance',
      desc: '',
      args: [],
    );
  }

  /// `Mileage at time of service`
  String get mileage_time_service {
    return Intl.message(
      'Mileage at time of service',
      name: 'mileage_time_service',
      desc: '',
      args: [],
    );
  }

  /// `By date`
  String get by_date {
    return Intl.message('By date', name: 'by_date', desc: '', args: []);
  }

  /// `By mileage`
  String get by_mileage {
    return Intl.message('By mileage', name: 'by_mileage', desc: '', args: []);
  }

  /// `Comment`
  String get comment {
    return Intl.message('Comment', name: 'comment', desc: '', args: []);
  }

  /// `Enter comment`
  String get enter_comment {
    return Intl.message(
      'Enter comment',
      name: 'enter_comment',
      desc: '',
      args: [],
    );
  }

  /// `Car history`
  String get car_history {
    return Intl.message('Car history', name: 'car_history', desc: '', args: []);
  }

  /// `Type`
  String get type {
    return Intl.message('Type', name: 'type', desc: '', args: []);
  }

  /// `Price`
  String get price {
    return Intl.message('Price', name: 'price', desc: '', args: []);
  }

  /// `Add photo`
  String get add_photo {
    return Intl.message('Add photo', name: 'add_photo', desc: '', args: []);
  }

  /// `Photo selected`
  String get photo_selected {
    return Intl.message(
      'Photo selected',
      name: 'photo_selected',
      desc: '',
      args: [],
    );
  }

  /// `Add new photo`
  String get add_new_photo {
    return Intl.message(
      'Add new photo',
      name: 'add_new_photo',
      desc: '',
      args: [],
    );
  }

  /// `Take a picture`
  String get take_a_picture {
    return Intl.message(
      'Take a picture',
      name: 'take_a_picture',
      desc: '',
      args: [],
    );
  }

  /// `Choose from gallery`
  String get choose_from_gallery {
    return Intl.message(
      'Choose from gallery',
      name: 'choose_from_gallery',
      desc: '',
      args: [],
    );
  }

  /// `Error choosing photo:`
  String get error_photo {
    return Intl.message(
      'Error choosing photo:',
      name: 'error_photo',
      desc: '',
      args: [],
    );
  }

  /// `Additional options`
  String get additional_options {
    return Intl.message(
      'Additional options',
      name: 'additional_options',
      desc: '',
      args: [],
    );
  }

  /// `Road accidents`
  String get of_road_accidents {
    return Intl.message(
      'Road accidents',
      name: 'of_road_accidents',
      desc: '',
      args: [],
    );
  }

  /// `Event will be invisible`
  String get event_invisible {
    return Intl.message(
      'Event will be invisible',
      name: 'event_invisible',
      desc: '',
      args: [],
    );
  }

  /// `Publish`
  String get publish {
    return Intl.message('Publish', name: 'publish', desc: '', args: []);
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
