import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../ponto/ponto_widget.dart';
import '../my_account/my_account_widget.dart';
import '../home/home_widget.dart';
import '../treinamentos/treinamentos_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'pesquisa_model.dart';

export 'pesquisa_model.dart';

class PesquisaWidget extends StatefulWidget {
  const PesquisaWidget({super.key});

  @override
  State<PesquisaWidget> createState() => _PesquisaWidgetState();
}

class _PesquisaWidgetState extends State<PesquisaWidget> {
  late PesquisaModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  String? userName;
  String? userRole;
  String? userHierarchy;
  String? supervisorName;
  String? userId;
  String? supervisorId;
  bool isLoading = true;
  String gestorId =
      'id_do_gestor'; // Defina o gestorId corretamente, obtido de algum lugar

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PesquisaModel());
    _fetchUserDetails();
    _fetchFullHierarchy();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email');

      if (userEmail != null) {
        final response = await Supabase.instance.client
            .from('funcionarios')
            .select('nome, cargo, supervisor')
            .eq('email', userEmail)
            .single()
            .execute();

        if (response.data != null) {
          setState(() {
            final userData = response.data as Map<String, dynamic>;
            userName = userData['nome'];
            userRole = userData['cargo'];
            supervisorId = userData['supervisor'];
          });
        } else {
          print(
              'Erro ao buscar dados do funcionário: ${response.data?.message}');
        }
      }
    } catch (e) {
      print('Erro ao buscar detalhes do usuário: $e');
    }
  }

  Future<void> _fetchFullHierarchy() async {
    setState(() {
      // Hierarquia fixa com supervisores e subordinados
      userHierarchy = '''
Maria Oliveira (Gestora de Projetos)
    ├─ João Pereira (Desenvolvedor Frontend)
    ├─ Ana Souza (Desenvolvedora Backend)
    ├─ Carlos Oliveira (UI/UX Designer)
    └─ Fernanda Costa (QA Engineer)
''';

      isLoading = false;
    });
  }

