import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class DadosWidget extends StatefulWidget {
  final String? departamento;

  const DadosWidget({Key? key, this.departamento}) : super(key: key);

  @override
  _DadosWidgetState createState() => _DadosWidgetState();
}

class _DadosWidgetState extends State<DadosWidget>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> qrCodes = [];
  List<Map<String, dynamic>> pontos = [];
  List<Map<String, dynamic>> assinaturas = [];
  bool isLoading = true;
  String? selectedDepartamento;
  late TabController _tabController;
  List<bool> isExpandedList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    selectedDepartamento =
        widget.departamento ?? 'Todos'; // Seleciona 'Todos' por padrão
    carregarDados();
    isExpandedList = List.generate(qrCodes.length, (_) => false);
  }

  Future<void> carregarDados() async {
    setState(() {
      isLoading = true;
    });

    if (selectedDepartamento == 'Todos') {
      await carregarTodosOsDados();
    } else {
      await carregarDadosPorDepartamento(selectedDepartamento!);
      await carregarPontosPorDepartamento(selectedDepartamento!);
      await carregarAssinaturasPorDepartamento(selectedDepartamento!);
    }
  }

  // Método para formatar o horário corretamente
  String formatarHorario(String? horario) {
    if (horario == null || horario.isEmpty) {
      return 'Horário inválido';
    }

    try {
      if (RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(horario)) {
        return horario;
      } else {
        final DateTime parsed = DateTime.parse(horario);
        return DateFormat('HH:mm:ss').format(parsed);
      }
    } catch (e) {
      print('Erro ao formatar horário: $e');
      return 'Horário inválido';
    }
  }

// Método para formatar a data
  String formatarData(String data) {
    final DateTime parsed = DateTime.parse(data);
    return DateFormat('dd/MM/yyyy').format(parsed);
  }

// Método para filtrar os dados por departamento
  void filtrarPorDepartamento(String? departamento) {
    setState(() {
      selectedDepartamento = departamento;
      isLoading = true;
    });
    carregarDados();
  }

