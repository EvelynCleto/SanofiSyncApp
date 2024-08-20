import '/flutter_flow/flutter_flow_util.dart';
import '../dados/dados_widget.dart' show DadosWidget;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DadosModel extends FlutterFlowModel<DadosWidget> {
  List<Map<String, dynamic>> horarios = [];
  bool isLoading = false;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  Future<void> carregarDadosFuncionario(String idFuncionario) async {
    isLoading = true;
    final response = await Supabase.instance.client
        .from('qrcodes')
        .select('*')
        .eq('id_funcionario', idFuncionario)
        .order('created_at', ascending: false)
        .execute();

    if (response.status == 200) {
      horarios = List<Map<String, dynamic>>.from(response.data);
    }
    isLoading = false;
  }

  String formatarHorario(String horario) {
    final DateTime parsed = DateTime.parse(horario);
    return DateFormat('dd/MM/yyyy HH:mm').format(parsed);
  }
}
