
class AppSettings {
  final String settingKey;
  final String settingValue;
  final int updatedAt;

  AppSettings({
    required this.settingKey,
    required this.settingValue,
    int? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;

  Map<String, dynamic> toMap() {
    return {
      'setting_key': settingKey,
      'setting_value': settingValue,
      'updated_at': updatedAt,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      settingKey: map['setting_key'] as String,
      settingValue: map['setting_value'] as String,
      updatedAt: map['updated_at'] as int,
    );
  }

  @override
  String toString() {
    return 'AppSettings(key: $settingKey, value: $settingValue)';
  }
}