class DiseaseInfo {
  DiseaseInfo({
    required this.diseaseId,
    required this.diseaseName,
    required this.symptoms,
    this.culturalControl,
    this.chemicalControl,
    this.biologicalControl,
    required this.severityLevel,
    required this.affectedCrops,
    this.referenceLinks = const [],
  });

  final String diseaseId;
  final String diseaseName;
  final String symptoms;
  final String? culturalControl;
  final String? chemicalControl;
  final String? biologicalControl;
  final String severityLevel;
  final String affectedCrops; // comma separated
  final List<String> referenceLinks;

  List<String> getSymptomsFormatted() =>
      symptoms.split('\n').where((s) => s.trim().isNotEmpty).toList();

  List<Map<String, String>> getTreatmentOptions() => [
    if (culturalControl != null)
      {'type': 'Cultural', 'detail': culturalControl!},
    if (chemicalControl != null)
      {'type': 'Chemical', 'detail': chemicalControl!},
    if (biologicalControl != null)
      {'type': 'Biological', 'detail': biologicalControl!},
  ];

  String getAffectedCropsList() =>
      affectedCrops.split(',').map((c) => c.trim()).join(', ');

  factory DiseaseInfo.fromMap(Map<String, dynamic> map) {
    final rawLinks = map['links'] as String?;
    final links = (rawLinks != null && rawLinks.isNotEmpty)
        ? rawLinks.split('|').where((l) => l.trim().isNotEmpty).toList()
        : <String>[];
    return DiseaseInfo(
      diseaseId: map['disease_id'] as String,
      diseaseName: map['disease_name'] as String,
      symptoms: map['symptoms'] as String,
      culturalControl: map['cultural_control'] as String?,
      chemicalControl: map['chemical_control'] as String?,
      biologicalControl: map['biological_control'] as String?,
      severityLevel: map['severity_level'] as String,
      affectedCrops: map['affected_crops'] as String,
      referenceLinks: links,
    );
  }

  Map<String, dynamic> toMap() => {
    'disease_id': diseaseId,
    'disease_name': diseaseName,
    'symptoms': symptoms,
    'cultural_control': culturalControl,
    'chemical_control': chemicalControl,
    'biological_control': biologicalControl,
    'severity_level': severityLevel,
    'affected_crops': affectedCrops,
  };
}
