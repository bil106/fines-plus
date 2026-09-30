// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a es locale. All the
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
  String get localeName => 'es';

  static String m0(error) => "Error al iniciar sesión con Apple: ${error}";

  static String m1(distance, unit) =>
      "Mejor precio cerca · ${distance} ${unit}";

  static String m2(distance, unit) =>
      "Mejor calificado cerca · ${distance} ${unit}";

  static String m3(distance, unit) => "${distance} ${unit}";

  static String m4(amount) => "Multa de tránsito: ${amount}";

  static String m5(count) => "Multas nuevas encontradas: ${count}";

  static String m6(count) =>
      "${Intl.plural(count, one: '1 auto', other: '${count} autos')}";

  static String m7(date) => "OK hasta ${date}";

  static String m8(date) => "Tu seguro vence el ${date}. Es hora de renovarlo.";

  static String m9(task) => "Es hora de: ${task}";

  static String m10(rating) => "calificación: ${rating}";

  static String m11(days) => "Servicio planeado en ${days} días.";

  static String m12(count) => "Aprox. en ${count} días";

  static String m13(count) => "Aprox. en ${count} semanas";

  static String m14(km) => "Cambio de aceite en ${km} km";

  static String m15(distance, unit) =>
      "Mejor calificado cerca · ${distance} ${unit}";

  static String m16(price, period) =>
      "Prueba gratis de 7 días, después ${price} por ${period}. Cancela cuando quieras, al menos 24 horas antes de que termine la prueba, en los ajustes de Google Play. La suscripción se renueva automáticamente si no la cancelas.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about_app_section": MessageLookupByLibrary.simpleMessage("Acerca de"),
    "add_car": MessageLookupByLibrary.simpleMessage("Agregar auto"),
    "add_cars": MessageLookupByLibrary.simpleMessage("Agregar un auto"),
    "add_expense": MessageLookupByLibrary.simpleMessage("Agregar gasto"),
    "add_reminder_button": MessageLookupByLibrary.simpleMessage(
      "Agregar recordatorio",
    ),
    "addition_cars": MessageLookupByLibrary.simpleMessage("Agregar un auto"),
    "additional_options": MessageLookupByLibrary.simpleMessage(
      "Opciones adicionales",
    ),
    "address_not_specified": MessageLookupByLibrary.simpleMessage(
      "Dirección no especificada",
    ),
    "all_exp_hist_deleted": MessageLookupByLibrary.simpleMessage(
      "Se eliminó todo el historial de gastos",
    ),
    "already_have_account": MessageLookupByLibrary.simpleMessage(
      "¿Ya tienes cuenta? Inicia sesión",
    ),
    "already_planned": MessageLookupByLibrary.simpleMessage("ya planeado"),
    "amount": MessageLookupByLibrary.simpleMessage("Monto"),
    "amount_month": MessageLookupByLibrary.simpleMessage("Monto por mes"),
    "analitics": MessageLookupByLibrary.simpleMessage("Análisis"),
    "analytics": MessageLookupByLibrary.simpleMessage("Análisis"),
    "app_libraries": MessageLookupByLibrary.simpleMessage(
      "Bibliotecas de la app",
    ),
    "app_libraries_description": MessageLookupByLibrary.simpleMessage(
      "Esta app usa componentes de código abierto.",
    ),
    "app_version": MessageLookupByLibrary.simpleMessage("Versión"),
    "apple_login_error": m0,
    "apple_login_successful": MessageLookupByLibrary.simpleMessage(
      "Inicio de sesión con Apple exitoso",
    ),
    "attention": MessageLookupByLibrary.simpleMessage("Atención"),
    "auto": MessageLookupByLibrary.simpleMessage("Auto"),
    "average": MessageLookupByLibrary.simpleMessage("Promedio"),
    "battery": MessageLookupByLibrary.simpleMessage("Batería"),
    "battery_capacity_kwh": MessageLookupByLibrary.simpleMessage(
      "Capacidad de la batería, kWh",
    ),
    "best_price_nearby_distance": m1,
    "build_route": MessageLookupByLibrary.simpleMessage("Cómo llegar"),
    "buyer_report": MessageLookupByLibrary.simpleMessage(
      "Informe para el comprador",
    ),
    "by_date": MessageLookupByLibrary.simpleMessage("Por fecha"),
    "by_mileage": MessageLookupByLibrary.simpleMessage("Por kilometraje"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
    "cannot_be_undone": MessageLookupByLibrary.simpleMessage(
      "Esta acción no se puede deshacer.",
    ),
    "car_history": MessageLookupByLibrary.simpleMessage("Historial del auto"),
    "car_inspection": MessageLookupByLibrary.simpleMessage(
      "Recordatorios de inspección y servicio del auto",
    ),
    "car_number": MessageLookupByLibrary.simpleMessage("Placa del auto"),
    "car_wash": MessageLookupByLibrary.simpleMessage("Autolavado"),
    "car_wash_best_rating_distance": m2,
    "car_wash_load_failed": MessageLookupByLibrary.simpleMessage(
      "No se pudieron cargar los autolavados",
    ),
    "car_wash_location_unavailable": MessageLookupByLibrary.simpleMessage(
      "Permite el acceso a tu ubicación para encontrar autolavados cercanos",
    ),
    "car_wash_nearby": MessageLookupByLibrary.simpleMessage(
      "Autolavados cercanos",
    ),
    "car_wash_no_nearby": MessageLookupByLibrary.simpleMessage(
      "No se encontraron autolavados cercanos",
    ),
    "cars_deleted_success": MessageLookupByLibrary.simpleMessage(
      "Auto eliminado correctamente",
    ),
    "category": MessageLookupByLibrary.simpleMessage("Categorías"),
    "category_removed": MessageLookupByLibrary.simpleMessage(
      "Categoría eliminada",
    ),
    "charger_location_unavailable": MessageLookupByLibrary.simpleMessage(
      "Permite el acceso a tu ubicación para encontrar cargadores cercanos",
    ),
    "charging_nearby": MessageLookupByLibrary.simpleMessage(
      "Cargadores cercanos",
    ),
    "chart_period_12m": MessageLookupByLibrary.simpleMessage("12 meses"),
    "chart_period_6m": MessageLookupByLibrary.simpleMessage("6 meses"),
    "check_fines_reminder_body": MessageLookupByLibrary.simpleMessage(
      "Revisa si hay nuevas multas de tránsito",
    ),
    "check_fines_reminder_title": MessageLookupByLibrary.simpleMessage(
      "Recordatorio de multas",
    ),
    "click_again": MessageLookupByLibrary.simpleMessage(
      "Toca de nuevo para salir",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Cerrar"),
    "comment": MessageLookupByLibrary.simpleMessage("Comentario"),
    "configure_action": MessageLookupByLibrary.simpleMessage(
      "Configurar acción",
    ),
    "connection_error": MessageLookupByLibrary.simpleMessage(
      "Error de conexión",
    ),
    "coolant_icon": MessageLookupByLibrary.simpleMessage("Anticongelante"),
    "cost": MessageLookupByLibrary.simpleMessage("Costo"),
    "cost_statistics": MessageLookupByLibrary.simpleMessage(
      "Estadísticas de gastos",
    ),
    "costs_stat": MessageLookupByLibrary.simpleMessage(
      "Estadísticas de gastos",
    ),
    "create": MessageLookupByLibrary.simpleMessage("Crear"),
    "create_account": MessageLookupByLibrary.simpleMessage(
      "Se necesita una cuenta de Google Play para comprar. Inicia sesión o crea una cuenta e inténtalo de nuevo.",
    ),
    "csv": MessageLookupByLibrary.simpleMessage("CSV"),
    "currency": MessageLookupByLibrary.simpleMessage("Moneda"),
    "current_mileage": MessageLookupByLibrary.simpleMessage(
      "Kilometraje actual",
    ),
    "date": MessageLookupByLibrary.simpleMessage("Fecha"),
    "days": MessageLookupByLibrary.simpleMessage("días"),
    "days_interv": MessageLookupByLibrary.simpleMessage("Días"),
    "del_all_expenses": MessageLookupByLibrary.simpleMessage(
      "Eliminar TODOS los gastos",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Eliminar"),
    "delete_account": MessageLookupByLibrary.simpleMessage("Eliminar cuenta"),
    "delete_account_confirmation": MessageLookupByLibrary.simpleMessage(
      "Tu cuenta, vehículos, gastos, recordatorios y fotos se eliminarán de forma permanente. Esta acción no se puede deshacer.",
    ),
    "delete_account_failed": MessageLookupByLibrary.simpleMessage(
      "No se pudo eliminar tu cuenta. Revisa tu conexión e inténtalo de nuevo.",
    ),
    "delete_account_relogin": MessageLookupByLibrary.simpleMessage(
      "Por tu seguridad, vuelve a iniciar sesión y luego elimina tu cuenta.",
    ),
    "delete_all_expenses": MessageLookupByLibrary.simpleMessage(
      "¿Eliminar todos los gastos?",
    ),
    "delete_car_number": MessageLookupByLibrary.simpleMessage(
      "Eliminar placa del auto",
    ),
    "delete_cars_confirm": MessageLookupByLibrary.simpleMessage(
      "Confirma la eliminación del auto",
    ),
    "delete_expense_history": MessageLookupByLibrary.simpleMessage(
      "Eliminar historial de gastos",
    ),
    "description": MessageLookupByLibrary.simpleMessage("Descripción"),
    "distance_km_short": m3,
    "done": MessageLookupByLibrary.simpleMessage("Listo"),
    "dont_have_account": MessageLookupByLibrary.simpleMessage(
      "¿No tienes cuenta? Regístrate",
    ),
    "due_amount": MessageLookupByLibrary.simpleMessage("Por pagar"),
    "edit": MessageLookupByLibrary.simpleMessage("Editar"),
    "edit_reminder": MessageLookupByLibrary.simpleMessage(
      "Editar recordatorio",
    ),
    "email": MessageLookupByLibrary.simpleMessage("Correo electrónico"),
    "email_already_exists": MessageLookupByLibrary.simpleMessage(
      "Ya existe un usuario con este correo electrónico",
    ),
    "english": MessageLookupByLibrary.simpleMessage("Inglés"),
    "enter_amount": MessageLookupByLibrary.simpleMessage("Ingresa el monto"),
    "enter_correct_number_auto": MessageLookupByLibrary.simpleMessage(
      "Ingresa una placa válida",
    ),
    "enter_email": MessageLookupByLibrary.simpleMessage(
      "Ingresa tu correo electrónico",
    ),
    "enter_mileage": MessageLookupByLibrary.simpleMessage(
      "Ingresa el kilometraje",
    ),
    "enter_password": MessageLookupByLibrary.simpleMessage(
      "Ingresa tu contraseña",
    ),
    "error": MessageLookupByLibrary.simpleMessage("Error:"),
    "eur": MessageLookupByLibrary.simpleMessage("EUR"),
    "every": MessageLookupByLibrary.simpleMessage("Cada"),
    "expense_save_failed": MessageLookupByLibrary.simpleMessage(
      "No se pudo guardar el registro. Inténtalo de nuevo.",
    ),
    "export": MessageLookupByLibrary.simpleMessage("Exportar"),
    "export_history": MessageLookupByLibrary.simpleMessage(
      "Exportar historial",
    ),
    "facebook_error": MessageLookupByLibrary.simpleMessage(
      "Error de Facebook: AccessToken vacío",
    ),
    "facebook_login_cancelled": MessageLookupByLibrary.simpleMessage(
      "El usuario canceló el inicio de sesión con Facebook.",
    ),
    "facebook_login_error": MessageLookupByLibrary.simpleMessage(
      "Error al iniciar sesión con Facebook:",
    ),
    "facebook_login_successful": MessageLookupByLibrary.simpleMessage(
      "Inicio de sesión con Facebook exitoso",
    ),
    "fact": MessageLookupByLibrary.simpleMessage("Real"),
    "failed_extract_tokens": MessageLookupByLibrary.simpleMessage(
      "No se pudieron obtener los tokens",
    ),
    "fill_date": MessageLookupByLibrary.simpleMessage(
      "Completa la fecha, el kilometraje y la cantidad de combustible",
    ),
    "fine_checking_disabled": MessageLookupByLibrary.simpleMessage(
      "La consulta de multas está desactivada en los ajustes",
    ),
    "fine_pdr_title": m4,
    "fines": MessageLookupByLibrary.simpleMessage("Multas"),
    "fines_checked": MessageLookupByLibrary.simpleMessage("Revisado"),
    "fines_control": MessageLookupByLibrary.simpleMessage("Control de multas"),
    "fines_mvs_hint": MessageLookupByLibrary.simpleMessage(
      "Resuelve el captcha y toca “Перевірити”: las multas se agregarán a la app automáticamente.",
    ),
    "fines_mvs_title": MessageLookupByLibrary.simpleMessage(
      "Consulta de multas (MVS)",
    ),
    "fines_new_found": m5,
    "fines_no_new": MessageLookupByLibrary.simpleMessage(
      "No hay multas nuevas",
    ),
    "fines_not_found_body": MessageLookupByLibrary.simpleMessage(
      "Por ahora no hay multas activas para tu placa",
    ),
    "fines_not_found_title": MessageLookupByLibrary.simpleMessage(
      "No se encontraron multas",
    ),
    "fines_recheck_confirm": MessageLookupByLibrary.simpleMessage(
      "Revisar de nuevo",
    ),
    "fines_recheck_message": MessageLookupByLibrary.simpleMessage(
      "Las multas ya se revisaron hoy. Tendrás que resolver el captcha otra vez. ¿Revisar de todos modos?",
    ),
    "fines_recheck_title": MessageLookupByLibrary.simpleMessage(
      "Ya se revisó hoy",
    ),
    "fines_reminder_body": MessageLookupByLibrary.simpleMessage(
      "Es hora de revisar si hay nuevas multas de tránsito",
    ),
    "fines_reminder_title": MessageLookupByLibrary.simpleMessage(
      "Recordatorio de multas",
    ),
    "fines_violation": MessageLookupByLibrary.simpleMessage("Infracción"),
    "free_trial_7_days": MessageLookupByLibrary.simpleMessage(
      "Prueba gratis de 7 días",
    ),
    "fuel": MessageLookupByLibrary.simpleMessage("Combustible"),
    "fuel_ai92": MessageLookupByLibrary.simpleMessage("AI-92"),
    "fuel_ai95": MessageLookupByLibrary.simpleMessage("AI-95"),
    "fuel_ai95_plus": MessageLookupByLibrary.simpleMessage("AI-95+"),
    "fuel_ai98": MessageLookupByLibrary.simpleMessage("AI-98"),
    "fuel_chip_a92": MessageLookupByLibrary.simpleMessage("A92"),
    "fuel_chip_a95": MessageLookupByLibrary.simpleMessage("A95"),
    "fuel_chip_diesel": MessageLookupByLibrary.simpleMessage("Diésel"),
    "fuel_chip_gas": MessageLookupByLibrary.simpleMessage("Gas"),
    "fuel_consumption": MessageLookupByLibrary.simpleMessage(
      "Consumo de combustible",
    ),
    "fuel_electric": MessageLookupByLibrary.simpleMessage("Eléctrico"),
    "fuel_gas_lpg": MessageLookupByLibrary.simpleMessage("Gas LP"),
    "fuel_location_unavailable": MessageLookupByLibrary.simpleMessage(
      "Permite el acceso a tu ubicación para encontrar gasolineras cercanas",
    ),
    "fuel_magna": MessageLookupByLibrary.simpleMessage("Magna"),
    "fuel_midgrade": MessageLookupByLibrary.simpleMessage("Intermedia"),
    "fuel_premium": MessageLookupByLibrary.simpleMessage("Premium"),
    "fuel_prompt_body": MessageLookupByLibrary.simpleMessage(
      "¿Agregar los datos de la carga de combustible?",
    ),
    "fuel_prompt_title": MessageLookupByLibrary.simpleMessage(
      "Cargar combustible",
    ),
    "fuel_regular": MessageLookupByLibrary.simpleMessage("Regular"),
    "fuel_super": MessageLookupByLibrary.simpleMessage("Súper"),
    "fuel_type": MessageLookupByLibrary.simpleMessage("Tipo de combustible"),
    "fuel_up": MessageLookupByLibrary.simpleMessage("Cargar combustible"),
    "full_charge": MessageLookupByLibrary.simpleMessage("Carga completa"),
    "full_tank": MessageLookupByLibrary.simpleMessage("Tanque lleno"),
    "full_tank_hint": MessageLookupByLibrary.simpleMessage(
      "Necesario para calcular el consumo con precisión",
    ),
    "gal": MessageLookupByLibrary.simpleMessage("gal"),
    "garage_action_error": MessageLookupByLibrary.simpleMessage(
      "No se pudo completar la acción",
    ),
    "garage_cars_count": m6,
    "garage_continue": MessageLookupByLibrary.simpleMessage("Continuar"),
    "garage_delete_confirm_body": MessageLookupByLibrary.simpleMessage(
      "Todos los datos de este auto (gastos, recordatorios, mantenimiento) se eliminarán de forma permanente.",
    ),
    "garage_delete_confirm_title": MessageLookupByLibrary.simpleMessage(
      "¿Quitar este auto de tu garaje?",
    ),
    "garage_delete_error": MessageLookupByLibrary.simpleMessage(
      "No se pudo eliminar el auto",
    ),
    "garage_empty_add_car": MessageLookupByLibrary.simpleMessage(
      "Agrega tu auto",
    ),
    "garage_make_hint": MessageLookupByLibrary.simpleMessage(
      "Selecciona una marca",
    ),
    "garage_make_label": MessageLookupByLibrary.simpleMessage("Marca del auto"),
    "garage_model_hint": MessageLookupByLibrary.simpleMessage(
      "Selecciona un modelo",
    ),
    "garage_model_label": MessageLookupByLibrary.simpleMessage(
      "Modelo del auto (opcional)",
    ),
    "garage_setup_subtitle": MessageLookupByLibrary.simpleMessage(
      "Agrega tu auto ahora o hazlo más tarde: puedes empezar a usar la app de inmediato",
    ),
    "garage_status_insurance_expired": MessageLookupByLibrary.simpleMessage(
      "Seguro vencido",
    ),
    "garage_status_ok": MessageLookupByLibrary.simpleMessage("OK"),
    "garage_status_ok_until": m7,
    "gas_station_nearby": MessageLookupByLibrary.simpleMessage(
      "Gasolineras cercanas",
    ),
    "general_section": MessageLookupByLibrary.simpleMessage("General"),
    "get_notified": MessageLookupByLibrary.simpleMessage(
      "Recibe avisos y paga a tiempo",
    ),
    "get_plan": MessageLookupByLibrary.simpleMessage("Obtener mi plan"),
    "good": MessageLookupByLibrary.simpleMessage("Bien"),
    "google_login_error": MessageLookupByLibrary.simpleMessage(
      "Error al iniciar sesión con Google",
    ),
    "grn": MessageLookupByLibrary.simpleMessage("UAH"),
    "hint_auto_num": MessageLookupByLibrary.simpleMessage("AH0000HA"),
    "hint_auto_num_ar": MessageLookupByLibrary.simpleMessage("AB123CD"),
    "hint_auto_num_es": MessageLookupByLibrary.simpleMessage("1234BCD"),
    "hint_auto_num_mx": MessageLookupByLibrary.simpleMessage("ABC123A"),
    "hint_auto_num_us": MessageLookupByLibrary.simpleMessage("8ABC123"),
    "hint_tech_data_num": MessageLookupByLibrary.simpleMessage("XEE128436"),
    "history": MessageLookupByLibrary.simpleMessage("Historial"),
    "history_unavailable": MessageLookupByLibrary.simpleMessage(
      "El historial no está disponible por ahora: se está creando el índice. Inténtalo de nuevo en unos minutos.",
    ),
    "home": MessageLookupByLibrary.simpleMessage("Inicio"),
    "incorrect_email": MessageLookupByLibrary.simpleMessage(
      "Correo electrónico incorrecto",
    ),
    "incorrect_email_address": MessageLookupByLibrary.simpleMessage(
      "Dirección de correo electrónico incorrecta",
    ),
    "incorrect_password": MessageLookupByLibrary.simpleMessage(
      "Contraseña incorrecta",
    ),
    "input_number": MessageLookupByLibrary.simpleMessage(
      "Ingresa la placa de tu auto ->",
    ),
    "insurance": MessageLookupByLibrary.simpleMessage("Seguro"),
    "insurance_company": MessageLookupByLibrary.simpleMessage("Aseguradora"),
    "insurance_control": MessageLookupByLibrary.simpleMessage(
      "Control del seguro",
    ),
    "insurance_expiry_reminder_body": m8,
    "insurance_osago": MessageLookupByLibrary.simpleMessage(
      "Seguro de responsabilidad civil",
    ),
    "interval": MessageLookupByLibrary.simpleMessage("Intervalo (km)"),
    "interval_by_date": MessageLookupByLibrary.simpleMessage(
      "Intervalo por fecha",
    ),
    "keep_track": MessageLookupByLibrary.simpleMessage(
      "Lleva el control de los vencimientos del seguro",
    ),
    "km": MessageLookupByLibrary.simpleMessage("km"),
    "kwh": MessageLookupByLibrary.simpleMessage("kWh"),
    "l": MessageLookupByLibrary.simpleMessage("l."),
    "language": MessageLookupByLibrary.simpleMessage("Idioma"),
    "large_login": MessageLookupByLibrary.simpleMessage("INICIAR SESIÓN"),
    "large_sign_up": MessageLookupByLibrary.simpleMessage("REGISTRARSE"),
    "last_insurance_date": MessageLookupByLibrary.simpleMessage(
      "Fecha del último seguro",
    ),
    "last_service_date": MessageLookupByLibrary.simpleMessage(
      "Fecha del último servicio",
    ),
    "licenses_and_sources": MessageLookupByLibrary.simpleMessage(
      "Licencias y fuentes",
    ),
    "licenses_load_error": MessageLookupByLibrary.simpleMessage(
      "No se pudo cargar el texto de la licencia.",
    ),
    "loaded": MessageLookupByLibrary.simpleMessage("Cargado"),
    "location_not_determined": MessageLookupByLibrary.simpleMessage(
      "No se pudo determinar tu ubicación. Inténtalo de nuevo más tarde.",
    ),
    "location_open_settings": MessageLookupByLibrary.simpleMessage(
      "Abrir Ajustes",
    ),
    "location_settings_steps": MessageLookupByLibrary.simpleMessage(
      "En Ajustes, toca «Ubicación» y elige «Al usar la app».",
    ),
    "location_settings_title": MessageLookupByLibrary.simpleMessage(
      "Activa la ubicación",
    ),
    "log_out": MessageLookupByLibrary.simpleMessage("Cerrar sesión"),
    "log_out_confirmation": MessageLookupByLibrary.simpleMessage(
      "¿Seguro que quieres cerrar sesión?",
    ),
    "login": MessageLookupByLibrary.simpleMessage("Iniciar sesión"),
    "maintenance": MessageLookupByLibrary.simpleMessage("Mantenimiento"),
    "maintenance_control": MessageLookupByLibrary.simpleMessage(
      "Control del mantenimiento",
    ),
    "maintenance_due_body": m9,
    "maintenance_due_title": MessageLookupByLibrary.simpleMessage(
      "Mantenimiento pendiente",
    ),
    "map_rating": m10,
    "mi": MessageLookupByLibrary.simpleMessage("mi"),
    "mileage": MessageLookupByLibrary.simpleMessage("Kilometraje"),
    "mileage_statistics": MessageLookupByLibrary.simpleMessage(
      "Estadísticas de kilometraje",
    ),
    "min_char": MessageLookupByLibrary.simpleMessage("Mínimo 6 caracteres"),
    "money_back": MessageLookupByLibrary.simpleMessage(
      "¡Garantía de reembolso de 30 días!",
    ),
    "month": MessageLookupByLibrary.simpleMessage("Mes"),
    "month_apr": MessageLookupByLibrary.simpleMessage("Abril"),
    "month_aug": MessageLookupByLibrary.simpleMessage("Agosto"),
    "month_dec": MessageLookupByLibrary.simpleMessage("Diciembre"),
    "month_feb": MessageLookupByLibrary.simpleMessage("Febrero"),
    "month_jan": MessageLookupByLibrary.simpleMessage("Enero"),
    "month_jul": MessageLookupByLibrary.simpleMessage("Julio"),
    "month_jun": MessageLookupByLibrary.simpleMessage("Junio"),
    "month_mar": MessageLookupByLibrary.simpleMessage("Marzo"),
    "month_may": MessageLookupByLibrary.simpleMessage("Mayo"),
    "month_nov": MessageLookupByLibrary.simpleMessage("Noviembre"),
    "month_oct": MessageLookupByLibrary.simpleMessage("Octubre"),
    "month_sep": MessageLookupByLibrary.simpleMessage("Septiembre"),
    "monthly_expenses": MessageLookupByLibrary.simpleMessage("Gastos del mes"),
    "months": MessageLookupByLibrary.simpleMessage("Meses"),
    "most_popular": MessageLookupByLibrary.simpleMessage("MÁS POPULAR"),
    "my_garage": MessageLookupByLibrary.simpleMessage("Garaje"),
    "my_position": MessageLookupByLibrary.simpleMessage("Estás aquí"),
    "name": MessageLookupByLibrary.simpleMessage("Nombre"),
    "new_reminder": MessageLookupByLibrary.simpleMessage("Nueva notificación"),
    "new_version": MessageLookupByLibrary.simpleMessage(
      "Hay una nueva versión de la app disponible",
    ),
    "next": MessageLookupByLibrary.simpleMessage("Siguiente"),
    "no_car_selected": MessageLookupByLibrary.simpleMessage(
      "No hay auto seleccionado",
    ),
    "no_expenses": MessageLookupByLibrary.simpleMessage(
      "Aún no hay datos de gastos",
    ),
    "no_fines": MessageLookupByLibrary.simpleMessage(
      "No se encontraron multas para este auto",
    ),
    "no_fines_short": MessageLookupByLibrary.simpleMessage("Sin multas"),
    "no_name": MessageLookupByLibrary.simpleMessage("Sin nombre"),
    "no_nearby_charger": MessageLookupByLibrary.simpleMessage(
      "No hay datos del cargador más cercano",
    ),
    "no_nearby_station": MessageLookupByLibrary.simpleMessage(
      "No hay datos de la gasolinera más cercana",
    ),
    "no_records": MessageLookupByLibrary.simpleMessage("No hay registros"),
    "no_reminders": MessageLookupByLibrary.simpleMessage(
      "No hay recordatorios activos",
    ),
    "no_reminders_body": MessageLookupByLibrary.simpleMessage(
      "Agrega un recordatorio de servicio, seguro o inspección para que nada se te pase",
    ),
    "no_schedule": MessageLookupByLibrary.simpleMessage("Aún no hay agenda"),
    "no_story": MessageLookupByLibrary.simpleMessage("Aún no hay historial"),
    "no_such_service": MessageLookupByLibrary.simpleMessage(
      "No_existe_el_servicio",
    ),
    "no_tasks": MessageLookupByLibrary.simpleMessage("No hay tareas"),
    "no_tokens_yet": MessageLookupByLibrary.simpleMessage("Aún no hay tokens"),
    "no_transactions_subtitle": MessageLookupByLibrary.simpleMessage(
      "Agrega arriba tu primera carga de combustible, servicio u otro gasto, y aquí aparecerán las estadísticas",
    ),
    "no_transactions_title": MessageLookupByLibrary.simpleMessage(
      "Aún no hay gastos",
    ),
    "not_auth": MessageLookupByLibrary.simpleMessage("No has iniciado sesión"),
    "notifications": MessageLookupByLibrary.simpleMessage("Notificaciones"),
    "odometer_scan_failed": MessageLookupByLibrary.simpleMessage(
      "No se pudo leer el kilometraje. Ingrésalo manualmente.",
    ),
    "of_course": MessageLookupByLibrary.simpleMessage("Entendido"),
    "oil": MessageLookupByLibrary.simpleMessage("aceite"),
    "oil_icon": MessageLookupByLibrary.simpleMessage("Aceite"),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "onboarding_demo_expenses_title": MessageLookupByLibrary.simpleMessage(
      "Gastos · septiembre",
    ),
    "onboarding_demo_fine_parking": MessageLookupByLibrary.simpleMessage(
      "Estacionamiento",
    ),
    "onboarding_demo_fine_speeding": MessageLookupByLibrary.simpleMessage(
      "Exceso de velocidad",
    ),
    "onboarding_demo_inspection": MessageLookupByLibrary.simpleMessage(
      "Inspección · 18 oct",
    ),
    "onboarding_demo_policy_number": MessageLookupByLibrary.simpleMessage(
      "N.º ER-213456789",
    ),
    "onboarding_demo_policy_valid_until": MessageLookupByLibrary.simpleMessage(
      "hasta 03/12/2027",
    ),
    "open_driver_page": MessageLookupByLibrary.simpleMessage(
      "Ir a la página de DriverTop",
    ),
    "open_google_play": MessageLookupByLibrary.simpleMessage(
      "Abrir Google Play",
    ),
    "open_site": MessageLookupByLibrary.simpleMessage("Abrir e-Drive"),
    "open_statistics": MessageLookupByLibrary.simpleMessage("Ver estadísticas"),
    "or_sign_in_using": MessageLookupByLibrary.simpleMessage(
      "O inicia sesión con",
    ),
    "other": MessageLookupByLibrary.simpleMessage("Otro"),
    "other_services": MessageLookupByLibrary.simpleMessage("Otros servicios"),
    "paid": MessageLookupByLibrary.simpleMessage("Pagado"),
    "paid_fines_section": MessageLookupByLibrary.simpleMessage("Pagadas"),
    "password": MessageLookupByLibrary.simpleMessage("Contraseña"),
    "pay": MessageLookupByLibrary.simpleMessage("Pagar"),
    "pay_safe": MessageLookupByLibrary.simpleMessage("Pago seguro y protegido"),
    "pdf": MessageLookupByLibrary.simpleMessage("PDF"),
    "per_day_suffix": MessageLookupByLibrary.simpleMessage("/ día"),
    "per_month_suffix": MessageLookupByLibrary.simpleMessage("/ mes"),
    "period_3_months": MessageLookupByLibrary.simpleMessage("3 meses"),
    "period_year": MessageLookupByLibrary.simpleMessage("año"),
    "periodicity": MessageLookupByLibrary.simpleMessage("Periodicidad:"),
    "planned_service_lead_reminder_body": m11,
    "planned_service_reminder_body": MessageLookupByLibrary.simpleMessage(
      "Tienes un servicio planeado. Agrega el costo cuando esté hecho.",
    ),
    "planned_services": MessageLookupByLibrary.simpleMessage(
      "Trabajos planeados",
    ),
    "please_log_in": MessageLookupByLibrary.simpleMessage(
      "Inicia sesión o regístrate para continuar.",
    ),
    "please_update": MessageLookupByLibrary.simpleMessage(
      "Actualiza la app para seguir usándola.",
    ),
    "policy_number": MessageLookupByLibrary.simpleMessage("Número de póliza"),
    "previous": MessageLookupByLibrary.simpleMessage("Anterior"),
    "price": MessageLookupByLibrary.simpleMessage("Precio"),
    "price_per_gallon_short": MessageLookupByLibrary.simpleMessage(
      "Precio/gal",
    ),
    "price_per_kwh_short": MessageLookupByLibrary.simpleMessage("Precio/kWh"),
    "price_per_liter_short": MessageLookupByLibrary.simpleMessage("Precio/L"),
    "privacy_policy": MessageLookupByLibrary.simpleMessage(
      "Política de privacidad",
    ),
    "purchase_not_available": MessageLookupByLibrary.simpleMessage(
      "Compra no disponible",
    ),
    "quarterly_plan": MessageLookupByLibrary.simpleMessage("Plan trimestral"),
    "recent_transactions": MessageLookupByLibrary.simpleMessage(
      "Movimientos recientes",
    ),
    "record": MessageLookupByLibrary.simpleMessage("Registro"),
    "reg_number": MessageLookupByLibrary.simpleMessage(
      "Número de la tarjeta de circulación (opcional)",
    ),
    "register": MessageLookupByLibrary.simpleMessage("Registrarse"),
    "registration": MessageLookupByLibrary.simpleMessage("Registro"),
    "reminder": MessageLookupByLibrary.simpleMessage("Recordatorio"),
    "reminder_approx_days": m12,
    "reminder_approx_weeks": m13,
    "reminder_insurance_expires": MessageLookupByLibrary.simpleMessage(
      "El seguro vence",
    ),
    "reminder_notifications": MessageLookupByLibrary.simpleMessage(
      "Notificaciones de recordatorios",
    ),
    "reminder_oil_due": MessageLookupByLibrary.simpleMessage(
      "Es hora de cambiar el aceite",
    ),
    "reminder_oil_in_km": m14,
    "reminder_overdue": MessageLookupByLibrary.simpleMessage("Vencido"),
    "reminder_soon": MessageLookupByLibrary.simpleMessage("Pronto"),
    "remove": MessageLookupByLibrary.simpleMessage("Eliminar"),
    "repair": MessageLookupByLibrary.simpleMessage("Reparación"),
    "repair_icon": MessageLookupByLibrary.simpleMessage("Reparación"),
    "request_error": MessageLookupByLibrary.simpleMessage(
      "Error en la solicitud",
    ),
    "save": MessageLookupByLibrary.simpleMessage("Guardar"),
    "schedule": MessageLookupByLibrary.simpleMessage("Agenda"),
    "search": MessageLookupByLibrary.simpleMessage("Buscar"),
    "select_a_service": MessageLookupByLibrary.simpleMessage(
      "Selecciona un servicio",
    ),
    "select_date": MessageLookupByLibrary.simpleMessage("Selecciona la fecha"),
    "select_service": MessageLookupByLibrary.simpleMessage(
      "Selecciona una fecha y al menos un servicio",
    ),
    "selected": MessageLookupByLibrary.simpleMessage("Seleccionado"),
    "selected_car_wash": MessageLookupByLibrary.simpleMessage(
      "Autolavado seleccionado",
    ),
    "selected_gas_station": MessageLookupByLibrary.simpleMessage(
      "Gasolinera seleccionada",
    ),
    "selected_service_station": MessageLookupByLibrary.simpleMessage(
      "Taller seleccionado",
    ),
    "service": MessageLookupByLibrary.simpleMessage("Servicio"),
    "service_add_work": MessageLookupByLibrary.simpleMessage("Agregar trabajo"),
    "service_amortyzatory_perednia_os_zamina":
        MessageLookupByLibrary.simpleMessage(
          "Amortiguadores (eje delantero) - reemplazo",
        ),
    "service_amortyzatory_zadnia_os_zamina":
        MessageLookupByLibrary.simpleMessage(
          "Amortiguadores (eje trasero) - reemplazo",
        ),
    "service_balansuvannya_kolis": MessageLookupByLibrary.simpleMessage(
      "Balanceo de ruedas",
    ),
    "service_best_rating_distance": m15,
    "service_capitalnyy_remont_dvyhuna": MessageLookupByLibrary.simpleMessage(
      "Reparación mayor del motor",
    ),
    "service_chystka_droselnoyi_zaslinky": MessageLookupByLibrary.simpleMessage(
      "Limpieza del cuerpo de aceleración",
    ),
    "service_chystka_forsunok": MessageLookupByLibrary.simpleMessage(
      "Limpieza de inyectores",
    ),
    "service_chystka_radiatoriv": MessageLookupByLibrary.simpleMessage(
      "Limpieza de radiadores de motor y aire acondicionado",
    ),
    "service_chystka_siden_avto": MessageLookupByLibrary.simpleMessage(
      "Limpieza de asientos",
    ),
    "service_completed_work": MessageLookupByLibrary.simpleMessage(
      "Trabajos realizados",
    ),
    "service_diagnostyka_i_remont_ebu": MessageLookupByLibrary.simpleMessage(
      "Diagnóstico y reparación de la ECU del motor",
    ),
    "service_diagnostyka_pidvisky": MessageLookupByLibrary.simpleMessage(
      "Diagnóstico de la suspensión",
    ),
    "service_diagnostyka_remont_dvs": MessageLookupByLibrary.simpleMessage(
      "Diagnóstico y reparación del motor",
    ),
    "service_diagnostyka_remont_palivnykh_forsunok":
        MessageLookupByLibrary.simpleMessage(
          "Diagnóstico y reparación de inyectores",
        ),
    "service_diagnostyka_remont_tnvd": MessageLookupByLibrary.simpleMessage(
      "Diagnóstico y reparación de la bomba de inyección",
    ),
    "service_diagnostyka_zamina_zcheplennya":
        MessageLookupByLibrary.simpleMessage("Diagnóstico y cambio de clutch"),
    "service_dvs_capitalnyy_remont": MessageLookupByLibrary.simpleMessage(
      "Motor de combustión - reparación mayor",
    ),
    "service_dvs_diagnostika": MessageLookupByLibrary.simpleMessage(
      "Motor de combustión - diagnóstico (inspección, medición de compresión)",
    ),
    "service_dvs_znyattya_ustanovka": MessageLookupByLibrary.simpleMessage(
      "Motor de combustión - desmontaje/instalación (reemplazo)",
    ),
    "service_golovnyy_cylyndr_zcheplennya_zamina":
        MessageLookupByLibrary.simpleMessage(
          "Cilindro maestro del clutch - reemplazo",
        ),
    "service_invalid_price": MessageLookupByLibrary.simpleMessage(
      "Ingresa un precio válido para cada trabajo",
    ),
    "service_inzhektor_chystka": MessageLookupByLibrary.simpleMessage(
      "Inyectores - limpieza (sin incluir líquidos especiales)",
    ),
    "service_kardannyy_val_zamina": MessageLookupByLibrary.simpleMessage(
      "Cardán - reemplazo",
    ),
    "service_khimchystka_salonu": MessageLookupByLibrary.simpleMessage(
      "Limpieza profunda del interior",
    ),
    "service_khodova_chastyna_diagnostyka":
        MessageLookupByLibrary.simpleMessage("Tren de rodaje - diagnóstico"),
    "service_kompleksna_diagnostyka": MessageLookupByLibrary.simpleMessage(
      "Diagnóstico integral (sin diagnóstico por computadora)",
    ),
    "service_kompleksna_diagnostyka_full": MessageLookupByLibrary.simpleMessage(
      "Diagnóstico integral",
    ),
    "service_kompyuterna_diagnostyka": MessageLookupByLibrary.simpleMessage(
      "Diagnóstico por computadora",
    ),
    "service_kpp_remont": MessageLookupByLibrary.simpleMessage(
      "Transmisión - reparación",
    ),
    "service_kpp_zamina": MessageLookupByLibrary.simpleMessage(
      "Transmisión - reemplazo",
    ),
    "service_krestovyna_kard_valu_zamina": MessageLookupByLibrary.simpleMessage(
      "Cruceta del cardán - reemplazo",
    ),
    "service_load_failed": MessageLookupByLibrary.simpleMessage(
      "No se pudieron cargar los talleres",
    ),
    "service_location_unavailable": MessageLookupByLibrary.simpleMessage(
      "Permite el acceso a tu ubicación para encontrar talleres cercanos",
    ),
    "service_maslo_transmisiine_zamina": MessageLookupByLibrary.simpleMessage(
      "Aceite de transmisión (diferencial/caja/transfer) - cambio",
    ),
    "service_nakonechnik_rulovoyi_tyahy_zamina":
        MessageLookupByLibrary.simpleMessage(
          "Terminal de dirección - reemplazo",
        ),
    "service_no_nearby": MessageLookupByLibrary.simpleMessage(
      "No se encontraron talleres cercanos",
    ),
    "service_no_rating": MessageLookupByLibrary.simpleMessage(
      "Sin calificación",
    ),
    "service_oliya_akpp_chastkova": MessageLookupByLibrary.simpleMessage(
      "Aceite de transmisión automática - cambio parcial (drenar/rellenar), con cambio de filtro",
    ),
    "service_oliya_akpp_zamna_povna_bez_filtra":
        MessageLookupByLibrary.simpleMessage(
          "Aceite de transmisión automática - cambio completo (con equipo) sin cambio de filtro",
        ),
    "service_oliya_akpp_zamna_povna_z_filtra": MessageLookupByLibrary.simpleMessage(
      "Aceite de transmisión automática - cambio completo (con equipo), con cambio de filtro",
    ),
    "service_oliya_mkpp_zamina": MessageLookupByLibrary.simpleMessage(
      "Aceite de transmisión manual - cambio",
    ),
    "service_palivna_systema_diagnostyka": MessageLookupByLibrary.simpleMessage(
      "Sistema de combustible - diagnóstico (medición de presión)",
    ),
    "service_pereprodazhne_polirovannya_kuzova":
        MessageLookupByLibrary.simpleMessage(
          "Pulido de carrocería para la venta",
        ),
    "service_pidshipnyk_matochyny_kolesa_zamina":
        MessageLookupByLibrary.simpleMessage(
          "Rodamiento de maza de rueda - reemplazo",
        ),
    "service_pokryttya_keramikoyu": MessageLookupByLibrary.simpleMessage(
      "Recubrimiento cerámico",
    ),
    "service_polirovka_far": MessageLookupByLibrary.simpleMessage(
      "Pulido de faros",
    ),
    "service_polirovka_kuzova": MessageLookupByLibrary.simpleMessage(
      "Pulido de carrocería",
    ),
    "service_predprodazhna_khimchystka_salonu":
        MessageLookupByLibrary.simpleMessage(
          "Limpieza profunda del interior antes de la venta",
        ),
    "service_profesijnyy_remont_grm": MessageLookupByLibrary.simpleMessage(
      "Reparación profesional de la distribución",
    ),
    "service_profilaktyka_halmyvnykh_mekhanizmiv":
        MessageLookupByLibrary.simpleMessage(
          "Mantenimiento preventivo de frenos",
        ),
    "service_prokladka_gbc": MessageLookupByLibrary.simpleMessage(
      "Junta de la culata - reemplazo",
    ),
    "service_prokladka_klapannoyi_krishki":
        MessageLookupByLibrary.simpleMessage(
          "Junta de la tapa de válvulas - reemplazo",
        ),
    "service_prokladka_poddonu_kartera": MessageLookupByLibrary.simpleMessage(
      "Junta del cárter - reemplazo",
    ),
    "service_promyvka_inzhektora": MessageLookupByLibrary.simpleMessage(
      "Lavado de inyectores",
    ),
    "service_promyvka_palivnoyi_systemy": MessageLookupByLibrary.simpleMessage(
      "Lavado del sistema de combustible",
    ),
    "service_promyvka_palivnoyi_systemy_dizel":
        MessageLookupByLibrary.simpleMessage(
          "Lavado del sistema de combustible diésel",
        ),
    "service_pryvodnyy_val_zamina": MessageLookupByLibrary.simpleMessage(
      "Flecha de transmisión - reemplazo",
    ),
    "service_pylovik_shrus_vnutrishniy_zamina":
        MessageLookupByLibrary.simpleMessage(
          "Guardapolvo de junta homocinética (interior) - reemplazo",
        ),
    "service_pylovik_shrus_zovnishniy_zamina":
        MessageLookupByLibrary.simpleMessage(
          "Guardapolvo de junta homocinética (exterior) - reemplazo",
        ),
    "service_remin_pryvodnyy": MessageLookupByLibrary.simpleMessage(
      "Banda de accesorios - reemplazo",
    ),
    "service_remkomplekt_grm": MessageLookupByLibrary.simpleMessage(
      "Kit de distribución - reemplazo",
    ),
    "service_remont_elektroprovodky": MessageLookupByLibrary.simpleMessage(
      "Reparación del cableado y equipo eléctrico",
    ),
    "service_remont_generatoriv": MessageLookupByLibrary.simpleMessage(
      "Reparación de alternadores",
    ),
    "service_remont_holovky_bloku_cylindriv_dvyhuna":
        MessageLookupByLibrary.simpleMessage("Reparación de la culata"),
    "service_remont_klapiv_dvyhuna": MessageLookupByLibrary.simpleMessage(
      "Reparación de válvulas del motor",
    ),
    "service_remont_maslyanogo_nasosa": MessageLookupByLibrary.simpleMessage(
      "Reparación de la bomba de aceite",
    ),
    "service_remont_pnevmopidvisky": MessageLookupByLibrary.simpleMessage(
      "Reparación de la suspensión neumática",
    ),
    "service_remont_porshniv_dvyhuna": MessageLookupByLibrary.simpleMessage(
      "Reparación de pistones del motor",
    ),
    "service_remont_radiatoriv": MessageLookupByLibrary.simpleMessage(
      "Reparación de radiadores",
    ),
    "service_remont_rulovykh_reyok": MessageLookupByLibrary.simpleMessage(
      "Reparación de la cremallera de dirección",
    ),
    "service_remont_starteriv": MessageLookupByLibrary.simpleMessage(
      "Reparación de motores de arranque",
    ),
    "service_remont_suporiv": MessageLookupByLibrary.simpleMessage(
      "Reparación de calipers de freno",
    ),
    "service_remont_turbokompressoriv": MessageLookupByLibrary.simpleMessage(
      "Reparación de turbocompresores",
    ),
    "service_remont_vazheliv_pidvisky": MessageLookupByLibrary.simpleMessage(
      "Reparación de horquillas de suspensión",
    ),
    "service_remont_zamina_aktuatora_zcheplennya":
        MessageLookupByLibrary.simpleMessage(
          "Reparación/reemplazo del actuador del clutch",
        ),
    "service_remont_zaminy_mahovyka_dvyhuna":
        MessageLookupByLibrary.simpleMessage(
          "Reparación (reemplazo) del volante del motor",
        ),
    "service_remont_zaminy_opor_dvyhuna": MessageLookupByLibrary.simpleMessage(
      "Reparación (reemplazo) de soportes del motor",
    ),
    "service_retry": MessageLookupByLibrary.simpleMessage("Reintentar"),
    "service_robochyy_cylyndr_zcheplennya_zamina":
        MessageLookupByLibrary.simpleMessage(
          "Cilindro esclavo del clutch - reemplazo",
        ),
    "service_rolik_pryvodnoho_remenya": MessageLookupByLibrary.simpleMessage(
      "Polea de la banda de accesorios - reemplazo",
    ),
    "service_rulova_reyka_remont": MessageLookupByLibrary.simpleMessage(
      "Cremallera de dirección - reparación",
    ),
    "service_rulova_tyaha_zamina": MessageLookupByLibrary.simpleMessage(
      "Barra de dirección - reemplazo",
    ),
    "service_sharova_opora_zamina": MessageLookupByLibrary.simpleMessage(
      "Rótula - reemplazo",
    ),
    "service_shrus_pryvodnoho_valu_zamina":
        MessageLookupByLibrary.simpleMessage(
          "Junta homocinética de la flecha - reemplazo",
        ),
    "service_silentblok_vazhelya_pidvisky_zamina":
        MessageLookupByLibrary.simpleMessage(
          "Buje de horquilla de suspensión - reemplazo (con la horquilla desmontada)",
        ),
    "service_skhid_rozval": MessageLookupByLibrary.simpleMessage("Alineación"),
    "service_station": MessageLookupByLibrary.simpleMessage("Taller"),
    "service_station_nearby": MessageLookupByLibrary.simpleMessage(
      "Taller cercano",
    ),
    "service_stiikyi_stabilizatora_zamina":
        MessageLookupByLibrary.simpleMessage(
          "Bieletas de la barra estabilizadora - reemplazo",
        ),
    "service_stupytsia_kolesa_zamina": MessageLookupByLibrary.simpleMessage(
      "Maza de rueda - reemplazo",
    ),
    "service_systema_kondytsionuvannya": MessageLookupByLibrary.simpleMessage(
      "Aire acondicionado - diagnóstico y recarga",
    ),
    "service_vazhel_pidvisky_zamina": MessageLookupByLibrary.simpleMessage(
      "Horquilla de suspensión - reemplazo",
    ),
    "service_vidalennya_dribnykh_podryapin":
        MessageLookupByLibrary.simpleMessage("Eliminación de rayones pequeños"),
    "service_vidalennya_katalizatora": MessageLookupByLibrary.simpleMessage(
      "Retiro del convertidor catalítico",
    ),
    "service_vstanovlennya_ksenonu": MessageLookupByLibrary.simpleMessage(
      "Instalación de luces de xenón",
    ),
    "service_vtulky_stabilizatora_zamina": MessageLookupByLibrary.simpleMessage(
      "Bujes de la barra estabilizadora - reemplazo",
    ),
    "service_zamina_akumulyatora": MessageLookupByLibrary.simpleMessage(
      "Cambio de batería",
    ),
    "service_zamina_amortyzatoriv": MessageLookupByLibrary.simpleMessage(
      "Cambio de amortiguadores",
    ),
    "service_zamina_antifryzu": MessageLookupByLibrary.simpleMessage(
      "Cambio de anticongelante",
    ),
    "service_zamina_benzonasosa": MessageLookupByLibrary.simpleMessage(
      "Cambio de la bomba de gasolina",
    ),
    "service_zamina_dvyhuna": MessageLookupByLibrary.simpleMessage(
      "Cambio de motor",
    ),
    "service_zamina_dyska_zcheplennya": MessageLookupByLibrary.simpleMessage(
      "Cambio del disco de clutch",
    ),
    "service_zamina_glushnyka": MessageLookupByLibrary.simpleMessage(
      "Cambio de mofle",
    ),
    "service_zamina_golovnogo_cylyndra_zcheplennya":
        MessageLookupByLibrary.simpleMessage(
          "Cambio del cilindro maestro del clutch",
        ),
    "service_zamina_halmykh_shlang": MessageLookupByLibrary.simpleMessage(
      "Cambio de mangueras de freno",
    ),
    "service_zamina_halmyvnoyi_ridyny": MessageLookupByLibrary.simpleMessage(
      "Cambio del líquido de frenos",
    ),
    "service_zamina_halmyvnykh_dyskiv": MessageLookupByLibrary.simpleMessage(
      "Cambio de discos de freno",
    ),
    "service_zamina_halmyvnykh_kolodok": MessageLookupByLibrary.simpleMessage(
      "Cambio de balatas",
    ),
    "service_zamina_hofry_pryymalnoyi_truby":
        MessageLookupByLibrary.simpleMessage(
          "Cambio del flexible del tubo de escape",
        ),
    "service_zamina_kard_valu": MessageLookupByLibrary.simpleMessage(
      "Cambio de cardán",
    ),
    "service_zamina_katalizatora": MessageLookupByLibrary.simpleMessage(
      "Cambio del convertidor catalítico",
    ),
    "service_zamina_kisnevogo_datchyka": MessageLookupByLibrary.simpleMessage(
      "Cambio del sensor de oxígeno (sonda lambda)",
    ),
    "service_zamina_kisnevogo_datchyka_lambda":
        MessageLookupByLibrary.simpleMessage(
          "Cambio del sensor de oxígeno (sonda lambda)",
        ),
    "service_zamina_kotushok_modulya_zapal":
        MessageLookupByLibrary.simpleMessage(
          "Cambio de bobina/módulo de encendido",
        ),
    "service_zamina_krestovyny_kard_valu": MessageLookupByLibrary.simpleMessage(
      "Cambio de la cruceta del cardán",
    ),
    "service_zamina_krestovyny_rulovogo_valu":
        MessageLookupByLibrary.simpleMessage(
          "Cambio de la cruceta de la columna de dirección",
        ),
    "service_zamina_kulovykh_opor": MessageLookupByLibrary.simpleMessage(
      "Cambio de rótulas",
    ),
    "service_zamina_lamp_protifumannykh_far":
        MessageLookupByLibrary.simpleMessage(
          "Cambio de focos de los faros antiniebla",
        ),
    "service_zamina_nakonechnikiv_rulovykh_tyag":
        MessageLookupByLibrary.simpleMessage(
          "Cambio de terminales de dirección",
        ),
    "service_zamina_oil_dvs": MessageLookupByLibrary.simpleMessage(
      "Cambio de aceite del motor",
    ),
    "service_zamina_oil_variator": MessageLookupByLibrary.simpleMessage(
      "Cambio de aceite de la transmisión CVT",
    ),
    "service_zamina_oliynoho_filtra": MessageLookupByLibrary.simpleMessage(
      "Cambio del filtro de aceite",
    ),
    "service_zamina_opornoho_pidshipnyka_amortyzatora":
        MessageLookupByLibrary.simpleMessage(
          "Cambio del rodamiento de la base del amortiguador",
        ),
    "service_zamina_palivnogo_filtra": MessageLookupByLibrary.simpleMessage(
      "Cambio del filtro de combustible",
    ),
    "service_zamina_perednikh_amortyzatoriv":
        MessageLookupByLibrary.simpleMessage(
          "Cambio de amortiguadores delanteros",
        ),
    "service_zamina_pidshipnykiv_matochok":
        MessageLookupByLibrary.simpleMessage("Cambio de rodamientos de maza"),
    "service_zamina_pompy": MessageLookupByLibrary.simpleMessage(
      "Cambio de bomba de agua",
    ),
    "service_zamina_povitryanogo_filtra_dvs":
        MessageLookupByLibrary.simpleMessage(
          "Cambio del filtro de aire del motor",
        ),
    "service_zamina_probky_piddonu": MessageLookupByLibrary.simpleMessage(
      "Cambio del tapón del cárter",
    ),
    "service_zamina_prokladky_gbc": MessageLookupByLibrary.simpleMessage(
      "Cambio de la junta de la culata",
    ),
    "service_zamina_prokladky_glushnyka": MessageLookupByLibrary.simpleMessage(
      "Cambio de la junta del mofle",
    ),
    "service_zamina_prokladky_klapannoyi_krishky":
        MessageLookupByLibrary.simpleMessage(
          "Cambio de la junta de la tapa de válvulas",
        ),
    "service_zamina_prokladky_poddonu_kartera":
        MessageLookupByLibrary.simpleMessage("Cambio de la junta del cárter"),
    "service_zamina_pruzhin_amortyzatoriv":
        MessageLookupByLibrary.simpleMessage(
          "Cambio de resortes de suspensión",
        ),
    "service_zamina_pryvodnykh_remeniv": MessageLookupByLibrary.simpleMessage(
      "Cambio de bandas de accesorios",
    ),
    "service_zamina_pryvodnykh_valiv": MessageLookupByLibrary.simpleMessage(
      "Cambio de flechas",
    ),
    "service_zamina_pylnyka_zadnogo_amortyzatora":
        MessageLookupByLibrary.simpleMessage(
          "Cambio del guardapolvo del amortiguador trasero",
        ),
    "service_zamina_radiatora": MessageLookupByLibrary.simpleMessage(
      "Cambio de radiador",
    ),
    "service_zamina_remenya_grm": MessageLookupByLibrary.simpleMessage(
      "Cambio de la banda de distribución",
    ),
    "service_zamina_ridyny_zcheplennya": MessageLookupByLibrary.simpleMessage(
      "Cambio del líquido del clutch",
    ),
    "service_zamina_rolika_natyaguvacha_remenya":
        MessageLookupByLibrary.simpleMessage(
          "Cambio del tensor de la banda de accesorios",
        ),
    "service_zamina_rulovykh_tyag": MessageLookupByLibrary.simpleMessage(
      "Cambio de barras de dirección",
    ),
    "service_zamina_salnyka_kolenvala": MessageLookupByLibrary.simpleMessage(
      "Cambio del retén del cigüeñal",
    ),
    "service_zamina_salnyka_rozpodilnogo_valu":
        MessageLookupByLibrary.simpleMessage(
          "Cambio del retén del árbol de levas",
        ),
    "service_zamina_salonnoho_filtra": MessageLookupByLibrary.simpleMessage(
      "Cambio del filtro de cabina",
    ),
    "service_zamina_shrus": MessageLookupByLibrary.simpleMessage(
      "Cambio de junta homocinética",
    ),
    "service_zamina_shyn": MessageLookupByLibrary.simpleMessage(
      "Cambio de llantas",
    ),
    "service_zamina_silentblokiv_pidvisky":
        MessageLookupByLibrary.simpleMessage("Cambio de bujes de suspensión"),
    "service_zamina_stiikiv_stabilizatora":
        MessageLookupByLibrary.simpleMessage(
          "Cambio de bieletas de la barra estabilizadora",
        ),
    "service_zamina_svichok_rozzharjuvannya":
        MessageLookupByLibrary.simpleMessage(
          "Cambio de bujías de precalentamiento",
        ),
    "service_zamina_svichok_zapal": MessageLookupByLibrary.simpleMessage(
      "Cambio de bujías",
    ),
    "service_zamina_termostata": MessageLookupByLibrary.simpleMessage(
      "Cambio de termostato",
    ),
    "service_zamina_transmisiynykh_ridin": MessageLookupByLibrary.simpleMessage(
      "Cambio de líquidos de transmisión (diferencial/caja/transfer)",
    ),
    "service_zamina_trosa_zcheplennya": MessageLookupByLibrary.simpleMessage(
      "Cambio del chicote del clutch",
    ),
    "service_zamina_truby_glushnyka": MessageLookupByLibrary.simpleMessage(
      "Cambio del tubo del mofle",
    ),
    "service_zamina_vidbijnyka_amortyzatora":
        MessageLookupByLibrary.simpleMessage(
          "Cambio del tope del amortiguador",
        ),
    "service_zamina_vilky_zcheplennya": MessageLookupByLibrary.simpleMessage(
      "Cambio del tenedor del clutch",
    ),
    "service_zamina_vtulok_stabilizatora": MessageLookupByLibrary.simpleMessage(
      "Cambio de bujes de la barra estabilizadora",
    ),
    "service_zamina_vykhlopnoyi_systemy": MessageLookupByLibrary.simpleMessage(
      "Cambio del sistema de escape (completo)",
    ),
    "service_zamina_vysokovolt_provodiv": MessageLookupByLibrary.simpleMessage(
      "Cambio de cables de bujías",
    ),
    "service_zamina_zadnikh_amortyzatoriv":
        MessageLookupByLibrary.simpleMessage(
          "Cambio de amortiguadores traseros",
        ),
    "service_zamina_zcheplennya_akpp": MessageLookupByLibrary.simpleMessage(
      "Cambio del embrague de la transmisión automática",
    ),
    "service_zcheplennya_zmina": MessageLookupByLibrary.simpleMessage(
      "Kit de clutch - reemplazo",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Ajustes"),
    "spanish": MessageLookupByLibrary.simpleMessage("Español"),
    "statistics": MessageLookupByLibrary.simpleMessage("Estadísticas"),
    "status": MessageLookupByLibrary.simpleMessage("Estado"),
    "store_unavailable": MessageLookupByLibrary.simpleMessage(
      "Tienda no disponible",
    ),
    "subscription": MessageLookupByLibrary.simpleMessage("Suscripción"),
    "subscription_error": MessageLookupByLibrary.simpleMessage(
      "Error de suscripción",
    ),
    "subscription_subtitle": MessageLookupByLibrary.simpleMessage(
      "Acceso completo al control de multas, mantenimiento y seguro",
    ),
    "subscription_subtitle_no_fines": MessageLookupByLibrary.simpleMessage(
      "Acceso completo al control de mantenimiento, seguro y gastos",
    ),
    "sum_short": MessageLookupByLibrary.simpleMessage("Monto"),
    "tank_volume_gallons": MessageLookupByLibrary.simpleMessage(
      "Capacidad del tanque, gal",
    ),
    "tank_volume_liters": MessageLookupByLibrary.simpleMessage(
      "Capacidad del tanque, L",
    ),
    "tech_service": MessageLookupByLibrary.simpleMessage(
      "Mantenimiento técnico",
    ),
    "terms_of_use": MessageLookupByLibrary.simpleMessage("Términos de uso"),
    "tires": MessageLookupByLibrary.simpleMessage("llanta"),
    "tires_icon": MessageLookupByLibrary.simpleMessage("Llantas"),
    "title": MessageLookupByLibrary.simpleMessage("Título"),
    "today_at": MessageLookupByLibrary.simpleMessage("hoy a las"),
    "tokens_already_present": MessageLookupByLibrary.simpleMessage(
      "Los tokens ya existen",
    ),
    "tokens_extracted": MessageLookupByLibrary.simpleMessage(
      "Tokens obtenidos",
    ),
    "total": MessageLookupByLibrary.simpleMessage("Total"),
    "track_costs": MessageLookupByLibrary.simpleMessage(
      "Controla gastos, kilometraje y rendimiento",
    ),
    "trial_disclosure_detailed": m16,
    "tuning": MessageLookupByLibrary.simpleMessage("Personalización"),
    "type": MessageLookupByLibrary.simpleMessage("Tipo"),
    "ukr": MessageLookupByLibrary.simpleMessage("Ucraniano"),
    "units": MessageLookupByLibrary.simpleMessage("Unidades"),
    "unpaid_fines_section": MessageLookupByLibrary.simpleMessage("Sin pagar"),
    "update": MessageLookupByLibrary.simpleMessage("Actualizar"),
    "usd": MessageLookupByLibrary.simpleMessage("USD"),
    "user_not_found": MessageLookupByLibrary.simpleMessage(
      "Usuario no encontrado",
    ),
    "valid_from": MessageLookupByLibrary.simpleMessage("Vigente desde"),
    "valid_to": MessageLookupByLibrary.simpleMessage("Vigente hasta"),
    "vehicle_data": MessageLookupByLibrary.simpleMessage("Datos de vehículos"),
    "vehicle_data_credit": MessageLookupByLibrary.simpleMessage(
      "Datos de vehículos de VehiclesDB · CC BY 4.0",
    ),
    "vehicle_data_terms": MessageLookupByLibrary.simpleMessage(
      "Fuentes y términos de uso",
    ),
    "vehicles_section": MessageLookupByLibrary.simpleMessage("Vehículos"),
    "view_licenses": MessageLookupByLibrary.simpleMessage("Ver licencias"),
    "volume_gallons_short": MessageLookupByLibrary.simpleMessage(
      "Volumen, gal",
    ),
    "volume_kwh_short": MessageLookupByLibrary.simpleMessage("Cantidad, kWh"),
    "volume_liters_short": MessageLookupByLibrary.simpleMessage("Volumen, L"),
    "vs_previous_month": MessageLookupByLibrary.simpleMessage(
      "vs. mes anterior",
    ),
    "yearly_plan": MessageLookupByLibrary.simpleMessage("Plan anual"),
    "years": MessageLookupByLibrary.simpleMessage("Años"),
  };
}
