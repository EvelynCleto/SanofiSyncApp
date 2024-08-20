import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class DadosWidget extends StatefulWidget {
  final String? userEmail;

  const DadosWidget({Key? key, this.userEmail}) : super(key: key);

  @override
  _DadosWidgetState createState() => _DadosWidgetState();
}

class _DadosWidgetState extends State<DadosWidget> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> qrCodes = [];
  List<Map<String, dynamic>> pontos = [];
  List<Map<String, dynamic>> assinaturas = [];
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if (widget.userEmail != null && widget.userEmail!.isNotEmpty) {
      carregarDadosFuncionario(widget.userEmail!);
      carregarPontosFuncionario(widget.userEmail!);
      carregarAssinaturasFuncionario(widget.userEmail!); // Carregar assinaturas
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> carregarDadosFuncionario(String userEmail) async {
    try {
      final response = await Supabase.instance.client
          .from('qrcodes')
          .select('*')
          .eq('user_email', userEmail)
          .execute();

      if (response.data != null && response.data is List) {
        setState(() {
          qrCodes = List<Map<String, dynamic>>.from(response.data);
        });
      } else {
        print('Erro ao carregar dados: Nenhum dado encontrado');
      }
    } catch (e) {
      print('Exceção ao carregar dados: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> carregarPontosFuncionario(String userEmail) async {
    try {
      final response = await Supabase.instance.client
          .from('pontos')
          .select('*')
          .eq('user_email', userEmail)
          .execute();

      if (response.data != null && response.data is List) {
        setState(() {
          pontos = List<Map<String, dynamic>>.from(response.data);
        });
      } else {
        print('Erro ao carregar pontos: Nenhum ponto encontrado');
      }
    } catch (e) {
      print('Exceção ao carregar pontos: $e');
    }
  }

  Future<void> carregarAssinaturasFuncionario(String userEmail) async {
    try {
      final response = await Supabase.instance.client
          .from('assinaturas')
          .select('*')
          .eq('user_email', userEmail)
          .execute();

      if (response.data != null && response.data is List) {
        setState(() {
          assinaturas = List<Map<String, dynamic>>.from(response.data);
        });
      } else {
        print('Erro ao carregar assinaturas: Nenhuma assinatura encontrada');
      }
    } catch (e) {
      print('Exceção ao carregar assinaturas: $e');
    }
  }

  String formatarHorario(String horario) {
    final DateTime parsed = DateTime.parse(horario);
    return DateFormat('HH:mm').format(parsed);
  }

  String formatarData(String horario) {
    final DateTime parsed = DateTime.parse(horario);
    return DateFormat('dd/MM/yyyy').format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dados'),
        backgroundColor: const Color(0xFFB751F6),
        bottom: widget.userEmail != null && widget.userEmail!.isNotEmpty
            ? TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(text: "QR Codes"),
                  Tab(text: "Pontos"),
                  Tab(text: "Assinaturas"), // Nova aba para assinaturas
                ],
              )
            : null,
      ),
      body: widget.userEmail == null || widget.userEmail!.isEmpty
          ? const Center(
              child: Text(
                'Nenhum funcionário selecionado',
                style: TextStyle(fontSize: 18),
              ),
            )
          : isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildQrCodesView(),
                          _buildPontosView(),
                          _buildAssinaturasView(), // Adicionar visualização de assinaturas
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildQrCodesView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: qrCodes.isEmpty
          ? const Center(child: Text('Nenhum QR Code encontrado'))
          : ListView.builder(
              itemCount: qrCodes.length,
              itemBuilder: (context, index) {
                final qrCode = qrCodes[index];
                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'QR Code Gerado em: ${formatarHorario(qrCode['created_at'])}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Image.network(
                          qrCode['qr_code_url'],
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildPontosView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: pontos.isEmpty
          ? const Center(child: Text('Nenhum ponto registrado'))
          : ListView.builder(
              itemCount: pontos.length,
              itemBuilder: (context, index) {
                final ponto = pontos[index];
                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Entrada: ${ponto['entry_time']}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ponto['exit_time'] != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Saída: ${ponto['exit_time']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Horas Trabalhadas: ${ponto['horas_trabalhadas']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                'Saída: Ainda não registrada',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.red,
                                ),
                              ),
                        const SizedBox(height: 10),
                        Text(
                          'Registrado em: ${formatarHorario(ponto['created_at'])}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildAssinaturasView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: assinaturas.isEmpty
          ? const Center(child: Text('Nenhuma assinatura registrada'))
          : ListView.builder(
              itemCount: assinaturas.length,
              itemBuilder: (context, index) {
                final assinatura = assinaturas[index];
                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data: ${formatarData(assinatura['created_at'])}',
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Horário: ${formatarHorario(assinatura['created_at'])}',
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Localização: ${assinatura['location']}',
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        assinatura['assinatura_base64'] != null
                            ? Center(
                                child: Image.memory(
                                  base64Decode(assinatura['assinatura_base64']),
                                  width: 200,
                                  height: 100,
                                  fit: BoxFit.contain,
                                ),
                              )
                            : const Text(
                                'Assinatura não disponível',
                                style: TextStyle(fontSize: 16, color: Colors.red),
                              ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
