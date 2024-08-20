import 'dart:convert';

import 'package:signature/signature.dart';
import '../ponto/ponto_widget.dart';
import '../my_account/my_account_widget.dart';
import '../pesquisa/pesquisa_widget.dart';
import '../treinamentos/treinamentos_widget.dart';
import '/flutter_flow/flutter_flow_calendar.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'home_model.dart';
export 'home_model.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
  );

  late HomeModel _model;
  String entryTime = '';
  String exitTime = '';
  String workedHours = '00:00:00';
  bool isEntryRegistered = false;
  bool isExitRegistered = false;
  List<Offset?> points = []; // Armazena os pontos da assinatura
  String qrCodeUrl = ''; // Armazena o URL do QR Code gerado
  bool isLoading = false; // Indicador de carregamento do QR code

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _signatureKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeModel());
    _loadEntryTime(); // Carrega o horário de entrada salvo, se houver
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String> _getLocationFromIP() async {
  try {
    final response = await http.get(Uri.parse('https://api.ipgeolocation.io/ipgeo?apiKey=51687a67dfa04490ac6c3849dfcc2056'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final city = data['city'];
      final country = data['country_name'];
      return '$city, $country';
    } else {
      print('Erro ao obter localização: ${response.statusCode}');
      return 'Localização desconhecida';
    }
  } catch (e) {
    print('Erro ao obter localização: $e');
    return 'Erro ao obter localização';
  }
}

Future<void> uploadSignature(Uint8List pngBytes) async {
  try {
    // Obtenha o email do usuário autenticado
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email') ?? '';

    if (email.isEmpty) {
      print('Erro: Email do usuário não encontrado.');
      return;
    }

    // Defina o nome do arquivo para o upload
    final fileName = 'Assinaturas/${DateTime.now().millisecondsSinceEpoch}.png';

    // Obtenha o tipo MIME do arquivo
    final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';
    final mimeTypeData = mimeType.split('/');

    // Crie a requisição Multipart
    var uri = Uri.parse('https://pglomkhepyjakvbuqoag.supabase.co/storage/v1/object/assinaturas/$fileName');
    var request = http.MultipartRequest('POST', uri);

    // Adicione os cabeçalhos de autenticação do Supabase
    request.headers['Authorization'] = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBnbG9ta2hlcHlqYWt2YnVxb2FnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjAxNzU3MzIsImV4cCI6MjAzNTc1MTczMn0.fmQXFa3o0OAF8uBR9r7Js4t-zTTRG9bC238ZQNUjZxw';
    request.headers['apikey'] = 'https://pglomkhepyjakvbuqoag.supabase.co';

    // Adicione o arquivo com o tipo MIME correto
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      pngBytes,
      filename: fileName,
      contentType: MediaType(mimeTypeData[0], mimeTypeData[1]), // Usar o tipo MIME correto
    ));

    // Envie a requisição
    var response = await request.send();

    if (response.statusCode == 200) {
      print('Upload realizado com sucesso.');
      String publicUrl = 'https://your-supabase-url.supabase.co/storage/v1/object/public/assinaturas/$fileName';
      print('URL da assinatura: $publicUrl');
    } else {
      print('Erro ao fazer upload da assinatura. Código de status: ${response.statusCode}');
    }
  } catch (e) {
    print('Erro ao fazer upload da assinatura: $e');
  }
}

  
  // Função para registrar a assinatura e salvar no Supabase Storage
