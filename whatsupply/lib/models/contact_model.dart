import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  final String id;
  final String name;
  final String company;
  final List<String> brands;
  final bool isWholesaler;
  final String site;
  final String whatsapp;
  final String app;

  Contact({
    required this.id,
    required this.name,
    required this.company,
    required this.brands,
    required this.isWholesaler,
    required this.site,
    required this.whatsapp,
    required this.app,
  });

  factory Contact.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Contact(
      id: doc.id,
      name: data['name'] ?? '',
      company: data['company'] ?? '',
      brands: List<String>.from(data['brands'] ?? []),
      isWholesaler: data['isWholesaler'] ?? false,
      site: data['site'] ?? '',
      whatsapp: data['whatsapp'] ?? '',
      app: data['app'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'company': company,
      'brands': brands,
      'isWholesaler': isWholesaler,
      'site': site,
      'whatsapp': whatsapp,
      'app': app,
    };
  }
}
