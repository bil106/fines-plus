// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(error) => "Apple sign-in error: ${error}";

  static String m1(distance, unit) => "Best price nearby · ${distance} ${unit}";

  static String m2(distance, unit) => "Best rated nearby · ${distance} ${unit}";

  static String m3(distance, unit) => "${distance} ${unit}";

  static String m4(amount) => "Traffic fine: ${amount}";

  static String m5(count) => "New fines found: ${count}";

  static String m6(count) => "${count} cars";

  static String m7(date) => "OK until ${date}";

  static String m8(date) =>
      "Your insurance expires on ${date}. Time to renew it.";

  static String m9(task) => "Time for: ${task}";

  static String m10(rating) => "rating: ${rating}";

  static String m11(days) => "Planned service in ${days} days.";

  static String m12(count) => "Approx. in ${count} days";

  static String m13(count) => "Approx. in ${count} weeks";

  static String m14(km) => "Oil change in ${km} km";

  static String m15(distance, unit) =>
      "Best rated nearby · ${distance} ${unit}";

  static String m16(price, period) =>
      "7-day free trial, then ${price} per ${period}. Cancel anytime, at least 24 hours before the trial ends, in Google Play Settings. Subscription renews automatically unless cancelled.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about_app_section": MessageLookupByLibrary.simpleMessage("About"),
    "add_car": MessageLookupByLibrary.simpleMessage("Add car"),
    "add_cars": MessageLookupByLibrary.simpleMessage("Add a car"),
    "add_expense": MessageLookupByLibrary.simpleMessage("Add expense"),
    "add_reminder_button": MessageLookupByLibrary.simpleMessage("Add reminder"),
    "addition_cars": MessageLookupByLibrary.simpleMessage("Adding a car"),
    "additional_options": MessageLookupByLibrary.simpleMessage(
      "Additional options",
    ),
    "address_not_specified": MessageLookupByLibrary.simpleMessage(
      "Address not specified",
    ),
    "all_exp_hist_deleted": MessageLookupByLibrary.simpleMessage(
      "All expense history deleted",
    ),
    "already_have_account": MessageLookupByLibrary.simpleMessage(
      "Already have an account? Sign in",
    ),
    "already_planned": MessageLookupByLibrary.simpleMessage("already planned"),
    "amount": MessageLookupByLibrary.simpleMessage("Amount"),
    "amount_month": MessageLookupByLibrary.simpleMessage("Amount per month"),
    "analitics": MessageLookupByLibrary.simpleMessage("Analytics"),
    "analytics": MessageLookupByLibrary.simpleMessage("Analytics"),
    "app_libraries": MessageLookupByLibrary.simpleMessage("App libraries"),
    "app_libraries_description": MessageLookupByLibrary.simpleMessage(
      "This app uses open-source components.",
    ),
    "app_version": MessageLookupByLibrary.simpleMessage("Version"),
    "apple_login_error": m0,
    "apple_login_successful": MessageLookupByLibrary.simpleMessage(
      "Sign in with Apple successful",
    ),
    "attention": MessageLookupByLibrary.simpleMessage("Attention"),
    "auto": MessageLookupByLibrary.simpleMessage("Auto"),
    "average": MessageLookupByLibrary.simpleMessage("Average"),
    "battery": MessageLookupByLibrary.simpleMessage("Battery"),
    "battery_capacity_kwh": MessageLookupByLibrary.simpleMessage(
      "Battery capacity, kWh",
    ),
    "best_price_nearby_distance": m1,
    "build_route": MessageLookupByLibrary.simpleMessage("Build route"),
    "buyer_report": MessageLookupByLibrary.simpleMessage("Buyer\'s report"),
    "by_date": MessageLookupByLibrary.simpleMessage("By date"),
    "by_mileage": MessageLookupByLibrary.simpleMessage("By mileage"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cannot_be_undone": MessageLookupByLibrary.simpleMessage(
      "This action cannot be undone.",
    ),
    "car_history": MessageLookupByLibrary.simpleMessage("Car history"),
    "car_inspection": MessageLookupByLibrary.simpleMessage(
      "Reminders for car inspection and service",
    ),
    "car_number": MessageLookupByLibrary.simpleMessage("Car number"),
    "car_wash": MessageLookupByLibrary.simpleMessage("Car wash"),
    "car_wash_best_rating_distance": m2,
    "car_wash_load_failed": MessageLookupByLibrary.simpleMessage(
      "Could not load car washes",
    ),
    "car_wash_location_unavailable": MessageLookupByLibrary.simpleMessage(
      "Allow location access to find nearby car washes",
    ),
    "car_wash_nearby": MessageLookupByLibrary.simpleMessage("Car wash nearby"),
    "car_wash_no_nearby": MessageLookupByLibrary.simpleMessage(
      "No nearby car washes found",
    ),
    "cars_deleted_success": MessageLookupByLibrary.simpleMessage(
      "Car deleted successfully",
    ),
    "category": MessageLookupByLibrary.simpleMessage("Categories"),
    "category_removed": MessageLookupByLibrary.simpleMessage(
      "Category removed",
    ),
    "charger_location_unavailable": MessageLookupByLibrary.simpleMessage(
      "Allow location access to find nearby chargers",
    ),
    "charging_nearby": MessageLookupByLibrary.simpleMessage("Chargers nearby"),
    "chart_period_12m": MessageLookupByLibrary.simpleMessage("12 months"),
    "chart_period_6m": MessageLookupByLibrary.simpleMessage("6 months"),
    "check_fines_reminder_body": MessageLookupByLibrary.simpleMessage(
      "Check for new traffic fines",
    ),
    "check_fines_reminder_title": MessageLookupByLibrary.simpleMessage(
      "Fines reminder",
    ),
    "click_again": MessageLookupByLibrary.simpleMessage("Click again to exit"),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "comment": MessageLookupByLibrary.simpleMessage("Comment"),
    "configure_action": MessageLookupByLibrary.simpleMessage(
      "Configure action",
    ),
    "connection_error": MessageLookupByLibrary.simpleMessage(
      "Connection error",
    ),
    "coolant_icon": MessageLookupByLibrary.simpleMessage("Coolant"),
    "cost": MessageLookupByLibrary.simpleMessage("Cost"),
    "cost_statistics": MessageLookupByLibrary.simpleMessage("Cost statistics"),
    "costs_stat": MessageLookupByLibrary.simpleMessage("Cost Statistics"),
    "create": MessageLookupByLibrary.simpleMessage("Create"),
    "create_account": MessageLookupByLibrary.simpleMessage(
      "A Google Play account is required to make a purchase. Please sign in or create an account and try again.",
    ),
    "csv": MessageLookupByLibrary.simpleMessage("CSV"),
    "currency": MessageLookupByLibrary.simpleMessage("Currency"),
    "current_mileage": MessageLookupByLibrary.simpleMessage("Current mileage"),
    "date": MessageLookupByLibrary.simpleMessage("Date"),
    "days": MessageLookupByLibrary.simpleMessage("days"),
    "days_interv": MessageLookupByLibrary.simpleMessage("Days"),
    "del_all_expenses": MessageLookupByLibrary.simpleMessage(
      "Delete ALL expenses",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "delete_all_expenses": MessageLookupByLibrary.simpleMessage(
      "Delete all expenses?",
    ),
    "delete_car_number": MessageLookupByLibrary.simpleMessage(
      "Delete car number",
    ),
    "delete_cars_confirm": MessageLookupByLibrary.simpleMessage(
      "Confirm car deletion",
    ),
    "delete_expense_history": MessageLookupByLibrary.simpleMessage(
      "Delete expense history",
    ),
    "description": MessageLookupByLibrary.simpleMessage("Description"),
    "distance_km_short": m3,
    "done": MessageLookupByLibrary.simpleMessage("Done"),
    "dont_have_account": MessageLookupByLibrary.simpleMessage(
      "Don\'t have an account? Sign up",
    ),
    "due_amount": MessageLookupByLibrary.simpleMessage("Due"),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "edit_reminder": MessageLookupByLibrary.simpleMessage("Edit reminder"),
    "email": MessageLookupByLibrary.simpleMessage("Email"),
    "email_already_exists": MessageLookupByLibrary.simpleMessage(
      "A user with this email already exists",
    ),
    "english": MessageLookupByLibrary.simpleMessage("English"),
    "enter_amount": MessageLookupByLibrary.simpleMessage("Enter amount"),
    "enter_correct_number_auto": MessageLookupByLibrary.simpleMessage(
      "Enter the correct car number",
    ),
    "enter_email": MessageLookupByLibrary.simpleMessage("Enter email"),
    "enter_mileage": MessageLookupByLibrary.simpleMessage("Enter mileage"),
    "enter_password": MessageLookupByLibrary.simpleMessage("Enter password"),
    "error": MessageLookupByLibrary.simpleMessage("Error:"),
    "eur": MessageLookupByLibrary.simpleMessage("EUR"),
    "every": MessageLookupByLibrary.simpleMessage("Every"),
    "expense_save_failed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t save the entry. Please try again.",
    ),
    "export": MessageLookupByLibrary.simpleMessage("Export"),
    "export_history": MessageLookupByLibrary.simpleMessage("Export history"),
    "facebook_error": MessageLookupByLibrary.simpleMessage(
      "Facebook error: AccessToken empty",
    ),
    "facebook_login_cancelled": MessageLookupByLibrary.simpleMessage(
      "Facebook login canceled by user.",
    ),
    "facebook_login_error": MessageLookupByLibrary.simpleMessage(
      "Facebook login error:",
    ),
    "facebook_login_successful": MessageLookupByLibrary.simpleMessage(
      "Facebook login successful",
    ),
    "fact": MessageLookupByLibrary.simpleMessage("Fact"),
    "failed_extract_tokens": MessageLookupByLibrary.simpleMessage(
      "Failed to extract tokens",
    ),
    "fill_date": MessageLookupByLibrary.simpleMessage(
      "Fill in date, mileage and fuel amount",
    ),
    "fine_checking_disabled": MessageLookupByLibrary.simpleMessage(
      "Fine checking is disabled in settings",
    ),
    "fine_pdr_title": m4,
    "fines": MessageLookupByLibrary.simpleMessage("Fines"),
    "fines_checked": MessageLookupByLibrary.simpleMessage("Checked"),
    "fines_control": MessageLookupByLibrary.simpleMessage("Fine fines control"),
    "fines_mvs_hint": MessageLookupByLibrary.simpleMessage(
      "Solve the captcha and tap “Перевірити” — the fines will be added to the app automatically.",
    ),
    "fines_mvs_title": MessageLookupByLibrary.simpleMessage(
      "Fines check (MVS)",
    ),
    "fines_new_found": m5,
    "fines_no_new": MessageLookupByLibrary.simpleMessage("No new fines"),
    "fines_not_found_body": MessageLookupByLibrary.simpleMessage(
      "There are no active fines for your plate right now",
    ),
    "fines_not_found_title": MessageLookupByLibrary.simpleMessage(
      "No fines found",
    ),
    "fines_recheck_confirm": MessageLookupByLibrary.simpleMessage(
      "Check again",
    ),
    "fines_recheck_message": MessageLookupByLibrary.simpleMessage(
      "Fines were already checked today. You will need to solve the captcha again. Check anyway?",
    ),
    "fines_recheck_title": MessageLookupByLibrary.simpleMessage(
      "Already checked today",
    ),
    "fines_reminder_body": MessageLookupByLibrary.simpleMessage(
      "Time to check for new traffic fines",
    ),
    "fines_reminder_title": MessageLookupByLibrary.simpleMessage(
      "Fines reminder",
    ),
    "fines_violation": MessageLookupByLibrary.simpleMessage("Violation"),
    "free_trial_7_days": MessageLookupByLibrary.simpleMessage(
      "7-day free trial",
    ),
    "fuel": MessageLookupByLibrary.simpleMessage("Fuel"),
    "fuel_ai92": MessageLookupByLibrary.simpleMessage("AI-92"),
    "fuel_ai95": MessageLookupByLibrary.simpleMessage("AI-95"),
    "fuel_ai95_plus": MessageLookupByLibrary.simpleMessage("AI-95+"),
    "fuel_ai98": MessageLookupByLibrary.simpleMessage("AI-98"),
    "fuel_chip_a92": MessageLookupByLibrary.simpleMessage("A92"),
    "fuel_chip_a95": MessageLookupByLibrary.simpleMessage("A95"),
    "fuel_chip_diesel": MessageLookupByLibrary.simpleMessage("Diesel"),
    "fuel_chip_gas": MessageLookupByLibrary.simpleMessage("Gas"),
    "fuel_consumption": MessageLookupByLibrary.simpleMessage(
      "Fuel consumption",
    ),
    "fuel_electric": MessageLookupByLibrary.simpleMessage("Electric"),
    "fuel_gas_lpg": MessageLookupByLibrary.simpleMessage("Gas LPG"),
    "fuel_location_unavailable": MessageLookupByLibrary.simpleMessage(
      "Allow location access to find nearby gas stations",
    ),
    "fuel_prompt_body": MessageLookupByLibrary.simpleMessage(
      "Add fuel purchase details?",
    ),
    "fuel_prompt_title": MessageLookupByLibrary.simpleMessage("Fuel up"),
    "fuel_type": MessageLookupByLibrary.simpleMessage("Fuel type"),
    "fuel_up": MessageLookupByLibrary.simpleMessage("Fuel up"),
    "full_charge": MessageLookupByLibrary.simpleMessage("Full charge"),
    "full_tank": MessageLookupByLibrary.simpleMessage("Full tank"),
    "full_tank_hint": MessageLookupByLibrary.simpleMessage(
      "Needed to calculate consumption accurately",
    ),
    "garage_action_error": MessageLookupByLibrary.simpleMessage(
      "Failed to complete the action",
    ),
    "garage_cars_count": m6,
    "garage_continue": MessageLookupByLibrary.simpleMessage("Continue"),
    "garage_delete_confirm_body": MessageLookupByLibrary.simpleMessage(
      "All data for this car (expenses, reminders, maintenance) will be permanently deleted.",
    ),
    "garage_delete_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Remove this car from your garage?",
    ),
    "garage_delete_error": MessageLookupByLibrary.simpleMessage(
      "Failed to delete the car",
    ),
    "garage_empty_add_car": MessageLookupByLibrary.simpleMessage(
      "Add your car",
    ),
    "garage_make_hint": MessageLookupByLibrary.simpleMessage("Select a make"),
    "garage_make_label": MessageLookupByLibrary.simpleMessage("Car make"),
    "garage_model_hint": MessageLookupByLibrary.simpleMessage("Select a model"),
    "garage_model_label": MessageLookupByLibrary.simpleMessage(
      "Car model (optional)",
    ),
    "garage_setup_subtitle": MessageLookupByLibrary.simpleMessage(
      "Add your car now, or do it later — you can start using the app right away",
    ),
    "garage_status_insurance_expired": MessageLookupByLibrary.simpleMessage(
      "Insurance expired",
    ),
    "garage_status_ok": MessageLookupByLibrary.simpleMessage("OK"),
    "garage_status_ok_until": m7,
    "gas_station_nearby": MessageLookupByLibrary.simpleMessage(
      "Gas stations nearby",
    ),
    "general_section": MessageLookupByLibrary.simpleMessage("General"),
    "get_notified": MessageLookupByLibrary.simpleMessage(
      "Get notified and pay on time",
    ),
    "get_plan": MessageLookupByLibrary.simpleMessage("Get My Plan"),
    "good": MessageLookupByLibrary.simpleMessage("Good"),
    "google_login_error": MessageLookupByLibrary.simpleMessage(
      "Google login error",
    ),
    "grn": MessageLookupByLibrary.simpleMessage("UAH"),
    "hint_auto_num": MessageLookupByLibrary.simpleMessage("AH0000HA"),
    "hint_auto_num_es": MessageLookupByLibrary.simpleMessage("1234BCD"),
    "hint_auto_num_us": MessageLookupByLibrary.simpleMessage("8ABC123"),
    "hint_tech_data_num": MessageLookupByLibrary.simpleMessage("XEE128436"),
    "history": MessageLookupByLibrary.simpleMessage("History"),
    "history_unavailable": MessageLookupByLibrary.simpleMessage(
      "History is temporarily unavailable: index is being built. Please try again in a few minutes.",
    ),
    "home": MessageLookupByLibrary.simpleMessage("Home"),
    "incorrect_email": MessageLookupByLibrary.simpleMessage("Incorrect email"),
    "incorrect_email_address": MessageLookupByLibrary.simpleMessage(
      "Incorrect email address",
    ),
    "incorrect_password": MessageLookupByLibrary.simpleMessage(
      "Incorrect password",
    ),
    "input_number": MessageLookupByLibrary.simpleMessage(
      "Input you car number ->",
    ),
    "insurance": MessageLookupByLibrary.simpleMessage("Insurance"),
    "insurance_company": MessageLookupByLibrary.simpleMessage(
      "Insurance company",
    ),
    "insurance_control": MessageLookupByLibrary.simpleMessage(
      "Insurance control",
    ),
    "insurance_expiry_reminder_body": m8,
    "insurance_osago": MessageLookupByLibrary.simpleMessage("MTPL"),
    "interval": MessageLookupByLibrary.simpleMessage("Interval (km)"),
    "interval_by_date": MessageLookupByLibrary.simpleMessage(
      "Interval by date",
    ),
    "keep_track": MessageLookupByLibrary.simpleMessage(
      "Track car insurance due dates",
    ),
    "km": MessageLookupByLibrary.simpleMessage("km"),
    "kwh": MessageLookupByLibrary.simpleMessage("kWh"),
    "l": MessageLookupByLibrary.simpleMessage("l."),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "large_login": MessageLookupByLibrary.simpleMessage("LOG IN"),
    "large_sign_up": MessageLookupByLibrary.simpleMessage("SIGN UP"),
    "last_insurance_date": MessageLookupByLibrary.simpleMessage(
      "Last insurance date",
    ),
    "last_service_date": MessageLookupByLibrary.simpleMessage(
      "Last service date",
    ),
    "licenses_and_sources": MessageLookupByLibrary.simpleMessage(
      "Licenses and sources",
    ),
    "licenses_load_error": MessageLookupByLibrary.simpleMessage(
      "Could not load the license text.",
    ),
    "loaded": MessageLookupByLibrary.simpleMessage("Loaded"),
    "log_out": MessageLookupByLibrary.simpleMessage("Log out"),
    "log_out_confirmation": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to log out?",
    ),
    "login": MessageLookupByLibrary.simpleMessage("Login"),
    "maintenance": MessageLookupByLibrary.simpleMessage("Maintenance"),
    "maintenance_control": MessageLookupByLibrary.simpleMessage(
      "Maintenance control",
    ),
    "maintenance_due_body": m9,
    "maintenance_due_title": MessageLookupByLibrary.simpleMessage(
      "Maintenance due",
    ),
    "map_rating": m10,
    "mileage": MessageLookupByLibrary.simpleMessage("Mileage"),
    "mileage_statistics": MessageLookupByLibrary.simpleMessage(
      "Mileage statistics",
    ),
    "min_char": MessageLookupByLibrary.simpleMessage("Minimum 6 characters"),
    "money_back": MessageLookupByLibrary.simpleMessage(
      "30-day money back guarantee!",
    ),
    "month": MessageLookupByLibrary.simpleMessage("Month"),
    "month_apr": MessageLookupByLibrary.simpleMessage("April"),
    "month_aug": MessageLookupByLibrary.simpleMessage("August"),
    "month_dec": MessageLookupByLibrary.simpleMessage("December"),
    "month_feb": MessageLookupByLibrary.simpleMessage("February"),
    "month_jan": MessageLookupByLibrary.simpleMessage("January"),
    "month_jul": MessageLookupByLibrary.simpleMessage("July"),
    "month_jun": MessageLookupByLibrary.simpleMessage("June"),
    "month_mar": MessageLookupByLibrary.simpleMessage("March"),
    "month_may": MessageLookupByLibrary.simpleMessage("May"),
    "month_nov": MessageLookupByLibrary.simpleMessage("November"),
    "month_oct": MessageLookupByLibrary.simpleMessage("October"),
    "month_sep": MessageLookupByLibrary.simpleMessage("September"),
    "monthly_expenses": MessageLookupByLibrary.simpleMessage(
      "Monthly expenses",
    ),
    "months": MessageLookupByLibrary.simpleMessage("Months"),
    "most_popular": MessageLookupByLibrary.simpleMessage("MOST POPULAR"),
    "my_garage": MessageLookupByLibrary.simpleMessage("Garage"),
    "my_position": MessageLookupByLibrary.simpleMessage("You are here"),
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "new_reminder": MessageLookupByLibrary.simpleMessage("New notification"),
    "new_version": MessageLookupByLibrary.simpleMessage(
      "A new version of the application is available",
    ),
    "next": MessageLookupByLibrary.simpleMessage("Next"),
    "no_car_selected": MessageLookupByLibrary.simpleMessage("No car selected"),
    "no_expenses": MessageLookupByLibrary.simpleMessage("No expense data yet"),
    "no_fines": MessageLookupByLibrary.simpleMessage(
      "No fines found for this car",
    ),
    "no_fines_short": MessageLookupByLibrary.simpleMessage("No fines"),
    "no_name": MessageLookupByLibrary.simpleMessage("No name"),
    "no_nearby_charger": MessageLookupByLibrary.simpleMessage(
      "No data on the nearest charger",
    ),
    "no_nearby_station": MessageLookupByLibrary.simpleMessage(
      "No data on the nearest gas station",
    ),
    "no_records": MessageLookupByLibrary.simpleMessage("No records"),
    "no_reminders": MessageLookupByLibrary.simpleMessage("No active reminders"),
    "no_reminders_body": MessageLookupByLibrary.simpleMessage(
      "Add a reminder for service, insurance or inspection so nothing slips by",
    ),
    "no_schedule": MessageLookupByLibrary.simpleMessage("No schedule yet"),
    "no_story": MessageLookupByLibrary.simpleMessage("No story yet"),
    "no_such_service": MessageLookupByLibrary.simpleMessage("No_such_service"),
    "no_tasks": MessageLookupByLibrary.simpleMessage("No tasks"),
    "no_tokens_yet": MessageLookupByLibrary.simpleMessage("No tokens yet"),
    "no_transactions_subtitle": MessageLookupByLibrary.simpleMessage(
      "Add your first fuel, service, or other expense above — and stats will show up here",
    ),
    "no_transactions_title": MessageLookupByLibrary.simpleMessage(
      "No expenses yet",
    ),
    "not_auth": MessageLookupByLibrary.simpleMessage("Not authorized"),
    "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
    "of_course": MessageLookupByLibrary.simpleMessage("Of course"),
    "oil": MessageLookupByLibrary.simpleMessage("oil"),
    "oil_icon": MessageLookupByLibrary.simpleMessage("Oil"),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "onboarding_demo_expenses_title": MessageLookupByLibrary.simpleMessage(
      "Expenses · September",
    ),
    "onboarding_demo_fine_parking": MessageLookupByLibrary.simpleMessage(
      "Parking",
    ),
    "onboarding_demo_fine_speeding": MessageLookupByLibrary.simpleMessage(
      "Speeding",
    ),
    "onboarding_demo_inspection": MessageLookupByLibrary.simpleMessage(
      "Inspection · Oct 18",
    ),
    "onboarding_demo_policy_number": MessageLookupByLibrary.simpleMessage(
      "No. ER-213456789",
    ),
    "onboarding_demo_policy_valid_until": MessageLookupByLibrary.simpleMessage(
      "until 03/12/2027",
    ),
    "open_driver_page": MessageLookupByLibrary.simpleMessage(
      "Go to DriverTop page",
    ),
    "open_google_play": MessageLookupByLibrary.simpleMessage(
      "Open Google Play",
    ),
    "open_site": MessageLookupByLibrary.simpleMessage("Open e-Drive"),
    "open_statistics": MessageLookupByLibrary.simpleMessage("Open statistics"),
    "or_sign_in_using": MessageLookupByLibrary.simpleMessage(
      "Or sign in using",
    ),
    "other": MessageLookupByLibrary.simpleMessage("Other"),
    "other_services": MessageLookupByLibrary.simpleMessage("Other services"),
    "paid": MessageLookupByLibrary.simpleMessage("Paid"),
    "paid_fines_section": MessageLookupByLibrary.simpleMessage("Paid"),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "pay": MessageLookupByLibrary.simpleMessage("Pay"),
    "pay_safe": MessageLookupByLibrary.simpleMessage("Safe and secure payment"),
    "pdf": MessageLookupByLibrary.simpleMessage("PDF"),
    "per_day_suffix": MessageLookupByLibrary.simpleMessage("/ day"),
    "per_month_suffix": MessageLookupByLibrary.simpleMessage("/ month"),
    "period_3_months": MessageLookupByLibrary.simpleMessage("3 months"),
    "period_year": MessageLookupByLibrary.simpleMessage("year"),
    "periodicity": MessageLookupByLibrary.simpleMessage("Periodicity:"),
    "planned_service_lead_reminder_body": m11,
    "planned_service_reminder_body": MessageLookupByLibrary.simpleMessage(
      "Planned service is due. Add the cost once it\'s done.",
    ),
    "planned_services": MessageLookupByLibrary.simpleMessage("Planned works"),
    "please_log_in": MessageLookupByLibrary.simpleMessage(
      "Please leave or register to continue.",
    ),
    "please_update": MessageLookupByLibrary.simpleMessage(
      "Please update the application to continue using it.",
    ),
    "policy_number": MessageLookupByLibrary.simpleMessage("Policy number"),
    "previous": MessageLookupByLibrary.simpleMessage("Previous"),
    "price": MessageLookupByLibrary.simpleMessage("Price"),
    "price_per_kwh_short": MessageLookupByLibrary.simpleMessage("Price/kWh"),
    "price_per_liter_short": MessageLookupByLibrary.simpleMessage("Price/L"),
    "privacy_policy": MessageLookupByLibrary.simpleMessage("Privacy Policy"),
    "purchase_not_available": MessageLookupByLibrary.simpleMessage(
      "Purchase not available",
    ),
    "quarterly_plan": MessageLookupByLibrary.simpleMessage("Quarterly Plan"),
    "recent_transactions": MessageLookupByLibrary.simpleMessage(
      "Recent transactions",
    ),
    "record": MessageLookupByLibrary.simpleMessage("Record"),
    "reg_number": MessageLookupByLibrary.simpleMessage(
      "Technical passport number (optional)",
    ),
    "register": MessageLookupByLibrary.simpleMessage("Register"),
    "registration": MessageLookupByLibrary.simpleMessage("Registration"),
    "reminder": MessageLookupByLibrary.simpleMessage("Reminder"),
    "reminder_approx_days": m12,
    "reminder_approx_weeks": m13,
    "reminder_insurance_expires": MessageLookupByLibrary.simpleMessage(
      "Insurance expires",
    ),
    "reminder_notifications": MessageLookupByLibrary.simpleMessage(
      "Reminder notifications",
    ),
    "reminder_oil_due": MessageLookupByLibrary.simpleMessage(
      "Time to change the oil",
    ),
    "reminder_oil_in_km": m14,
    "reminder_overdue": MessageLookupByLibrary.simpleMessage("Overdue"),
    "reminder_soon": MessageLookupByLibrary.simpleMessage("Soon"),
    "remove": MessageLookupByLibrary.simpleMessage("Remove"),
    "repair": MessageLookupByLibrary.simpleMessage("Repair"),
    "repair_icon": MessageLookupByLibrary.simpleMessage("Repair"),
    "request_error": MessageLookupByLibrary.simpleMessage("Request error"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "schedule": MessageLookupByLibrary.simpleMessage("Schedule"),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "select_a_service": MessageLookupByLibrary.simpleMessage(
      "Select a service",
    ),
    "select_date": MessageLookupByLibrary.simpleMessage("Select date"),
    "select_service": MessageLookupByLibrary.simpleMessage(
      "Select a date and at least one service",
    ),
    "selected": MessageLookupByLibrary.simpleMessage("Selected"),
    "selected_car_wash": MessageLookupByLibrary.simpleMessage(
      "Selected car wash",
    ),
    "selected_gas_station": MessageLookupByLibrary.simpleMessage(
      "Selected gas station",
    ),
    "selected_service_station": MessageLookupByLibrary.simpleMessage(
      "Selected service station",
    ),
    "service": MessageLookupByLibrary.simpleMessage("Service"),
    "service_add_work": MessageLookupByLibrary.simpleMessage("Add work"),
    "service_amortyzatory_perednia_os_zamina":
        MessageLookupByLibrary.simpleMessage(
          "Shock absorbers suspension (front axle) - replacement",
        ),
    "service_amortyzatory_zadnia_os_zamina":
        MessageLookupByLibrary.simpleMessage(
          "Suspension shock absorbers (rear axle) - replacement",
        ),
    "service_balansuvannya_kolis": MessageLookupByLibrary.simpleMessage(
      "Wheel balancing",
    ),
    "service_best_rating_distance": m15,
    "service_capitalnyy_remont_dvyhuna": MessageLookupByLibrary.simpleMessage(
      "Overhaul of the engine",
    ),
    "service_chystka_droselnoyi_zaslinky": MessageLookupByLibrary.simpleMessage(
      "Cleaning of throttle valve",
    ),
    "service_chystka_forsunok": MessageLookupByLibrary.simpleMessage(
      "Injector cleaning",
    ),
    "service_chystka_radiatoriv": MessageLookupByLibrary.simpleMessage(
      "Cleaning of cooling and air conditioning radiators",
    ),
    "service_chystka_siden_avto": MessageLookupByLibrary.simpleMessage(
      "Car seat cleaning",
    ),
    "service_completed_work": MessageLookupByLibrary.simpleMessage(
      "Completed work",
    ),
    "service_diagnostyka_i_remont_ebu": MessageLookupByLibrary.simpleMessage(
      "Diagnostics and repair of ECU units engine",
    ),
    "service_diagnostyka_pidvisky": MessageLookupByLibrary.simpleMessage(
      "Suspension diagnostics",
    ),
    "service_diagnostyka_remont_dvs": MessageLookupByLibrary.simpleMessage(
      "Diagnostics and repair of internal combustion engines",
    ),
    "service_diagnostyka_remont_palivnykh_forsunok":
        MessageLookupByLibrary.simpleMessage(
          "Diagnostics and repair of fuel injectors",
        ),
    "service_diagnostyka_remont_tnvd": MessageLookupByLibrary.simpleMessage(
      "Diagnostics and repair of fuel injection pumps",
    ),
    "service_diagnostyka_zamina_zcheplennya":
        MessageLookupByLibrary.simpleMessage(
          "Clutch diagnostics and replacement",
        ),
    "service_dvs_capitalnyy_remont": MessageLookupByLibrary.simpleMessage(
      "Internal combustion engine - major overhaul",
    ),
    "service_dvs_diagnostika": MessageLookupByLibrary.simpleMessage(
      "Internal combustion engine - diagnostics (inspection, compression measurement)",
    ),
    "service_dvs_znyattya_ustanovka": MessageLookupByLibrary.simpleMessage(
      "Internal combustion engine - removal/installation (replacement)",
    ),
    "service_golovnyy_cylyndr_zcheplennya_zamina":
        MessageLookupByLibrary.simpleMessage(
          "Clutch master cylinder - replacement",
        ),
    "service_invalid_price": MessageLookupByLibrary.simpleMessage(
      "Enter a valid price for each job",
    ),
    "service_inzhektor_chystka": MessageLookupByLibrary.simpleMessage(
      "Injector - cleaning (excluding special fluids)",
    ),
    "service_kardannyy_val_zamina": MessageLookupByLibrary.simpleMessage(
      "Cardan shaft - replacement",
    ),
    "service_khimchystka_salonu": MessageLookupByLibrary.simpleMessage(
      "Dry cleaning of the interior",
    ),
    "service_khodova_chastyna_diagnostyka":
        MessageLookupByLibrary.simpleMessage("Chassis - diagnostics"),
    "service_kompleksna_diagnostyka": MessageLookupByLibrary.simpleMessage(
      "Comprehensive diagnostics (excluding computer diagnostics)",
    ),
    "service_kompleksna_diagnostyka_full": MessageLookupByLibrary.simpleMessage(
      "Comprehensive diagnostics",
    ),
    "service_kompyuterna_diagnostyka": MessageLookupByLibrary.simpleMessage(
      "Computer diagnostics",
    ),
    "service_kpp_remont": MessageLookupByLibrary.simpleMessage(
      "Gearbox - repair",
    ),
    "service_kpp_zamina": MessageLookupByLibrary.simpleMessage(
      "Gearbox - replacement",
    ),
    "service_krestovyna_kard_valu_zamina": MessageLookupByLibrary.simpleMessage(
      "Cardan shaft cross - replacement",
    ),
    "service_load_failed": MessageLookupByLibrary.simpleMessage(
      "Could not load service stations",
    ),
    "service_location_unavailable": MessageLookupByLibrary.simpleMessage(
      "Allow location access to find nearby service stations",
    ),
    "service_maslo_transmisiine_zamina": MessageLookupByLibrary.simpleMessage(
      "Transmission oil (axle/gearbox/transfer case) - replacement",
    ),
    "service_nakonechnik_rulovoyi_tyahy_zamina":
        MessageLookupByLibrary.simpleMessage(
          "Steering tie rod end - replacement",
        ),
    "service_no_nearby": MessageLookupByLibrary.simpleMessage(
      "No nearby service stations found",
    ),
    "service_no_rating": MessageLookupByLibrary.simpleMessage("No rating"),
    "service_oliya_akpp_chastkova": MessageLookupByLibrary.simpleMessage(
      "Automatic transmission oil - partial replacement (drain/fill), including automatic transmission filter replacement",
    ),
    "service_oliya_akpp_zamna_povna_bez_filtra":
        MessageLookupByLibrary.simpleMessage(
          "Automatic transmission oil - complete replacement (hardware) without automatic transmission filter replacement",
        ),
    "service_oliya_akpp_zamna_povna_z_filtra": MessageLookupByLibrary.simpleMessage(
      "Automatic transmission oil - complete replacement (hardware), including automatic transmission filter replacement",
    ),
    "service_oliya_mkpp_zamina": MessageLookupByLibrary.simpleMessage(
      "Manual transmission oil - replacement",
    ),
    "service_palivna_systema_diagnostyka": MessageLookupByLibrary.simpleMessage(
      "Fuel system - diagnostics (pressure measurement)",
    ),
    "service_pereprodazhne_polirovannya_kuzova":
        MessageLookupByLibrary.simpleMessage("Resale body polishing"),
    "service_pidshipnyk_matochyny_kolesa_zamina":
        MessageLookupByLibrary.simpleMessage("Wheel hub bearing - replacement"),
    "service_pokryttya_keramikoyu": MessageLookupByLibrary.simpleMessage(
      "Ceramic coating",
    ),
    "service_polirovka_far": MessageLookupByLibrary.simpleMessage(
      "Headlight polishing",
    ),
    "service_polirovka_kuzova": MessageLookupByLibrary.simpleMessage(
      "Body polishing",
    ),
    "service_predprodazhna_khimchystka_salonu":
        MessageLookupByLibrary.simpleMessage(
          "Pre-sale dry cleaning of the interior",
        ),
    "service_profesijnyy_remont_grm": MessageLookupByLibrary.simpleMessage(
      "Professional timing repair",
    ),
    "service_profilaktyka_halmyvnykh_mekhanizmiv":
        MessageLookupByLibrary.simpleMessage("Brake mechanism prevention"),
    "service_prokladka_gbc": MessageLookupByLibrary.simpleMessage(
      "Cylinder head gasket - replacement",
    ),
    "service_prokladka_klapannoyi_krishki":
        MessageLookupByLibrary.simpleMessage(
          "Valve cover gasket - replacement",
        ),
    "service_prokladka_poddonu_kartera": MessageLookupByLibrary.simpleMessage(
      "Crankcase pan gasket - replacement",
    ),
    "service_promyvka_inzhektora": MessageLookupByLibrary.simpleMessage(
      "Injector flushing",
    ),
    "service_promyvka_palivnoyi_systemy": MessageLookupByLibrary.simpleMessage(
      "Fuel system flushing",
    ),
    "service_promyvka_palivnoyi_systemy_dizel":
        MessageLookupByLibrary.simpleMessage(
          "Fuel system flushing of diesel cars",
        ),
    "service_pryvodnyy_val_zamina": MessageLookupByLibrary.simpleMessage(
      "Drive shaft - replacement",
    ),
    "service_pylovik_shrus_vnutrishniy_zamina":
        MessageLookupByLibrary.simpleMessage(
          "CV joint boot (internal) - replacement",
        ),
    "service_pylovik_shrus_zovnishniy_zamina":
        MessageLookupByLibrary.simpleMessage(
          "CV joint boot (external) - replacement",
        ),
    "service_remin_pryvodnyy": MessageLookupByLibrary.simpleMessage(
      "Drive belt - replacement",
    ),
    "service_remkomplekt_grm": MessageLookupByLibrary.simpleMessage(
      "Timing repair kit - replacement",
    ),
    "service_remont_elektroprovodky": MessageLookupByLibrary.simpleMessage(
      "Repair of electrical wiring and electrical equipment",
    ),
    "service_remont_generatoriv": MessageLookupByLibrary.simpleMessage(
      "Repair of generators",
    ),
    "service_remont_holovky_bloku_cylindriv_dvyhuna":
        MessageLookupByLibrary.simpleMessage("Engine cylinder head repair"),
    "service_remont_klapiv_dvyhuna": MessageLookupByLibrary.simpleMessage(
      "Engine valve repair",
    ),
    "service_remont_maslyanogo_nasosa": MessageLookupByLibrary.simpleMessage(
      "Oil pump repair",
    ),
    "service_remont_pnevmopidvisky": MessageLookupByLibrary.simpleMessage(
      "Repair of air suspension",
    ),
    "service_remont_porshniv_dvyhuna": MessageLookupByLibrary.simpleMessage(
      "Engine piston repair",
    ),
    "service_remont_radiatoriv": MessageLookupByLibrary.simpleMessage(
      "Radiator repair",
    ),
    "service_remont_rulovykh_reyok": MessageLookupByLibrary.simpleMessage(
      "Steering rack repair",
    ),
    "service_remont_starteriv": MessageLookupByLibrary.simpleMessage(
      "Repair of starters",
    ),
    "service_remont_suporiv": MessageLookupByLibrary.simpleMessage(
      "Repair of brake supors mouths",
    ),
    "service_remont_turbokompressoriv": MessageLookupByLibrary.simpleMessage(
      "Repair of turbocompressors",
    ),
    "service_remont_vazheliv_pidvisky": MessageLookupByLibrary.simpleMessage(
      "Repair of suspension arms",
    ),
    "service_remont_zamina_aktuatora_zcheplennya":
        MessageLookupByLibrary.simpleMessage(
          "Clutch actuator repair / replacement",
        ),
    "service_remont_zaminy_mahovyka_dvyhuna":
        MessageLookupByLibrary.simpleMessage(
          "Engine flywheel repair (replacement)",
        ),
    "service_remont_zaminy_opor_dvyhuna": MessageLookupByLibrary.simpleMessage(
      "Engine mount repair (replacement)",
    ),
    "service_retry": MessageLookupByLibrary.simpleMessage("Try again"),
    "service_robochyy_cylyndr_zcheplennya_zamina":
        MessageLookupByLibrary.simpleMessage(
          "Clutch slave cylinder - replacement",
        ),
    "service_rolik_pryvodnoho_remenya": MessageLookupByLibrary.simpleMessage(
      "Drive belt roller - replacement",
    ),
    "service_rulova_reyka_remont": MessageLookupByLibrary.simpleMessage(
      "Steering rack - repair",
    ),
    "service_rulova_tyaha_zamina": MessageLookupByLibrary.simpleMessage(
      "Steering tie rod - replacement",
    ),
    "service_sharova_opora_zamina": MessageLookupByLibrary.simpleMessage(
      "Ball bearing - replacement",
    ),
    "service_shrus_pryvodnoho_valu_zamina":
        MessageLookupByLibrary.simpleMessage(
          "CV joint drive shaft - replacement",
        ),
    "service_silentblok_vazhelya_pidvisky_zamina":
        MessageLookupByLibrary.simpleMessage(
          "Suspension lever silent block - replacement (with lever removed)",
        ),
    "service_skhid_rozval": MessageLookupByLibrary.simpleMessage("Disassembly"),
    "service_station": MessageLookupByLibrary.simpleMessage("Service station"),
    "service_station_nearby": MessageLookupByLibrary.simpleMessage(
      "Service station nearby",
    ),
    "service_stiikyi_stabilizatora_zamina":
        MessageLookupByLibrary.simpleMessage("Stabilizer struts - replacement"),
    "service_stupytsia_kolesa_zamina": MessageLookupByLibrary.simpleMessage(
      "Wheel hub - replacement",
    ),
    "service_systema_kondytsionuvannya": MessageLookupByLibrary.simpleMessage(
      "Air conditioning system - diagnostics and refueling",
    ),
    "service_vazhel_pidvisky_zamina": MessageLookupByLibrary.simpleMessage(
      "Suspension lever - replacement",
    ),
    "service_vidalennya_dribnykh_podryapin":
        MessageLookupByLibrary.simpleMessage("Removal of small scratches"),
    "service_vidalennya_katalizatora": MessageLookupByLibrary.simpleMessage(
      "Removing the catalyst",
    ),
    "service_vstanovlennya_ksenonu": MessageLookupByLibrary.simpleMessage(
      "Installation of xenon",
    ),
    "service_vtulky_stabilizatora_zamina": MessageLookupByLibrary.simpleMessage(
      "Stabilizer bushings - replacement",
    ),
    "service_zamina_akumulyatora": MessageLookupByLibrary.simpleMessage(
      "Battery replacement",
    ),
    "service_zamina_amortyzatoriv": MessageLookupByLibrary.simpleMessage(
      "Replacement of shock absorbers",
    ),
    "service_zamina_antifryzu": MessageLookupByLibrary.simpleMessage(
      "Antifreeze replacement",
    ),
    "service_zamina_benzonasosa": MessageLookupByLibrary.simpleMessage(
      "Fuel pump replacement",
    ),
    "service_zamina_dvyhuna": MessageLookupByLibrary.simpleMessage(
      "Replacing the engine",
    ),
    "service_zamina_dyska_zcheplennya": MessageLookupByLibrary.simpleMessage(
      "Clutch disc replacement",
    ),
    "service_zamina_glushnyka": MessageLookupByLibrary.simpleMessage(
      "Muffler replacement",
    ),
    "service_zamina_golovnogo_cylyndra_zcheplennya":
        MessageLookupByLibrary.simpleMessage(
          "Clutch master cylinder replacement",
        ),
    "service_zamina_halmykh_shlang": MessageLookupByLibrary.simpleMessage(
      "Replacement of brake hoses",
    ),
    "service_zamina_halmyvnoyi_ridyny": MessageLookupByLibrary.simpleMessage(
      "Replacement of brake fluid",
    ),
    "service_zamina_halmyvnykh_dyskiv": MessageLookupByLibrary.simpleMessage(
      "Replacement of brake discs",
    ),
    "service_zamina_halmyvnykh_kolodok": MessageLookupByLibrary.simpleMessage(
      "Replacement of brake pads",
    ),
    "service_zamina_hofry_pryymalnoyi_truby":
        MessageLookupByLibrary.simpleMessage(
          "Replacing the intake pipe corrugation",
        ),
    "service_zamina_kard_valu": MessageLookupByLibrary.simpleMessage(
      "Cardan shaft replacement",
    ),
    "service_zamina_katalizatora": MessageLookupByLibrary.simpleMessage(
      "Replacing the catalyst",
    ),
    "service_zamina_kisnevogo_datchyka": MessageLookupByLibrary.simpleMessage(
      "Replacement of oxygen sensor (lambda probe)",
    ),
    "service_zamina_kisnevogo_datchyka_lambda":
        MessageLookupByLibrary.simpleMessage(
          "Replacing the oxygen sensor (lambda probe)",
        ),
    "service_zamina_kotushok_modulya_zapal":
        MessageLookupByLibrary.simpleMessage(
          "Car ignition coil/module replacement",
        ),
    "service_zamina_krestovyny_kard_valu": MessageLookupByLibrary.simpleMessage(
      "Cardan shaft crosspiece replacement",
    ),
    "service_zamina_krestovyny_rulovogo_valu":
        MessageLookupByLibrary.simpleMessage(
          "Replacement of steering shaft cross",
        ),
    "service_zamina_kulovykh_opor": MessageLookupByLibrary.simpleMessage(
      "Replacement of ball support",
    ),
    "service_zamina_lamp_protifumannykh_far":
        MessageLookupByLibrary.simpleMessage("Replacement of fog lamp bulbs"),
    "service_zamina_nakonechnikiv_rulovykh_tyag":
        MessageLookupByLibrary.simpleMessage("Replacement of tie rod ends"),
    "service_zamina_oil_dvs": MessageLookupByLibrary.simpleMessage(
      "Replacement of engine oil",
    ),
    "service_zamina_oil_variator": MessageLookupByLibrary.simpleMessage(
      "Changing oil in variators",
    ),
    "service_zamina_oliynoho_filtra": MessageLookupByLibrary.simpleMessage(
      "Oil filter replacement",
    ),
    "service_zamina_opornoho_pidshipnyka_amortyzatora":
        MessageLookupByLibrary.simpleMessage(
          "Replacement of shock absorber support bearing",
        ),
    "service_zamina_palivnogo_filtra": MessageLookupByLibrary.simpleMessage(
      "Fuel filter replacement",
    ),
    "service_zamina_perednikh_amortyzatoriv":
        MessageLookupByLibrary.simpleMessage(
          "Replacement of front shock absorbers",
        ),
    "service_zamina_pidshipnykiv_matochok":
        MessageLookupByLibrary.simpleMessage("Replacement of support bearings"),
    "service_zamina_pompy": MessageLookupByLibrary.simpleMessage(
      "Pump replacement",
    ),
    "service_zamina_povitryanogo_filtra_dvs":
        MessageLookupByLibrary.simpleMessage(
          "Replacement of engine air filter",
        ),
    "service_zamina_probky_piddonu": MessageLookupByLibrary.simpleMessage(
      "Drain plug replacement",
    ),
    "service_zamina_prokladky_gbc": MessageLookupByLibrary.simpleMessage(
      "Replacement of cylinder head gasket",
    ),
    "service_zamina_prokladky_glushnyka": MessageLookupByLibrary.simpleMessage(
      "Replacing the muffler gasket",
    ),
    "service_zamina_prokladky_klapannoyi_krishky":
        MessageLookupByLibrary.simpleMessage(
          "Replacement of valve cover gasket",
        ),
    "service_zamina_prokladky_poddonu_kartera":
        MessageLookupByLibrary.simpleMessage(
          "Replacement of crankcase pan gasket",
        ),
    "service_zamina_pruzhin_amortyzatoriv":
        MessageLookupByLibrary.simpleMessage(
          "Replacement of shock absorber springs",
        ),
    "service_zamina_pryvodnykh_remeniv": MessageLookupByLibrary.simpleMessage(
      "Replacing drive belts",
    ),
    "service_zamina_pryvodnykh_valiv": MessageLookupByLibrary.simpleMessage(
      "Drive shaft replacement",
    ),
    "service_zamina_pylnyka_zadnogo_amortyzatora":
        MessageLookupByLibrary.simpleMessage(
          "Replacement of rear shock absorber boot",
        ),
    "service_zamina_radiatora": MessageLookupByLibrary.simpleMessage(
      "Radiator replacement",
    ),
    "service_zamina_remenya_grm": MessageLookupByLibrary.simpleMessage(
      "Replacing the timing belt",
    ),
    "service_zamina_ridyny_zcheplennya": MessageLookupByLibrary.simpleMessage(
      "Clutch fluid replacement",
    ),
    "service_zamina_rolika_natyaguvacha_remenya":
        MessageLookupByLibrary.simpleMessage(
          "Replacing the drive belt tensioner roller",
        ),
    "service_zamina_rulovykh_tyag": MessageLookupByLibrary.simpleMessage(
      "Replacement of tie rod ends",
    ),
    "service_zamina_salnyka_kolenvala": MessageLookupByLibrary.simpleMessage(
      "Crankshaft oil seal replacement",
    ),
    "service_zamina_salnyka_rozpodilnogo_valu":
        MessageLookupByLibrary.simpleMessage("Replacing the camshaft oil seal"),
    "service_zamina_salonnoho_filtra": MessageLookupByLibrary.simpleMessage(
      "Replacement of cabin filter",
    ),
    "service_zamina_shrus": MessageLookupByLibrary.simpleMessage(
      "ShRUS replacement",
    ),
    "service_zamina_shyn": MessageLookupByLibrary.simpleMessage(
      "Tire replacement",
    ),
    "service_zamina_silentblokiv_pidvisky":
        MessageLookupByLibrary.simpleMessage(
          "Replacement of suspension silent blocks",
        ),
    "service_zamina_stiikiv_stabilizatora":
        MessageLookupByLibrary.simpleMessage(
          "Replacement of stabilizer struts",
        ),
    "service_zamina_svichok_rozzharjuvannya":
        MessageLookupByLibrary.simpleMessage("Replacing glow plugs"),
    "service_zamina_svichok_zapal": MessageLookupByLibrary.simpleMessage(
      "Spark plug replacement",
    ),
    "service_zamina_termostata": MessageLookupByLibrary.simpleMessage(
      "Thermostat replacement",
    ),
    "service_zamina_transmisiynykh_ridin": MessageLookupByLibrary.simpleMessage(
      "Transmission fluid replacement (axle/gearbox/transfer case)",
    ),
    "service_zamina_trosa_zcheplennya": MessageLookupByLibrary.simpleMessage(
      "Clutch cable replacement",
    ),
    "service_zamina_truby_glushnyka": MessageLookupByLibrary.simpleMessage(
      "Replacing the muffler pipe",
    ),
    "service_zamina_vidbijnyka_amortyzatora":
        MessageLookupByLibrary.simpleMessage(
          "Replacement of shock absorber bumper",
        ),
    "service_zamina_vilky_zcheplennya": MessageLookupByLibrary.simpleMessage(
      "Clutch fork replacement",
    ),
    "service_zamina_vtulok_stabilizatora": MessageLookupByLibrary.simpleMessage(
      "Replacement of stabilizer bushings",
    ),
    "service_zamina_vykhlopnoyi_systemy": MessageLookupByLibrary.simpleMessage(
      "Exhaust system replacement (assembly)",
    ),
    "service_zamina_vysokovolt_provodiv": MessageLookupByLibrary.simpleMessage(
      "Replacement high-voltage wires",
    ),
    "service_zamina_zadnikh_amortyzatoriv":
        MessageLookupByLibrary.simpleMessage(
          "Replacement of rear shock absorbers",
        ),
    "service_zamina_zcheplennya_akpp": MessageLookupByLibrary.simpleMessage(
      "Automatic transmission clutch replacement",
    ),
    "service_zcheplennya_zmina": MessageLookupByLibrary.simpleMessage(
      "Clutch (set) - replacement",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "statistics": MessageLookupByLibrary.simpleMessage("Statistics"),
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "store_unavailable": MessageLookupByLibrary.simpleMessage(
      "Store unavailable",
    ),
    "subscription": MessageLookupByLibrary.simpleMessage("Subscription"),
    "subscription_error": MessageLookupByLibrary.simpleMessage(
      "Subscription error",
    ),
    "subscription_subtitle": MessageLookupByLibrary.simpleMessage(
      "Full access to fines, maintenance and insurance tracking",
    ),
    "subscription_subtitle_no_fines": MessageLookupByLibrary.simpleMessage(
      "Full access to maintenance, insurance and expense tracking",
    ),
    "sum_short": MessageLookupByLibrary.simpleMessage("Amount"),
    "tank_volume_liters": MessageLookupByLibrary.simpleMessage(
      "Tank volume, L",
    ),
    "tech_service": MessageLookupByLibrary.simpleMessage(
      "Technical maintenance",
    ),
    "terms_of_use": MessageLookupByLibrary.simpleMessage("Terms of Use"),
    "tires": MessageLookupByLibrary.simpleMessage("tire"),
    "tires_icon": MessageLookupByLibrary.simpleMessage("Tires"),
    "title": MessageLookupByLibrary.simpleMessage("Title"),
    "today_at": MessageLookupByLibrary.simpleMessage("today at"),
    "tokens_already_present": MessageLookupByLibrary.simpleMessage(
      "Tokens already present",
    ),
    "tokens_extracted": MessageLookupByLibrary.simpleMessage(
      "Tokens extracted",
    ),
    "total": MessageLookupByLibrary.simpleMessage("Total"),
    "track_costs": MessageLookupByLibrary.simpleMessage(
      "Track costs, mileage and efficiency",
    ),
    "trial_disclosure_detailed": m16,
    "tuning": MessageLookupByLibrary.simpleMessage("Tuning"),
    "type": MessageLookupByLibrary.simpleMessage("Type"),
    "ukr": MessageLookupByLibrary.simpleMessage("Ukrainian"),
    "units": MessageLookupByLibrary.simpleMessage("Units"),
    "unpaid_fines_section": MessageLookupByLibrary.simpleMessage("Unpaid"),
    "update": MessageLookupByLibrary.simpleMessage("Update"),
    "usd": MessageLookupByLibrary.simpleMessage("USD"),
    "user_not_found": MessageLookupByLibrary.simpleMessage("User not found"),
    "valid_from": MessageLookupByLibrary.simpleMessage("Valid from"),
    "valid_to": MessageLookupByLibrary.simpleMessage("Valid to"),
    "vehicle_data": MessageLookupByLibrary.simpleMessage("Vehicle data"),
    "vehicle_data_credit": MessageLookupByLibrary.simpleMessage(
      "Vehicle data by VehiclesDB · CC BY 4.0",
    ),
    "vehicle_data_terms": MessageLookupByLibrary.simpleMessage(
      "Sources and terms of use",
    ),
    "vehicles_section": MessageLookupByLibrary.simpleMessage("Vehicles"),
    "view_licenses": MessageLookupByLibrary.simpleMessage("View licenses"),
    "volume_kwh_short": MessageLookupByLibrary.simpleMessage("Amount, kWh"),
    "volume_liters_short": MessageLookupByLibrary.simpleMessage("Volume, L"),
    "vs_previous_month": MessageLookupByLibrary.simpleMessage("vs last month"),
    "yearly_plan": MessageLookupByLibrary.simpleMessage("Yearly Plan"),
    "years": MessageLookupByLibrary.simpleMessage("Years"),
  };
}
