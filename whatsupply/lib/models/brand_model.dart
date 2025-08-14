import 'package:cloud_firestore/cloud_firestore.dart';


class Brand {
  final String id;
  final String name;
  final List<String> categories; // Storing category names as strings

  Brand({
    required this.id,
    required this.name,
    required this.categories,
  });

  factory Brand.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Brand(
      id: doc.id,
      name: data['name'] ?? '',
      categories: List<String>.from(data['categories'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'categories': categories,
    };
  }
}
