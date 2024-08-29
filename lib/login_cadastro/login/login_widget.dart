import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_model.dart';
export 'login_model.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  late LoginModel _model;
  bool _isLoading =
      false; // Adicionado para mostrar o indicador de carregamento

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();
    _model.textFieldFocusNode1!.addListener(() => setState(() {}));
    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final input = _model.textController1.text.trim(); // Pode ser email ou ID
    final senha = _model.textController2.text.trim();

    // Verifica se os campos estão preenchidos
    if (input.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Verifica se o input é um email
    bool isEmail = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(input);

    try {
      // Faz a consulta ao banco de dados usando email ou ID
      final response = await Supabase.instance.client
          .from('Acesso Geral')
          .select('id_usuario, email, senha, is_gestor')
          .eq(isEmail ? 'email' : 'id_usuario', input)
          .eq('senha', senha) // Verifica também a senha
          .execute();

      // Verifica se a consulta retornou dados
      if (response.data != null && response.data.isNotEmpty) {
        final user = response.data[0]; // Pega o primeiro resultado da lista

        // Verifica se a senha corresponde à senha armazenada
        if (senha == user['senha']) {
          // Login bem-sucedido
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_email', user['email']);
          await prefs.setString('user_id', user['id_usuario']);
          await prefs.setBool('is_gestor', user['is_gestor'] ?? false);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login bem-sucedido!')),
          );
          context.pushNamed('home');
        } else {
          // Senha incorreta
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Senha incorreta.')),
          );
        }
      } else {
        // Usuário não encontrado
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Usuário não encontrado. Verifique o ID ou email.')),
        );
      }
    } catch (e) {
      // Tratar qualquer exceção lançada durante a requisição
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro inesperado: ${e.toString()}')),
      );
    } finally {
      // Garantir que o indicador de carregamento seja desativado
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final width = mediaQueryData.size.width;
    final height = mediaQueryData.size.height;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        top: true,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(0.0),
                    bottomRight: Radius.circular(0.0),
                    topLeft: Radius.circular(0.0),
                    topRight: Radius.circular(0.0),
                  ),
                  shape: BoxShape.rectangle,
                  border: Border.all(
                    color: Colors.white,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    width * 0.07,
                    30.0,
                    width * 0.07,
                    0.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: const AlignmentDirectional(-1.0, 0.0),
                        child: FFButtonWidget(
                          onPressed: () async {
                            context.pushNamed(
                              'Welcome',
                              extra: <String, dynamic>{
                                kTransitionInfoKey: const TransitionInfo(
                                  hasTransition: true,
                                  transitionType: PageTransitionType.fade,
                                  duration: Duration(milliseconds: 0),
                                ),
                              },
                            );
                          },
                          text: '',
                          icon: const Icon(
                            Icons.chevron_left,
                            color: Color(0xFF8B8989),
                            size: 40.0,
                          ),
                          options: FFButtonOptions(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: Colors.transparent,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0x005C5C5C),
                                  letterSpacing: 0.0,
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
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          0.0,
                          height * 0.1,
                          0.0,
                          0.0,
                        ),
                        child: Container(
                          width: width * 0.9,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    8.0, height * 0.04, 8.0, 0.0),
                                child: TextFormField(
                                  controller: _model.textController1,
                                  focusNode: _model.textFieldFocusNode1,
                                  autofocus: true,
                                  textCapitalization: TextCapitalization.none,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    isDense: false,
                                    alignLabelWithHint: false,
                                    hintText: 'ID funcionário ou Email',
                                    hintStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          color: const Color(0xFF3C3A3A),
                                          letterSpacing: 1.0,
                                          lineHeight: 1.4,
                                        ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Color(0xFF3C3A3A),
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Color(0xFF404040), width: 2.0),
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                    contentPadding: const EdgeInsets.all(24.0),
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
                                      color: Colors.black,
                                      size: 30.0,
                                    ),
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Readex Pro',
                                        letterSpacing: 0.0,
                                      ),
                                  cursorColor: const Color(0xFF4F4F4F),
                                  validator: _model.textController1Validator
                                      .asValidator(context),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    8.0, height * 0.04, 8.0, 0.0),
                                child: TextFormField(
                                  controller: _model.textController2,
                                  focusNode: _model.textFieldFocusNode2,
                                  autofocus: true,
                                  textCapitalization: TextCapitalization.none,
                                  obscureText: !_model.passwordVisibility,
                                  decoration: InputDecoration(
                                    isDense: false,
                                    alignLabelWithHint: false,
                                    hintText: 'Password',
                                    hintStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          color: const Color(0xFF3C3A3A),
                                          letterSpacing: 1.0,
                                          lineHeight: 1.7,
                                        ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Color(0xFF3C3A3A), width: 2.0),
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Color(0xFF333030), width: 2.0),
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                    contentPadding: const EdgeInsets.all(24.0),
                                    prefixIcon: const Icon(
                                      Icons.lock_outlined,
                                      color: Colors.black,
                                      size: 30.0,
                                    ),
                                    suffixIcon: InkWell(
                                      onTap: () => setState(
                                        () => _model.passwordVisibility =
                                            !_model.passwordVisibility,
                                      ),
                                      focusNode: FocusNode(skipTraversal: true),
                                      child: Icon(
                                        _model.passwordVisibility
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Readex Pro',
                                        letterSpacing: 0.0,
                                      ),
                                  keyboardType: TextInputType.visiblePassword,
                                  cursorColor: const Color(0xFF4F4F4F),
                                  validator: _model.textController2Validator
                                      .asValidator(context),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, height * 0.04, 0.0, 0.0),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    context.pushNamed('Reset_Password');
                                  },
                                  child: Text(
                                    'Esqueceu sua senha?',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, height * 0.04, 0.0, 0.0),
                                child: FFButtonWidget(
                                  onPressed: () async {
                                    await _login();
                                  },
                                  text: 'LOG IN',
                                  options: FFButtonOptions(
                                    width: width * 0.6,
                                    height: 48.0,
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            24.0, 0.0, 24.0, 0.0),
                                    iconPadding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 0.0, 0.0),
                                    color: const Color(0xFFB751F6),
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
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
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoading) // Exibe um indicador de carregamento enquanto o login é processado
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
