import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  String? userName;
  String? userId;
  String? userLocation;
  bool isGestor = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MyAccountModel());
    _loadUserData();
  }

  Future<void> _loadUserLocation() async {
    // Carregar a localização de uma API ou do SharedPreferences, por exemplo.
    // Exemplo: usando SharedPreferences para carregar uma localização salva.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userLocation =
          prefs.getString('user_location') ?? 'Localização desconhecida';
    });
  }

  // Função para carregar os dados salvos no SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id');
      userEmail = prefs.getString('user_email');
      isGestor = prefs.getBool('is_gestor') ?? false;

      // Se o email estiver salvo, busca o nome do usuário
      if (userEmail != null) {
        _fetchUserName(userEmail!);
      }
    });
  }

  // Função para buscar o nome do usuário a partir do email
  Future<void> _fetchUserName(String email) async {
    print('Buscando usuário com email: $email'); // Mensagem de depuração

    try {
      final response = await Supabase.instance.client
          .from('funcionarios')
          .select('email, nome') // Seleciona os campos 'email' e 'nome'
          .eq('email', email) // Filtra pelo email
          .single()
          .execute(); // Método correto para executar a consulta

      // Verifique se a resposta tem sucesso
      if (response.status != null) {
        print('Erro ao buscar usuário: ${response.data!.message}');
        return;
      }

      final data = response.data;
      if (data != null) {
        setState(() {
          userName = data['nome']; // Atualiza o nome do usuário
        });
      } else {
        print('Nenhum usuário encontrado para o email: $email');
      }
    } catch (e) {
      print('Erro ao buscar nome do usuário: $e');
    }
  }

  // Função para garantir que o email e ID sejam salvos ao logar ou cadastrar
  Future<void> _saveUserDataToPreferences(
      String userId, String email, bool isGestorFlag) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
    await prefs.setString('user_email', email);
    await prefs.setBool('is_gestor', isGestorFlag);
  }

  // Função para limpar os dados e fazer logout
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
                                      userName ??
                                          userEmail ??
                                          'Usuário não disponível',
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
                                                usuarioId: userId ??
                                                    '', // Substituído para usar o ID do usuário
                                                usuarioNome: userName ?? '',
                                                localizacao: userLocation ??
                                                    '', // Se houver uma variável de localização
                                              )),
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
                          ],

                          // O botão de logout agora aparece para todos os usuários
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
