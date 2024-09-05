import 'package:flutter/material.dart';

class ContractorModel {
  final int? id;
  final int? phone;
  final String title;
  final String name;
  final String? address;
  final String city;
  ContractorModel({
    this.id,
    this.phone,
    this.address,
    required this.city,
    required this.title,
    required this.name,
  });

  Map<String, Object?> toJson() => {};

  ContractorModel copy({
    int? id,
    int? phone,
    String? title,
    String? name,
    String? address,
    String? city,
  }) =>
      ContractorModel(
        id: id ?? this.id,
        phone: phone ?? this.phone,
        title: title ?? this.title,
        name: name ?? this.name,
        address: address ?? this.address,
        city: city ?? this.city,
      );
}
