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

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeWidget()),
      (Route<dynamic> route) => false,
    );
  }

 Future<void> cadastrarFuncionarioPeloGestor(
    String nomeFuncionario, 
    String emailFuncionario, 
    String nomeTreinamento, 
    String dataTreinamento) async {
  try {
    // Cadastro do funcionário pelo gestor
    print('Gestor cadastrando funcionário: Nome=$nomeFuncionario, Email=$emailFuncionario');

    // Insere o funcionário no banco, da mesma forma como ocorre no fluxo de cadastro normal
    await inserirFuncionarioNoBanco(nomeFuncionario, emailFuncionario);
    print('Funcionário cadastrado pelo gestor com sucesso.');

    // Agora, segue o mesmo fluxo de cadastro de treinamento, utilizando o email do funcionário recém-cadastrado
    await _cadastrarTreinamento(nomeTreinamento, dataTreinamento, emailFuncionario);
    print('Treinamento associado com sucesso ao funcionário.');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionário cadastrado pelo gestor e treinamento associado com sucesso!')),
    );
  } catch (e) {
    print('Erro ao cadastrar funcionário pelo gestor ou associar treinamento: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao cadastrar funcionário ou treinamento: $e')),
    );
  }
}


Future<Map<String, dynamic>?> buscarFuncionarioPorEmail(String email) async {
  // Função de busca no banco de dados pelo email
  print('Buscando funcionário pelo email: $email');
  
  // Simulação de busca no banco de dados
  // Aqui você precisa implementar a busca no seu banco de dados Supabase
  // Retorne os dados do funcionário se encontrado
  return {
    'nome': 'Nome Exemplo',
    'email': email,
    // Outros dados que precisar
  };
}



Future<void> inserirFuncionarioNoBanco(String nome, String email) async {
  // Simulação de inserção no banco de dados
  print('Inserindo funcionário no banco: Nome=$nome, Email=$email');
  
  // Aqui você insere o funcionário tanto na tabela `Acesso Geral` quanto na tabela `funcionarios`
  // Exemplo de verificação se o nome ou o email está ultrapassando os limites
  if (nome.length > 10) {
    print('Erro: Nome excede o limite de 10 caracteres.');
    throw 'Nome muito longo';
  }

  if (email.length > 50) {
    print('Erro: Email excede o limite de 50 caracteres.');
    throw 'Email muito longo';
  }

  // Simulação de inserção bem-sucedida
  print('Funcionário inserido com sucesso no banco.');
}

Future<void> _cadastrarTreinamento(String nomeTreinamento, String dataTreinamento, String emailFuncionario) async {
  try {
    print('Iniciando inserção do treinamento no banco: Nome Treinamento=$nomeTreinamento, Data=$dataTreinamento, Email Funcionario=$emailFuncionario');

    if (emailFuncionario.isEmpty) {
      print('Erro: Email do funcionário não disponível.');
      throw 'Email do funcionário não disponível';
    }

    // Simulação da inserção de treinamento no banco de dados
    final response = await inserirTreinamentoNoBanco({
      'nome': nomeTreinamento,
      'data': dataTreinamento,
      'funcionario_email': emailFuncionario,
    });

    if (response != null && response.contains('error')) {
      print('Erro ao inserir dados no banco de dados: $response');
      throw 'Erro ao inserir dados no banco de dados';
    }

    print('Treinamento inserido com sucesso.');
  } catch (e) {
    print('Erro ao cadastrar treinamento: $e');
    throw 'Erro ao cadastrar treinamento: $e';
  }
}

Future<String?> inserirTreinamentoNoBanco(Map<String, String> dados) async {
  print('Tentando inserir o treinamento no banco de dados com os seguintes dados: ${dados.toString()}');
  
  // Simulação de verificação de limites de caracteres no banco
  if (dados['nome'] != null && dados['nome']!.length > 10) {
    print('Erro: O nome do treinamento excede o limite de 10 caracteres.');
    return 'error';
  }

  if (dados['data'] != null && dados['data']!.length > 10) {
    print('Erro: A data do treinamento excede o limite de 10 caracteres.');
    return 'error';
  }

  if (dados['funcionario_email'] != null && dados['funcionario_email']!.length > 50) {
    print('Erro: O email do funcionário excede o limite permitido.');
    return 'error';
  }

  // Simulação de inserção bem-sucedida no banco
  print('Treinamento inserido com sucesso no banco de dados.');
  return null; // Retorna null se tudo der certo
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
                padding: const EdgeInsetsDirectional.fromSTEB(10.0, 30.0, 10.0, 0.0),
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
                          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
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
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
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
                  padding: const EdgeInsetsDirectional.fromSTEB(20.0, 5.0, 20.0, 0.0),
                  child: Container(
                    width: size.width * 0.9,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Divider(thickness: 0.5, color: Color(0xFF404951)),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
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
                                    padding: const EdgeInsetsDirectional.fromSTEB(15.0, 0.0, 0.0, 0.0),
                                    child: Text(
                                      userEmail ?? 'Email não disponível',
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
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
                          Row(
                            children: [
                              const Icon(Icons.logout, color: Color(0xFF6F7F8E), size: 24.0),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(15.0, 0.0, 0.0, 0.0),
                                child: GestureDetector(
                                  onTap: _logout,
                                  child: Text(
                                    'Logout',
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          fontFamily: 'Readex Pro',
                                          fontSize: 15.0,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (isGestor) ...[
                            Row(
                              children: [
                                const Icon(Icons.admin_panel_settings, color: Color(0xFF6F7F8E), size: 24.0),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(15.0, 0.0, 0.0, 0.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const GestaoWidget()),
                                      );
                                    },
                                    child: Text(
                                      'Gestão',
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                            fontFamily: 'Readex Pro',
                                            fontSize: 15.0,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.add_box_outlined, color: Color(0xFF6F7F8E), size: 24.0),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(15.0, 0.0, 0.0, 0.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        // Cadastrar treinamento usando o email do usuário
                                        String funcionarioEmail = 'funcionario@exemplo.com'; 
                                        _cadastrarTreinamento('Treinamento Exemplo', '2024-08-17', funcionarioEmail);
                                      },
                                      child: Text(
                                        'Cadastrar Treinamento',
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                              fontFamily: 'Readex Pro',
                                              fontSize: 15.0,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
