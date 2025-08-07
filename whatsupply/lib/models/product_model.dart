import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String imageUrl;
  final String sku;
  final String brand;
  final String category;
  final String description;
  final Timestamp createdAt;

  Product({
    required this.id,
    required this.imageUrl,
    required this.sku,
    required this.brand,
    required this.category,
    required this.description,
    required this.createdAt,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      imageUrl: data['imageUrl'] ?? '',
      sku: data['sku'] ?? '',
      brand: data['brand'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
