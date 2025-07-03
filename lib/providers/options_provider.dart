import 'package:flutter/material.dart';

class OptionsProvider extends ChangeNotifier {
  final List<String> _options = [];

  List<String> get options => List.unmodifiable(_options);

  void addOption(String option) {
    if (option.trim().isEmpty) return;
    _options.add(option.trim());
    notifyListeners();
  }

  void removeOption(int index) {
    if (index >= 0 && index < _options.length) {
      _options.removeAt(index);
      notifyListeners();
    }
  }

  void clearOptions() {
    _options.clear();
    notifyListeners();
  }
} 