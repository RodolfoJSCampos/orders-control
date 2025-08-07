import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import '../models/product_model.dart';

class ProductViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  List<Product> _products = [];

  bool get isLoading => _isLoading;
  List<Product> get products => _products;

  Future<String> _generateUniqueSku() async {
    final random = Random();
    String sku;
    bool isUnique = false;

    do {
      sku = (1000 + random.nextInt(9000)).toString();
      final querySnapshot =
          await _firestore.collection('produtos').where('sku', isEqualTo: sku).limit(1).get();

      if (querySnapshot.docs.isEmpty) {
        isUnique = true;
      }
    } while (!isUnique);

    return sku;
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final querySnapshot =
          await _firestore.collection('produtos').orderBy('createdAt', descending: true).get();
      _products =
          querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint("Erro ao buscar produtos: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct({
    required String imageUrl,
    required String brand,
    required String category,
    required String description,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final String newSku = await _generateUniqueSku();

      await _firestore.collection('produtos').add({
        'imageUrl': imageUrl,
        'sku': newSku,
        'brand': brand,
        'category': category,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await fetchProducts();
    } catch (e) {
      debugPrint("Erro ao adicionar produto: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct({
    required String productId,
    required String description,
    required String brand,
    required String category,
    required String imageUrl,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> updatedData = {
        'description': description,
        'brand': brand,
        'category': category,
        'imageUrl': imageUrl,
      };

      await _firestore.collection('produtos').doc(productId).update(updatedData);
      await fetchProducts();

    } catch (e) {
      debugPrint("Erro ao atualizar produto: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('produtos').doc(productId).delete();
      _products.removeWhere((product) => product.id == productId);
    } catch (e) {
      debugPrint("Erro ao excluir produto: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}