import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'signup_model.dart';
export 'signup_model.dart';

class SignupWidget extends StatefulWidget {
  const SignupWidget({super.key});

  @override
  State<SignupWidget> createState() => _SignupWidgetState();
}

class _SignupWidgetState extends State<SignupWidget> {
  late SignupModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SignupModel());

    _model.textController1 ??= TextEditingController();
    _model.textController2 ??= TextEditingController();
    _model.textController3 ??= TextEditingController();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _navigateToHome() async {
    context.pushNamed('home');
  }

  Future<void> _saveGestorData() async {
    final response =
        await Supabase.instance.client.from('Acesso Geral').insert({
      'email': 'gestor@example.com',
      'id_usuario': 'gestor',
      'senha': '1',
      'is_gestor': true, // Este usuário é um gestor
    }).execute();

    if (response.status == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gestor cadastrado com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao cadastrar gestor!')),
      );
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
        child: SingleChildScrollView(
          // Adicionado para permitir a rolagem em telas menores
          child: Container(
            width: double.infinity,
            height:
                height, // Tornando o container responsivo ao tamanho da tela
            decoration: BoxDecoration(
              // Removido o 'const' daqui
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(0.0),
                bottomRight: Radius.circular(0.0),
                topLeft: Radius.circular(0.0),
                topRight: Radius.circular(0.0),
              ),
              shape: BoxShape.rectangle,
              border: Border.all(
                // Border.all não pode ser const
                color: Colors.white,
              ),
            ),

            child: Align(
              alignment: const AlignmentDirectional(0.0, -1.0),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  width * 0.07, // Adaptação da margem para responsividade
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
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
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
                    Align(
                      alignment: const AlignmentDirectional(0.0, 0.0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          0.0,
                          height * 0.1,
                          0.0,
                          0.0,
                        ),
                        child: Container(
                          width: width *
                              0.9, // Responsividade para a largura da tela
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                'OR SIGN UP WITH EMAIL',
                                style: FlutterFlowTheme.of(context)
                                    .headlineSmall
                                    .override(
                                      fontFamily: 'Outfit',
                                      fontSize: 17.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    8.0, height * 0.06, 8.0, 0.0),
                                child: TextFormField(
                                  controller: _model.textController1,
                                  autofocus: true,
                                  textCapitalization: TextCapitalization.none,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    isDense: false,
                                    alignLabelWithHint: false,
                                    hintText: '  E-mail empresarial',
                                    hintStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          letterSpacing: 0.0,
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
                                          color: Color(0xFF636262), width: 2.0),
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                    contentPadding: const EdgeInsets.all(24.0),
                                    prefixIcon: const Icon(
                                      Icons.email_outlined,
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
                                  textAlign: TextAlign.start,
                                  keyboardType: TextInputType.emailAddress,
                                  cursorColor: const Color(0xFF4F4F4F),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    8.0, height * 0.04, 8.0, 0.0),
                                child: TextFormField(
                                  controller: _model.textController2,
                                  autofocus: true,
                                  textCapitalization: TextCapitalization.none,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    isDense: false,
                                    alignLabelWithHint: false,
                                    hintText: '  ID funcionário',
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
                                          color: Color(0xFF3C3A3A), width: 2.0),
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
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    8.0, height * 0.04, 8.0, 0.0),
                                child: TextFormField(
                                  controller: _model.textController3,
                                  autofocus: true,
                                  textCapitalization: TextCapitalization.none,
                                  obscureText: !_model.passwordVisibility,
                                  decoration: InputDecoration(
                                    isDense: false,
                                    alignLabelWithHint: false,
                                    hintText: '  Password',
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
                                    prefixIcon: const Icon(Icons.lock_outlined,
                                        color: Colors.black, size: 30.0),
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
                                  cursorColor: const Color(0xFF4F4F4F),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, height * 0.06, 0.0, 0.0),
                                child: FFButtonWidget(
                                  onPressed: () async {
                                    await _saveGestorData();
                                    await _navigateToHome();
                                  },
                                  text: 'SIGN UP',
                                  options: FFButtonOptions(
                                    width: width *
                                        0.6, // Adaptando para a largura da tela
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
                                        color: Colors.transparent, width: 1.0),
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, height * 0.06, 0.0, 0.0),
                                child: Text(
                                  'By signing up you agree to our Terms and Conditions and Privacy Policy.',
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Readex Pro',
                                        letterSpacing: 0.0,
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
        ),
      ),
    );
  }
}
