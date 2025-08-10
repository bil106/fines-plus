class AppConfig {
  final String brandName;
  final String primaryColorHex;
  final String logoAssetPath;
  final String supportEmail;
  final String phoneNumber;
  final String viberNumber;

  const AppConfig({
    required this.brandName,
    required this.primaryColorHex,
    required this.logoAssetPath,
    required this.supportEmail,
    required this.phoneNumber,
    required this.viberNumber,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      brandName: json['brandName'],
      primaryColorHex: json['primaryColorHex'],
      logoAssetPath: json['logoAssetPath'],
      supportEmail: json['supportEmail'],
      phoneNumber: json['phoneNumber'],
      viberNumber: json['viberNumber'],
    );
  }
}
