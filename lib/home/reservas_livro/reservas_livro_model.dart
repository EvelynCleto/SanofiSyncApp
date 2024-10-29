import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ReservasLivroModel extends FlutterFlowModel {
  // Variáveis para armazenar o estado das reservas de livro
  String? idLivro;
  String? idFuncionario;
  String? dataReserva;
  String? dataDevolucao;

  // Construtor padrão
  ReservasLivroModel();

  // Implementação obrigatória do initState
  @override
  void initState(BuildContext context) {
    // Inicializa o estado do modelo
    dataReserva = null;
    dataDevolucao = null;
  }

  // Implementação obrigatória do dispose
  @override
  void dispose() {
    // Limpeza do modelo, caso necessário
  }

  // Função para limpar os dados da reserva
  void clearData() {
    idLivro = null;
    idFuncionario = null;
    dataReserva = null;
    dataDevolucao = null;
  }

  // Função para atualizar os dados da reserva
  void updateReserva(String novoIdLivro, String novoIdFuncionario,
      String novaDataReserva, String novaDataDevolucao) {
    idLivro = novoIdLivro;
    idFuncionario = novoIdFuncionario;
    dataReserva = novaDataReserva;
    dataDevolucao = novaDataDevolucao;
  }
}