Future<void> _saveSignature() async {
  if (_controller.isNotEmpty) {
    try {
      // Captura a localização do IP
      String location = await _getLocationFromIP();

      // Converte a assinatura em imagem
      final signatureImage = await _controller.toImage();
      final byteData = await signatureImage!.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Captura a hora e a data atuais
      final currentDateTime = DateTime.now();
      final String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(currentDateTime);

      // Converte para base64
      String base64Image = base64Encode(pngBytes);

      // Recupera o email do usuário salvo no SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email') ?? '';

      if (email.isEmpty) {
        print('Erro: Email do usuário não encontrado.');
        return;
      }

      // Insere os dados da assinatura diretamente no banco de dados, incluindo a data correta
      final supabaseClient = Supabase.instance.client;
      final dbResponse = await supabaseClient
          .from('assinaturas')
          .insert({
            'user_email': email,
            'created_at': formattedDateTime,
            'assinatura_base64': base64Image,
            'location': location,
            'date': formattedDateTime, // Certifique-se de passar a data aqui
          })
          .execute();

      if (dbResponse.data != null) {
        print('Erro ao salvar a assinatura no banco de dados: ${dbResponse.data!.message}');
      } else {
        print('Assinatura salva com sucesso no banco de dados!');
        _controller.clear(); // Limpa a assinatura após o salvamento
        Navigator.of(context).pop(); // Fecha o modal
      }
    } catch (e) {
      print('Erro ao capturar assinatura: $e');
    }
  } else {
    print('Assinatura está vazia');
  }
}





