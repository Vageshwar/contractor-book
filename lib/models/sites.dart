class Sites {
  int siteId, date, active;
  String location, name, ownerName;

  Sites(
      {required this.siteId,
      required this.ownerName,
      required this.date,
      required this.active,
      required this.name,
      required this.location});

  //to be used when inserting a row in the table
  Map<String, dynamic> toMapWithoutId() {
    final map = <String, dynamic>{};
    map["name"] = name;
    map["location"] = location;
    map["ownerName"] = ownerName;
    map["active"] = active;
    map["date"] = date;
    return map;
  }

  factory Sites.fromMap(Map<String, dynamic> data) => Sites(
        siteId: data['id'],
        ownerName:
            data['ownerName'] != Null ? data['ownerName'].toString() : "--",
        date: data['date'] != Null ? data['date'] : 0,
        active: data['active'] ?? 0,
        name: data['name'] != Null ? data['name'].toString() : "--",
        location: data['location'] != Null ? data['location'].toString() : "--",
      );
}