// Método para construir a visualização dos QR Codes
  Widget _buildQrCodesView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: qrCodes.isEmpty
          ? const Center(
              child: Text(
                'Nenhum QR Code encontrado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              itemCount: qrCodes.length,
              itemBuilder: (context, index) {
                final qrCode = qrCodes[index];
                final funcionarioNome = qrCode['funcionarios'] != null
                    ? qrCode['funcionarios']['nome'] ?? qrCode['user_email']
                    : qrCode['user_email'] ?? 'Nome não disponível';

                final funcionarioEmail = qrCode['funcionarios'] != null
                    ? qrCode['funcionarios']['email'] ?? qrCode['user_email']
                    : qrCode['user_email'] ?? 'Email não disponível';

                final qrCodeUrl =
                    qrCode['qr_code_url'] ?? 'URL do QR Code não disponível';
                final createdAt = qrCode['created_at'] ?? 'Data não disponível';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(
                            'QR Code gerado por: $funcionarioNome',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            'Email: $funcionarioEmail',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          trailing: IconButton(
                            icon:
                                const Icon(Icons.qr_code, color: Colors.purple),
                            onPressed: () {
                              // Mostrar o popup ao clicar no ícone do QR Code
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    contentPadding: const EdgeInsets.all(16.0),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'QR Code Gerado por $funcionarioNome',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        qrCodeUrl.isNotEmpty
                                            ? Image.network(
                                                qrCodeUrl,
                                                width: 200,
                                                height: 200,
                                                fit: BoxFit.contain,
                                              )
                                            : const Text(
                                                'QR Code não disponível',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.red,
                                                ),
                                              ),
                                        const SizedBox(height: 20),
                                        Text(
                                          'QR Code Gerado em: ${formatarHorario(createdAt)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.purple,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                          ),
                                          child: const Text('Fechar'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'QR Code Gerado em: ${formatarHorario(createdAt)}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
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

// Método para construir a visualização dos pontos
  Widget _buildPontosView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: pontos.isEmpty
          ? const Center(
              child: Text(
                'Nenhum ponto registrado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              itemCount: pontos.length,
              itemBuilder: (context, index) {
                final ponto = pontos[index];
                final funcionarioEmail = ponto['funcionarios'] != null
                    ? ponto['funcionarios']['email'] ?? ponto['user_email']
                    : ponto['user_email'] ?? 'Email não disponível';

                final entryTime =
                    ponto['entry_time'] ?? 'Horário de entrada não disponível';
                final exitTime = ponto['exit_time'] ?? 'Saída não registrada';
                final horasTrabalhadas =
                    ponto['horas_trabalhadas'] ?? 'Não calculado';

                return Card(
                  color: Colors.white,
                  elevation: 6,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.email_outlined, color: Colors.purple),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Email: $funcionarioEmail',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Divider(color: Colors.grey[300]),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.login, color: Colors.green),
                                const SizedBox(width: 8),
                                Text(
                                  'Entrada:',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              formatarHorario(entryTime),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        exitTime != 'Saída não registrada'
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.logout, color: Colors.red),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Saída:',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        formatarHorario(exitTime),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.access_time,
                                              color: Colors.blue),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Horas Trabalhadas:',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        horasTrabalhadas,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : const Text(
                                'Saída: Ainda não registrada',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
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

// Método para construir a visualização das assinaturas
  Widget _buildAssinaturasView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: assinaturas.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma assinatura registrada',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              itemCount: assinaturas.length,
              itemBuilder: (context, index) {
                final assinatura = assinaturas[index];
                final funcionarioEmail = assinatura['funcionarios'] != null
                    ? assinatura['funcionarios']['email'] ??
                        assinatura['user_email']
                    : assinatura['user_email'] ?? 'Email não disponível';
                final createdAt =
                    assinatura['created_at'] ?? 'Data não disponível';
                final location =
                    assinatura['location'] ?? 'Localização não disponível';
                final assinaturaBase64 = assinatura['assinatura_base64'];

                return Card(
                  color: Colors.white,
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.email_outlined,
                                color: Colors.purple, size: 22),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                funcionarioEmail,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                color: Colors.purple, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              'Data: ${formatarData(createdAt)}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.access_time_outlined,
                                color: Colors.purple, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              'Horário: ${formatarHorario(createdAt)}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                color: Colors.purple, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              'Localização: $location',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        assinaturaBase64 != null
                            ? Center(
                                child: TextButton.icon(
                                  onPressed: () {
                                    // Mostrar o popup da assinatura
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.all(20.0),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Text(
                                                'Assinatura',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              assinaturaBase64.isNotEmpty
                                                  ? Image.memory(
                                                      base64Decode(
                                                          assinaturaBase64),
                                                      width: 250,
                                                      height: 150,
                                                      fit: BoxFit.contain,
                                                    )
                                                  : const Text(
                                                      'Assinatura não disponível',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                              const SizedBox(height: 20),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.purple,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                ),
                                                child: const Text('Fechar'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.visibility,
                                    color: Colors.purple,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Ver Assinatura',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.purple,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                              )
                            : const Center(
                                child: Text(
                                  'Assinatura não disponível',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
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

  Future<void> carregarDadosPorDepartamento(String departamento) async {
    try {
      final response = await Supabase.instance.client
          .from('qrcodes')
          .select('*, funcionarios(nome, email)')
          .eq('departamento', departamento)
          .execute();

      if (response.status == 200 && response.data is List) {
        setState(() {
          qrCodes = List<Map<String, dynamic>>.from(response.data);
        });

        for (var qrCode in qrCodes) {
          var funcionario = qrCode['funcionarios'];
          var nome = funcionario != null
              ? funcionario['nome']
              : qrCode['user_email'] ?? 'Nome não disponível';
          var email = funcionario != null
              ? funcionario['email']
              : qrCode['user_email'] ?? 'Email não disponível';
          print('QR Code gerado por: $nome');
          print('Email do funcionário: $email');
        }

        print(
            'QR Codes carregados com sucesso: ${qrCodes.length} registros encontrados.');
      } else {
        print('Erro ao carregar QR Codes: ${response.status}');
        print('Dados recebidos: ${response.data}');
      }
    } catch (e) {
      print('Exceção ao carregar QR Codes: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> carregarPontosPorDepartamento(String departamento) async {
    try {
      final response = await Supabase.instance.client
          .from('pontos')
          .select(
              'id_funcionario_referencia, funcionarios(nome, email), user_email, entry_time, exit_time')
          .eq('departamento', departamento)
          .execute();

      if (response.status == 200 && response.data is List) {
        setState(() {
          pontos = List<Map<String, dynamic>>.from(response.data);
        });

        for (var ponto in pontos) {
          var funcionario = ponto['funcionarios'];
          var nome = funcionario != null
              ? funcionario['nome']
              : ponto['user_email'] ?? 'Nome não disponível';
          var email = funcionario != null
              ? funcionario['email']
              : ponto['user_email'] ?? 'Email não disponível';
          print('Ponto gerado por: $nome');
          print('Email do funcionário: $email');
          print('Entrada: ${formatarHorario(ponto['entry_time'])}');
          print('Saída: ${formatarHorario(ponto['exit_time'])}');
        }

        print(
            'Pontos carregados com sucesso: ${pontos.length} registros encontrados.');
      } else {
        print('Erro ao carregar pontos: ${response.status}');
      }
    } catch (e) {
      print('Exceção ao carregar pontos: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> carregarAssinaturasPorDepartamento(String departamento) async {
    try {
      final response = await Supabase.instance.client
          .from('assinaturas')
          .select(
              'id_funcionario_referencia, funcionarios(nome, email), user_email, created_at, location, assinatura_base64')
          .eq('departamento', departamento)
          .execute();

      if (response.status == 200 && response.data is List) {
        setState(() {
          assinaturas = List<Map<String, dynamic>>.from(response.data);
        });

        for (var assinatura in assinaturas) {
          var funcionario = assinatura['funcionarios'];
          var nome = funcionario != null
              ? funcionario['nome']
              : assinatura['user_email'] ?? 'Nome não disponível';
          var email = funcionario != null
              ? funcionario['email']
              : assinatura['user_email'] ?? 'Email não disponível';
          print('Assinatura gerada por: $nome');
          print('Email do funcionário: $email');
        }

        print(
            'Assinaturas carregadas com sucesso: ${assinaturas.length} registros encontrados.');
      } else {
        print('Erro ao carregar assinaturas: ${response.status}');
      }
    } catch (e) {
      print('Exceção ao carregar assinaturas: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> carregarTodosOsDados() async {
    try {
      final responseQrCodes = await Supabase.instance.client
          .from('qrcodes')
          .select('*, funcionarios(nome, email)')
          .execute();

      final responsePontos = await Supabase.instance.client
          .from('pontos')
          .select('*, funcionarios(nome, email)')
          .execute();

      final responseAssinaturas = await Supabase.instance.client
          .from('assinaturas')
          .select('*, funcionarios(nome, email)')
          .execute();

      if (responseQrCodes.status == 200 && responseQrCodes.data is List) {
        setState(() {
          qrCodes = List<Map<String, dynamic>>.from(responseQrCodes.data);
        });

        for (var qrCode in qrCodes) {
          var funcionario = qrCode['funcionarios'];
          var nome = funcionario != null
              ? funcionario['nome']
              : qrCode['user_email'] ?? 'Nome não disponível';
          var email = funcionario != null
              ? funcionario['email']
              : qrCode['user_email'] ?? 'Email não disponível';
          print('QR Code gerado por: $nome');
          print('Email do funcionário: $email');
        }

        print(
            'QR Codes carregados com sucesso: ${qrCodes.length} registros encontrados.');
      } else {
        print('Erro ao carregar QR Codes: ${responseQrCodes.status}');
        print('Dados recebidos: ${responseQrCodes.data}');
      }

      if (responsePontos.status == 200 && responsePontos.data is List) {
        setState(() {
          pontos = List<Map<String, dynamic>>.from(responsePontos.data);
        });

        for (var ponto in pontos) {
          var funcionario = ponto['funcionarios'];
          var nome = funcionario != null
              ? funcionario['nome']
              : ponto['user_email'] ?? 'Nome não disponível';
          var email = funcionario != null
              ? funcionario['email']
              : ponto['user_email'] ?? 'Email não disponível';
          print('Ponto gerado por: $nome');
          print('Email do funcionário: $email');
        }

        print(
            'Pontos carregados com sucesso: ${pontos.length} registros encontrados.');
      } else {
        print('Erro ao carregar pontos: ${responsePontos.status}');
        print('Dados recebidos: ${responsePontos.data}');
      }

      if (responseAssinaturas.status == 200 &&
          responseAssinaturas.data is List) {
        setState(() {
          assinaturas =
              List<Map<String, dynamic>>.from(responseAssinaturas.data);
        });

        for (var assinatura in assinaturas) {
          var funcionario = assinatura['funcionarios'];
          var nome = funcionario != null
              ? funcionario['nome']
              : assinatura['user_email'] ?? 'Nome não disponível';
          var email = funcionario != null
              ? funcionario['email']
              : assinatura['user_email'] ?? 'Email não disponível';
          print('Assinatura gerada por: $nome');
          print('Email do funcionário: $email');
        }

        print(
            'Assinaturas carregadas com sucesso: ${assinaturas.length} registros encontrados.');
      } else {
        print('Erro ao carregar assinaturas: ${responseAssinaturas.status}');
        print('Dados recebidos: ${responseAssinaturas.data}');
      }
    } catch (e) {
      print('Erro ao carregar todos os dados: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // As funções de exibição (_buildQrCodesView, _buildPontosView, etc.) já estão no código anterior, com a mesma lógica de verificar e mostrar o nome do funcionário.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dados'),
        backgroundColor: Colors.black,
        actions: [
          DropdownButton<String>(
            value: selectedDepartamento,
            icon: const Icon(Icons.filter_list, color: Colors.white),
            dropdownColor: Colors.black,
            onChanged: (String? newValue) {
              filtrarPorDepartamento(newValue);
            },
            items: <String>[
              'Todos',
              'RH',
              'TI',
              'Financeiro',
              'Operações',
              'Vendas'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "QR Codes"),
            Tab(text: "Pontos"),
            Tab(text: "Assinaturas"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildQrCodesView(),
                      _buildPontosView(),
                      _buildAssinaturasView(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