Widget _buildSignatureImage(String base64String) {
  final bytes = base64Decode(base64String);
  return Image.memory(
    bytes,
    width: 200,
    height: 100,
    fit: BoxFit.contain,
  );
}





  // Função para gerar o QR code
  void _generateQRCode() async {
    setState(() {
      isLoading = true; // Inicia o indicador de carregamento
    });

    // Gera o QR code usando uma API externa
    String qrData = 'TOKEN_${DateTime.now().millisecondsSinceEpoch}';
    qrCodeUrl = 'https://api.qrserver.com/v1/create-qr-code/?data=$qrData&size=300x300&color=4A148C&bgcolor=D1C4E9';

    await Future.delayed(const Duration(milliseconds: 1000)); // Simulação de espera

    setState(() {
      isLoading = false; // Termina o carregamento
      _showQRCodeModal(context); // Exibe o modal após o QR code ser gerado
    });

    // Salva o QR code no banco de dados automaticamente
    _saveQRCodeToDatabase(qrCodeUrl);
  }

  // Função para salvar o QR code no banco de dados
  void _saveQRCodeToDatabase(String qrCodeUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email') ?? '';

    if (email.isEmpty) {
      print('Erro: Email do usuário não encontrado.');
      return;
    }

    try {
      final supabaseClient = Supabase.instance.client;
      final response = await supabaseClient
          .from('qrcodes')
          .insert({
            'user_email': email,
            'qr_code_url': qrCodeUrl,
            'created_at': DateTime.now().toIso8601String(),
          })
          .execute();

      if (response.data == null) {
        print('QR code salvo com sucesso!');
      } else {
        print('Erro ao salvar o QR code no banco de dados: ${response.data!.message}');
      }
    } catch (e) {
      print('Erro: $e');
    }
  }

  // Modal para capturar a assinatura do usuário
  void _showSignatureModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 500.0,
          child: Column(
            children: [
              const Text('Assine abaixo', style: TextStyle(fontSize: 20)),
              Expanded(
                child: Signature(
                  controller: _controller,
                  backgroundColor: Colors.grey[200]!,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _controller.clear();
                    },
                    child: const Text('Limpar'),
                  ),
                  ElevatedButton(
                    onPressed: _saveSignature,
                    child: const Text('Salvar'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }








  // Função para recuperar o horário de entrada ao abrir o app
  void _loadEntryTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEntryTime = prefs.getString('entry_time');
    String? savedExitTime = prefs.getString('exit_time');
    String? savedWorkedHours = prefs.getString('worked_hours');

    if (savedEntryTime != null) {
      setState(() {
        entryTime = savedEntryTime;
        isEntryRegistered = true;
      });
    }

    if (savedExitTime != null) {
      setState(() {
        exitTime = savedExitTime;
        workedHours = savedWorkedHours ?? '00:00:00';
        isExitRegistered = true;
      });
    }
  }

  // Função para registrar o horário de entrada
  void _registerEntry() async {
    String currentEntryTime = DateFormat('HH:mm:ss').format(DateTime.now());

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('entry_time', currentEntryTime);

    setState(() {
      entryTime = currentEntryTime;
      isEntryRegistered = true;
      isExitRegistered = false;
    });

    // Salva o horário de entrada no banco de dados
    final supabaseClient = Supabase.instance.client;
    final response = await supabaseClient
        .from('pontos')
        .insert({
          'user_email': prefs.getString('user_email') ?? '',
          'entry_time': currentEntryTime,
        })
        .execute();

    if (response.data == null) {
      print('Horário de entrada salvo com sucesso no banco de dados!');
    } else {
      print('Erro ao salvar o horário de entrada: ${response.data!.message}');
    }
  }

  // Função para finalizar o ponto
  void _finalizePoint() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email') ?? '';

    if (email.isEmpty) {
      print('Erro: Email do usuário não encontrado.');
      return;
    }

    try {
      exitTime = DateFormat('HH:mm:ss').format(DateTime.now());

      // Calcula as horas trabalhadas
      DateTime entryDateTime = DateFormat('HH:mm:ss').parse(entryTime);
      DateTime exitDateTime = DateFormat('HH:mm:ss').parse(exitTime);
      Duration difference = exitDateTime.difference(entryDateTime);
      workedHours = difference.toString().split('.').first; // Formato HH:mm:ss

      // Atualiza o banco de dados com o horário de saída e horas trabalhadas
      final supabaseClient = Supabase.instance.client;
      final response = await supabaseClient
          .from('pontos')
          .update({
            'exit_time': exitTime,
            'horas_trabalhadas': workedHours,
          })
          .eq('user_email', email)
          .eq('entry_time', entryTime) // Certifica-se de atualizar o registro correto
          .execute();

      if (response.data == null) {
        print('Horário de saída e horas trabalhadas salvos com sucesso no banco de dados!');
      } else {
        print('Erro ao salvar o horário de saída e horas trabalhadas: ${response.data!.message}');
      }

      await prefs.setString('exit_time', exitTime);
      await prefs.setString('worked_hours', workedHours);

      setState(() {
        isExitRegistered = true;
      });
    } catch (e) {
      print('Erro ao finalizar o ponto: $e');
    }
  }

  // Função para exibir o modal com o QR Code
  void _showQRCodeModal(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (context, _, __) {
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFBB86FC), Color(0xFF4A148C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Seu QR Code',
                  style: TextStyle(
                    fontFamily: 'Readex Pro',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 3.0,
                        color: Colors.black26,
                      ),
                    ],
                    decoration: TextDecoration.none, // Remove o sublinhado
                  ),
                ),
                const SizedBox(height: 15),
                if (qrCodeUrl.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2.0),
                      border: Border.all(
                        color: const Color(0xFFBB86FC), // Contorno roxo claro
                        width: 2.0,
                      ),
                    ),
                    child: Image.network(
                      qrCodeUrl,
                      width: 220,
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 30.0),
                    backgroundColor: const Color(0xFF4A148C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    shadowColor: Colors.black26,
                    elevation: 6,
                  ),
                  child: const Text(
                    'Fechar',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Readex Pro',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: anim1,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFBB4CFF),
        drawer: Drawer(
          child: MyAccountWidget(),
        ),
        body: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 70.0, 0.0, 0.0),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                        child: SingleChildScrollView(
                          primary: false,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  FlutterFlowIconButton(
                                    borderRadius: 20.0,
                                    borderWidth: 1.0,
                                    buttonSize: screenWidth * 0.1,
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
                                        'Home',
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
                                  const Icon(
                                    Icons.location_history,
                                    color: Color(0xFFE6EEF0),
                                    size: 37.0,
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 18.0, 0.0, 0.0),
                                child: FlutterFlowCalendar(
                                  color: Colors.white,
                                  iconColor: Colors.white,
                                  weekFormat: true,
                                  weekStartsMonday: false,
                                  rowHeight: 64.0,
                                  onChange: (DateTimeRange? newSelectedDate) {
                                    setState(() => _model.calendarSelectedDay = newSelectedDate);
                                  },
                                  titleStyle: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .override(
                                        fontFamily: 'Outfit',
                                        color: Colors.white,
                                        letterSpacing: 0.0,
                                      ),
                                  dayOfWeekStyle: FlutterFlowTheme.of(context)
                                      .labelLarge
                                      .override(
                                        fontFamily: 'Readex Pro',
                                        color: Colors.white,
                                        letterSpacing: 0.0,
                                      ),
                                  dateStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Readex Pro',
                                        color: Colors.white,
                                        letterSpacing: 0.0,
                                      ),
                                  selectedDateStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            fontFamily: 'Readex Pro',
                                            color: const Color(0xFFBB4CFF),
                                            letterSpacing: 0.0,
                                          ),
                                  inactiveDateStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            fontFamily: 'Readex Pro',
                                            color: const Color(0xFFBB4CFF),
                                            letterSpacing: 0.0,
                                          ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                                child: Container(
                                  width: double.infinity,
                                  height: screenHeight * 0.15,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0BAF7),
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional.fromSTEB(screenWidth * 0.2, 0.0, 0.0, 5.0),
                                              child: const Icon(
                                                Icons.qr_code_2,
                                                color: Color(0xFFBB4CFF),
                                                size: 50.0,
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsetsDirectional.fromSTEB(30.0, 0.0, 0.0, 0.0),
                                                child: Center(
                                                  child: entryTime.isEmpty
                                                      ? Text(
                                                          'Marcar ponto',
                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                fontFamily: 'Readex Pro',
                                                                color: Colors.black,
                                                                letterSpacing: 0.0,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                        )
                                                      : Text(
                                                          entryTime,
                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                fontFamily: 'Readex Pro',
                                                                fontSize: 20.0,
                                                                color: Colors.black,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 0.0, 0.0),
                                              child: FFButtonWidget(
                                                onPressed: isLoading ? null : _generateQRCode, // Desabilita o botão enquanto está carregando
                                                text: isLoading ? 'Carregando...' : 'GERAR QR CODE', // Mostra o estado de carregamento
                                                options: FFButtonOptions(
                                                  width: screenWidth * 0.4,
                                                  height: screenHeight * 0.05,
                                                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                  iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                  color: isLoading ? const Color.fromARGB(255, 0, 0, 0) : const Color.fromARGB(255, 0, 0, 0), // Cor roxa para carregamento e normal
                                                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                        fontFamily: 'Readex Pro',
                                                        color: Colors.white,
                                                        fontSize: 14.0, // Font size ajustado para melhor legibilidade
                                                        letterSpacing: 0.0,
                                                      ),
                                                  elevation: 6.0, // Elevação do botão
                                                  borderSide: const BorderSide(
                                                    color: Colors.transparent,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius: BorderRadius.circular(24.0),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 0.0, 0.0),
                                              child: FFButtonWidget(
                                                onPressed: () {
                                                  if (!isEntryRegistered) {
                                                    _registerEntry();
                                                  } else if (!isExitRegistered) {
                                                    _finalizePoint();
                                                  } else {
                                                    setState(() {
                                                      entryTime = '';
                                                      exitTime = '';
                                                      workedHours = '00:00:00';
                                                      isEntryRegistered = false;
                                                      isExitRegistered = false;
                                                    });

                                                    SharedPreferences.getInstance().then((prefs) {
                                                      prefs.remove('entry_time');
                                                      prefs.remove('exit_time');
                                                      prefs.remove('worked_hours');
                                                    });
                                                  }
                                                },
                                                text: !isEntryRegistered
                                                    ? 'REGISTRAR PONTO'
                                                    : !isExitRegistered
                                                        ? 'FINALIZAR PONTO'
                                                        : 'REINICIAR',
                                                options: FFButtonOptions(
                                                  width: screenWidth * 0.4,
                                                  height: screenHeight * 0.05,
                                                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                  iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                  color: Colors.black,
                                                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                        fontFamily: 'Readex Pro',
                                                        letterSpacing: 0.0,
                                                        fontSize: 12.0,
                                                        color: Colors.white,
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
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 30.0, 0.0, 0.0),
                                child: Text(
                                  'Observações importantes:',
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        fontFamily: 'Readex Pro',
                                        color: Colors.white,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Align(
                                      alignment: const AlignmentDirectional(-1.0, 0.0),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                                        child: Container(
                                          width: screenWidth * 0.4,
                                          height: screenHeight * 0.3,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(16.0),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                const Icon(
                                                  Icons.watch_later_outlined,
                                                  color: Color(0xFFF9A34B),
                                                  size: 24.0,
                                                ),
                                                Align(
                                                  alignment: const AlignmentDirectional(0.0, 0.0),
                                                  child: Padding(
                                                    padding: const EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 0.0),
                                                    child: CircularPercentIndicator(
                                                      percent: 0.82,
                                                      radius: screenWidth * 0.15,
                                                      lineWidth: 4.0,
                                                      animation: true,
                                                      animateFromLastPercent: true,
                                                      progressColor: FlutterFlowTheme.of(context).tertiary,
                                                      backgroundColor: const Color(0xFFF1F4F8),
                                                      center: Text(
                                                        workedHours, // Substitui "00:00" pelas horas trabalhadas
                                                        style: FlutterFlowTheme.of(context).displaySmall.override(
                                                              fontFamily: 'Outfit',
                                                              color: const Color(0xFF14181B),
                                                              fontSize: 15.0,
                                                              letterSpacing: 0.0,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment: const AlignmentDirectional(0.0, 1.0),
                                                  child: Padding(
                                                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 50.0, 0.0, 0.0),
                                                    child: Text(
                                                      'Horas trabalhadas',
                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                            fontFamily: 'Readex Pro',
                                                            color: const Color(0xFF999FA0),
                                                            fontSize: 10.0,
                                                            letterSpacing: 0.0,
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

                                  Align(
                                    alignment: const AlignmentDirectional(-1.0, 0.0),
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(10.0, 10.0, 0.0, 0.0),
                                      child: Container(
                                        width: screenWidth * 0.4,
                                        height: screenHeight * 0.3,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF90EAFF),
                                          borderRadius: BorderRadius.circular(16.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              const Icon(
                                                Icons.lock,
                                                color: Colors.black,
                                                size: 24.0,
                                              ),
                                              Padding(
                                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                                                child: Text(
                                                  'xxxxxxxx',
                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                        fontFamily: 'Readex Pro',
                                                        fontSize: 20.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 10.0, 0.0),
                                                child: FFButtonWidget(
                                                  onPressed: _showSignatureModal,
                                                  text: 'REGISTRAR TOKEN',
                                                  options: FFButtonOptions(
                                                    width: screenWidth * 0.4,
                                                    height: screenHeight * 0.05,
                                                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                    iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                    color: Colors.black,
                                                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                          fontFamily: 'Readex Pro',
                                                          fontSize: 12.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight: FontWeight.w500,
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
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, 1.0),
                child: Container(
                  width: 400.0,
                  height: 53.0,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 50.0, 0.0),
                          child: IconButton(
                            icon: const Icon(
                              Icons.home,
                              color: Color(0xFFE0BAF7),
                              size: 25.0,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomeWidget(), // Tela inicial
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 50.0, 0.0),
                          child: IconButton(
                            icon: const Icon(
                              Icons.access_time,
                              color: Color(0xFFCCD3D4),
                              size: 25.0,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PontoWidget(),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 50.0, 0.0),
                          child: IconButton(
                            icon: const Icon(
                              Icons.search,
                              color: Color(0xFFCCD3D4),
                              size: 25.0,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PesquisaWidget(),
                                ),
                              );
                            },
                          ),
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
                                builder: (context) => TreinamentosWidget(), // Tela de treinamentos
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
      ),
    );
  }
}

// Custom Painter para desenhar a assinatura
class SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => true;
}
