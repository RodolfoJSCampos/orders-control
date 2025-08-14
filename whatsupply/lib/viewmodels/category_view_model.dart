import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsupply/models/category_model.dart';

class CategoryViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'categories';

  List<Category> _categories = [];
  bool _isLoading = false;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  CategoryViewModel() {
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection(_collectionPath).get();
      _categories = snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory({required String name}) async {
    try {
      await _firestore.collection(_collectionPath).add({'name': name});
      await fetchCategories();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> updateCategory({required String categoryId, required String name}) async {
    try {
      await _firestore.collection(_collectionPath).doc(categoryId).update({'name': name});
      await fetchCategories();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore.collection(_collectionPath).doc(categoryId).delete();
      await fetchCategories();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
