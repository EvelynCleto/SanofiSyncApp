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
    try {
      final response = await Supabase.instance.client
          .from('funcionarios')
          .select('nome, cargo, nivel_hierarquico')
          .not('nivel_hierarquico', 'is',
              null) // Filtra apenas os que têm nível hierárquico
          .order('nivel_hierarquico', ascending: true)
          .execute();

      // Verificar o que a API está retornando
      print('Resposta da API: ${response.data}');

      if (response.data != null && response.data.isNotEmpty) {
        setState(() {
          userHierarchy = ''; // Inicializa como string vazia

          // Itera sobre os funcionários válidos e monta a hierarquia
          for (final funcionario in response.data as List<dynamic>) {
            final nome = funcionario['nome'] ?? 'Desconhecido';
            final cargo = funcionario['cargo'] ?? 'Cargo não informado';

            // Concatena o nome e o cargo
            userHierarchy = '$userHierarchy$nome ($cargo)\n';
          }

          isLoading = false;
        });
      } else {
        // Se não houver dados, exibe uma mensagem
        setState(() {
          userHierarchy =
              'Nenhum funcionário encontrado com hierarquia definida.';
          isLoading = false;
        });
      }
    } catch (e) {
      // Captura e exibe erros no log
      print('Erro ao buscar a hierarquia: $e');
      setState(() {
        userHierarchy = 'Erro ao carregar a hierarquia.';
        isLoading = false;
      });
    }
  }

  void _onGestorGeralClick(String nomeGestor) async {
    try {
      print(
          'Nome do Gestor recebido: $nomeGestor'); // Verifique o nome que está sendo passado

      // Buscar detalhes do gestor pelo nome
      final gestorResponse = await Supabase.instance.client
          .from('funcionarios')
          .select('nome, cargo, nivel_hierarquico')
          .eq('nome', nomeGestor) // Agora estamos usando o nome do gestor
          .single()
          .execute();

      // Verificar a resposta do gestor
      print('Resposta do gestor: ${gestorResponse.data}');

      if (gestorResponse.data != null) {
        final gestor = gestorResponse.data;

        // Buscar subordinados diretos do gestor (baseado no cargo ou outro critério, se necessário)
        final subordinadosResponse = await Supabase.instance.client
            .from('funcionarios')
            .select('nome, cargo')
            .eq('supervisor',
                nomeGestor) // Pode usar 'supervisor' como nome do gestor, se aplicável
            .execute();

        // Verificar a resposta dos subordinados
        print('Resposta dos subordinados: ${subordinadosResponse.data}');

        if (subordinadosResponse.data != null) {
          final subordinados = subordinadosResponse.data as List<dynamic>;

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
        } else {
          print('Erro: Nenhum subordinado encontrado');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nenhum subordinado encontrado.')),
          );
        }
      } else {
        print('Erro: Dados do gestor não encontrados');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados do gestor não encontrados.')),
        );
      }
    } catch (e) {
      print('Erro ao carregar detalhes do gestor: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar dados do gestor.')),
      );
    }
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
                                  userName ?? 'Carregando...',
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
                                      'Cargo: ${userRole ?? 'Carregando...'}',
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
                                        _onGestorGeralClick(
                                            'Gestor Exemplo'); // Nome do gestor, como "Gestor Exemplo"
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
