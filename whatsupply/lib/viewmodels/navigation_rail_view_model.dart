import 'package:flutter/material.dart';

class NavigationRailViewModel extends ChangeNotifier {
  bool _isExtended = false;

  bool get isExtended => _isExtended;

  void toggle() {
    _isExtended = !_isExtended;
    notifyListeners();
  }

  void set(bool value) {
    _isExtended = value;
    notifyListeners();
  }
}
