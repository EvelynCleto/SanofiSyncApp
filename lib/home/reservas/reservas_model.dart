import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ReservasModel extends FlutterFlowModel {
  // Variáveis para armazenar o estado das reservas
  String? sala;
  String? data;

  // Construtor padrão
  ReservasModel();

  // Implementação obrigatória do initState
  @override
  void initState(BuildContext context) {
    // Inicializa o estado do modelo
  }

  // Implementação obrigatória do dispose
  @override
  void dispose() {
    // Limpeza do modelo, caso necessário
  }

  // Função para limpar os dados da reserva
  void clearData() {
    sala = null;
    data = null;
  }

  // Função para atualizar os dados da reserva
  void updateReserva(String novaSala, String novaData) {
    sala = novaSala;
    data = novaData;
  }
}
