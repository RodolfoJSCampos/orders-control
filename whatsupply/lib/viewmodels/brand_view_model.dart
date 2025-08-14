import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsupply/models/brand_model.dart';

class BrandViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'brands';

  List<Brand> _brands = [];
  bool _isLoading = false;

  List<Brand> get brands => _brands;
  bool get isLoading => _isLoading;

  BrandViewModel() {
    fetchBrands();
  }

  Future<void> fetchBrands() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection(_collectionPath).get();
      _brands = snapshot.docs.map((doc) => Brand.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBrand({
    required String name,
    required List<String> categories,
  }) async {
    try {
      await _firestore.collection(_collectionPath).add({
        'name': name,
        'categories': categories,
      });
      await fetchBrands();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> updateBrand({
    required String brandId,
    required String name,
    required List<String> categories,
  }) async {
    try {
      await _firestore.collection(_collectionPath).doc(brandId).update({
        'name': name,
        'categories': categories,
      });
      await fetchBrands();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> deleteBrand(String brandId) async {
    try {
      await _firestore.collection(_collectionPath).doc(brandId).delete();
      await fetchBrands();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
