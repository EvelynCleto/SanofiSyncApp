import '../home/home_widget.dart';
import '../ponto/ponto_widget.dart';
import '../pesquisa/pesquisa_widget.dart';
import '../my_account/my_account_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TreinamentosWidget extends StatefulWidget {
  const TreinamentosWidget({super.key});

  @override
  State<TreinamentosWidget> createState() => _TreinamentosWidgetState();
}

class _TreinamentosWidgetState extends State<TreinamentosWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = true;
  String? userEmail;
  String? userId;
  List<Map<String, dynamic>> treinamentosFiltrados = [];
  String filtroStatus = 'Todos';
  Map<String, bool> assinaturasTreinamentos = {};
  Map<String, bool> presencasConfirmadas = {};

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void initState() {
    super.initState();
    carregarEmailUsuarioLogado();
  }

  // Método para exibir o diálogo de assinatura
  void mostrarDialogoAssinatura(String idTreinamento) {
    // Limpa a assinatura anterior antes de abrir o diálogo
    _signatureController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text(
            'Assine para liberar o treinamento',
            style: FlutterFlowTheme.of(context).titleMedium,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Signature(
                controller: _signatureController,
                height: 200,
                backgroundColor:
                    FlutterFlowTheme.of(context).secondaryBackground,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () => _signatureController.clear(),
                    child: const Text('Limpar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          FlutterFlowTheme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                    onPressed: () {
                      salvarAssinatura(idTreinamento);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Enviar'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Método para baixar o certificado
  void baixarCertificado(String idTreinamento) {
    // Lógica para baixar o certificado
    mostrarMensagemSucesso(
        'Certificado baixado para o treinamento $idTreinamento');
  }

  // Método para enviar feedback
  void enviarFeedback(String idTreinamento) {
    // Lógica para enviar feedback
    mostrarMensagemSucesso(
        'Feedback enviado para o treinamento $idTreinamento');
  }

  Future<void> carregarEmailUsuarioLogado() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('user_email') ?? '';
    });

    if (userEmail != null && userEmail!.isNotEmpty) {
      userId = await buscarIdFuncionario(userEmail!);
      if (userId != null) {
        await carregarTreinamentosUsuario(userId!);
      }
    }
  }

  Future<String?> buscarIdFuncionario(String emailFuncionario) async {
    final response = await Supabase.instance.client
        .from('Acesso Geral')
        .select('id_usuario')
        .eq('email', emailFuncionario)
        .single()
        .execute();

    if (response.status == 200 && response.data != null) {
      return response.data['id_usuario'] as String?;
    } else {
      print('Erro ao buscar ID do funcionário: ${response.data?.message}');
      return null;
    }
  }

  Future<void> carregarTreinamentosUsuario(String idFuncionario) async {
    setState(() {
      isLoading = true;
    });

    final response = await Supabase.instance.client
        .from('treinamentos')
        .select('*')
        .eq('id_funcionario', idFuncionario)
        .order('data_inicio', ascending: false)
        .execute();

    if (response.status == 200) {
      setState(() {
        treinamentosFiltrados = List<Map<String, dynamic>>.from(response.data);
        for (var treinamento in treinamentosFiltrados) {
          assinaturasTreinamentos[treinamento['id']] = false;
          presencasConfirmadas[treinamento['id']] = false;
        }
      });
    } else {
      print('Erro ao carregar treinamentos: ${response.data?.message}');
    }

    setState(() {
      isLoading = false;
    });
  }

  void aplicarFiltro(String status) {
    setState(() {
      filtroStatus = status;
    });
  }

  String verificarStatusTreinamento(Map<String, dynamic> treinamento) {
    final dataFim = DateTime.parse(treinamento['data_fim']);
    final dataAtual = DateTime.now();

    if (dataAtual.isAfter(dataFim)) {
      return 'Concluído';
    } else if (dataAtual.isBefore(DateTime.parse(treinamento['data_inicio']))) {
      return 'Futuro';
    } else {
      return 'Em Andamento';
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
      final duracaoTotal = dataFim.difference(dataInicio).inDays;
      final duracaoAteAgora = dataAtual.difference(dataInicio).inDays;
      return duracaoAteAgora / duracaoTotal;
    }
  }

  Future<void> salvarAssinatura(String idTreinamento) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final emailFuncionario = prefs.getString('user_email') ?? '';

      if (emailFuncionario.isEmpty) {
        mostrarMensagemErro("Email do funcionário não encontrado.");
        return;
      }

      final signatureImage = await _signatureController.toPngBytes();
      if (signatureImage == null || signatureImage.isEmpty) {
        mostrarMensagemErro("Assinatura está vazia.");
        return;
      }

      final base64Signature = base64Encode(signatureImage);
      final location = await _getLocationFromIP();
      final currentDate = DateTime.now().toIso8601String();

      // Insere ou atualiza a assinatura no banco de dados para o treinamento específico
      final response =
          await Supabase.instance.client.from('assinaturas').upsert({
        'user_email': emailFuncionario,
        'assinatura_treinamento_data': currentDate,
        'assinatura_treinamento_img': base64Signature,
        'location': location,
        'date': currentDate,
        'id_treinamento': idTreinamento,
      }).execute();

      if (response.data != null) {
        mostrarMensagemErro('Erro ao salvar assinatura.');
      } else {
        setState(() {
          assinaturasTreinamentos[idTreinamento] = true;
        });
        mostrarMensagemSucesso('Assinatura salva com sucesso!');
      }
    } catch (e) {
      mostrarMensagemErro('Erro ao salvar assinatura: $e');
    }
  }

  Future<void> carregarAssinaturasUsuario() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final emailFuncionario = prefs.getString('user_email') ?? '';

      if (emailFuncionario.isNotEmpty) {
        final response = await Supabase.instance.client
            .from('assinaturas')
            .select('*')
            .eq('user_email', emailFuncionario)
            .execute();

        if (response.data != null) {
          print('Erro ao carregar assinaturas: ${response.data?.message}');
        } else {
          final data = response.data as List<dynamic>;

          setState(() {
            for (var assinatura in data) {
              assinaturasTreinamentos[assinatura['id_treinamento']] = true;
            }
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar assinaturas: $e');
    }
  }

  Future<String> _getLocationFromIP() async {
    try {
      final response = await http.get(
          Uri.parse('https://api.ipgeolocation.io/ipgeo?apiKey=YOUR_API_KEY'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final city = data['city'];
        final country = data['country_name'];
        return '$city, $country';
      } else {
        return 'Localização desconhecida';
      }
    } catch (e) {
      return 'Erro ao obter localização';
    }
  }

  void mostrarMensagemSucesso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.green,
      ),
    );
  }

  void mostrarMensagemErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
  }

  void confirmarPresenca(String idTreinamento) {
    setState(() {
      presencasConfirmadas[idTreinamento] = true;
    });
    mostrarMensagemSucesso(
        'Presença confirmada para o treinamento $idTreinamento');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            drawer: Drawer(
              child: MyAccountWidget(),
            ),
            body: Column(children: [
              // Header
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
                                            .headlineMedium
                                            .override(
                                              fontFamily: 'Readex Pro',
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
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
                              20.0, 20.0, 20.0, 0.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              FFButtonWidget(
                                onPressed: () => aplicarFiltro('Todos'),
                                text: 'Todos',
                                options: FFButtonOptions(
                                  width: 100,
                                  height: 40,
                                  color:
                                      FlutterFlowTheme.of(context).primaryColor,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .subtitle2
                                      .override(
                                        fontFamily: 'Readex Pro',
                                        color: Colors.white,
                                      ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              FFButtonWidget(
                                onPressed: () => aplicarFiltro('Concluído'),
                                text: 'Concluído',
                                options: FFButtonOptions(
                                  width: 100,
                                  height: 40,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryColor,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .subtitle2
                                      .override(
                                        fontFamily: 'Readex Pro',
                                        color: Colors.white,
                                      ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              FFButtonWidget(
                                onPressed: () => aplicarFiltro('Em Andamento'),
                                text: 'Em Andamento',
                                options: FFButtonOptions(
                                  width: 140,
                                  height: 40,
                                  color: FlutterFlowTheme.of(context)
                                      .tertiaryColor,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .subtitle2
                                      .override(
                                        fontFamily: 'Readex Pro',
                                        color: Colors.white,
                                      ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 20.0, 0.0, 0.0),
                          child: Container(
                            width: size.width * 0.9,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      20.0, 20.0, 20.0, 20.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      if (isLoading)
                                        const CircularProgressIndicator()
                                      else if (treinamentosFiltrados.isEmpty)
                                        const Text(
                                            "Nenhum treinamento disponível.")
                                      else
                                        Column(
                                          children: treinamentosFiltrados
                                              .where((treinamento) {
                                            final status =
                                                verificarStatusTreinamento(
                                                    treinamento);
                                            return filtroStatus == 'Todos' ||
                                                status == filtroStatus;
                                          }).map((treinamento) {
                                            final idTreinamento =
                                                treinamento['id'];
                                            final status =
                                                verificarStatusTreinamento(
                                                    treinamento);
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Treinamento: ${treinamento['descricao']}',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .titleMedium
                                                        .override(
                                                          fontFamily:
                                                              'Readex Pro',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryText,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                  Text(
                                                    'Data de início: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(treinamento['data_inicio']))}',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyText2
                                                        .override(
                                                          fontFamily:
                                                              'Readex Pro',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText,
                                                        ),
                                                  ),
                                                  Text(
                                                    'Localização: ${treinamento['localizacao']}',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyText2
                                                        .override(
                                                          fontFamily:
                                                              'Readex Pro',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  LinearProgressIndicator(
                                                    value:
                                                        calcularProgressoTreinamento(
                                                            treinamento),
                                                    backgroundColor:
                                                        Colors.grey[300],
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryColor,
                                                  ),
                                                  const SizedBox(height: 10),
                                                  if (!assinaturasTreinamentos[
                                                      idTreinamento]!)
                                                    FFButtonWidget(
                                                      onPressed: () {
                                                        mostrarDialogoAssinatura(
                                                            idTreinamento);
                                                      },
                                                      text:
                                                          'Assinar para começar',
                                                      options: FFButtonOptions(
                                                        width: 200,
                                                        height: 40,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryColor,
                                                        textStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .subtitle2
                                                                .override(
                                                                  fontFamily:
                                                                      'Readex Pro',
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                    )
                                                  else if (!presencasConfirmadas[
                                                      idTreinamento]!)
                                                    FFButtonWidget(
                                                      onPressed: () {
                                                        confirmarPresenca(
                                                            idTreinamento);
                                                      },
                                                      text:
                                                          'Confirmar Presença',
                                                      options: FFButtonOptions(
                                                        width: 170,
                                                        height: 40,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryColor,
                                                        textStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .subtitle2
                                                                .override(
                                                                  fontFamily:
                                                                      'Readex Pro',
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                    )
                                                  else if (status ==
                                                      'Concluído')
                                                    FFButtonWidget(
                                                      onPressed: () {
                                                        baixarCertificado(
                                                            idTreinamento);
                                                      },
                                                      text:
                                                          'Baixar Certificado',
                                                      options: FFButtonOptions(
                                                        width: 170,
                                                        height: 40,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .tertiaryColor,
                                                        textStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .subtitle2
                                                                .override(
                                                                  fontFamily:
                                                                      'Readex Pro',
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                    ),
                                                  if (status == 'Concluído' &&
                                                      presencasConfirmadas[
                                                          idTreinamento]!)
                                                    FFButtonWidget(
                                                      onPressed: () {
                                                        enviarFeedback(
                                                            idTreinamento);
                                                      },
                                                      text: 'Enviar Feedback',
                                                      options: FFButtonOptions(
                                                        width: 170,
                                                        height: 40,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryColor,
                                                        textStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .subtitle2
                                                                .override(
                                                                  fontFamily:
                                                                      'Readex Pro',
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                    ),
                                                  const SizedBox(height: 10),
                                                  const Divider(
                                                    color: Colors.grey,
                                                    height: 1,
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                    ],
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
              Align(
                alignment: const AlignmentDirectional(0.0, 1.0),
                child: Container(
                  width: size.width,
                  height: size.height * 0.07,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
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
                            color: Color(0xFF6A1B9A),
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
                            color: Color(0xFF6A1B9A),
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
                            color: Color(0xFF6A1B9A),
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
                            color: Color(0xFF6A1B9A),
                            size: 25.0,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TreinamentosWidget(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ])));
  }
}
