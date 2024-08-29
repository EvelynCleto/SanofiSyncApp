import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AgendamentoModel {
  final SupabaseClient supabaseClient;

  AgendamentoModel(this.supabaseClient);

  Future<List<Map<String, dynamic>>> carregarAgendamentosPendentes() async {
    final response = await supabaseClient
        .from('agendamentos')
        .select()
        .eq('status', 'pendente')
        .execute();

    if (response.data == null) {
      return List<Map<String, dynamic>>.from(response.data);
    } else {
      throw Exception(
          'Erro ao carregar agendamentos: ${response.data!.message}');
    }
  }

  Future<void> atualizarAgendamento(
      String agendamentoId, String status, DateTime novaData) async {
    final response = await supabaseClient
        .from('agendamentos')
        .update({'status': status, 'data': novaData.toIso8601String()})
        .eq('id', agendamentoId)
        .execute();

    if (response.data != null) {
      throw Exception(
          'Erro ao atualizar agendamento: ${response.data!.message}');
    }
  }
}
