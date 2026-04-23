

class ReferenceLink {
  final int?   linkId;
  final String diseaseId;
  final String linkUrl;
  final String linkTitle;
  final String source;

  const ReferenceLink({
    this.linkId,
    required this.diseaseId,
    required this.linkUrl,
    required this.linkTitle,
    required this.source,
  });

  Map<String, dynamic> toMap() => {
    if (linkId != null) 'link_id': linkId,
    'disease_id':   diseaseId,
    'link_url':     linkUrl,
    'link_title':   linkTitle,
    'source':       source,
    'created_at':   DateTime.now().millisecondsSinceEpoch,
  };

  factory ReferenceLink.fromMap(Map<String, dynamic> map) => ReferenceLink(
    linkId:    map['link_id'] as int?,
    diseaseId: map['disease_id'] as String,
    linkUrl:   map['link_url'] as String,
    linkTitle: map['link_title'] as String,
    source:    map['source'] as String,
  );
}
