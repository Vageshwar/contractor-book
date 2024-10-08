class Note {
  final int id;
  final int siteId;
  final String content;
  final DateTime dateAdded;

  Note({
    required this.id,
    required this.siteId,
    required this.content,
    required this.dateAdded,
  });

  // Convert to map for inserting into the database
  Map<String, dynamic> toMapWithoutId() {
    final map = <String, dynamic>{};
    map["content"] = content;
    map["siteId"] = siteId;
    map["dateAdded"] = dateAdded.millisecondsSinceEpoch; // Store as timestamp
    return map;
  }

  // Convert from map when retrieving from the database
  factory Note.fromMap(Map<String, dynamic> data) => Note(
        id: data['id'],
        siteId: data['siteId'],
        content: data['content'],
        dateAdded: DateTime.fromMillisecondsSinceEpoch(data['dateAdded']),
      );
}
