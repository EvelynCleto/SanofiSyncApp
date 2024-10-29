import 'package:flutter/material.dart';

class BuildEmployeeHomeModel extends ChangeNotifier {
  bool _isLoading = true;
  String _employeeName = '';

  bool get isLoading => _isLoading;
  String get employeeName => _employeeName;

  Future<void> initializeEmployeeData() async {
    // Simula uma chamada ao backend para buscar os dados do funcionário
    await Future.delayed(const Duration(seconds: 2));

    // Definir o nome do funcionário (substitua isso pela lógica real de dados)
    _employeeName = 'João Silva';

    _isLoading = false;
    notifyListeners(); // Notifica que houve mudança nos dados
  }
}
