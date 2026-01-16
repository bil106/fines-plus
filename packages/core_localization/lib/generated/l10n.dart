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

  /// `Fuel up`
  String get fuel_up {
    return Intl.message('Fuel up', name: 'fuel_up', desc: '', args: []);
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

  /// `UAH`
  String get grn {
    return Intl.message('UAH', name: 'grn', desc: '', args: []);
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

  /// `Enter liters`
  String get enter_liters {
    return Intl.message(
      'Enter liters',
      name: 'enter_liters',
      desc: '',
      args: [],
    );
  }

  /// `New task`
  String get new_task {
    return Intl.message('New task', name: 'new_task', desc: '', args: []);
  }

  /// `Name`
  String get name {
    return Intl.message('Name', name: 'name', desc: '', args: []);
  }

  /// `Sign in with Google`
  String get sign_in_google {
    return Intl.message(
      'Sign in with Google',
      name: 'sign_in_google',
      desc: '',
      args: [],
    );
  }

  /// `Previous`
  String get previous {
    return Intl.message('Previous', name: 'previous', desc: '', args: []);
  }

  /// `Fact`
  String get fact {
    return Intl.message('Fact', name: 'fact', desc: '', args: []);
  }

  /// `Address not specified`
  String get address_not_specified {
    return Intl.message(
      'Address not specified',
      name: 'address_not_specified',
      desc: '',
      args: [],
    );
  }

  /// `No tasks`
  String get no_tasks {
    return Intl.message('No tasks', name: 'no_tasks', desc: '', args: []);
  }

  /// `No name`
  String get no_name {
    return Intl.message('No name', name: 'no_name', desc: '', args: []);
  }

  /// `Enter the correct car number`
  String get enter_correct_number_auto {
    return Intl.message(
      'Enter the correct car number',
      name: 'enter_correct_number_auto',
      desc: '',
      args: [],
    );
  }

  /// `Enter the correct registration number`
  String get enter_correct_registration_number {
    return Intl.message(
      'Enter the correct registration number',
      name: 'enter_correct_registration_number',
      desc: '',
      args: [],
    );
  }

  /// `Internal combustion engine - diagnostics (inspection, compression measurement)`
  String get service_dvs_diagnostika {
    return Intl.message(
      'Internal combustion engine - diagnostics (inspection, compression measurement)',
      name: 'service_dvs_diagnostika',
      desc: '',
      args: [],
    );
  }

  /// `Internal combustion engine - removal/installation (replacement)`
  String get service_dvs_znyattya_ustanovka {
    return Intl.message(
      'Internal combustion engine - removal/installation (replacement)',
      name: 'service_dvs_znyattya_ustanovka',
      desc: '',
      args: [],
    );
  }

  /// `Internal combustion engine - major overhaul`
  String get service_dvs_capitalnyy_remont {
    return Intl.message(
      'Internal combustion engine - major overhaul',
      name: 'service_dvs_capitalnyy_remont',
      desc: '',
      args: [],
    );
  }

  /// `Valve cover gasket - replacement`
  String get service_prokladka_klapannoyi_krishki {
    return Intl.message(
      'Valve cover gasket - replacement',
      name: 'service_prokladka_klapannoyi_krishki',
      desc: '',
      args: [],
    );
  }

  /// `Cylinder head gasket - replacement`
  String get service_prokladka_gbc {
    return Intl.message(
      'Cylinder head gasket - replacement',
      name: 'service_prokladka_gbc',
      desc: '',
      args: [],
    );
  }

  /// `Crankcase pan gasket - replacement`
  String get service_prokladka_poddonu_kartera {
    return Intl.message(
      'Crankcase pan gasket - replacement',
      name: 'service_prokladka_poddonu_kartera',
      desc: '',
      args: [],
    );
  }

  /// `Drive belt - replacement`
  String get service_remin_pryvodnyy {
    return Intl.message(
      'Drive belt - replacement',
      name: 'service_remin_pryvodnyy',
      desc: '',
      args: [],
    );
  }

  /// `Drive belt roller - replacement`
  String get service_rolik_pryvodnoho_remenya {
    return Intl.message(
      'Drive belt roller - replacement',
      name: 'service_rolik_pryvodnoho_remenya',
      desc: '',
      args: [],
    );
  }

  /// `Timing repair kit - replacement`
  String get service_remkomplekt_grm {
    return Intl.message(
      'Timing repair kit - replacement',
      name: 'service_remkomplekt_grm',
      desc: '',
      args: [],
    );
  }

  /// `Injector - cleaning (excluding special fluids)`
  String get service_inzhektor_chystka {
    return Intl.message(
      'Injector - cleaning (excluding special fluids)',
      name: 'service_inzhektor_chystka',
      desc: '',
      args: [],
    );
  }

  /// `Replacement of engine oil`
  String get service_zamina_oil_dvs {
    return Intl.message(
      'Replacement of engine oil',
      name: 'service_zamina_oil_dvs',
      desc: '',
      args: [],
    );
  }

  /// `Replacement of engine air filter`
  String get service_zamina_povitryanogo_filtra_dvs {
    return Intl.message(
      'Replacement of engine air filter',
      name: 'service_zamina_povitryanogo_filtra_dvs',
      desc: '',
      args: [],
    );
  }

  /// `Replacement of cabin filter`
  String get service_zamina_salonnoho_filtra {
    return Intl.message(
      'Replacement of cabin filter',
      name: 'service_zamina_salonnoho_filtra',
      desc: '',
      args: [],
    );
  }

  /// `Cleaning of throttle valve`
  String get service_chystka_droselnoyi_zaslinky {
    return Intl.message(
      'Cleaning of throttle valve',
      name: 'service_chystka_droselnoyi_zaslinky',
      desc: '',
      args: [],
    );
  }

  /// `Computer diagnostics`
  String get service_kompyuterna_diagnostyka {
    return Intl.message(
      'Computer diagnostics',
      name: 'service_kompyuterna_diagnostyka',
      desc: '',
      args: [],
    );
  }

  /// `Repair of electrical wiring and electrical equipment`
  String get service_remont_elektroprovodky {
    return Intl.message(
      'Repair of electrical wiring and electrical equipment',
      name: 'service_remont_elektroprovodky',
      desc: '',
      args: [],
    );
  }

  /// `Repair of generators`
  String get service_remont_generatoriv {
    return Intl.message(
      'Repair of generators',
      name: 'service_remont_generatoriv',
      desc: '',
      args: [],
    );
  }

  /// `Repair of starters`
  String get service_remont_starteriv {
    return Intl.message(
      'Repair of starters',
      name: 'service_remont_starteriv',
      desc: '',
      args: [],
    );
  }

  /// `Replacement of oxygen sensor (lambda probe)`
  String get service_zamina_kisnevogo_datchyka {
    return Intl.message(
      'Replacement of oxygen sensor (lambda probe)',
      name: 'service_zamina_kisnevogo_datchyka',
      desc: '',
      args: [],
    );
  }

  /// `Diagnostics and repair of ECU units engine`
  String get service_diagnostyka_i_remont_ebu {
    return Intl.message(
      'Diagnostics and repair of ECU units engine',
      name: 'service_diagnostyka_i_remont_ebu',
      desc: '',
      args: [],
    );
  }

  /// `Replacement of fog lamp bulbs`
  String get service_zamina_lamp_protifumannykh_far {
    return Intl.message(
      'Replacement of fog lamp bulbs',
      name: 'service_zamina_lamp_protifumannykh_far',
      desc: '',
      args: [],
    );
  }

  /// `Installation of xenon`
  String get service_vstanovlennya_ksenonu {
    return Intl.message(
      'Installation of xenon',
      name: 'service_vstanovlennya_ksenonu',
      desc: '',
      args: [],
    );
  }

  /// `Comprehensive diagnostics (excluding computer diagnostics)`
  String get service_kompleksna_diagnostyka {
    return Intl.message(
      'Comprehensive diagnostics (excluding computer diagnostics)',
      name: 'service_kompleksna_diagnostyka',
      desc: '',
      args: [],
    );
  }

  /// `Comprehensive diagnostics`
  String get service_kompleksna_diagnostyka_full {
    return Intl.message(
      'Comprehensive diagnostics',
      name: 'service_kompleksna_diagnostyka_full',
      desc: '',
      args: [],
    );
  }

  /// `Air conditioning system - diagnostics and refueling`
  String get service_systema_kondytsionuvannya {
    return Intl.message(
      'Air conditioning system - diagnostics and refueling',
      name: 'service_systema_kondytsionuvannya',
      desc: '',
      args: [],
    );
  }

  /// `Fuel system - diagnostics (pressure measurement)`
  String get service_palivna_systema_diagnostyka {
    return Intl.message(
      'Fuel system - diagnostics (pressure measurement)',
      name: 'service_palivna_systema_diagnostyka',
      desc: '',
      args: [],
    );
  }

  /// `Suspension diagnostics`
  String get service_diagnostyka_pidvisky {
    return Intl.message(
      'Suspension diagnostics',
      name: 'service_diagnostyka_pidvisky',
      desc: '',
      args: [],
    );
  }

  /// `Repair of suspension arms`
  String get service_remont_vazheliv_pidvisky {
    return Intl.message(
      'Repair of suspension arms',
      name: 'service_remont_vazheliv_pidvisky',
      desc: '',
      args: [],
    );
  }

  /// `Replacement of shock absorbers`
  String get service_zamina_amortyzatoriv {
    return Intl.message(
      'Replacement of shock absorbers',
      name: 'service_zamina_amortyzatoriv',
      desc: '',
      args: [],
    );
  }

  /// `Replacement of front shock absorbers`
  String get service_zamina_perednikh_amortyzatoriv {
    return Intl.message(
      'Replacement of front shock absorbers',
      name: 'service_zamina_perednikh_amortyzatoriv',
      desc: '',
      args: [],
    );
  }

  /// `Replacement of rear shock absorbers`
  String get service_zamina_zadnikh_amortyzatoriv {
    return Intl.message(
      'Replacement of rear shock absorbers',
      name: 'service_zamina_zadnikh_amortyzatoriv',
      desc: '',
      args: [],
    );
  }

  /// `Replacement of shock absorber bumper`
  String get service_zamina_vidbijnyka_amortyzatora {
    return Intl.message(
      'Replacement of shock absorber bumper',
      name: 'service_zamina_vidbijnyka_amortyzatora',
      desc: '',
      args: [],
    );
  }

  /// `Replacement of shock absorber support bearing`
  String get service_zamina_opornoho_pidshipnyka_amortyzatora {
    return Intl.message(
      'Replacement of shock absorber support bearing',
      name: 'service_zamina_opornoho_pidshipnyka_amortyzatora',
      desc: '',
      args: [],
    );
  }

  /// `Replacement of shock absorber springs`
  String get service_zamina_pruzhin_amortyzatoriv {
    return Intl.message(
      'Replacement of shock absorber springs',
      name: 'service_zamina_pruzhin_amortyzatoriv',
      desc: '',
      args: [],
    );
  }

  /// `Replacement of rear shock absorber boot`
  String get service_zamina_pylnyka_zadnogo_amortyzatora {
    return Intl.message(
      'Replacement of rear shock absorber boot',
      name: 'service_zamina_pylnyka_zadnogo_amortyzatora',
      desc: '',
      args: [],
    );
  }

  /// `Repair of air suspension`
  String get service_remont_pnevmopidvisky {
    return Intl.message(
      'Repair of air suspension',
      name: 'service_remont_pnevmopidvisky',
      desc: '',
      args: [],
    );
  }

  /// `Replacement of stabilizer struts`
  String get service_zamina_stiikiv_stabilizatora {
    return Intl.message(
      'Replacement of stabilizer struts',
      name: 'service_zamina_stiikiv_stabilizatora',
      desc: '',
      args: [],
    );
  }

  /// `Replacement of stabilizer bushings`
  String get service_zamina_vtulok_stabilizatora {
    return Intl.message(
      'Replacement of stabilizer bushings',
      name: 'service_zamina_vtulok_stabilizatora',
      desc: '',
      args: [],
    );
  }

  /// `Replacement of ball support`
  String get service_zamina_kulovykh_opor {
    return Intl.message(
      'Replacement of ball support',
      name: 'service_zamina_kulovykh_opor',
      desc: '',
      args: [],
    );
  }

  /// `Replacement of support bearings`
  String get service_zamina_pidshipnykiv_matochok {
    return Intl.message(
      'Replacement of support bearings',
      name: 'service_zamina_pidshipnykiv_matochok',
      desc: '',
      args: [],
    );
  }

  /// `Replacement of suspension silent blocks`
  String get service_zamina_silentblokiv_pidvisky {
    return Intl.message(
      'Replacement of suspension silent blocks',
      name: 'service_zamina_silentblokiv_pidvisky',
      desc: '',
      args: [],
    );
  }

  /// `Disassembly`
  String get service_skhid_rozval {
    return Intl.message(
      'Disassembly',
      name: 'service_skhid_rozval',
      desc: '',
      args: [],
    );
  }

  /// `Chassis - diagnostics`
  String get service_khodova_chastyna_diagnostyka {
    return Intl.message(
      'Chassis - diagnostics',
      name: 'service_khodova_chastyna_diagnostyka',
      desc: '',
      args: [],
    );
  }

  /// `Stabilizer struts - replacement`
  String get service_stiikyi_stabilizatora_zamina {
    return Intl.message(
      'Stabilizer struts - replacement',
      name: 'service_stiikyi_stabilizatora_zamina',
      desc: '',
      args: [],
    );
  }

  /// `Stabilizer bushings - replacement`
  String get service_vtulky_stabilizatora_zamina {
    return Intl.message(
      'Stabilizer bushings - replacement',
      name: 'service_vtulky_stabilizatora_zamina',
      desc: '',
      args: [],
    );
  }

  /// `Ball bearing - replacement`
  String get service_sharova_opora_zamina {
    return Intl.message(
      'Ball bearing - replacement',
      name: 'service_sharova_opora_zamina',
      desc: '',
      args: [],
    );
  }

  /// `Steering tie rod end - replacement`
  String get service_nakonechnik_rulovoyi_tyahy_zamina {
    return Intl.message(
      'Steering tie rod end - replacement',
      name: 'service_nakonechnik_rulovoyi_tyahy_zamina',
      desc: '',
      args: [],
    );
  }

  /// `Steering tie rod - replacement`
  String get service_rulova_tyaha_zamina {
    return Intl.message(
      'Steering tie rod - replacement',
      name: 'service_rulova_tyaha_zamina',
      desc: '',
      args: [],
    );
  }

  /// `Shock absorbers suspension (front axle) - replacement`
  String get service_amortyzatory_perednia_os_zamina {
    return Intl.message(
      'Shock absorbers suspension (front axle) - replacement',
      name: 'service_amortyzatory_perednia_os_zamina',
      desc: '',
      args: [],
    );
  }

  /// `Suspension shock absorbers (rear axle) - replacement`
  String get service_amortyzatory_zadnia_os_zamina {
    return Intl.message(
      'Suspension shock absorbers (rear axle) - replacement',
      name: 'service_amortyzatory_zadnia_os_zamina',
      desc: '',
      args: [],
    );
  }

  /// `Wheel hub - replacement`
  String get service_stupytsia_kolesa_zamina {
    return Intl.message(
      'Wheel hub - replacement',
      name: 'service_stupytsia_kolesa_zamina',
      desc: '',
      args: [],
    );
  }

  /// `Wheel hub bearing - replacement`
  String get service_pidshipnyk_matochyny_kolesa_zamina {
    return Intl.message(
      'Wheel hub bearing - replacement',
      name: 'service_pidshipnyk_matochyny_kolesa_zamina',
      desc: '',
      args: [],
    );
  }

  /// `Steering rack - repair`
  String get service_rulova_reyka_remont {
    return Intl.message(
      'Steering rack - repair',
      name: 'service_rulova_reyka_remont',
      desc: '',
      args: [],
    );
  }

  /// `Suspension lever - replacement`
  String get service_vazhel_pidvisky_zamina {
    return Intl.message(
      'Suspension lever - replacement',
      name: 'service_vazhel_pidvisky_zamina',
      desc: '',
      args: [],
    );
  }

  /// `Suspension lever silent block - replacement (with lever removed)`
  String get service_silentblok_vazhelya_pidvisky_zamina {
    return Intl.message(
      'Suspension lever silent block - replacement (with lever removed)',
      name: 'service_silentblok_vazhelya_pidvisky_zamina',
      desc: '',
      args: [],
    );
  }

  /// `CV joint boot (external) - replacement`
  String get service_pylovik_shrus_zovnishniy_zamina {
    return Intl.message(
      'CV joint boot (external) - replacement',
      name: 'service_pylovik_shrus_zovnishniy_zamina',
      desc: '',
      args: [],
    );
  }

  /// `CV joint boot (internal) - replacement`
  String get service_pylovik_shrus_vnutrishniy_zamina {
    return Intl.message(
      'CV joint boot (internal) - replacement',
      name: 'service_pylovik_shrus_vnutrishniy_zamina',
      desc: '',
      args: [],
    );
  }

  /// `CV joint drive shaft - replacement`
  String get service_shrus_pryvodnoho_valu_zamina {
    return Intl.message(
      'CV joint drive shaft - replacement',
      name: 'service_shrus_pryvodnoho_valu_zamina',
      desc: '',
      args: [],
    );
  }

  /// `Drive shaft - replacement`
  String get service_pryvodnyy_val_zamina {
    return Intl.message(
      'Drive shaft - replacement',
      name: 'service_pryvodnyy_val_zamina',
      desc: '',
      args: [],
    );
  }

  /// `Body polishing`
  String get service_polirovka_kuzova {
    return Intl.message(
      'Body polishing',
      name: 'service_polirovka_kuzova',
      desc: '',
      args: [],
    );
  }

  /// `Headlight polishing`
  String get service_polirovka_far {
    return Intl.message(
      'Headlight polishing',
      name: 'service_polirovka_far',
      desc: '',
      args: [],
    );
  }

  /// `Pre-sale dry cleaning of the interior`
  String get service_predprodazhna_khimchystka_salonu {
    return Intl.message(
      'Pre-sale dry cleaning of the interior',
      name: 'service_predprodazhna_khimchystka_salonu',
      desc: '',
      args: [],
    );
  }

  /// `Resale body polishing`
  String get service_pereprodazhne_polirovannya_kuzova {
    return Intl.message(
      'Resale body polishing',
      name: 'service_pereprodazhne_polirovannya_kuzova',
      desc: '',
      args: [],
    );
  }

  /// `Car seat cleaning`
  String get service_chystka_siden_avto {
    return Intl.message(
      'Car seat cleaning',
      name: 'service_chystka_siden_avto',
      desc: '',
      args: [],
    );
  }

  /// `Dry cleaning of the interior`
  String get service_khimchystka_salonu {
    return Intl.message(
      'Dry cleaning of the interior',
      name: 'service_khimchystka_salonu',
      desc: '',
      args: [],
    );
  }

  /// `Ceramic coating`
  String get service_pokryttya_keramikoyu {
    return Intl.message(
      'Ceramic coating',
      name: 'service_pokryttya_keramikoyu',
      desc: '',
      args: [],
    );
  }

  /// `Removal of small scratches`
  String get service_vidalennya_dribnykh_podryapin {
    return Intl.message(
      'Removal of small scratches',
      name: 'service_vidalennya_dribnykh_podryapin',
      desc: '',
      args: [],
    );
  }

  /// `Replacement of brake pads`
  String get service_zamina_halmyvnykh_kolodok {
    return Intl.message(
      'Replacement of brake pads',
      name: 'service_zamina_halmyvnykh_kolodok',
      desc: '',
      args: [],
    );
  }

  /// `Replacement of brake discs`
  String get service_zamina_halmyvnykh_dyskiv {
    return Intl.message(
      'Replacement of brake discs',
      name: 'service_zamina_halmyvnykh_dyskiv',
      desc: '',
      args: [],
    );
  }

  /// `Replacement of brake fluid`
  String get service_zamina_halmyvnoyi_ridyny {
    return Intl.message(
      'Replacement of brake fluid',
      name: 'service_zamina_halmyvnoyi_ridyny',
      desc: '',
      args: [],
    );
  }

  /// `Replacement of brake hoses`
  String get service_zamina_halmykh_shlang {
    return Intl.message(
      'Replacement of brake hoses',
      name: 'service_zamina_halmykh_shlang',
      desc: '',
      args: [],
    );
  }

  /// `Repair of brake supors mouths`
  String get service_remont_suporiv {
    return Intl.message(
      'Repair of brake supors mouths',
      name: 'service_remont_suporiv',
      desc: '',
      args: [],
    );
  }

  /// `Brake mechanism prevention`
  String get service_profilaktyka_halmyvnykh_mekhanizmiv {
    return Intl.message(
      'Brake mechanism prevention',
      name: 'service_profilaktyka_halmyvnykh_mekhanizmiv',
      desc: '',
      args: [],
    );
  }

  /// `Steering rack repair`
  String get service_remont_rulovykh_reyok {
    return Intl.message(
      'Steering rack repair',
      name: 'service_remont_rulovykh_reyok',
      desc: '',
      args: [],
    );
  }

  /// `Replacement of tie rod ends`
  String get service_zamina_nakonechnikiv_rulovykh_tyag {
    return Intl.message(
      'Replacement of tie rod ends',
      name: 'service_zamina_nakonechnikiv_rulovykh_tyag',
      desc: '',
      args: [],
    );
  }

  /// `Replacement of tie rod ends`
  String get service_zamina_rulovykh_tyag {
    return Intl.message(
      'Replacement of tie rod ends',
      name: 'service_zamina_rulovykh_tyag',
      desc: '',
      args: [],
    );
  }

  /// `Replacement of steering shaft cross`
  String get service_zamina_krestovyny_rulovogo_valu {
    return Intl.message(
      'Replacement of steering shaft cross',
      name: 'service_zamina_krestovyny_rulovogo_valu',
      desc: '',
      args: [],
    );
  }

  /// `Diagnostics and repair of internal combustion engines`
  String get service_diagnostyka_remont_dvs {
    return Intl.message(
      'Diagnostics and repair of internal combustion engines',
      name: 'service_diagnostyka_remont_dvs',
      desc: '',
      args: [],
    );
  }

  /// `Replacement of valve cover gasket`
  String get service_zamina_prokladky_klapannoyi_krishky {
    return Intl.message(
      'Replacement of valve cover gasket',
      name: 'service_zamina_prokladky_klapannoyi_krishky',
      desc: '',
      args: [],
    );
  }

  /// `Replacement of cylinder head gasket`
  String get service_zamina_prokladky_gbc {
    return Intl.message(
      'Replacement of cylinder head gasket',
      name: 'service_zamina_prokladky_gbc',
      desc: '',
      args: [],
    );
  }

  /// `Replacement of crankcase pan gasket`
  String get service_zamina_prokladky_poddonu_kartera {
    return Intl.message(
      'Replacement of crankcase pan gasket',
      name: 'service_zamina_prokladky_poddonu_kartera',
      desc: '',
      args: [],
    );
  }

  /// `Crankshaft oil seal replacement`
  String get service_zamina_salnyka_kolenvala {
    return Intl.message(
      'Crankshaft oil seal replacement',
      name: 'service_zamina_salnyka_kolenvala',
      desc: '',
      args: [],
    );
  }

  /// `Professional timing repair`
  String get service_profesijnyy_remont_grm {
    return Intl.message(
      'Professional timing repair',
      name: 'service_profesijnyy_remont_grm',
      desc: '',
      args: [],
    );
  }

  /// `Changing oil in variators`
  String get service_zamina_oil_variator {
    return Intl.message(
      'Changing oil in variators',
      name: 'service_zamina_oil_variator',
      desc: '',
      args: [],
    );
  }

  /// `Replacing the camshaft oil seal`
  String get service_zamina_salnyka_rozpodilnogo_valu {
    return Intl.message(
      'Replacing the camshaft oil seal',
      name: 'service_zamina_salnyka_rozpodilnogo_valu',
      desc: '',
      args: [],
    );
  }

  /// `Repair of turbocompressors`
  String get service_remont_turbokompressoriv {
    return Intl.message(
      'Repair of turbocompressors',
      name: 'service_remont_turbokompressoriv',
      desc: '',
      args: [],
    );
  }

  /// `Replacing the timing belt`
  String get service_zamina_remenya_grm {
    return Intl.message(
      'Replacing the timing belt',
      name: 'service_zamina_remenya_grm',
      desc: '',
      args: [],
    );
  }

  /// `Replacing drive belts`
  String get service_zamina_pryvodnykh_remeniv {
    return Intl.message(
      'Replacing drive belts',
      name: 'service_zamina_pryvodnykh_remeniv',
      desc: '',
      args: [],
    );
  }

  /// `Replacing the drive belt tensioner roller`
  String get service_zamina_rolika_natyaguvacha_remenya {
    return Intl.message(
      'Replacing the drive belt tensioner roller',
      name: 'service_zamina_rolika_natyaguvacha_remenya',
      desc: '',
      args: [],
    );
  }

  /// `Replacing the engine`
  String get service_zamina_dvyhuna {
    return Intl.message(
      'Replacing the engine',
      name: 'service_zamina_dvyhuna',
      desc: '',
      args: [],
    );
  }

  /// `Overhaul of the engine`
  String get service_capitalnyy_remont_dvyhuna {
    return Intl.message(
      'Overhaul of the engine',
      name: 'service_capitalnyy_remont_dvyhuna',
      desc: '',
      args: [],
    );
  }

  /// `Engine cylinder head repair`
  String get service_remont_holovky_bloku_cylindriv_dvyhuna {
    return Intl.message(
      'Engine cylinder head repair',
      name: 'service_remont_holovky_bloku_cylindriv_dvyhuna',
      desc: '',
      args: [],
    );
  }

  /// `Engine valve repair`
  String get service_remont_klapiv_dvyhuna {
    return Intl.message(
      'Engine valve repair',
      name: 'service_remont_klapiv_dvyhuna',
      desc: '',
      args: [],
    );
  }

  /// `Oil pump repair`
  String get service_remont_maslyanogo_nasosa {
    return Intl.message(
      'Oil pump repair',
      name: 'service_remont_maslyanogo_nasosa',
      desc: '',
      args: [],
    );
  }

  /// `Engine flywheel repair (replacement)`
  String get service_remont_zaminy_mahovyka_dvyhuna {
    return Intl.message(
      'Engine flywheel repair (replacement)',
      name: 'service_remont_zaminy_mahovyka_dvyhuna',
      desc: '',
      args: [],
    );
  }

  /// `Engine mount repair (replacement)`
  String get service_remont_zaminy_opor_dvyhuna {
    return Intl.message(
      'Engine mount repair (replacement)',
      name: 'service_remont_zaminy_opor_dvyhuna',
      desc: '',
      args: [],
    );
  }

  /// `Engine piston repair`
  String get service_remont_porshniv_dvyhuna {
    return Intl.message(
      'Engine piston repair',
      name: 'service_remont_porshniv_dvyhuna',
      desc: '',
      args: [],
    );
  }

  /// `Radiator repair`
  String get service_remont_radiatoriv {
    return Intl.message(
      'Radiator repair',
      name: 'service_remont_radiatoriv',
      desc: '',
      args: [],
    );
  }

  /// `Spark plug replacement`
  String get service_zamina_svichok_zapal {
    return Intl.message(
      'Spark plug replacement',
      name: 'service_zamina_svichok_zapal',
      desc: '',
      args: [],
    );
  }

  /// `Car ignition coil/module replacement`
  String get service_zamina_kotushok_modulya_zapal {
    return Intl.message(
      'Car ignition coil/module replacement',
      name: 'service_zamina_kotushok_modulya_zapal',
      desc: '',
      args: [],
    );
  }

  /// `Replacement high-voltage wires`
  String get service_zamina_vysokovolt_provodiv {
    return Intl.message(
      'Replacement high-voltage wires',
      name: 'service_zamina_vysokovolt_provodiv',
      desc: '',
      args: [],
    );
  }

  /// `Battery replacement`
  String get service_zamina_akumulyatora {
    return Intl.message(
      'Battery replacement',
      name: 'service_zamina_akumulyatora',
      desc: '',
      args: [],
    );
  }

  /// `Antifreeze replacement`
  String get service_zamina_antifryzu {
    return Intl.message(
      'Antifreeze replacement',
      name: 'service_zamina_antifryzu',
      desc: '',
      args: [],
    );
  }

  /// `Thermostat replacement`
  String get service_zamina_termostata {
    return Intl.message(
      'Thermostat replacement',
      name: 'service_zamina_termostata',
      desc: '',
      args: [],
    );
  }

  /// `Pump replacement`
  String get service_zamina_pompy {
    return Intl.message(
      'Pump replacement',
      name: 'service_zamina_pompy',
      desc: '',
      args: [],
    );
  }

  /// `Radiator replacement`
  String get service_zamina_radiatora {
    return Intl.message(
      'Radiator replacement',
      name: 'service_zamina_radiatora',
      desc: '',
      args: [],
    );
  }

  /// `Cleaning of cooling and air conditioning radiators`
  String get service_chystka_radiatoriv {
    return Intl.message(
      'Cleaning of cooling and air conditioning radiators',
      name: 'service_chystka_radiatoriv',
      desc: '',
      args: [],
    );
  }

  /// `Injector cleaning`
  String get service_chystka_forsunok {
    return Intl.message(
      'Injector cleaning',
      name: 'service_chystka_forsunok',
      desc: '',
      args: [],
    );
  }

  /// `Fuel system flushing`
  String get service_promyvka_palivnoyi_systemy {
    return Intl.message(
      'Fuel system flushing',
      name: 'service_promyvka_palivnoyi_systemy',
      desc: '',
      args: [],
    );
  }

  /// `Fuel filter replacement`
  String get service_zamina_palivnogo_filtra {
    return Intl.message(
      'Fuel filter replacement',
      name: 'service_zamina_palivnogo_filtra',
      desc: '',
      args: [],
    );
  }

  /// `Fuel pump replacement`
  String get service_zamina_benzonasosa {
    return Intl.message(
      'Fuel pump replacement',
      name: 'service_zamina_benzonasosa',
      desc: '',
      args: [],
    );
  }

  /// `Injector flushing`
  String get service_promyvka_inzhektora {
    return Intl.message(
      'Injector flushing',
      name: 'service_promyvka_inzhektora',
      desc: '',
      args: [],
    );
  }

  /// `Gearbox - replacement`
  String get service_kpp_zamina {
    return Intl.message(
      'Gearbox - replacement',
      name: 'service_kpp_zamina',
      desc: '',
      args: [],
    );
  }

  /// `Gearbox - repair`
  String get service_kpp_remont {
    return Intl.message(
      'Gearbox - repair',
      name: 'service_kpp_remont',
      desc: '',
      args: [],
    );
  }

  /// `Automatic transmission oil - partial replacement (drain/fill), including automatic transmission filter replacement`
  String get service_oliya_akpp_chastkova {
    return Intl.message(
      'Automatic transmission oil - partial replacement (drain/fill), including automatic transmission filter replacement',
      name: 'service_oliya_akpp_chastkova',
      desc: '',
      args: [],
    );
  }

  /// `Automatic transmission oil - complete replacement (hardware) without automatic transmission filter replacement`
  String get service_oliya_akpp_zamna_povna_bez_filtra {
    return Intl.message(
      'Automatic transmission oil - complete replacement (hardware) without automatic transmission filter replacement',
      name: 'service_oliya_akpp_zamna_povna_bez_filtra',
      desc: '',
      args: [],
    );
  }

  /// `Automatic transmission oil - complete replacement (hardware), including automatic transmission filter replacement`
  String get service_oliya_akpp_zamna_povna_z_filtra {
    return Intl.message(
      'Automatic transmission oil - complete replacement (hardware), including automatic transmission filter replacement',
      name: 'service_oliya_akpp_zamna_povna_z_filtra',
      desc: '',
      args: [],
    );
  }

  /// `Manual transmission oil - replacement`
  String get service_oliya_mkpp_zamina {
    return Intl.message(
      'Manual transmission oil - replacement',
      name: 'service_oliya_mkpp_zamina',
      desc: '',
      args: [],
    );
  }

  /// `Transmission oil (axle/gearbox/transfer case) - replacement`
  String get service_maslo_transmisiine_zamina {
    return Intl.message(
      'Transmission oil (axle/gearbox/transfer case) - replacement',
      name: 'service_maslo_transmisiine_zamina',
      desc: '',
      args: [],
    );
  }

  /// `Clutch (set) - replacement`
  String get service_zcheplennya_zmina {
    return Intl.message(
      'Clutch (set) - replacement',
      name: 'service_zcheplennya_zmina',
      desc: '',
      args: [],
    );
  }

  /// `Clutch master cylinder - replacement`
  String get service_golovnyy_cylyndr_zcheplennya_zamina {
    return Intl.message(
      'Clutch master cylinder - replacement',
      name: 'service_golovnyy_cylyndr_zcheplennya_zamina',
      desc: '',
      args: [],
    );
  }

  /// `Clutch slave cylinder - replacement`
  String get service_robochyy_cylyndr_zcheplennya_zamina {
    return Intl.message(
      'Clutch slave cylinder - replacement',
      name: 'service_robochyy_cylyndr_zcheplennya_zamina',
      desc: '',
      args: [],
    );
  }

  /// `Cardan shaft cross - replacement`
  String get service_krestovyna_kard_valu_zamina {
    return Intl.message(
      'Cardan shaft cross - replacement',
      name: 'service_krestovyna_kard_valu_zamina',
      desc: '',
      args: [],
    );
  }

  /// `Cardan shaft - replacement`
  String get service_kardannyy_val_zamina {
    return Intl.message(
      'Cardan shaft - replacement',
      name: 'service_kardannyy_val_zamina',
      desc: '',
      args: [],
    );
  }

  /// `Clutch diagnostics and replacement`
  String get service_diagnostyka_zamina_zcheplennya {
    return Intl.message(
      'Clutch diagnostics and replacement',
      name: 'service_diagnostyka_zamina_zcheplennya',
      desc: '',
      args: [],
    );
  }

  /// `Clutch actuator repair / replacement`
  String get service_remont_zamina_aktuatora_zcheplennya {
    return Intl.message(
      'Clutch actuator repair / replacement',
      name: 'service_remont_zamina_aktuatora_zcheplennya',
      desc: '',
      args: [],
    );
  }

  /// `Clutch disc replacement`
  String get service_zamina_dyska_zcheplennya {
    return Intl.message(
      'Clutch disc replacement',
      name: 'service_zamina_dyska_zcheplennya',
      desc: '',
      args: [],
    );
  }

  /// `Clutch master cylinder replacement`
  String get service_zamina_golovnogo_cylyndra_zcheplennya {
    return Intl.message(
      'Clutch master cylinder replacement',
      name: 'service_zamina_golovnogo_cylyndra_zcheplennya',
      desc: '',
      args: [],
    );
  }

  /// `Automatic transmission clutch replacement`
  String get service_zamina_zcheplennya_akpp {
    return Intl.message(
      'Automatic transmission clutch replacement',
      name: 'service_zamina_zcheplennya_akpp',
      desc: '',
      args: [],
    );
  }

  /// `Clutch cable replacement`
  String get service_zamina_trosa_zcheplennya {
    return Intl.message(
      'Clutch cable replacement',
      name: 'service_zamina_trosa_zcheplennya',
      desc: '',
      args: [],
    );
  }

  /// `Clutch fork replacement`
  String get service_zamina_vilky_zcheplennya {
    return Intl.message(
      'Clutch fork replacement',
      name: 'service_zamina_vilky_zcheplennya',
      desc: '',
      args: [],
    );
  }

  /// `Clutch fluid replacement`
  String get service_zamina_ridyny_zcheplennya {
    return Intl.message(
      'Clutch fluid replacement',
      name: 'service_zamina_ridyny_zcheplennya',
      desc: '',
      args: [],
    );
  }

  /// `Drive shaft replacement`
  String get service_zamina_pryvodnykh_valiv {
    return Intl.message(
      'Drive shaft replacement',
      name: 'service_zamina_pryvodnykh_valiv',
      desc: '',
      args: [],
    );
  }

  /// `ShRUS replacement`
  String get service_zamina_shrus {
    return Intl.message(
      'ShRUS replacement',
      name: 'service_zamina_shrus',
      desc: '',
      args: [],
    );
  }

  /// `Cardan shaft replacement`
  String get service_zamina_kard_valu {
    return Intl.message(
      'Cardan shaft replacement',
      name: 'service_zamina_kard_valu',
      desc: '',
      args: [],
    );
  }

  /// `Cardan shaft crosspiece replacement`
  String get service_zamina_krestovyny_kard_valu {
    return Intl.message(
      'Cardan shaft crosspiece replacement',
      name: 'service_zamina_krestovyny_kard_valu',
      desc: '',
      args: [],
    );
  }

  /// `Transmission fluid replacement (axle/gearbox/transfer case)`
  String get service_zamina_transmisiynykh_ridin {
    return Intl.message(
      'Transmission fluid replacement (axle/gearbox/transfer case)',
      name: 'service_zamina_transmisiynykh_ridin',
      desc: '',
      args: [],
    );
  }

  /// `Exhaust system replacement (assembly)`
  String get service_zamina_vykhlopnoyi_systemy {
    return Intl.message(
      'Exhaust system replacement (assembly)',
      name: 'service_zamina_vykhlopnoyi_systemy',
      desc: '',
      args: [],
    );
  }

  /// `Muffler replacement`
  String get service_zamina_glushnyka {
    return Intl.message(
      'Muffler replacement',
      name: 'service_zamina_glushnyka',
      desc: '',
      args: [],
    );
  }

  /// `Replacing the intake pipe corrugation`
  String get service_zamina_hofry_pryymalnoyi_truby {
    return Intl.message(
      'Replacing the intake pipe corrugation',
      name: 'service_zamina_hofry_pryymalnoyi_truby',
      desc: '',
      args: [],
    );
  }

  /// `Replacing the oxygen sensor (lambda probe)`
  String get service_zamina_kisnevogo_datchyka_lambda {
    return Intl.message(
      'Replacing the oxygen sensor (lambda probe)',
      name: 'service_zamina_kisnevogo_datchyka_lambda',
      desc: '',
      args: [],
    );
  }

  /// `Replacing the catalyst`
  String get service_zamina_katalizatora {
    return Intl.message(
      'Replacing the catalyst',
      name: 'service_zamina_katalizatora',
      desc: '',
      args: [],
    );
  }

  /// `Removing the catalyst`
  String get service_vidalennya_katalizatora {
    return Intl.message(
      'Removing the catalyst',
      name: 'service_vidalennya_katalizatora',
      desc: '',
      args: [],
    );
  }

  /// `Replacing the muffler gasket`
  String get service_zamina_prokladky_glushnyka {
    return Intl.message(
      'Replacing the muffler gasket',
      name: 'service_zamina_prokladky_glushnyka',
      desc: '',
      args: [],
    );
  }

  /// `Replacing the muffler pipe`
  String get service_zamina_truby_glushnyka {
    return Intl.message(
      'Replacing the muffler pipe',
      name: 'service_zamina_truby_glushnyka',
      desc: '',
      args: [],
    );
  }

  /// `Diagnostics and repair of fuel injectors`
  String get service_diagnostyka_remont_palivnykh_forsunok {
    return Intl.message(
      'Diagnostics and repair of fuel injectors',
      name: 'service_diagnostyka_remont_palivnykh_forsunok',
      desc: '',
      args: [],
    );
  }

  /// `Diagnostics and repair of fuel injection pumps`
  String get service_diagnostyka_remont_tnvd {
    return Intl.message(
      'Diagnostics and repair of fuel injection pumps',
      name: 'service_diagnostyka_remont_tnvd',
      desc: '',
      args: [],
    );
  }

  /// `Replacing glow plugs`
  String get service_zamina_svichok_rozzharjuvannya {
    return Intl.message(
      'Replacing glow plugs',
      name: 'service_zamina_svichok_rozzharjuvannya',
      desc: '',
      args: [],
    );
  }

  /// `Fuel system flushing of diesel cars`
  String get service_promyvka_palivnoyi_systemy_dizel {
    return Intl.message(
      'Fuel system flushing of diesel cars',
      name: 'service_promyvka_palivnoyi_systemy_dizel',
      desc: '',
      args: [],
    );
  }

  /// `Resource out`
  String get resource_out {
    return Intl.message(
      'Resource out',
      name: 'resource_out',
      desc: '',
      args: [],
    );
  }

  /// `reached 90% usage`
  String get reached_usage {
    return Intl.message(
      'reached 90% usage',
      name: 'reached_usage',
      desc: '',
      args: [],
    );
  }

  /// `Don't forget to change the oil`
  String get not_forget {
    return Intl.message(
      'Don\'t forget to change the oil',
      name: 'not_forget',
      desc: '',
      args: [],
    );
  }

  /// `Time to check the tires`
  String get check_tires {
    return Intl.message(
      'Time to check the tires',
      name: 'check_tires',
      desc: '',
      args: [],
    );
  }

  /// `The filter needs to be replaced`
  String get check_filter {
    return Intl.message(
      'The filter needs to be replaced',
      name: 'check_filter',
      desc: '',
      args: [],
    );
  }

  /// `Don't forget to complete the task`
  String get not_forget_task {
    return Intl.message(
      'Don\'t forget to complete the task',
      name: 'not_forget_task',
      desc: '',
      args: [],
    );
  }

  /// `oil`
  String get oil {
    return Intl.message('oil', name: 'oil', desc: '', args: []);
  }

  /// `tire`
  String get tires {
    return Intl.message('tire', name: 'tires', desc: '', args: []);
  }

  /// `filter`
  String get filter {
    return Intl.message('filter', name: 'filter', desc: '', args: []);
  }

  /// `Notifications about reaching 90% resource`
  String get notifications_resource {
    return Intl.message(
      'Notifications about reaching 90% resource',
      name: 'notifications_resource',
      desc: '',
      args: [],
    );
  }

  /// `Successful registration`
  String get successful_registration {
    return Intl.message(
      'Successful registration',
      name: 'successful_registration',
      desc: '',
      args: [],
    );
  }

  /// `Google login error`
  String get google_login_error {
    return Intl.message(
      'Google login error',
      name: 'google_login_error',
      desc: '',
      args: [],
    );
  }

  /// `History is temporarily unavailable: index is being built. Please try again in a few minutes.`
  String get history_unavailable {
    return Intl.message(
      'History is temporarily unavailable: index is being built. Please try again in a few minutes.',
      name: 'history_unavailable',
      desc: '',
      args: [],
    );
  }

  /// `Not authorized`
  String get not_auth {
    return Intl.message('Not authorized', name: 'not_auth', desc: '', args: []);
  }

  /// `Please leave or register to continue.`
  String get please_log_in {
    return Intl.message(
      'Please leave or register to continue.',
      name: 'please_log_in',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `Comment published!`
  String get comment_published {
    return Intl.message(
      'Comment published!',
      name: 'comment_published',
      desc: '',
      args: [],
    );
  }

  /// `Amount per month`
  String get amount_month {
    return Intl.message(
      'Amount per month',
      name: 'amount_month',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get total {
    return Intl.message('Total', name: 'total', desc: '', args: []);
  }

  /// `OK`
  String get ok {
    return Intl.message('OK', name: 'ok', desc: '', args: []);
  }

  /// `Car wash`
  String get car_wash {
    return Intl.message('Car wash', name: 'car_wash', desc: '', args: []);
  }

  /// `Car wash nearby`
  String get car_wash_nearby {
    return Intl.message(
      'Car wash nearby',
      name: 'car_wash_nearby',
      desc: '',
      args: [],
    );
  }

  /// `Enter amount`
  String get enter_amount {
    return Intl.message(
      'Enter amount',
      name: 'enter_amount',
      desc: '',
      args: [],
    );
  }

  /// `Failed to extract tokens`
  String get failed_extract_tokens {
    return Intl.message(
      'Failed to extract tokens',
      name: 'failed_extract_tokens',
      desc: '',
      args: [],
    );
  }

  /// `Tokens extracted`
  String get tokens_extracted {
    return Intl.message(
      'Tokens extracted',
      name: 'tokens_extracted',
      desc: '',
      args: [],
    );
  }

  /// `No tokens yet`
  String get no_tokens_yet {
    return Intl.message(
      'No tokens yet',
      name: 'no_tokens_yet',
      desc: '',
      args: [],
    );
  }

  /// `Tokens already present`
  String get tokens_already_present {
    return Intl.message(
      'Tokens already present',
      name: 'tokens_already_present',
      desc: '',
      args: [],
    );
  }

  /// `Loaded`
  String get loaded {
    return Intl.message('Loaded', name: 'loaded', desc: '', args: []);
  }

  /// `Open e-Drive`
  String get open_site {
    return Intl.message('Open e-Drive', name: 'open_site', desc: '', args: []);
  }

  /// `Extracting...`
  String get extracting {
    return Intl.message(
      'Extracting...',
      name: 'extracting',
      desc: '',
      args: [],
    );
  }

  /// `Extract tokens`
  String get extract_tokens {
    return Intl.message(
      'Extract tokens',
      name: 'extract_tokens',
      desc: '',
      args: [],
    );
  }

  /// `No records`
  String get no_records {
    return Intl.message('No records', name: 'no_records', desc: '', args: []);
  }

  /// `Fine checking is disabled in settings`
  String get fine_checking_disabled {
    return Intl.message(
      'Fine checking is disabled in settings',
      name: 'fine_checking_disabled',
      desc: '',
      args: [],
    );
  }

  /// `Delete expense history`
  String get delete_expense_history {
    return Intl.message(
      'Delete expense history',
      name: 'delete_expense_history',
      desc: '',
      args: [],
    );
  }

  /// `Delete all expenses?`
  String get delete_all_expenses {
    return Intl.message(
      'Delete all expenses?',
      name: 'delete_all_expenses',
      desc: '',
      args: [],
    );
  }

  /// `This action cannot be undone.`
  String get cannot_be_undone {
    return Intl.message(
      'This action cannot be undone.',
      name: 'cannot_be_undone',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get remove {
    return Intl.message('Remove', name: 'remove', desc: '', args: []);
  }

  /// `Category removed`
  String get category_removed {
    return Intl.message(
      'Category removed',
      name: 'category_removed',
      desc: '',
      args: [],
    );
  }

  /// `Delete ALL expenses`
  String get del_all_expenses {
    return Intl.message(
      'Delete ALL expenses',
      name: 'del_all_expenses',
      desc: '',
      args: [],
    );
  }

  /// `All expense history deleted`
  String get all_exp_hist_deleted {
    return Intl.message(
      'All expense history deleted',
      name: 'all_exp_hist_deleted',
      desc: '',
      args: [],
    );
  }

  /// `A new version of the application is available`
  String get new_version {
    return Intl.message(
      'A new version of the application is available',
      name: 'new_version',
      desc: '',
      args: [],
    );
  }

  /// `Please update the application to continue using it.`
  String get please_update {
    return Intl.message(
      'Please update the application to continue using it.',
      name: 'please_update',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get update {
    return Intl.message('Update', name: 'update', desc: '', args: []);
  }

  /// `Field required`
  String get field_required {
    return Intl.message(
      'Field required',
      name: 'field_required',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email`
  String get invalid_email {
    return Intl.message(
      'Invalid email',
      name: 'invalid_email',
      desc: '',
      args: [],
    );
  }

  /// `Minimum 6 characters`
  String get password_too_short {
    return Intl.message(
      'Minimum 6 characters',
      name: 'password_too_short',
      desc: '',
      args: [],
    );
  }

  /// `3 Month Subscription`
  String get subscription_3_month {
    return Intl.message(
      '3 Month Subscription',
      name: 'subscription_3_month',
      desc: '',
      args: [],
    );
  }

  /// `6 Month Subscription`
  String get subscription_6_month {
    return Intl.message(
      '6 Month Subscription',
      name: 'subscription_6_month',
      desc: '',
      args: [],
    );
  }

  /// `12 Month Subscription`
  String get subscription_12_month {
    return Intl.message(
      '12 Month Subscription',
      name: 'subscription_12_month',
      desc: '',
      args: [],
    );
  }

  /// `Test subscription for`
  String get test_subscription {
    return Intl.message(
      'Test subscription for',
      name: 'test_subscription',
      desc: '',
      args: [],
    );
  }

  /// `months successfully completed!`
  String get successfully_completed {
    return Intl.message(
      'months successfully completed!',
      name: 'successfully_completed',
      desc: '',
      args: [],
    );
  }

  /// `Authorization required`
  String get authorization_required {
    return Intl.message(
      'Authorization required',
      name: 'authorization_required',
      desc: '',
      args: [],
    );
  }

  /// `Subscription`
  String get subscription {
    return Intl.message(
      'Subscription',
      name: 'subscription',
      desc: '',
      args: [],
    );
  }

  /// `Store unavailable`
  String get store_unavailable {
    return Intl.message(
      'Store unavailable',
      name: 'store_unavailable',
      desc: '',
      args: [],
    );
  }

  /// `Click again to exit`
  String get click_again {
    return Intl.message(
      'Click again to exit',
      name: 'click_again',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get sign_up {
    return Intl.message('Sign Up', name: 'sign_up', desc: '', args: []);
  }

  /// `Enter email`
  String get enter_email {
    return Intl.message('Enter email', name: 'enter_email', desc: '', args: []);
  }

  /// `Incorrect email`
  String get incorrect_email {
    return Intl.message(
      'Incorrect email',
      name: 'incorrect_email',
      desc: '',
      args: [],
    );
  }

  /// `Enter password`
  String get enter_password {
    return Intl.message(
      'Enter password',
      name: 'enter_password',
      desc: '',
      args: [],
    );
  }

  /// `Minimum 6 characters`
  String get min_char {
    return Intl.message(
      'Minimum 6 characters',
      name: 'min_char',
      desc: '',
      args: [],
    );
  }

  /// `LOG IN`
  String get large_login {
    return Intl.message('LOG IN', name: 'large_login', desc: '', args: []);
  }

  /// `SIGN UP`
  String get large_sign_up {
    return Intl.message('SIGN UP', name: 'large_sign_up', desc: '', args: []);
  }

  /// `Don't have an account? Sign up`
  String get dont_have_account {
    return Intl.message(
      'Don\'t have an account? Sign up',
      name: 'dont_have_account',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account? Sign in`
  String get already_have_account {
    return Intl.message(
      'Already have an account? Sign in',
      name: 'already_have_account',
      desc: '',
      args: [],
    );
  }

  /// `Or sign in using`
  String get or_sign_in_using {
    return Intl.message(
      'Or sign in using',
      name: 'or_sign_in_using',
      desc: '',
      args: [],
    );
  }

  /// `Google login successful`
  String get google_login {
    return Intl.message(
      'Google login successful',
      name: 'google_login',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect password`
  String get incorrect_password {
    return Intl.message(
      'Incorrect password',
      name: 'incorrect_password',
      desc: '',
      args: [],
    );
  }

  /// `A user with this email already exists`
  String get email_already_exists {
    return Intl.message(
      'A user with this email already exists',
      name: 'email_already_exists',
      desc: '',
      args: [],
    );
  }

  /// `User not found`
  String get user_not_found {
    return Intl.message(
      'User not found',
      name: 'user_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect email address`
  String get incorrect_email_address {
    return Intl.message(
      'Incorrect email address',
      name: 'incorrect_email_address',
      desc: '',
      args: [],
    );
  }

  /// `Email verification error`
  String get email_verification_error {
    return Intl.message(
      'Email verification error',
      name: 'email_verification_error',
      desc: '',
      args: [],
    );
  }

  /// `Subscription for`
  String get subscription_for {
    return Intl.message(
      'Subscription for',
      name: 'subscription_for',
      desc: '',
      args: [],
    );
  }

  /// `months completed`
  String get subscription_complected {
    return Intl.message(
      'months completed',
      name: 'subscription_complected',
      desc: '',
      args: [],
    );
  }

  /// `Access to basic features`
  String get access_basic {
    return Intl.message(
      'Access to basic features',
      name: 'access_basic',
      desc: '',
      args: [],
    );
  }

  /// `Ad-free experience`
  String get free_experience {
    return Intl.message(
      'Ad-free experience',
      name: 'free_experience',
      desc: '',
      args: [],
    );
  }

  /// `Premium support`
  String get premium_support {
    return Intl.message(
      'Premium support',
      name: 'premium_support',
      desc: '',
      args: [],
    );
  }

  /// `Selected`
  String get selected {
    return Intl.message('Selected', name: 'selected', desc: '', args: []);
  }

  /// `Select plan`
  String get select_plan {
    return Intl.message('Select plan', name: 'select_plan', desc: '', args: []);
  }

  /// `Full tank`
  String get full_tank {
    return Intl.message('Full tank', name: 'full_tank', desc: '', args: []);
  }

  /// `Costs`
  String get total_costs {
    return Intl.message('Costs', name: 'total_costs', desc: '', args: []);
  }

  /// `Oil`
  String get oil_icon {
    return Intl.message('Oil', name: 'oil_icon', desc: '', args: []);
  }

  /// `Coolant`
  String get coolant_icon {
    return Intl.message('Coolant', name: 'coolant_icon', desc: '', args: []);
  }

  /// `Service`
  String get service_icon {
    return Intl.message('Service', name: 'service_icon', desc: '', args: []);
  }

  /// `Repair`
  String get repair_icon {
    return Intl.message('Repair', name: 'repair_icon', desc: '', args: []);
  }

  /// `Battery`
  String get battery {
    return Intl.message('Battery', name: 'battery', desc: '', args: []);
  }

  /// `Tires`
  String get tires_icon {
    return Intl.message('Tires', name: 'tires_icon', desc: '', args: []);
  }

  /// `Car`
  String get car_icon {
    return Intl.message('Car', name: 'car_icon', desc: '', args: []);
  }

  /// `Insurance`
  String get insurance {
    return Intl.message('Insurance', name: 'insurance', desc: '', args: []);
  }

  /// `Last event`
  String get last_event {
    return Intl.message('Last event', name: 'last_event', desc: '', args: []);
  }

  /// `Open events`
  String get open_events {
    return Intl.message('Open events', name: 'open_events', desc: '', args: []);
  }

  /// `No recent events`
  String get no_recent_events {
    return Intl.message(
      'No recent events',
      name: 'no_recent_events',
      desc: '',
      args: [],
    );
  }

  /// `Cost Statistics`
  String get costs_stat {
    return Intl.message(
      'Cost Statistics',
      name: 'costs_stat',
      desc: '',
      args: [],
    );
  }

  /// `Mileage Statistics`
  String get mileage_stat {
    return Intl.message(
      'Mileage Statistics',
      name: 'mileage_stat',
      desc: '',
      args: [],
    );
  }

  /// `Request error`
  String get request_error {
    return Intl.message(
      'Request error',
      name: 'request_error',
      desc: '',
      args: [],
    );
  }

  /// `Connection error`
  String get connection_error {
    return Intl.message(
      'Connection error',
      name: 'connection_error',
      desc: '',
      args: [],
    );
  }

  /// `per month`
  String get per_month {
    return Intl.message('per month', name: 'per_month', desc: '', args: []);
  }

  /// `Plan successfully activated`
  String get plan_activated {
    return Intl.message(
      'Plan successfully activated',
      name: 'plan_activated',
      desc: '',
      args: [],
    );
  }

  /// `Subscription failed to activate`
  String get subscription_failed {
    return Intl.message(
      'Subscription failed to activate',
      name: 'subscription_failed',
      desc: '',
      args: [],
    );
  }

  /// `Facebook error: AccessToken empty`
  String get facebook_error {
    return Intl.message(
      'Facebook error: AccessToken empty',
      name: 'facebook_error',
      desc: '',
      args: [],
    );
  }

  /// `Facebook login successful`
  String get facebook_login_successful {
    return Intl.message(
      'Facebook login successful',
      name: 'facebook_login_successful',
      desc: '',
      args: [],
    );
  }

  /// `Facebook login canceled by user.`
  String get facebook_login_cancelled {
    return Intl.message(
      'Facebook login canceled by user.',
      name: 'facebook_login_cancelled',
      desc: '',
      args: [],
    );
  }

  /// `Facebook login error:`
  String get facebook_login_error {
    return Intl.message(
      'Facebook login error:',
      name: 'facebook_login_error',
      desc: '',
      args: [],
    );
  }

  /// `Subscription error`
  String get subscription_error {
    return Intl.message(
      'Subscription error',
      name: 'subscription_error',
      desc: '',
      args: [],
    );
  }

  /// `Trial period activated`
  String get trial_period_activated {
    return Intl.message(
      'Trial period activated',
      name: 'trial_period_activated',
      desc: '',
      args: [],
    );
  }

  /// `days free`
  String get days_free {
    return Intl.message('days free', name: 'days_free', desc: '', args: []);
  }

  /// `Trial period expired`
  String get trial_expired {
    return Intl.message(
      'Trial period expired',
      name: 'trial_expired',
      desc: '',
      args: [],
    );
  }

  /// `Maintenance control`
  String get maintenance_control {
    return Intl.message(
      'Maintenance control',
      name: 'maintenance_control',
      desc: '',
      args: [],
    );
  }

  /// `Reminders for car inspection and service`
  String get car_inspection {
    return Intl.message(
      'Reminders for car inspection and service',
      name: 'car_inspection',
      desc: '',
      args: [],
    );
  }

  /// `Insurance control`
  String get insurance_control {
    return Intl.message(
      'Insurance control',
      name: 'insurance_control',
      desc: '',
      args: [],
    );
  }

  /// `Track car insurance due dates`
  String get keep_track {
    return Intl.message(
      'Track car insurance due dates',
      name: 'keep_track',
      desc: '',
      args: [],
    );
  }

  /// `Fine fines control`
  String get fines_control {
    return Intl.message(
      'Fine fines control',
      name: 'fines_control',
      desc: '',
      args: [],
    );
  }

  /// `Get notified and pay on time`
  String get get_notified {
    return Intl.message(
      'Get notified and pay on time',
      name: 'get_notified',
      desc: '',
      args: [],
    );
  }

  /// `Analytics`
  String get analytics {
    return Intl.message('Analytics', name: 'analytics', desc: '', args: []);
  }

  /// `Track costs, mileage and efficiency`
  String get track_costs {
    return Intl.message(
      'Track costs, mileage and efficiency',
      name: 'track_costs',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get miss {
    return Intl.message('Skip', name: 'miss', desc: '', args: []);
  }

  /// `Done`
  String get done {
    return Intl.message('Done', name: 'done', desc: '', args: []);
  }

  /// `No plan selected`
  String get no_plan_selected {
    return Intl.message(
      'No plan selected',
      name: 'no_plan_selected',
      desc: '',
      args: [],
    );
  }

  /// `Jan`
  String get month_jan {
    return Intl.message('Jan', name: 'month_jan', desc: '', args: []);
  }

  /// `Feb`
  String get month_feb {
    return Intl.message('Feb', name: 'month_feb', desc: '', args: []);
  }

  /// `Mar`
  String get month_mar {
    return Intl.message('Mar', name: 'month_mar', desc: '', args: []);
  }

  /// `Apr`
  String get month_apr {
    return Intl.message('Apr', name: 'month_apr', desc: '', args: []);
  }

  /// `May`
  String get month_may {
    return Intl.message('May', name: 'month_may', desc: '', args: []);
  }

  /// `Jun`
  String get month_jun {
    return Intl.message('Jun', name: 'month_jun', desc: '', args: []);
  }

  /// `Jul`
  String get month_jul {
    return Intl.message('Jul', name: 'month_jul', desc: '', args: []);
  }

  /// `Aug`
  String get month_aug {
    return Intl.message('Aug', name: 'month_aug', desc: '', args: []);
  }

  /// `Sep`
  String get month_sep {
    return Intl.message('Sep', name: 'month_sep', desc: '', args: []);
  }

  /// `Oct`
  String get month_oct {
    return Intl.message('Oct', name: 'month_oct', desc: '', args: []);
  }

  /// `Nov`
  String get month_nov {
    return Intl.message('Nov', name: 'month_nov', desc: '', args: []);
  }

  /// `Dec`
  String get month_dec {
    return Intl.message('Dec', name: 'month_dec', desc: '', args: []);
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Units`
  String get units {
    return Intl.message('Units', name: 'units', desc: '', args: []);
  }

  /// `Currency`
  String get currency {
    return Intl.message('Currency', name: 'currency', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Fuel consumption`
  String get fuel_consumption {
    return Intl.message(
      'Fuel consumption',
      name: 'fuel_consumption',
      desc: '',
      args: [],
    );
  }

  /// `l.`
  String get l {
    return Intl.message('l.', name: 'l', desc: '', args: []);
  }

  /// `USD`
  String get usd {
    return Intl.message('USD', name: 'usd', desc: '', args: []);
  }

  /// `EUR`
  String get eur {
    return Intl.message('EUR', name: 'eur', desc: '', args: []);
  }

  /// `already planned`
  String get already_planned {
    return Intl.message(
      'already planned',
      name: 'already_planned',
      desc: '',
      args: [],
    );
  }

  /// `Ukrainian`
  String get ukr {
    return Intl.message('Ukrainian', name: 'ukr', desc: '', args: []);
  }

  /// `Create`
  String get create {
    return Intl.message('Create', name: 'create', desc: '', args: []);
  }

  /// `Next`
  String get next {
    return Intl.message('Next', name: 'next', desc: '', args: []);
  }

  /// `Good`
  String get good {
    return Intl.message('Good', name: 'good', desc: '', args: []);
  }

  /// `Of course`
  String get of_course {
    return Intl.message('Of course', name: 'of_course', desc: '', args: []);
  }

  /// `Terms of Use`
  String get terms_of_use {
    return Intl.message(
      'Terms of Use',
      name: 'terms_of_use',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacy_policy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacy_policy',
      desc: '',
      args: [],
    );
  }

  /// `Cancel anytime on Google Play`
  String get cancel_anytime {
    return Intl.message(
      'Cancel anytime on Google Play',
      name: 'cancel_anytime',
      desc: '',
      args: [],
    );
  }

  /// `Try Premium`
  String get try_premium {
    return Intl.message('Try Premium', name: 'try_premium', desc: '', args: []);
  }

  /// `Sign Up`
  String get sign_up_button {
    return Intl.message('Sign Up', name: 'sign_up_button', desc: '', args: []);
  }

  /// `Trial period active`
  String get trial_period_active {
    return Intl.message(
      'Trial period active',
      name: 'trial_period_active',
      desc: '',
      args: [],
    );
  }

  /// `days left`
  String get days_left {
    return Intl.message('days left', name: 'days_left', desc: '', args: []);
  }

  /// `Trial period ended`
  String get trial_period_ended {
    return Intl.message(
      'Trial period ended',
      name: 'trial_period_ended',
      desc: '',
      args: [],
    );
  }

  /// `No ads`
  String get no_ads {
    return Intl.message('No ads', name: 'no_ads', desc: '', args: []);
  }

  /// `Increased download limit`
  String get increased_download_limit {
    return Intl.message(
      'Increased download limit',
      name: 'increased_download_limit',
      desc: '',
      args: [],
    );
  }

  /// `Search fines`
  String get search_fines {
    return Intl.message(
      'Search fines',
      name: 'search_fines',
      desc: '',
      args: [],
    );
  }

  /// `Categories`
  String get category {
    return Intl.message('Categories', name: 'category', desc: '', args: []);
  }

  /// `Interval by date`
  String get interval_by_date {
    return Intl.message(
      'Interval by date',
      name: 'interval_by_date',
      desc: '',
      args: [],
    );
  }

  /// `Days`
  String get days_interv {
    return Intl.message('Days', name: 'days_interv', desc: '', args: []);
  }

  /// `Months`
  String get months {
    return Intl.message('Months', name: 'months', desc: '', args: []);
  }

  /// `Years`
  String get years {
    return Intl.message('Years', name: 'years', desc: '', args: []);
  }

  /// `Interval (km)`
  String get interval {
    return Intl.message('Interval (km)', name: 'interval', desc: '', args: []);
  }

  /// `Last service date`
  String get last_service_date {
    return Intl.message(
      'Last service date',
      name: 'last_service_date',
      desc: '',
      args: [],
    );
  }

  /// `Last insurance date`
  String get last_insurance_date {
    return Intl.message(
      'Last insurance date',
      name: 'last_insurance_date',
      desc: '',
      args: [],
    );
  }

  /// `Attention`
  String get attention {
    return Intl.message('Attention', name: 'attention', desc: '', args: []);
  }

  /// `No_such_service`
  String get no_such_service {
    return Intl.message(
      'No_such_service',
      name: 'no_such_service',
      desc: '',
      args: [],
    );
  }

  /// `Every`
  String get every {
    return Intl.message('Every', name: 'every', desc: '', args: []);
  }

  /// `Action`
  String get action {
    return Intl.message('Action', name: 'action', desc: '', args: []);
  }

  /// `No expense data yet`
  String get no_expenses {
    return Intl.message(
      'No expense data yet',
      name: 'no_expenses',
      desc: '',
      args: [],
    );
  }

  /// `Get My Plan`
  String get get_plan {
    return Intl.message('Get My Plan', name: 'get_plan', desc: '', args: []);
  }

  /// `30-day money back guarantee!`
  String get money_back {
    return Intl.message(
      '30-day money back guarantee!',
      name: 'money_back',
      desc: '',
      args: [],
    );
  }

  /// `Safe and secure payment`
  String get pay_safe {
    return Intl.message(
      'Safe and secure payment',
      name: 'pay_safe',
      desc: '',
      args: [],
    );
  }

  /// `MOST POPULAR`
  String get most_popular {
    return Intl.message(
      'MOST POPULAR',
      name: 'most_popular',
      desc: '',
      args: [],
    );
  }

  /// `Input you car number ->`
  String get input_number {
    return Intl.message(
      'Input you car number ->',
      name: 'input_number',
      desc: '',
      args: [],
    );
  }

  /// `No schedule yet`
  String get no_schedule {
    return Intl.message(
      'No schedule yet',
      name: 'no_schedule',
      desc: '',
      args: [],
    );
  }

  /// `No story yet`
  String get no_story {
    return Intl.message('No story yet', name: 'no_story', desc: '', args: []);
  }

  /// `View all events`
  String get view_all_events {
    return Intl.message(
      'View all events',
      name: 'view_all_events',
      desc: '',
      args: [],
    );
  }

  /// `Delete car number`
  String get delete_car_number {
    return Intl.message(
      'Delete car number',
      name: 'delete_car_number',
      desc: '',
      args: [],
    );
  }

  /// `Car deleted successfully`
  String get cars_deleted_success {
    return Intl.message(
      'Car deleted successfully',
      name: 'cars_deleted_success',
      desc: '',
      args: [],
    );
  }

  /// `Confirm car deletion`
  String get delete_cars_confirm {
    return Intl.message(
      'Confirm car deletion',
      name: 'delete_cars_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Select insurance type`
  String get select_type_insurance {
    return Intl.message(
      'Select insurance type',
      name: 'select_type_insurance',
      desc: '',
      args: [],
    );
  }

  /// `Already added`
  String get already_added {
    return Intl.message(
      'Already added',
      name: 'already_added',
      desc: '',
      args: [],
    );
  }

  /// `No car selected`
  String get no_car_selected {
    return Intl.message(
      'No car selected',
      name: 'no_car_selected',
      desc: '',
      args: [],
    );
  }

  /// `Your subscription will automatically renew at the full price at the end of the chosen term. You can cancel anytime.`
  String get text_automatically_renew {
    return Intl.message(
      'Your subscription will automatically renew at the full price at the end of the chosen term. You can cancel anytime.',
      name: 'text_automatically_renew',
      desc: '',
      args: [],
    );
  }

  /// `Use Cyrillic`
  String get enter_cyrillic_only {
    return Intl.message(
      'Use Cyrillic',
      name: 'enter_cyrillic_only',
      desc: '',
      args: [],
    );
  }

  /// `Purchase not available`
  String get purchase_not_available {
    return Intl.message(
      'Purchase not available',
      name: 'purchase_not_available',
      desc: '',
      args: [],
    );
  }

  /// `A Google Play account is required to make a purchase. Please sign in or create an account and try again.`
  String get create_account {
    return Intl.message(
      'A Google Play account is required to make a purchase. Please sign in or create an account and try again.',
      name: 'create_account',
      desc: '',
      args: [],
    );
  }

  /// `Open Google Play`
  String get open_google_play {
    return Intl.message(
      'Open Google Play',
      name: 'open_google_play',
      desc: '',
      args: [],
    );
  }

  /// `Go to DriverTop page`
  String get open_driver_page {
    return Intl.message(
      'Go to DriverTop page',
      name: 'open_driver_page',
      desc: '',
      args: [],
    );
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
