

class AppSettings {
  final String language;
  final String modelVersion;
  final double confidenceThreshold;
  final int    lastSync;

  const AppSettings({
    this.language             = 'en',
    this.modelVersion         = '1.0',
    this.confidenceThreshold  = 0.60,
    this.lastSync             = 0,
  });

  AppSettings copyWith({
    String? language,
    String? modelVersion,
    double? confidenceThreshold,
    int?    lastSync,
  }) => AppSettings(
    language:            language            ?? this.language,
    modelVersion:        modelVersion        ?? this.modelVersion,
    confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
    lastSync:            lastSync            ?? this.lastSync,
  );

  Map<String, String> toSettingsRows() => {
    'language':             language,
    'model_version':        modelVersion,
    'confidence_threshold': confidenceThreshold.toString(),
    'last_sync':            lastSync.toString(),
  };

  factory AppSettings.fromRows(Map<String, String> rows) => AppSettings(
    language:            rows['language']             ?? 'en',
    modelVersion:        rows['model_version']        ?? '1.0',
    confidenceThreshold: double.tryParse(rows['confidence_threshold'] ?? '') ?? 0.60,
    lastSync:            int.tryParse(rows['last_sync'] ?? '')               ?? 0,
  );
}
