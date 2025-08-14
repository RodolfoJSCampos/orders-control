import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsupply/models/contact_model.dart';

class ContactViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'contacts';
  final String _brandsCollectionPath = 'brands';

  List<Contact> _contacts = [];
  List<String> _brands = [];
  bool _isLoading = false;

  List<Contact> get contacts => _contacts;
  List<String> get brands => _brands;
  bool get isLoading => _isLoading;

  ContactViewModel() {
    fetchContacts();
    fetchBrands();
  }

  Future<void> fetchContacts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection(_collectionPath).get();
      _contacts = snapshot.docs.map((doc) => Contact.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBrands() async {
    try {
      final snapshot = await _firestore.collection(_brandsCollectionPath).get();
      _brands = snapshot.docs.map((doc) => doc['name'] as String).toList();
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
      // If the brands collection doesn't exist, we can add some default ones.
      if (e is FirebaseException && e.code == 'not-found') {
        await _addDefaultBrands();
        await fetchBrands();
      }
    }
  }

  Future<void> _addDefaultBrands() async {
    final defaultBrands = ['Nestlé', 'Mars', 'Ferrero', 'Lacta', 'Kellogg\'s'];
    for (var brand in defaultBrands) {
      await _firestore.collection(_brandsCollectionPath).add({'name': brand});
    }
  }

  Future<void> addContact({
    required String name,
    required String company,
    required List<String> brands,
    required bool isWholesaler,
    required String site,
    required String whatsapp,
    required String app,
  }) async {
    try {
      await _firestore.collection(_collectionPath).add({
        'name': name,
        'company': company,
        'brands': brands,
        'isWholesaler': isWholesaler,
        'site': site,
        'whatsapp': whatsapp,
        'app': app,
      });
      await fetchContacts();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> updateContact({
    required String contactId,
    required String name,
    required String company,
    required List<String> brands,
    required bool isWholesaler,
    required String site,
    required String whatsapp,
    required String app,
  }) async {
    try {
      await _firestore.collection(_collectionPath).doc(contactId).update({
        'name': name,
        'company': company,
        'brands': brands,
        'isWholesaler': isWholesaler,
        'site': site,
        'whatsapp': whatsapp,
        'app': app,
      });
      await fetchContacts();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> deleteContact(String contactId) async {
    try {
      await _firestore.collection(_collectionPath).doc(contactId).delete();
      await fetchContacts();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}