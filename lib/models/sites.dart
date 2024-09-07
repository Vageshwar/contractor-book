class Sites {
  int siteId, ownerId, date, active;
  String location, name;

  Sites(
      {required this.siteId,
      required this.ownerId,
      required this.date,
      required this.active,
      required this.name,
      required this.location});

  //to be used when inserting a row in the table
  Map<String, dynamic> toMapWithoutId() {
    final map = new Map<String, dynamic>();
    map["name"] = name;
    map["location"] = location;
    map["ownerId"] = ownerId;
    map["location"] = location;
    map["date"] = date;
    return map;
  }

  factory Sites.fromMap(Map<String, dynamic> data) => Sites(
        siteId: data['id'],
        ownerId: data['ownerId'],
        date: data['date'],
        active: data['active'],
        name: data['name'],
        location: data['location'],
      );
}
