
class ReferenceLink {
  final int? linkId; // Auto-increment PK
  final String diseaseId; // FK to disease_info
  final String linkUrl;
  final String linkTitle;
  final String source; // FAO, CIMMYT, USDA, etc.
  final int createdAt;

  ReferenceLink({
    this.linkId,
    required this.diseaseId,
    required this.linkUrl,
    required this.linkTitle,
    required this.source,
    int? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;

  Map<String, dynamic> toMap() {
    return {
      'link_id': linkId,
      'disease_id': diseaseId,
      'link_url': linkUrl,
      'link_title': linkTitle,
      'source': source,
      'created_at': createdAt,
    };
  }

  factory ReferenceLink.fromMap(Map<String, dynamic> map) {
    return ReferenceLink(
      linkId: map['link_id'] as int?,
      diseaseId: map['disease_id'] as String,
      linkUrl: map['link_url'] as String,
      linkTitle: map['link_title'] as String,
      source: map['source'] as String,
      createdAt: map['created_at'] as int,
    );
  }

  @override
  String toString() {
    return 'ReferenceLink(title: $linkTitle, source: $source)';
  }
}