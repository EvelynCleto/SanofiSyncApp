import 'dart:convert';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
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
  bool isGestor = false; // Verifica se o usuário é gestor

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _signatureKey = GlobalKey();
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeWidget(),
    const PontoWidget(),
    const PesquisaWidget(),
    const TreinamentosWidget(),
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeModel());
    _loadEntryTime(); // Carrega o horário de entrada salvo, se houver
    _checkUserRole(); // Verifica se o usuário é gestor
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Função para carregar o horário de entrada salvo anteriormente
  // Função para carregar o horário de entrada salvo anteriormente
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

  // Função para obter a localização do usuário a partir do IP
  Future<String> _getLocationFromIP() async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.ipgeolocation.io/ipgeo?apiKey=51687a67dfa04490ac6c3849dfcc2056'));

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

  // Função para gerar o QR code
  // Supondo que você tenha a URL do QR code armazenada em uma variável chamada 'qrCodeUrl'

  void _generateQRCode() async {
    setState(() {
      isLoading = true; // Inicia o indicador de carregamento
    });

    // Gera o QR code usando uma API externa
    String qrData = 'TOKEN_${DateTime.now().millisecondsSinceEpoch}';
    String qrCodeUrl =
        'https://api.qrserver.com/v1/create-qr-code/?data=$qrData&size=300x300&color=4A148C&bgcolor=D1C4E9';

    await Future.delayed(
        const Duration(milliseconds: 1000)); // Simulação de espera

    setState(() {
      isLoading = false; // Termina o carregamento
      _showQRCodeModal(
          context, qrCodeUrl); // Exibe o modal após o QR code ser gerado
    });

    // Salva o QR code no banco de dados automaticamente
    _saveQRCodeToDatabase(qrCodeUrl);
  }

  // Função para exibir o modal de QR code
  void _showQRCodeModal(BuildContext context, String qrCodeUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Colors.white,
          content: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10.0,
                  spreadRadius: 5.0,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título acima do QR code para simular a identidade da Sanofi
                Text(
                  'Sanofi',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0084CA), // Azul da Sanofi
                  ),
                ),
                SizedBox(height: 20.0),

                // Exibição do QR code com borda estilizada
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(
                      color: Color(0xFF0084CA), // Azul da Sanofi
                      width: 3.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10.0,
                        spreadRadius: 5.0,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(10.0),
                  child: Image.network(
                    qrCodeUrl,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 20.0),

                // Texto abaixo do QR code
                Text(
                  'Apresente este QR code na entrada',
                  style: TextStyle(
                    color: Color(0xFF4A148C), // Roxo da Sanofi
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 20.0),

                // Botão para fechar o modal
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Fechar',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFF0084CA), // Azul da Sanofi
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
      final response = await supabaseClient.from('qrcodes').insert({
        'user_email': email,
        'qr_code_url': qrCodeUrl,
        'created_at': DateTime.now().toIso8601String(),
      }).execute();

      if (response.data == null) {
        print('QR code salvo com sucesso!');
      } else {
        print(
            'Erro ao salvar o QR code no banco de dados: ${response.data!.message}');
      }
    } catch (e) {
      print('Erro: $e');
    }
  }

  // Função para exibir o modal para capturar a assinatura
  void _showSignatureModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)], // Gradiente roxo
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25.0), // Cantos superiores mais arredondados
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15.0,
                spreadRadius: 5.0,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Título
              Text(
                'Assine Abaixo',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Cor branca para contraste
                ),
              ),
              SizedBox(height: 15.0),

              // Caixa de Assinatura
              Container(
                height: 180.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(20.0), // Bordas mais arredondadas
                  border: Border.all(
                    color:
                        Colors.white, // Mantendo a borda branca para contraste
                    width: 3.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset:
                          Offset(0, 5), // Sombra mais forte para profundidade
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Signature(
                    controller: _controller,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
              SizedBox(height: 15.0),

              // Botões de Ação
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _controller.clear();
                    },
                    icon: Icon(Icons.clear, color: Color(0xFF6A1B9A)),
                    label: Text('Limpar',
                        style: TextStyle(color: Color(0xFF6A1B9A))),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Color(0xFF6A1B9A), width: 2.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 12.0),
                      elevation: 5.0,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _saveSignature,
                    icon: Icon(Icons.check, color: Colors.white),
                    label:
                        Text('Salvar', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6A1B9A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 12.0),
                      elevation: 5.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Função para verificar se o usuário é gestor
  Future<void> _checkUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email') ?? '';

    if (email.isNotEmpty) {
      final response = await Supabase.instance.client
          .from('Acesso Geral')
          .select()
          .eq('email', email)
          .single()
          .execute();

      if (response.data != null) {
        setState(() {
          isGestor = response.data['is_gestor'] == true;
        });
      }
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
        final byteData =
            await signatureImage!.toByteData(format: ui.ImageByteFormat.png);
        final pngBytes = byteData!.buffer.asUint8List();

        // Captura a hora e a data atuais
        final currentDateTime = DateTime.now();
        final String formattedDateTime =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(currentDateTime);

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
        final dbResponse = await supabaseClient.from('assinaturas').insert({
          'user_email': email,
          'created_at': formattedDateTime,
          'assinatura_base64': base64Image,
          'location': location,
          'date': formattedDateTime, // Certifique-se de passar a data aqui
        }).execute();

        if (dbResponse.data != null) {
          print(
              'Erro ao salvar a assinatura no banco de dados: ${dbResponse.data!.message}');
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
    final response = await supabaseClient.from('pontos').insert({
      'user_email': prefs.getString('user_email') ?? '',
      'entry_time': currentEntryTime,
    }).execute();

    if (response.data == null) {
      print('Horário de entrada salvo com sucesso no banco de dados!');
    } else {
      print('Erro ao salvar o horário de entrada: ${response.data!.message}');
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => _pages[index],
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(0.0, 1.0);
          var end = Offset.zero;
          var curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
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
          .eq('entry_time',
              entryTime) // Certifica-se de atualizar o registro correto
          .execute();

      if (response.data == null) {
        print(
            'Horário de saída e horas trabalhadas salvos com sucesso no banco de dados!');
      } else {
        print(
            'Erro ao salvar o horário de saída e horas trabalhadas: ${response.data!.message}');
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Color(0xFFF5F5F5), // Fundo cinza claro
        appBar: AppBar(
          backgroundColor: Color(0xFF512DA8), // Roxo suave para a AppBar
          title: Text('Home', style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Calendário
              Container(
                color: Color(0xFFEDEDED), // Fundo cinza claro para o calendário
                child: CalendarDatePicker(
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  onDateChanged: (date) {},
                ),
              ),
              SizedBox(height: 16.0),
              // Seção de botões
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white, // Fundo branco para a caixa
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Marcar ponto',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2196F3), // Azul vibrante
                          ),
                          child: Text('GERAR QR CODE',
                              style: TextStyle(color: Colors.white)),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2196F3), // Azul vibrante
                          ),
                          child: Text('FINALIZAR PONTO',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              // Seção de Gestão de Funcionários
              Text(
                'Gestão de Funcionários',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 150.0,
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.watch_later_outlined,
                            color: Color(0xFF673AB7), size: 30.0), // Roxo claro
                        SizedBox(height: 8.0),
                        Text('00:00:00',
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0)),
                        SizedBox(height: 8.0),
                        Text('Horas trabalhadas',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  Container(
                    width: 150.0,
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.lock,
                            color: Color(0xFF673AB7), size: 30.0), // Roxo claro
                        SizedBox(height: 8.0),
                        Text('XXXXXXXX',
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0)),
                        SizedBox(height: 8.0),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2196F3), // Azul vibrante
                          ),
                          child: Text('REGISTRAR TOKEN',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

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
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 70.0, 0.0, 0.0),
                child: Stack(children: [
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                20.0, 0.0, 20.0, 0.0),
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
                                          scaffoldKey.currentState
                                              ?.openDrawer();
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
                                  // Seção de Calendário
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 18.0, 0.0, 0.0),
                                    child: FlutterFlowCalendar(
                                      color: Colors.white,
                                      iconColor: Colors.white,
                                      weekFormat: true,
                                      weekStartsMonday: false,
                                      rowHeight: 64.0,
                                      onChange:
                                          (DateTimeRange? newSelectedDate) {
                                        setState(() =>
                                            _model.calendarSelectedDay =
                                                newSelectedDate);
                                      },
                                      titleStyle: FlutterFlowTheme.of(context)
                                          .headlineSmall
                                          .override(
                                            fontFamily: 'Outfit',
                                            color: Colors.white,
                                            letterSpacing: 0.0,
                                          ),
                                      dayOfWeekStyle:
                                          FlutterFlowTheme.of(context)
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
                                      selectedDateStyle:
                                          FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .override(
                                                fontFamily: 'Readex Pro',
                                                color: const Color(0xFFBB4CFF),
                                                letterSpacing: 0.0,
                                              ),
                                      inactiveDateStyle:
                                          FlutterFlowTheme.of(context)
                                              .labelMedium
                                              .override(
                                                fontFamily: 'Readex Pro',
                                                color: const Color(0xFFBB4CFF),
                                                letterSpacing: 0.0,
                                              ),
                                    ),
                                  ),
                                  // Seção de Registro de Ponto e QR Code
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 10.0, 0.0, 0.0),
                                    child: Container(
                                      width: double.infinity,
                                      height: screenHeight * 0.15,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0BAF7),
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 12.0, 0.0, 0.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          60.0,
                                                          0.0,
                                                          0.0,
                                                          5.0), // Ajuste o valor de 20.0 para controlar o espaço à esquerda do ícone
                                                  child: const Icon(
                                                    Icons.qr_code_2,
                                                    color: Color(0xFFBB4CFF),
                                                    size: 50.0,
                                                  ),
                                                ),
                                                Spacer(), // Espaço flexível entre o ícone e o texto
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          0.0,
                                                          0.0,
                                                          50.0,
                                                          0.0), // Ajuste o valor de 20.0 para controlar o espaço à direita do texto
                                                  child: entryTime.isEmpty
                                                      ? Text(
                                                          'Marcar ponto',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily:
                                                                    'Readex Pro',
                                                                color: const Color(
                                                                    0xFFBB4CFF), // Cor ajustada para combinar com o tema roxo
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                        )
                                                      : Text(
                                                          entryTime,
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily:
                                                                    'Readex Pro',
                                                                fontSize: 20.0,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                        ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          10.0, 0.0, 0.0, 0.0),
                                                  child: FFButtonWidget(
                                                    onPressed: isLoading
                                                        ? null
                                                        : _generateQRCode, // Desabilita o botão enquanto está carregando
                                                    text: isLoading
                                                        ? 'Carregando...'
                                                        : 'GERAR QR CODE', // Mostra o estado de carregamento
                                                    options: FFButtonOptions(
                                                      width: screenWidth * 0.4,
                                                      height:
                                                          screenHeight * 0.05,
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(0.0,
                                                              0.0, 0.0, 0.0),
                                                      iconPadding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(0.0,
                                                              0.0, 0.0, 0.0),
                                                      color: isLoading
                                                          ? const Color
                                                              .fromARGB(
                                                              255, 0, 0, 0)
                                                          : const Color
                                                              .fromARGB(
                                                              255,
                                                              0,
                                                              0,
                                                              0), // Cor roxa para carregamento e normal
                                                      textStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleSmall
                                                              .override(
                                                                fontFamily:
                                                                    'Readex Pro',
                                                                color: Colors
                                                                    .white,
                                                                fontSize:
                                                                    14.0, // Font size ajustado para melhor legibilidade
                                                                letterSpacing:
                                                                    0.0,
                                                              ),
                                                      elevation:
                                                          6.0, // Elevação do botão
                                                      borderSide:
                                                          const BorderSide(
                                                        color:
                                                            Colors.transparent,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              24.0),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          10.0, 0.0, 0.0, 0.0),
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
                                                          workedHours =
                                                              '00:00:00';
                                                          isEntryRegistered =
                                                              false;
                                                          isExitRegistered =
                                                              false;
                                                        });

                                                        SharedPreferences
                                                                .getInstance()
                                                            .then((prefs) {
                                                          prefs.remove(
                                                              'entry_time');
                                                          prefs.remove(
                                                              'exit_time');
                                                          prefs.remove(
                                                              'worked_hours');
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
                                                      height:
                                                          screenHeight * 0.05,
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(0.0,
                                                              0.0, 0.0, 0.0),
                                                      iconPadding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(0.0,
                                                              0.0, 0.0, 0.0),
                                                      color: Colors.black,
                                                      textStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleSmall
                                                              .override(
                                                                fontFamily:
                                                                    'Readex Pro',
                                                                letterSpacing:
                                                                    0.0,
                                                                fontSize: 12.0,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                      elevation: 3.0,
                                                      borderSide:
                                                          const BorderSide(
                                                        color:
                                                            Colors.transparent,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              24.0),
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
                                  // Condicional para mostrar seções específicas para gestores
                                  if (isGestor) ...[
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 30.0, 0.0, 0.0),
                                      child: Text(
                                        'Gestão de Funcionários',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Readex Pro',
                                              color: Colors.white,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                    ),
                                    // Aqui você pode adicionar outras funcionalidades específicas para gestores
                                    // Por exemplo, exibir uma lista de funcionários, relatórios, etc.
                                  ],
                                  // Outras seções padrão
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Align(
                                        alignment: const AlignmentDirectional(
                                            -1.0, 0.0),
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 10.0, 20.0, 0.0),
                                          child: Container(
                                            width: screenWidth * 0.4,
                                            height: screenHeight * 0.3,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                      0.0, 20.0, 0.0, 0.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  const Icon(
                                                    Icons.watch_later_outlined,
                                                    color: Color(0xFFF9A34B),
                                                    size: 24.0,
                                                  ),
                                                  Align(
                                                    alignment:
                                                        const AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(24.0,
                                                              24.0, 24.0, 0.0),
                                                      child:
                                                          CircularPercentIndicator(
                                                        percent: 0.82,
                                                        radius:
                                                            screenWidth * 0.15,
                                                        lineWidth: 4.0,
                                                        animation: true,
                                                        animateFromLastPercent:
                                                            true,
                                                        progressColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .tertiary,
                                                        backgroundColor:
                                                            const Color(
                                                                0xFFF1F4F8),
                                                        center: Text(
                                                          workedHours, // Substitui "00:00" pelas horas trabalhadas
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .displaySmall
                                                              .override(
                                                                fontFamily:
                                                                    'Outfit',
                                                                color: const Color(
                                                                    0xFF14181B),
                                                                fontSize: 15.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        const AlignmentDirectional(
                                                            0.0, 1.0),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(0.0,
                                                              50.0, 0.0, 0.0),
                                                      child: Text(
                                                        'Horas trabalhadas',
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .bodyMedium
                                                            .override(
                                                              fontFamily:
                                                                  'Readex Pro',
                                                              color: const Color(
                                                                  0xFF999FA0),
                                                              fontSize: 10.0,
                                                              letterSpacing:
                                                                  0.0,
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
                                        alignment: const AlignmentDirectional(
                                            -1.0, 0.0),
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(10.0, 10.0, 0.0, 0.0),
                                          child: Container(
                                            width: screenWidth * 0.4,
                                            height: screenHeight * 0.3,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF90EAFF),
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                      0.0, 20.0, 0.0, 0.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  const Icon(
                                                    Icons.lock,
                                                    color: Colors.black,
                                                    size: 24.0,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 20.0,
                                                            0.0, 0.0),
                                                    child: Text(
                                                      'xxxxxxxx',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                'Readex Pro',
                                                            fontSize: 20.0,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(10.0, 0.0,
                                                            10.0, 0.0),
                                                    child: FFButtonWidget(
                                                      onPressed:
                                                          _showSignatureModal,
                                                      text: 'REGISTRAR TOKEN',
                                                      options: FFButtonOptions(
                                                        width:
                                                            screenWidth * 0.4,
                                                        height:
                                                            screenHeight * 0.05,
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(0.0,
                                                                0.0, 0.0, 0.0),
                                                        iconPadding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(0.0,
                                                                0.0, 0.0, 0.0),
                                                        color: Colors.black,
                                                        textStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .override(
                                                                  fontFamily:
                                                                      'Readex Pro',
                                                                  fontSize:
                                                                      12.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                        elevation: 3.0,
                                                        borderSide:
                                                            const BorderSide(
                                                          color: Colors
                                                              .transparent,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(24.0),
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
                  // Rodapé com ícones de navegação e logout
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
                                color: Color(0xFFE0BAF7),
                                size:
                                    22.0, // Tamanho do ícone ligeiramente reduzido
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        const HomeWidget(),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      const begin = Offset(0.0,
                                          1.0); // Inicia a partir da parte inferior da tela
                                      const end = Offset.zero;
                                      const curve = Curves.easeInOut;

                                      var tween = Tween(begin: begin, end: end)
                                          .chain(CurveTween(curve: curve));
                                      var offsetAnimation =
                                          animation.drive(tween);

                                      return SlideTransition(
                                        position: offsetAnimation,
                                        child: child,
                                      );
                                    },
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
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        const PontoWidget(),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      const begin = Offset(0.0, 1.0);
                                      const end = Offset.zero;
                                      const curve = Curves.easeInOut;

                                      var tween = Tween(begin: begin, end: end)
                                          .chain(CurveTween(curve: curve));
                                      var offsetAnimation =
                                          animation.drive(tween);

                                      return SlideTransition(
                                        position: offsetAnimation,
                                        child: child,
                                      );
                                    },
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
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        const PesquisaWidget(),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      const begin = Offset(0.0, 1.0);
                                      const end = Offset.zero;
                                      const curve = Curves.easeInOut;

                                      var tween = Tween(begin: begin, end: end)
                                          .chain(CurveTween(curve: curve));
                                      var offsetAnimation =
                                          animation.drive(tween);

                                      return SlideTransition(
                                        position: offsetAnimation,
                                        child: child,
                                      );
                                    },
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
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        const TreinamentosWidget(),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      const begin = Offset(0.0, 1.0);
                                      const end = Offset.zero;
                                      const curve = Curves.easeInOut;

                                      var tween = Tween(begin: begin, end: end)
                                          .chain(CurveTween(curve: curve));
                                      var offsetAnimation =
                                          animation.drive(tween);

                                      return SlideTransition(
                                        position: offsetAnimation,
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]))));
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
