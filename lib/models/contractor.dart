class Contractor {
  int contractorId;
  String name, city, address, phone, title;

  Contractor(
      {required this.contractorId,
      required this.name,
      required this.city,
      required this.address,
      required this.phone,
      required this.title});

  //to be used when inserting a row in the table
  Map<String, dynamic> toMapWithoutId() {
    final map = new Map<String, dynamic>();
    map["name"] = name;
    map["city"] = city;
    map["address"] = address;
    map["phone"] = phone;
    map["title"] = title;
    return map;
  }
}
