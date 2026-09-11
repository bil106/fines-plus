import 'package:core_localization/generated/l10n.dart';
import 'package:flutter/widgets.dart';

Map<String, String> getServiceMap(BuildContext context) {
  final s = S.of(context);

  return {
    "service_dvs_diagnostika": s.service_dvs_diagnostika,
    "service_dvs_znyattya_ustanovka": s.service_dvs_znyattya_ustanovka,
    "service_dvs_capitalnyy_remont": s.service_dvs_capitalnyy_remont,
    "service_prokladka_klapannoyi_krishki": s.service_prokladka_klapannoyi_krishki,
    "service_prokladka_gbc": s.service_prokladka_gbc,
    "service_prokladka_poddonu_kartera": s.service_prokladka_poddonu_kartera,
    "service_remin_pryvodnyy": s.service_remin_pryvodnyy,
    "service_rolik_pryvodnoho_remenya": s.service_rolik_pryvodnoho_remenya,
    "service_remkomplekt_grm": s.service_remkomplekt_grm,
    "service_inzhektor_chystka": s.service_inzhektor_chystka,
    "service_zamina_oil_dvs": s.service_zamina_oil_dvs,
    "service_zamina_povitryanogo_filtra_dvs": s.service_zamina_povitryanogo_filtra_dvs,
    "service_zamina_salonnoho_filtra": s.service_zamina_salonnoho_filtra,
    "service_chystka_droselnoyi_zaslinky": s.service_chystka_droselnoyi_zaslinky,
    "service_kompyuterna_diagnostyka": s.service_kompyuterna_diagnostyka,
    "service_remont_elektroprovodky": s.service_remont_elektroprovodky,
    "service_remont_generatoriv": s.service_remont_generatoriv,
    "service_remont_starteriv": s.service_remont_starteriv,
    "service_zamina_kisnevogo_datchyka": s.service_zamina_kisnevogo_datchyka,
    "service_diagnostyka_i_remont_ebu": s.service_diagnostyka_i_remont_ebu,
    "service_zamina_lamp_protifumannykh_far": s.service_zamina_lamp_protifumannykh_far,
    "service_kompleksna_diagnostyka": s.service_kompleksna_diagnostyka,
    "service_kompleksna_diagnostyka_full": s.service_kompleksna_diagnostyka_full,
    "service_systema_kondytsionuvannya": s.service_systema_kondytsionuvannya,
    "service_palivna_systema_diagnostyka": s.service_palivna_systema_diagnostyka,
  };
}

String getServiceName(BuildContext context, String? key) {
  if (key == null) return "";

  final map = getServiceMap(context);
  return map[key] ?? key;
}