// Função para exibir a hierarquia com um design aprimorado e estilizado
  Widget buildHierarchyWidget() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 10.0,
            spreadRadius: 4.0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_tree_outlined,
                  size: 28.0, color: Colors.purple),
              const SizedBox(width: 8.0),
              Text(
                'Estrutura Hierárquica do Time',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          _buildHierarchyItem(
              'Maria Oliveira', 'Gestora de Projetos', Icons.business, true),
          const SizedBox(height: 12.0),
          const Divider(color: Colors.purpleAccent, thickness: 1.2),
          Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: Column(
              children: [
                _buildHierarchyItem('João Pereira', 'Desenvolvedor Frontend',
                    Icons.code, false),
                const SizedBox(height: 8.0),
                _buildHierarchyItem('Ana Souza', 'Desenvolvedora Backend',
                    Icons.computer, false),
                const SizedBox(height: 8.0),
                _buildHierarchyItem('Carlos Oliveira', 'UI/UX Designer',
                    Icons.design_services, false),
                const SizedBox(height: 8.0),
                _buildHierarchyItem(
                    'Fernanda Costa', 'QA Engineer', Icons.bug_report, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Função auxiliar para criar cada item da hierarquia com mais estilo
  Widget _buildHierarchyItem(
      String name, String role, IconData icon, bool isSupervisor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: isSupervisor
                ? Colors.purpleAccent.withOpacity(0.1)
                : Colors.purple.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 24.0,
            color: isSupervisor ? Colors.purpleAccent : Colors.purple.shade400,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: isSupervisor ? Colors.purple.shade700 : Colors.black87,
              ),
            ),
            Text(
              role,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _onGestorGeralClick(String nomeGestor) {
    // Dados fixos para teste
    final gestor = {
      'nome': 'Maria Oliveira',
      'cargo': 'Gestora de Projetos',
      'nivel_hierarquico': 'Nível 3'
    };

    final subordinados = [
      {'nome': 'João Pereira', 'cargo': 'Desenvolvedor Frontend'},
      {'nome': 'Ana Souza', 'cargo': 'Desenvolvedora Backend'},
      {'nome': 'Carlos Oliveira', 'cargo': 'UI/UX Designer'},
      {'nome': 'Fernanda Costa', 'cargo': 'QA Engineer'}
    ];

    // Mostrar o modal com detalhes do gestor e subordinados
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${gestor['nome']} - ${gestor['cargo']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Nível Hierárquico: ${gestor['nivel_hierarquico'] ?? 'Não informado'}'),
              const SizedBox(height: 10),
              const Text(
                'Subordinados Diretos:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              for (final subordinado in subordinados)
                Text('${subordinado['nome']} - ${subordinado['cargo']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
            TextButton(
              onPressed: () {
                // Implementar ação adicional, como enviar mensagem
                Navigator.of(context).pop();
              },
              child: const Text('Enviar Mensagem'),
            ),
          ],
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
            value.isNotEmpty ? value : 'N/A',
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

  Future<void> _fetchSupervisorDetails(String supervisorId) async {
    final response = await Supabase.instance.client
        .from('funcionarios')
        .select('nome')
        .eq('id', supervisorId)
        .single()
        .execute();

    if (response.data != null) {
      setState(() {
        supervisorName = response.data['nome'];
        isLoading = false;
      });
    } else {
      setState(() {
        supervisorName = 'Erro ao buscar supervisor';
      });
      print('Erro ao buscar detalhes do supervisor: ${response.data}');
    }
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
        backgroundColor: const Color(0xFFBB4CFF),
        drawer: Drawer(
          child: MyAccountWidget(),
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 70.0, 0.0, 0.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20.0, 0.0, 20.0, 0.0),
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
                                      'PESQUISA',
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
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 16.0, 0.0, 0.0),
                        child: Container(
                          width: size.width * 0.9,
                          height: size.height * 0.07,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1ECEE),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    8.0, 5.0, 15.0, 5.0),
                                child: Container(
                                  width: size.width * 0.35,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Align(
                                    alignment:
                                        const AlignmentDirectional(-1.0, 0.0),
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              15.0, 0.0, 0.0, 0.0),
                                      child: Text(
                                        'Nome:',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Readex Pro',
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  userName ?? 'Maria Oliveira',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Readex Pro',
                                        color: const Color(0xFF999FA0),
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    45.0, 0.0, 0.0, 0.0),
                                child: Icon(
                                  Icons.search,
                                  color: Color(0xFFCCD3D4),
                                  size: 24.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 20.0, 0.0, 20.0),
                        child: Text(
                          'Minha estrutura hierárquica:',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Readex Pro',
                                    color: Colors.white,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                      ),
                      Container(
                        width: size.width * 0.9,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0BAF7),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Supervisores:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                supervisorName ??
                                    'Nenhum supervisor encontrado',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Estrutura Completa:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                userHierarchy ?? 'Nenhuma estrutura disponível',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 16.0, 0.0, 0.0),
                        child: Container(
                          width: size.width * 0.9,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                20.0, 20.0, 20.0, 10.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Align(
                                  alignment:
                                      const AlignmentDirectional(-1.0, -1.0),
                                  child: Text(
                                    userName ?? 'Fulano',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                Align(
                                  alignment:
                                      const AlignmentDirectional(-1.0, 0.0),
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 5.0, 0.0, 0.0),
                                    child: Text(
                                      'Cargo: ${userRole ?? 'Gestor(a)'}',
                                      textAlign: TextAlign.start,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Readex Pro',
                                            color: const Color(0xFF999FA0),
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment:
                                      const AlignmentDirectional(-1.0, 1.0),
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 20.0, 0.0, 0.0),
                                    child: FFButtonWidget(
                                      onPressed: () {
                                        _onGestorGeralClick('Nome do Gestor');
                                      },
                                      text: 'Gestor Geral',
                                      options: FFButtonOptions(
                                        width: size.width * 0.5,
                                        height: size.height * 0.06,
                                        padding: EdgeInsets.zero,
                                        color: const Color(0xFF701B90),
                                        textStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
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
                                        borderRadius:
                                            BorderRadius.circular(24.0),
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
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      20.0, 0.0, 20.0, 0.0),
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
                          color: Color(0xFFCCD3D4),
                          size: 25.0,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PontoWidget(),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.search,
                          color: Color(0xFFE0BAF7),
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
