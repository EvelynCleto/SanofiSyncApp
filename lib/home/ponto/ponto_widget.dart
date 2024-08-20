import 'package:shared_preferences/shared_preferences.dart';

import '../home/home_widget.dart';
import '../my_account/my_account_widget.dart';
import '../pesquisa/pesquisa_widget.dart';
import '../treinamentos/treinamentos_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'ponto_model.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:supabase_flutter/supabase_flutter.dart';

export 'ponto_model.dart';

class PontoWidget extends StatefulWidget {
  final Function(String, String, String)? onPontoUpdated; // Callback para atualizar os dados em outras telas

  const PontoWidget({super.key, this.onPontoUpdated});

  @override
  State<PontoWidget> createState() => _PontoWidgetState();
}

class _PontoWidgetState extends State<PontoWidget> {
  late PontoModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String entrada = '';
  String saida = '';
  String horasTrabalhadas = '';
  String descanso = '';

  Timer? _timer;
  DateTime? startTime;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PontoModel());
    _loadSavedDataFromDatabase();

    // Initialize the timer
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _model.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadSavedDataFromDatabase() async {
    final supabaseClient = Supabase.instance.client;
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email') ?? '';

    if (email.isEmpty) {
      print('Erro: Email do usuário não encontrado.');
      return;
    }

    try {
      final response = await supabaseClient
          .from('pontos')
          .select('*')
          .eq('user_email', email)
          .order('created_at', ascending: false)
          .limit(1)
          .execute();

      if (response.data != null && response.data.isNotEmpty) {
        final lastPoint = response.data[0];
        setState(() {
          entrada = lastPoint['entry_time'] ?? '';
          saida = lastPoint['exit_time'] ?? '';
          horasTrabalhadas = lastPoint['horas_trabalhadas'] ?? '';
          String? savedStartTime = lastPoint['created_at'];
          if (savedStartTime != null && entrada.isNotEmpty && saida.isEmpty) {
            startTime = DateTime.parse(savedStartTime);
          }
        });
      }
    } catch (e) {
      print('Erro ao carregar dados do banco de dados: $e');
    }
  }

  Future<void> _saveDataToDatabase() async {
    final supabaseClient = Supabase.instance.client;
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email') ?? '';

    if (email.isEmpty) {
      print('Erro: Email do usuário não encontrado.');
      return;
    }

    try {
      final response = await supabaseClient.from('pontos').insert({
        'user_email': email,
        'entry_time': entrada,
        'exit_time': saida,
        'horas_trabalhadas': horasTrabalhadas,
        'created_at': startTime != null ? startTime!.toIso8601String() : DateTime.now().toIso8601String(),
      }).execute();

      if (response.data == null) {
        print('Erro ao salvar dados no banco de dados.');
      } else {
        print('Dados salvos com sucesso no banco de dados.');
      }
    } catch (e) {
      print('Erro ao salvar dados no banco de dados: $e');
    }
  }

  void _marcarPonto() {
    if (entrada.isEmpty) {
      startTime = DateTime.now();
      entrada = DateFormat('HH:mm').format(startTime!);
    } else if (saida.isEmpty) {
      saida = DateFormat('HH:mm').format(DateTime.now());
      final difference = DateTime.now().difference(startTime!);
      horasTrabalhadas = '${difference.inHours.toString().padLeft(2, '0')}:${(difference.inMinutes % 60).toString().padLeft(2, '0')}';
      startTime = null;
    } else {
      // Reset the point after the user finalizes
      entrada = '';
      saida = '';
      horasTrabalhadas = '';
    }

    _saveDataToDatabase();
    _notifyOtherScreens(); // Notifica outras telas que o ponto foi atualizado
    setState(() {});
  }

  void _notifyOtherScreens() {
    if (widget.onPontoUpdated != null) {
      widget.onPontoUpdated!(entrada, saida, horasTrabalhadas);
    }
  }

  void _mostrarControleHoras() {
    // Display the detailed hours control with a modal or new screen
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: const Color(0xFFBB4CFF),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Controle de horas do mês',
                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                    fontFamily: 'Readex Pro',
                    color: Colors.white,
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildInfoRow(context, 'Entradas:', entrada),
                _buildInfoRow(context, 'Saídas:', saida),
                _buildInfoRow(context, 'Horas Trabalhadas:', horasTrabalhadas),
                _buildInfoRow(context, 'Horas em Descanso:', descanso),
                const SizedBox(height: 20),
                FFButtonWidget(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  text: 'Fechar',
                  options: FFButtonOptions(
                    width: 120,
                    height: 40,
                    color: Colors.white,
                    textStyle: FlutterFlowTheme.of(context).labelMedium.override(
                      fontFamily: 'Readex Pro',
                      color: const Color(0xFFBB4CFF),
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'Readex Pro',
              color: Colors.white,
              fontSize: 16.0,
            ),
          ),
          Text(
            value.isNotEmpty ? value : '--:--',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'Readex Pro',
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentTime() {
    return DateFormat('HH:mm').format(DateTime.now());
  }

  double _getPercentage() {
    if (startTime == null) return 0.0;
    final now = DateTime.now();
    final elapsed = now.difference(startTime!).inSeconds;
    final total = const Duration(hours: 8).inSeconds; // Assuming an 8-hour workday
    return (elapsed / total).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currentTime = _getCurrentTime();
    final rotationAngle = (_getPercentage() * 2 * math.pi) - (math.pi / 2);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFBB4CFF),
        drawer: Drawer(
          child: MyAccountWidget(),
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 70.0, 0.0, 0.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                FlutterFlowIconButton(
                                  borderColor: Colors.transparent,
                                  borderRadius: 20.0,
                                  borderWidth: 1.0,
                                  buttonSize: size.width * 0.1,
                                  icon: const Icon(
                                    Icons.density_medium,
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
                                      'PONTO',
                                      textAlign: TextAlign.center,
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
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
                                    Icons.location_history,
                                    color: Color(0xFFE6EEF0),
                                    size: 37.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(0.0, 0.0),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 0.0),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularPercentIndicator(
                                percent: _getPercentage(),
                                radius: size.width * 0.3,
                                lineWidth: size.width * 0.05,
                                animation: true,
                                animateFromLastPercent: true,
                                progressColor: const Color(0xFF701B90),
                                backgroundColor: const Color(0xFFF1F4F8),
                              ),
                              Transform.rotate(
                                angle: rotationAngle,
                                child: Container(
                                  width: 8.0,
                                  height: size.width * 0.15,
                                  color: const Color(0xFF701B90),
                                ),
                              ),
                              Text(
                                currentTime,
                                style: FlutterFlowTheme.of(context).displaySmall.override(
                                  fontFamily: 'Outfit',
                                  color: Colors.white,
                                  fontSize: size.width * 0.07,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(10.0, 20.0, 10.0, 0.0),
                        child: FFButtonWidget(
                          onPressed: _marcarPonto,
                          text: entrada.isEmpty ? 'Marcar Ponto Eletrônico' : saida.isEmpty ? 'Finalizar Ponto' : 'Reiniciar',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: size.height * 0.07,
                            padding: EdgeInsets.zero,
                            color: const Color(0xFF701B90),
                            textStyle: FlutterFlowTheme.of(context).labelLarge.override(
                                  fontFamily: 'Readex Pro',
                                  color: Colors.white,
                                  letterSpacing: 0.0,
                                ),
                            elevation: 3.0,
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                        child: Container(
                          width: size.width * 0.9,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 30.0, 0.0, 0.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Entradas:',
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  fontFamily: 'Readex Pro',
                                                  color: const Color(0xFF999FA0),
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                          Text(
                                            entrada.isEmpty ? '--:--' : entrada,
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  fontFamily: 'Readex Pro',
                                                  color: Colors.black,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Saídas:',
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  fontFamily: 'Readex Pro',
                                                  color: const Color(0xFF999FA0),
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                          Text(
                                            saida.isEmpty ? '--:--' : saida,
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  fontFamily: 'Readex Pro',
                                                  color: Colors.black,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (horasTrabalhadas.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Horas trabalhadas:',
                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                fontFamily: 'Readex Pro',
                                                color: const Color(0xFF999FA0),
                                                letterSpacing: 0.0,
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        Text(
                                          horasTrabalhadas,
                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                fontFamily: 'Readex Pro',
                                                color: Colors.black,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w900,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                        child: Container(
                          width: size.width * 0.9,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 10.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Align(
                                  alignment: const AlignmentDirectional(-1.0, -1.0),
                                  child: Text(
                                    'Controle de horas do mês:',
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          fontFamily: 'Readex Pro',
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 5.0, 0.0, 0.0),
                                  child: Text(
                                    'Veja as suas horas trabalhadas, banco de horas, atestado e férias:',
                                    textAlign: TextAlign.start,
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          fontFamily: 'Readex Pro',
                                          color: const Color(0xFF999FA0),
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                                Align(
                                  alignment: const AlignmentDirectional(0.0, 0.0),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                                    child: FFButtonWidget(
                                      onPressed: _mostrarControleHoras,
                                      text: 'FIND OUT',
                                      options: FFButtonOptions(
                                        width: size.width * 0.4,
                                        height: size.height * 0.05,
                                        padding: EdgeInsets.zero,
                                        color: const Color(0xFF701B90),
                                        textStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                              fontFamily: 'Readex Pro',
                                              color: Colors.white,
                                              letterSpacing: 0.0,
                                            ),
                                        elevation: 3.0,
                                        borderSide: const BorderSide(
                                          color: Colors.transparent,
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(24.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                  padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.home,
                          color: Color(0xFFCCD3D4),
                          size: 25.0,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeWidget(),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.access_time,
                          color: Color(0xFFE0BAF7),
                          size: 25.0,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PontoWidget(
                                onPontoUpdated: (entradaAtualizada, saidaAtualizada, horasTrabalhadasAtualizadas) {
                                  setState(() {
                                    entrada = entradaAtualizada;
                                    saida = saidaAtualizada;
                                    horasTrabalhadas = horasTrabalhadasAtualizadas;
                                  });
                                },
                              ),
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
                            MaterialPageRoute(
                              builder: (context) => const PesquisaWidget(),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.person_outline_sharp,
                          color: Color(0xFFCCD3D4),
                          size: 25.0,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TreinamentosWidget(),
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
