import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:intl/intl.dart'; // Pacote intl para formatar data/hora
import 'dart:async'; // Pacote necessário para usar o Timer
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../home/home_widget.dart';
import '../my_account/my_account_widget.dart';
import '../pesquisa/pesquisa_widget.dart';
import '../ponto/ponto_widget.dart';

import '/flutter_flow/flutter_flow_calendar.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';

import 'package:geolocator/geolocator.dart';

class TreinamentosWidget extends StatefulWidget {
  const TreinamentosWidget({super.key});

  @override
  State<TreinamentosWidget> createState() => _TreinamentosWidgetState();
}

class Util {
  static Future<void> salvarDadosNoCache(
      List<Map<String, dynamic>> treinamentosFiltrados) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'cache_treinamentos', jsonEncode(treinamentosFiltrados));
  }

  static Future<List<Map<String, dynamic>>> carregarDadosCache() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cacheTreinamentos = prefs.getString('cache_treinamentos');
    if (cacheTreinamentos != null && cacheTreinamentos.isNotEmpty) {
      return List<Map<String, dynamic>>.from(jsonDecode(cacheTreinamentos));
    }
    return [];
  }
}

class _TreinamentosWidgetState extends State<TreinamentosWidget>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String? justificativaSelecionada;
  late TabController _tabController;
  bool isLoading = true;
  bool isTreinamentoNoPassado(Map<String, dynamic> treinamento) {
    final dataTreinamento = DateTime.parse(treinamento['data_inicio']);
    final agora = DateTime.now();
    return dataTreinamento.isBefore(agora);
  }

  String? userEmail;
  String? userDepartment;
  List<Map<String, dynamic>> treinamentosFiltrados = [];
  String filtroStatus = 'Todos';
  late SignatureController _controller;

  @override
  void initState() {
    super.initState();
    carregarDados();
    _tabController = TabController(length: 3, vsync: this);
    carregarAbaAtiva().then((index) {
      setState(() {
        _tabController.index = index; // Define a aba inicial
      });
    });
    _controller = SignatureController(
      penStrokeWidth: 5,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
    final subscription = Supabase.instance.client
        .from('treinamentos')
        .stream(primaryKey: ['id']).listen((treinamentosAtualizados) {
      setState(() {
        treinamentosFiltrados =
            List<Map<String, dynamic>>.from(treinamentosAtualizados);
        Util.salvarDadosNoCache(treinamentosFiltrados);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _showJustifyModal(String idTreinamento) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Justifique sua falta',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Selecione uma justificativa',
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.purpleAccent, width: 2.0),
                      ),
                    ),
                    items: <String>[
                      'Problema de saúde',
                      'Compromisso familiar',
                      'Problema de transporte',
                      'Outros'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        justificativaSelecionada =
                            newValue; // Armazena a justificativa
                      });
                    },
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onPressed: () {
                      if (justificativaSelecionada == null ||
                          justificativaSelecionada!.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Por favor, selecione uma justificativa.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Fecha o modal de justificativa
                      Navigator.pop(context);

                      // Exibe o modal de assinatura
                      _showSignatureModal(
                          context, // Primeiro argumento, o contexto
                          idTreinamento, // Segundo argumento, o ID do treinamento
                          justificativaSelecionada! // Terceiro argumento, a justificativa selecionada
                          );
                    },
                    child: const Text(
                      'Continuar para Assinatura',
                      style: TextStyle(fontSize: 16.0, color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSignatureModal(BuildContext context, String idTreinamento,
      String justificativaSelecionada) {
    SignatureController _signatureController = SignatureController(
      penStrokeWidth: 5,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Assine abaixo para confirmar',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15.0),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Signature(
                  controller: _signatureController,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 15.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _signatureController.clear(); // Limpa a assinatura
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                    ),
                    icon: const Icon(Icons.clear, color: Colors.white),
                    label: const Text('Limpar',
                        style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (_signatureController.isNotEmpty) {
                        final signatureImage =
                            await _signatureController.toImage();
                        final byteData = await signatureImage?.toByteData(
                          format: ui.ImageByteFormat.png,
                        );
                        final pngBytes = byteData!.buffer.asUint8List();
                        final base64Signature = base64Encode(pngBytes);

                        // Salvar justificativa e assinatura
                        await salvarCheckIn(
                          idTreinamento,
                          justificativa: justificativaSelecionada,
                          assinatura: base64Signature,
                        );

                        // Atualiza o status do treinamento para 'Falta Justificada'
                        setState(() {
                          final treinamento = treinamentosFiltrados.firstWhere(
                              (treinamento) =>
                                  treinamento['id'] == idTreinamento);
                          treinamento['status'] = 'Falta Justificada';
                        });

                        // Fecha o modal após salvar
                        Navigator.pop(context);

                        // Mudar para a última aba (aba de "Concluídos" ou "Justificados")
                        _tabController.animateTo(2);

                        // Exibir mensagem de sucesso
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Justificado com sucesso.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Por favor, forneça sua assinatura.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                    ),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text('Confirmar Assinatura',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void salvarEstadoAbas() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('estado_abas', jsonEncode(treinamentosFiltrados));
  }

  void salvarAbaAtiva(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('aba_ativa', index);
  }

  Future<int> carregarAbaAtiva() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('aba_ativa') ?? 0; // 0 é o índice padrão
  }

  Future<void> carregarEstadoAbas() async {
    final prefs = await SharedPreferences.getInstance();
    final String? estadoAbas = prefs.getString('estado_abas');
    if (estadoAbas != null && estadoAbas.isNotEmpty) {
      setState(() {
        treinamentosFiltrados =
            List<Map<String, dynamic>>.from(jsonDecode(estadoAbas));
      });
    }
  }

  Future<void> salvarCheckIn(String idTreinamento,
      {String? justificativa, String? assinatura}) async {
    try {
      // Exemplo simples de como salvar no Supabase. Adapte conforme sua estrutura de banco de dados.
      final response = await Supabase.instance.client.from('check_ins').insert({
        'id_treinamento': idTreinamento,
        'justificativa': justificativa,
        'assinatura': assinatura,
        'data_check_in': DateTime.now().toIso8601String(),
      }).execute();

      if (response.status == 201) {
        print('Check-in salvo com sucesso.');
      } else {
        print('Erro ao salvar check-in: ${response.data.message}');
      }
    } catch (e) {
      print('Erro ao salvar check-in: $e');
    }
  }

  Future<void> carregarDados() async {
    await carregarEmailUsuarioLogado();
    await carregarDepartamentoUsuarioLogado();
    carregarTreinamentos();
  }

  Future<void> carregarEmailUsuarioLogado() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('user_email');
    });
  }

  Future<void> carregarDepartamentoUsuarioLogado() async {
    try {
      final response = await Supabase.instance.client
          .from('Acesso Geral')
          .select('departamento')
          .eq('email', userEmail)
          .single()
          .execute();

      if (response.data != null && response.data.isNotEmpty) {
        setState(() {
          userDepartment = response.data['departamento'];
        });
      } else {
        print('Nenhum departamento encontrado para o usuário.');
      }
    } catch (e) {
      print('Erro ao buscar detalhes do usuário: $e');
    }
  }

  DateTime? formatarDataHora(String data, String hora) {
    try {
      // Remover o 'T' e combinar data e hora corretamente
      final dateTimeString = '$data $hora'.replaceAll('T', ' ');
      print('Tentando combinar data e hora: $dateTimeString');

      // Ajuste o formato da string para um formato válido
      final dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTimeString);
      print('Data e hora combinadas com sucesso: $dateTime');
      return dateTime;
    } catch (e) {
      print('Erro ao formatar data e hora: $e');
      return null;
    }
  }

  double calcularProgressoTreinamento(Map<String, dynamic> treinamento) {
    final dataInicio = DateTime.parse(treinamento['data_inicio']);
    final dataFim = DateTime.parse(treinamento['data_fim']);
    final dataAtual = DateTime.now();

    if (dataAtual.isAfter(dataFim)) {
      return 1.0;
    } else if (dataAtual.isBefore(dataInicio)) {
      return 0.0;
    } else {
      final duracaoTotal = dataFim.difference(dataInicio).inMinutes;
      final duracaoAteAgora = dataAtual.difference(dataInicio).inMinutes;
      return (duracaoAteAgora / duracaoTotal).clamp(0.0, 1.0);
    }
  }

  void carregarTreinamentos() async {
    // Exemplo para garantir que os dados estejam corretos
    final response =
        await Supabase.instance.client.from('treinamentos').select().execute();

    if (response.data == null) {
      setState(() {
        treinamentosFiltrados = List<Map<String, dynamic>>.from(response.data);
        // Verificar se os dados do treinamento têm o status correto
        treinamentosFiltrados.forEach((treinamento) {
          print(
              'Treinamento: ${treinamento['descricao']}, Status: ${treinamento['status']}');
        });
      });
    }
  }

  Widget _buildTreinamentoCardComJustificar(Map<String, dynamic> treinamento) {
    return Card(
      elevation: 6.0,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ExpansionTile(
        leading: Icon(
          Icons.assignment_late,
          color: Colors.redAccent,
        ),
        title: Text(
          treinamento['descricao'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Início: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(treinamento['data_inicio']))} ${treinamento['horario_inicio']}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            Text(
              'Data Fim: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(treinamento['data_fim']))} ${treinamento['horario_fim']}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            Text(
              'Localização: ${treinamento['localizacao'] ?? 'Não informado'}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Participantes: ${treinamento['participantes'] ?? 'Não informado'}',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 10),
                LinearPercentIndicator(
                  lineHeight: 8.0,
                  percent: calcularProgressoTreinamento(treinamento),
                  backgroundColor: Colors.grey.shade300,
                  progressColor: Colors.purpleAccent,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showJustifyModal(treinamento['id']);
                      atualizarStatusTreinamento(
                          treinamento, 'Falta Justificada',
                          justificativa:
                              justificativaSelecionada); // Passa a justificativa
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Justificar Falta'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreinamentoCardComBotoesComFinalizar(
      Map<String, dynamic> treinamento) {
    return Card(
      elevation: 6.0,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ExpansionTile(
        leading: Icon(
          Icons.assignment,
          color: Colors.purpleAccent,
        ),
        title: Text(
          treinamento['descricao'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Início: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(treinamento['data_inicio']))} ${treinamento['horario_inicio']}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            Text(
              'Data Fim: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(treinamento['data_fim']))} ${treinamento['horario_fim']}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            Text(
              'Localização: ${treinamento['localizacao'] ?? 'Não informado'}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Participantes: ${treinamento['participantes'] ?? 'Não informado'}',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 10),
                LinearPercentIndicator(
                  lineHeight: 8.0,
                  percent: calcularProgressoTreinamento(treinamento),
                  backgroundColor: Colors.grey.shade300,
                  progressColor: Colors.purpleAccent,
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      atualizarStatusTreinamento(treinamento, 'Concluído');
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Cor verde para finalizar
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15), // Tamanho do botão
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12.0), // Bordas arredondadas
                    ),
                    elevation: 6, // Sombra
                  ),
                  icon: const Icon(Icons.task_alt,
                      color: Colors.white, size: 24), // Ícone de finalização
                  label: const Text(
                    'Finalizar Tarefa',
                    style: TextStyle(
                        fontSize: 16.0, color: Colors.white), // Texto do botão
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreinamentoCardSemBotoes(Map<String, dynamic> treinamento) {
    String statusMensagem = '';

    // Checa o status e exibe a mensagem adequada
    if (treinamento['status'] == 'Falta Justificada') {
      statusMensagem = 'Falta justificada com sucesso.';
    } else if (treinamento['status'] == 'Concluído') {
      statusMensagem = 'Treinamento concluído com sucesso, parabéns!';
    }

    return Card(
      elevation: 6.0,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ExpansionTile(
        leading: Icon(
          Icons.assignment,
          color: Colors.purpleAccent,
        ),
        title: Text(
          treinamento['descricao'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Início: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(treinamento['data_inicio']))} ${treinamento['horario_inicio']}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            Text(
              'Data Fim: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(treinamento['data_fim']))} ${treinamento['horario_fim']}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            Text(
              'Localização: ${treinamento['localizacao'] ?? 'Não informado'}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            // Exibe a justificativa se existir
            if (treinamento['justificativa'] != null)
              Text(
                'Justificativa: ${treinamento['justificativa']}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            // Exibe a mensagem apropriada
            if (statusMensagem.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  statusMensagem,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: statusMensagem ==
                            'Treinamento concluído com sucesso, parabéns!'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget exibirBotaoConfirmacaoOuJustificativa(
      Map<String, dynamic> treinamento) {
    final agora = DateTime.now();
    final dataTreinamento = DateTime.parse(treinamento['data_inicio']);
    final horarioInicioTreinamento = DateTime(
      dataTreinamento.year,
      dataTreinamento.month,
      dataTreinamento.day,
      int.parse(treinamento['horario_inicio'].split(':')[0]),
      int.parse(treinamento['horario_inicio'].split(':')[1]),
    );
    final horarioAssinaturaPermitido =
        horarioInicioTreinamento.subtract(const Duration(minutes: 5));
    final horarioMaximoAssinatura =
        horarioInicioTreinamento.add(const Duration(minutes: 5));

    // Verifica se o horário está antes do permitido
    if (agora.isBefore(horarioAssinaturaPermitido)) {
      final diferenca = horarioAssinaturaPermitido.difference(agora);
      final horasRestantes = diferenca.inHours;
      final minutosRestantes = diferenca.inMinutes % 60;
      final segundosRestantes = diferenca.inSeconds % 60;

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.access_time_outlined,
              color: Colors.purpleAccent,
              size: 50.0,
            ),
            const SizedBox(height: 10),
            Text(
              horasRestantes > 0
                  ? 'Faltam $horasRestantes horas, $minutosRestantes minutos e $segundosRestantes segundos para assinar'
                  : 'Faltam $minutosRestantes minutos e $segundosRestantes segundos para assinar',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: Colors.purpleAccent,
              ),
            ),
          ],
        ),
      );
    }

    // Verifica se está no intervalo permitido para assinar
    if (agora.isAfter(horarioAssinaturaPermitido) &&
        agora.isBefore(horarioMaximoAssinatura)) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.greenAccent,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        onPressed: () {
          _showSignatureModalConfirmarPresenca(treinamento['id']);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check_circle, size: 28, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Confirmar Presença',
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
          ],
        ),
      );
    }

    // Verifica se já passou o horário de assinatura
    if (agora.isAfter(horarioMaximoAssinatura)) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orangeAccent,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        onPressed: () {
          _showJustifyModal(treinamento['id']);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.warning_amber_outlined, size: 28, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Justificar Falta',
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showSignatureModalConfirmarPresenca(String idTreinamento) {
    SignatureController _signatureController = SignatureController(
      penStrokeWidth: 5,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Assine abaixo para confirmar presença',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15.0),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Signature(
                  controller: _signatureController,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 15.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _signatureController.clear(); // Limpa a assinatura
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                    ),
                    icon: const Icon(Icons.clear, color: Colors.white),
                    label: const Text('Limpar',
                        style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (_signatureController.isNotEmpty) {
                        final signatureImage =
                            await _signatureController.toImage();
                        final byteData = await signatureImage?.toByteData(
                          format: ui.ImageByteFormat.png,
                        );
                        final pngBytes = byteData!.buffer.asUint8List();
                        final base64Signature = base64Encode(pngBytes);

                        // Salvar presença e assinatura
                        await salvarCheckIn(
                          idTreinamento,
                          justificativa: 'Presença Confirmada',
                          assinatura: base64Signature,
                        );

                        // Atualiza o status do treinamento para 'Em Andamento'
                        setState(() {
                          final treinamento = treinamentosFiltrados.firstWhere(
                              (treinamento) =>
                                  treinamento['id'] == idTreinamento);
                          treinamento['status'] = 'Em Andamento';
                        });

                        // Fechar o modal após salvar
                        Navigator.pop(context);

                        // Mudar para a segunda aba (aba de "Em Andamento")
                        _tabController.animateTo(1);

                        // Exibir mensagem de sucesso
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Presença confirmada com sucesso.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Por favor, forneça sua assinatura.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                    ),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text('Confirmar Presença',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTreinamentoCardComBotoes(Map<String, dynamic> treinamento) {
    return Card(
      elevation: 6.0,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ExpansionTile(
        leading: Icon(
          Icons.assignment,
          color: Colors.purpleAccent,
        ),
        title: Text(
          treinamento['descricao'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Início: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(treinamento['data_inicio']))} ${treinamento['horario_inicio']}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            Text(
              'Data Fim: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(treinamento['data_fim']))} ${treinamento['horario_fim']}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            Text(
              'Localização: ${treinamento['localizacao'] ?? 'Não informado'}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Participantes: ${treinamento['participantes'] ?? 'Não informado'}',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 10),
                LinearPercentIndicator(
                  lineHeight: 8.0,
                  percent: calcularProgressoTreinamento(treinamento),
                  backgroundColor: Colors.grey.shade300,
                  progressColor: Colors.purpleAccent,
                ),
                const SizedBox(height: 10),
                // Exibe os botões de acordo com o status do treinamento
                exibirBotaoConfirmacaoOuJustificativa(treinamento),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreinamentoCard(Map<String, dynamic> treinamento) {
    return Card(
      elevation: 6.0,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ExpansionTile(
        leading: Icon(
          Icons.assignment,
          color: Colors.purpleAccent,
        ),
        title: Text(
          treinamento['descricao'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Início: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(treinamento['data_inicio']))} ${treinamento['horario_inicio']}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            Text(
              'Data Fim: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(treinamento['data_fim']))} ${treinamento['horario_fim']}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            Text(
              'Localização: ${treinamento['localizacao'] ?? 'Não informado'}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Participantes: ${treinamento['participantes'] ?? 'Não informado'}',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 10),
                LinearPercentIndicator(
                  lineHeight: 8.0,
                  percent: calcularProgressoTreinamento(treinamento),
                  backgroundColor: Colors.grey.shade300,
                  progressColor: Colors.purpleAccent,
                ),
                const SizedBox(height: 10),
                exibirBotaoConfirmacaoOuJustificativa(
                    treinamento), // Botões dependendo da aba e status
              ],
            ),
          ),
        ],
      ),
    );
  }

  String formatarParaExibicao(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
  }

  void atualizarStatusTreinamento(
      Map<String, dynamic> treinamento, String status,
      {String? justificativa}) {
    setState(() {
      // Atualiza o status e a justificativa do treinamento
      treinamento['status'] = status;
      if (justificativa != null) {
        treinamento['justificativa'] = justificativa;
      }

      // Salva as mudanças no cache/local storage ou banco de dados
      Util.salvarDadosNoCache(treinamentosFiltrados);

      // Recalcula as listas filtradas após a mudança do status
      treinamentosFiltrados = List<Map<String, dynamic>>.from(
          treinamentosFiltrados); // Isso garante que a lista seja atualizada no estado
    });
  }

  Widget exibirInformacaoTreinamento(Map<String, dynamic> treinamento) {
    final inicioTreinamento = formatarDataHora(
      treinamento['data_inicio'],
      treinamento['horario_inicio'],
    );
    final fimTreinamento = formatarDataHora(
      treinamento['data_fim'],
      treinamento['horario_fim'],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Início: ${inicioTreinamento != null ? formatarParaExibicao(inicioTreinamento) : 'Erro ao formatar data/hora'}',
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        Text(
          'Fim: ${fimTreinamento != null ? formatarParaExibicao(fimTreinamento) : 'Erro ao formatar data/hora'}',
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFBB4CFF),
        drawer: Drawer(child: MyAccountWidget()),
        body: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 70.0, 0.0, 0.0),
              child: Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        FlutterFlowIconButton(
                          borderColor: Colors.transparent,
                          borderRadius: 20.0,
                          borderWidth: 1.0,
                          buttonSize: size.width * 0.1,
                          icon: const Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 24.0,
                          ),
                          onPressed: () {
                            scaffoldKey.currentState?.openDrawer();
                          },
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'TREINAMENTOS',
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Readex Pro',
                                    color: Colors.white,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                        ),
                        const Align(
                          alignment: AlignmentDirectional(1.0, -1.0),
                          child: Icon(
                            Icons.person_outline,
                            color: Color(0xFFE6EEF0),
                            size: 37.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    TabBar(
                      controller: _tabController, // Adiciona o controlador
                      onTap: (index) {
                        salvarAbaAtiva(index);
                      },
                      tabs: [
                        Tab(icon: Icon(Icons.pending)),
                        Tab(icon: Icon(Icons.sync)),
                        Tab(icon: Icon(Icons.done_all)),
                      ],
                      indicatorColor: Colors.white,
                      indicatorPadding:
                          const EdgeInsets.symmetric(vertical: 8.0),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                child: TabBarView(
                  controller: _tabController, // Adiciona o controlador
                  children: [
                    // Primeira aba: Exibe os treinamentos que não estão em andamento ou concluídos
                    ListView.builder(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 0.0, 20.0, 0.0),
                      itemCount: treinamentosFiltrados
                          .where((treinamento) =>
                              treinamento['status'] != 'Em Andamento' &&
                              treinamento['status'] != 'Concluído' &&
                              treinamento['status'] != 'Falta Justificada')
                          .toList()
                          .length,
                      itemBuilder: (context, i) {
                        final treinamento = treinamentosFiltrados
                            .where((treinamento) =>
                                treinamento['status'] != 'Em Andamento' &&
                                treinamento['status'] != 'Concluído' &&
                                treinamento['status'] != 'Falta Justificada')
                            .toList()[i];
                        return _buildTreinamentoCardComBotoes(treinamento);
                      },
                    ),

                    // Segunda aba: Exibe treinamentos "Em Andamento"
                    ListView.builder(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 0.0, 20.0, 0.0),
                      itemCount: treinamentosFiltrados
                          .where((treinamento) =>
                              treinamento['status'] == 'Em Andamento')
                          .toList()
                          .length,
                      itemBuilder: (context, i) {
                        final treinamento = treinamentosFiltrados
                            .where((treinamento) =>
                                treinamento['status'] == 'Em Andamento')
                            .toList()[i];
                        return _buildTreinamentoCardComBotoesComFinalizar(
                            treinamento);
                      },
                    ),

                    // Terceira aba: Exibe os treinamentos "Concluídos" e "Falta Justificada"
                    ListView.builder(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 0.0, 20.0, 0.0),
                      itemCount: treinamentosFiltrados
                          .where((treinamento) =>
                              treinamento['status'] == 'Concluído' ||
                              treinamento['status'] == 'Falta Justificada')
                          .toList()
                          .length,
                      itemBuilder: (context, i) {
                        final treinamento = treinamentosFiltrados
                            .where((treinamento) =>
                                treinamento['status'] == 'Concluído' ||
                                treinamento['status'] == 'Falta Justificada')
                            .toList()[i];
                        return _buildTreinamentoCardSemBotoes(treinamento);
                      },
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: const AlignmentDirectional(0.0, 1.0),
              child: Container(
                width: size.width,
                height: size.height * 0.07,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      20.0, 0.0, 20.0, 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.home,
                          color: Color(0xFFCCD3D4),
                          size: 22.0,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const HomeWidget(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                const begin = Offset(0.0, 1.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;

                                var tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);

                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.access_time,
                          color: Color(0xFFCCD3D4),
                          size: 25.0,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const PontoWidget(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                const begin = Offset(0.0, 1.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;

                                var tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);

                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.search,
                          color: Color(0xFFCCD3D4),
                          size: 25.0,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const PesquisaWidget(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                const begin = Offset(0.0, 1.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;

                                var tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);

                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.person_outline_sharp,
                          color: Color(0xFFE0BAF7),
                          size: 25.0,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const TreinamentosWidget(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                const begin = Offset(0.0, 1.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;

                                var tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);

                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
