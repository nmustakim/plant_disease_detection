import 'dart:convert';

enum SeverityLevel {
  low,
  medium,
  high;

  String get displayName {
    switch (this) {
      case SeverityLevel.low:
        return 'Low';
      case SeverityLevel.medium:
        return 'Medium';
      case SeverityLevel.high:
        return 'High';
    }
  }

  static SeverityLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return SeverityLevel.low;
      case 'medium':
        return SeverityLevel.medium;
      case 'high':
        return SeverityLevel.high;
      default:
        return SeverityLevel.medium;
    }
  }
}


class DiseaseInfo {
  final String diseaseId; // PK
  final String diseaseName; // Unique
  final String symptoms;
  final String? culturalControl;
  final String? chemicalControl;
  final String? biologicalControl;
  final SeverityLevel severityLevel;
  final List<String> affectedCrops;
  final int createdAt;
  final int updatedAt;

  DiseaseInfo({
    required this.diseaseId,
    required this.diseaseName,
    required this.symptoms,
    this.culturalControl,
    this.chemicalControl,
    this.biologicalControl,
    required this.severityLevel,
    required this.affectedCrops,
    int? createdAt,
    int? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
        updatedAt = updatedAt ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;

  String getSymptomsFormatted() {
    return symptoms;
  }

  TreatmentInfo getTreatmentOptions() {
    return TreatmentInfo(
      cultural: culturalControl,
      chemical: chemicalControl,
      biological: biologicalControl,
    );
  }

  List<String> getAffectedCropsList() {
    return affectedCrops;
  }

  Map<String, dynamic> toMap() {
    return {
      'disease_id': diseaseId,
      'disease_name': diseaseName,
      'symptoms': symptoms,
      'cultural_control': culturalControl,
      'chemical_control': chemicalControl,
      'biological_control': biologicalControl,
      'severity_level': severityLevel.displayName,
      'affected_crops': jsonEncode(affectedCrops),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory DiseaseInfo.fromMap(Map<String, dynamic> map) {
    return DiseaseInfo(
      diseaseId: map['disease_id'] as String,
      diseaseName: map['disease_name'] as String,
      symptoms: map['symptoms'] as String,
      culturalControl: map['cultural_control'] as String?,
      chemicalControl: map['chemical_control'] as String?,
      biologicalControl: map['biological_control'] as String?,
      severityLevel: SeverityLevel.fromString(map['severity_level'] as String),
      affectedCrops: List<String>.from(
        jsonDecode(map['affected_crops'] as String),
      ),
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  @override
  String toString() {
    return 'DiseaseInfo(id: $diseaseId, name: $diseaseName, severity: ${severityLevel.displayName})';
  }
}

class TreatmentInfo {
  final String? cultural;
  final String? chemical;
  final String? biological;

  TreatmentInfo({
    this.cultural,
    this.chemical,
    this.biological,
  });

  bool get hasCulturalControl => cultural != null && cultural!.isNotEmpty;
  bool get hasChemicalControl => chemical != null && chemical!.isNotEmpty;
  bool get hasBiologicalControl => biological != null && biological!.isNotEmpty;
  bool get hasAnyTreatment => hasCulturalControl || hasChemicalControl || hasBiologicalControl;
}