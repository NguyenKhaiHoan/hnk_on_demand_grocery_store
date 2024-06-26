import 'package:cloud_firestore/cloud_firestore.dart';

class UserAddressModel {
  String id;
  String name;
  String phoneNumber;
  String city;
  String district;
  String ward;
  String street;
  double latitude;
  double longitude;

  UserAddressModel(
      {required this.id,
      required this.name,
      required this.phoneNumber,
      this.city = 'Hà Nội',
      required this.district,
      required this.ward,
      required this.street,
      required this.latitude,
      required this.longitude});

  static UserAddressModel empty() => UserAddressModel(
        id: '',
        name: '',
        phoneNumber: '',
        district: '',
        ward: '',
        street: '',
        latitude: 0,
        longitude: 0,
      );

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'PhoneNumber': phoneNumber,
      'City': city,
      'District': district,
      'Ward': ward,
      'Street': street,
      'Latitude': latitude,
      'Longitude': longitude,
    };
  }

  factory UserAddressModel.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return UserAddressModel(
        id: document.id,
        name: data['Name'] ?? '',
        phoneNumber: data['PhoneNumber'] ?? '',
        city: data['City'] ??= 'Hà Nội',
        district: data['District'] ?? '',
        ward: data['Ward'] ?? '',
        street: data['Street'] ?? '',
        latitude: double.parse((data['Latitude'] ?? 0.0).toString()),
        longitude: double.parse((data['Longitude'] ?? 0.0).toString()),
      );
    }
    return UserAddressModel.empty();
  }

  factory UserAddressModel.fromJson(Map<String, dynamic> json) {
    return UserAddressModel(
      id: json['Id'] ?? '',
      name: json['Name'] ?? '',
      phoneNumber: json['PhoneNumber'] ?? '',
      city: json['City'] ?? '',
      district: json['District'] ?? '',
      ward: json['Ward'] ?? '',
      street: json['Street'] ?? '',
      latitude: json['Latitude']?.toDouble() ?? 0.0,
      longitude: json['Longitude']?.toDouble() ?? 0.0,
    );
  }
  @override
  String toString() {
    return [street, ward, district, city].join(', ');
  }
}
