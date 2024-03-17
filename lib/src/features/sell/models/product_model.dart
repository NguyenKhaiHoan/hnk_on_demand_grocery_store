import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  String id;
  String name;
  String image;
  String categoryId;
  String description;
  String status;
  int price;
  int salePersent;
  int priceSale;
  String unit;
  int countBuyed;
  double rating;
  String origin;
  String storeId;
  DateTime uploadTime;
  ProductModel({
    required this.id,
    required this.name,
    required this.image,
    required this.categoryId,
    required this.description,
    required this.status,
    required this.price,
    required this.salePersent,
    required this.priceSale,
    required this.unit,
    required this.countBuyed,
    required this.rating,
    required this.origin,
    required this.storeId,
    required this.uploadTime,
  });

  static ProductModel empty() => ProductModel(
      id: '',
      name: '',
      image: '',
      categoryId: '',
      description: '',
      status: '',
      price: 0,
      salePersent: 0,
      priceSale: 0,
      unit: '',
      countBuyed: 0,
      rating: 5.0,
      origin: '',
      storeId: '',
      uploadTime: DateTime.fromMillisecondsSinceEpoch(0));

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'Image': image,
      'CategoryId': categoryId,
      'Description': description,
      'Status': status,
      'Price': price,
      'SalePersent': salePersent,
      'PriceSale': priceSale,
      'Unit': unit,
      'CountBuyed': countBuyed,
      'Rating': rating,
      'Origin': origin,
      'StoreId': storeId,
      'UploadTime': uploadTime.millisecondsSinceEpoch
    };
  }

  factory ProductModel.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return ProductModel(
        id: document.id,
        name: data['Name'] ?? '',
        image: data['Image'] ?? '',
        categoryId: data['CategoryId'] ?? '',
        description: data['Description'] ?? '',
        status: data['Status'] ?? '',
        price: int.parse((data['Price'] ?? 0).toString()),
        salePersent: int.parse((data['SalePersent'] ?? 0).toString()),
        priceSale: int.parse((data['PriceSale'] ?? 0).toString()),
        unit: data['Unit'] ?? '',
        countBuyed: int.parse((data['CountBuyed'] ?? 0).toString()),
        rating: double.parse((data['Rating'] ?? 5.0).toString()),
        origin: data['Origin'] ?? '',
        storeId: data['StoreId'] ?? '',
        uploadTime: DateTime.fromMillisecondsSinceEpoch(
            int.parse((data['UploadTime'] ?? 0).toString())),
      );
    }
    return ProductModel.empty();
  }
}
