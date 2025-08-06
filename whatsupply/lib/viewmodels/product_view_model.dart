import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class ProductViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  /// Gera um SKU numérico de 4 dígitos e garante que ele seja único na coleção.
  Future<String> _generateUniqueSku() async {
    final random = Random();
    String sku;
    bool isUnique = false;

    do {
      // Gera um número entre 1000 e 9999 e o converte para String.
      sku = (1000 + random.nextInt(9000)).toString();
      final querySnapshot = await _firestore
          .collection('produtos')
          .where('sku', isEqualTo: sku)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        isUnique = true;
      }
    } while (!isUnique);

    return sku;
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
        'createdAt': FieldValue.serverTimestamp(), // Adiciona um timestamp de criação
      });
    } catch (e) {
      // Em uma aplicação real, você trataria este erro de forma mais robusta
      // (ex: exibindo uma mensagem para o usuário).
      debugPrint("Erro ao adicionar produto: $e");
      rethrow; // Re-lança o erro para que a UI possa reagir se necessário.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}