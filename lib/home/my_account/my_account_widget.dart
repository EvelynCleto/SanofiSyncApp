import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ponto/ponto_widget.dart';
import '../home/home_widget.dart';
import '../pesquisa/pesquisa_widget.dart';
import '../treinamentos/treinamentos_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '../../login_cadastro/welcome/welcome_widget.dart';
import 'my_account_model.dart';
import '../../gestao/gestao/gestao_widget.dart';
import '../reservas/reservas_widget.dart'; // Certifique-se de que o caminho está correto
import '../../login_cadastro/notification_allow/notification_allow_widget.dart';
export 'my_account_model.dart';

class MyAccountWidget extends StatefulWidget {
  const MyAccountWidget({super.key});

  @override
  State<MyAccountWidget> createState() => _MyAccountWidgetState();
}

class _MyAccountWidgetState extends State<MyAccountWidget> {
  late MyAccountModel _model;
  String? userEmail;
  bool isGestor = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MyAccountModel());
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('user_email') ?? 'Email não disponível';
      isGestor = prefs.getBool('is_gestor') ?? false;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Limpa todas as preferências

    // Remover todas as rotas até a raiz e empurrar a nova tela
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const WelcomeWidget()),
      (route) => false,
    );
  }

  Future<void> cadastrarFuncionarioPeloGestor(
      String nomeFuncionario,
      String emailFuncionario,
      String nomeTreinamento,
      String dataTreinamento) async {
    try {
      // Lógica de cadastro de funcionário
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao cadastrar funcionário ou treinamento: $e')),
      );
    }
  }

  Future<void> inserirFuncionarioNoBanco(String nome, String email) async {
    // Simulação de inserção no banco de dados
  }

  Future<void> _cadastrarTreinamento(String nomeTreinamento,
      String dataTreinamento, String emailFuncionario) async {
    // Simulação de inserção de treinamento no banco de dados
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: SafeArea(
          top: true,
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(10.0, 30.0, 10.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Align(
                      alignment: const AlignmentDirectional(-1.0, -1.0),
                      child: FFButtonWidget(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        text: '',
                        icon: const Icon(
                          Icons.chevron_left,
                          color: Color(0xFF8B8989),
                          size: 40.0,
                        ),
                        options: FFButtonOptions(
                          padding: EdgeInsets.zero,
                          iconPadding: EdgeInsets.zero,
                          color: Colors.transparent,
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    fontFamily: 'Readex Pro',
                                    color: const Color(0x005C5C5C),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                          elevation: 0.0,
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            width: 0.0,
                          ),
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        showLoadingIndicator: false,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Minha conta',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Readex Pro',
                                    color: const Color(0xFFB751F6),
                                    fontSize: 26.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      20.0, 5.0, 20.0, 0.0),
                  child: Container(
                    width: size.width * 0.9,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Divider(
                              thickness: 0.5, color: Color(0xFF404951)),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 20.0, 0.0, 0.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                const Align(
                                  alignment: AlignmentDirectional(-1.0, 0.0),
                                  child: Icon(
                                    Icons.supervised_user_circle_rounded,
                                    color: Color(0xFF7561F2),
                                    size: 24.0,
                                  ),
                                ),
                                Flexible(
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            15.0, 0.0, 0.0, 0.0),
                                    child: Text(
                                      userEmail ?? 'Email não disponível',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Readex Pro',
                                            fontSize: 17.0,
                                            letterSpacing: 0.0,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                          // Agora as opções de Reservar e Notificações aparecem para todos
                          Row(
                            children: [
                              const Icon(Icons.event,
                                  color: Color(0xFF6F7F8E), size: 24.0),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    15.0, 0.0, 0.0, 0.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ReservasWidget(
                                            usuarioId: userEmail ?? ''),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Reservar Eventos/Salas',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          fontSize: 15.0,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const Icon(Icons.notifications,
                                  color: Color(0xFF6F7F8E), size: 24.0),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    15.0, 0.0, 0.0, 0.0),
                                child: GestureDetector(
                                  onTap: () {
                                    // Navegação para a tela de notificações
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const NotificationAllowWidget()),
                                    );
                                  },
                                  child: Text(
                                    'Notificações',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          fontSize: 15.0,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          // Apenas gestor verá a seção de Gestão
                          if (isGestor) ...[
                            Row(
                              children: [
                                const Icon(Icons.admin_panel_settings,
                                    color: Color(0xFF6F7F8E), size: 24.0),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      15.0, 0.0, 0.0, 0.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const GestaoWidget()),
                                      );
                                    },
                                    child: Text(
                                      'Gestão',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Readex Pro',
                                            fontSize: 15.0,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                const Icon(
                                  Icons.logout,
                                  color: Color(0xFF6F7F8E),
                                  size: 24.0,
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                    15.0,
                                    0.0,
                                    0.0,
                                    0.0,
                                  ),
                                  child: GestureDetector(
                                    onTap: _logout,
                                    child: Text(
                                      'Logout',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontFamily: 'Readex Pro',
                                            fontSize: 15.0,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
