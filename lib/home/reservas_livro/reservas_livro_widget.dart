import 'package:flutter/material.dart';
import 'package:sanofi_evelyn/flutter_flow/flutter_flow_util.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:signature/signature.dart';

class ReservasLivroWidget extends StatefulWidget {
  final String usuarioId;
  final String usuarioNome;
  final String usuarioEmail;

  const ReservasLivroWidget({
    Key? key,
    required this.usuarioId,
    required this.usuarioNome,
    required this.usuarioEmail,
  }) : super(key: key);

  @override
  _ReservasLivroWidgetState createState() => _ReservasLivroWidgetState();
}

class _ReservasLivroWidgetState extends State<ReservasLivroWidget>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _livros = [];
  List<String> _livrosAssinados = [];
  List<Map<String, dynamic>> _reservas = [];
  bool _isLoading = true;
  late TabController _tabController;
  String? _base64Signature;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _carregarLivrosReservas();
  }

  Future<void> _carregarLivrosReservas() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _loadLivros();
      await _verificarReservasUsuario();
      await _loadFilaEspera();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _showErrorDialog('Erro ao carregar dados: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLivros() async {
    final response =
        await Supabase.instance.client.from('livros').select().execute();
    if (response.status == 200 && response.data != null) {
      setState(() {
        _livros = List<Map<String, dynamic>>.from(response.data.map((livro) {
          return {
            'id': livro['id'],
            'titulo': livro['titulo'] ?? 'Título Desconhecido',
            'autor': livro['autor'] ?? 'Autor Desconhecido',
            'status': livro['status'] ?? 'disponivel',
            'descricao': livro['descricao'] ?? 'Descrição indisponível',
            'data_disponibilidade': livro['data_disponibilidade'],
          };
        }));
      });
    } else {
      throw Exception('Erro ao carregar livros');
    }
  }

  Future<void> _verificarReservasUsuario() async {
    try {
      final response = await Supabase.instance.client
          .from('livros_reservas')
          .select('livro_id, data_devolucao')
          .eq('id_funcionario', widget.usuarioId)
          .execute();

      if (response.status == 200 && response.data != null) {
        setState(() {
          _livrosAssinados = List<String>.from(
              response.data.map((reserva) => reserva['livro_id']));

          _reservas =
              List<Map<String, dynamic>>.from(response.data.map((reserva) {
            final dataDevolucao = reserva['data_devolucao'];
            return {
              'livro_id': reserva['livro_id'],
              'data_devolucao': dataDevolucao,
            };
          }));

          // Atualize o objeto livro com a data de devolução
          // Atualize o objeto livro com a data de devolução
          _livros = _livros.map((livro) {
            final reserva = _reservas.firstWhere(
                (reserva) => reserva['livro_id'] == livro['id'],
                orElse: () => <String, dynamic>{});
            if (reserva.isNotEmpty) {
              livro['data_devolucao'] = reserva['data_devolucao'];
            }
            return livro;
          }).toList();
        });
      } else {
        throw Exception('Erro ao carregar reservas');
      }
    } catch (e) {
      throw Exception('Erro ao verificar reservas do usuário: $e');
    }
  }

  Future<void> _loadFilaEspera() async {
    final response = await Supabase.instance.client
        .from('livros_reservas')
        .select(
            'livro_id, data_reserva, data_devolucao, posicao_fila, status, livros!fk_livro_reserva(titulo)')
        .eq('id_funcionario', widget.usuarioId)
        .execute();
    if (response.status == 200 && response.data != null) {
      setState(() {
        _reservas =
            List<Map<String, dynamic>>.from(response.data.map((reserva) {
          return {
            'nome_livro':
                reserva['livros']['titulo'] ?? 'Informação indisponível',
            'data_reserva': reserva['data_reserva'],
            'data_devolucao': reserva['data_devolucao'] ?? 'Não devolvido',
            'posicao_fila': reserva['posicao_fila'] ?? 'Indefinida',
            'status': reserva['status'],
          };
        }));
      });
    } else {
      throw Exception('Erro ao carregar fila de espera');
    }
  }

  // Abrir a captura de assinatura em um BottomSheet (modal)
  Future<void> _exibirModalAssinatura(String livroId, String status) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _buildSignatureModal(context, livroId, status);
      },
    );
  }

  // Widget do Modal de Captura de Assinatura
  Widget _buildSignatureModal(
      BuildContext context, String livroId, String status) {
    final SignatureController _controller = SignatureController(
      penStrokeWidth: 5,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: [
          Text(
            'Assine Abaixo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          SizedBox(height: 10),
          Signature(
            controller: _controller,
            height: 200,
            backgroundColor: Colors.grey[200]!,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _controller.clear();
                },
                icon: Icon(Icons.clear),
                label: Text('Limpar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  if (_controller.isNotEmpty) {
                    final signature = await _controller.toPngBytes();
                    final base64Signature = base64Encode(signature!);
                    setState(() {
                      _base64Signature = base64Signature;
                    });
                    Navigator.pop(context);
                    if (status == 'Assinado') {
                      _reservarLivro(livroId);
                    } else {
                      _entrarFilaEspera(livroId);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Por favor, assine."),
                    ));
                  }
                },
                icon: Icon(Icons.check),
                label: Text('Confirmar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _reservarLivro(String livroId) async {
    if (_base64Signature == null) {
      _showErrorDialog("Por favor, capture a assinatura antes de reservar.");
      return;
    }

    try {
      if (_livrosAssinados.contains(livroId)) {
        _showErrorDialog('Você já assinou este livro.');
        return;
      }

      final response =
          await Supabase.instance.client.from('livros_reservas').insert({
        'livro_id': livroId,
        'id_funcionario': widget.usuarioId,
        'usuario_email': widget.usuarioEmail,
        'usuario_nome': widget.usuarioNome,
        'assinatura_base64': _base64Signature,
        'data_reserva': DateTime.now().toIso8601String(),
        'status': 'Assinado'
      }).execute();

      if (response.status == 201) {
        setState(() {
          _livrosAssinados.add(livroId);
        });
        _showSuccessDialog('Reserva realizada com sucesso!');
      } else {
        throw Exception('Erro ao reservar o livro');
      }
    } catch (e) {
      _showErrorDialog('Erro ao reservar o livro: $e');
    }
  }

  Future<void> _entrarFilaEspera(String livroId) async {
    if (_base64Signature == null) {
      _showErrorDialog(
          "Por favor, capture a assinatura antes de entrar na fila de espera.");
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('livros_reservas')
          .update({
            'status': 'Assinado', // Altera o status para 'Assinado'
            'assinatura_base64':
                _base64Signature, // Salva a assinatura capturada
            'data_reserva': DateTime.now()
                .toIso8601String(), // Atualiza a data da assinatura
          })
          .eq('livro_id', livroId)
          .eq('id_funcionario', widget.usuarioId)
          .execute();

      if (response.status == 200) {
        setState(() {
          // Atualiza a lista de reservas para refletir a mudança de status
          _reservas = _reservas.map((reserva) {
            if (reserva['livro_id'] == livroId) {
              reserva['status'] =
                  'Assinado'; // Atualiza o status localmente também
            }
            return reserva;
          }).toList();
        });

        _showSuccessDialog(
            'Você foi adicionado à fila de espera e o livro foi assinado.');
      } else {
        throw Exception('Erro ao atualizar o status na fila de espera');
      }
    } catch (e) {
      _showErrorDialog('Erro ao entrar na fila de espera: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservar Livro'),
        backgroundColor: Colors.deepPurple,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(icon: Icon(Icons.library_books), text: "Reservar"),
            Tab(icon: Icon(Icons.check_circle), text: "Assinados"),
            Tab(icon: Icon(Icons.access_time), text: "Fila de Espera"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReservarLivroTab(),
          _buildLivrosAssinadosTab(),
          _buildFilaEsperaTab(),
        ],
      ),
    );
  }

  Widget _buildReservarLivroTab() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.7,
            ),
            padding: EdgeInsets.all(10),
            itemCount: _livros.length,
            itemBuilder: (context, index) {
              final livro = _livros[index];
              bool jaAssinou = _livrosAssinados.contains(livro['id']);
              return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.book, color: Colors.purple, size: 28),
                      SizedBox(height: 8),
                      Text(
                        livro['titulo'] ?? 'Título não disponível',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Autor: ${livro['autor'] ?? 'Autor não disponível'}',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Status: ${jaAssinou ? 'Assinado' : livro['status'] == 'disponivel' ? 'Disponível' : 'Indisponível'}',
                        style: TextStyle(
                          color: jaAssinou
                              ? Colors.grey
                              : livro['status'] == 'disponivel'
                                  ? Colors.green
                                  : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: jaAssinou
                              ? ElevatedButton.icon(
                                  onPressed: null,
                                  icon: Icon(Icons.check_circle,
                                      color: Colors.grey),
                                  label: Text('Assinado'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                )
                              : livro['status'] == 'disponivel'
                                  ? ElevatedButton.icon(
                                      onPressed: () => _exibirModalAssinatura(
                                          livro['id'].toString(), 'Assinado'),
                                      icon:
                                          Icon(Icons.book, color: Colors.white),
                                      label: Text('Reservar'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    )
                                  : ElevatedButton.icon(
                                      onPressed: () => _exibirModalAssinatura(
                                          livro['id'].toString(),
                                          'Fila de Espera'),
                                      icon: Icon(Icons.queue,
                                          color: Colors.white),
                                      label: Text('Fila Espera'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildLivrosAssinadosTab() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _livrosAssinados.length,
      itemBuilder: (context, index) {
        final livroId = _livrosAssinados[index];

        // Obtendo o livro e a data de devolução diretamente do Supabase
        final livro = _livros.firstWhere((l) => l['id'] == livroId,
            orElse: () => <String, dynamic>{
                  'id': 'indefinido',
                  'titulo': 'Título não disponível',
                  'autor': 'Autor desconhecido',
                  'descricao': 'Descrição não disponível',
                  'data_devolucao': null
                });

        print(
            'Livro ID: $livroId, Livro Data: $livro'); // Verificar se o livro está sendo encontrado corretamente

        // Definir a data de devolução a partir do que foi cadastrado
        final dataDevolucao = livro['data_devolucao'] != null
            ? DateTime.parse(livro['data_devolucao'])
            : null;

        print(
            'Data de devolução do livro $livroId: $dataDevolucao'); // Verificação da data de devolução

        // Calcula os dias restantes para a devolução
        final diasRestantes = dataDevolucao != null
            ? dataDevolucao.difference(DateTime.now()).inDays
            : null;

        // Define as cores e mensagens de alerta com base na data de devolução
        Color corAlerta;
        String mensagemAlerta;

        if (diasRestantes != null) {
          if (diasRestantes > 7) {
            corAlerta = Colors.green;
            mensagemAlerta =
                'Prazo de devolução normal, faltam $diasRestantes dias.';
          } else if (diasRestantes > 0 && diasRestantes <= 7) {
            corAlerta = Colors.orange;
            mensagemAlerta =
                'Atenção, prazo de devolução se aproxima. Faltam $diasRestantes dias.';
          } else if (diasRestantes == 0) {
            corAlerta = Colors.red;
            mensagemAlerta = 'Devolução é hoje! Urgente!';
          } else {
            corAlerta = Colors.red;
            mensagemAlerta = 'Prazo de devolução expirado!';
          }
        } else {
          corAlerta = Colors.grey;
          mensagemAlerta = 'Data de devolução não definida';
        }

        return Card(
          elevation: 5,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        livro['titulo'] ?? 'Título não disponível',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.check_circle,
                      color: corAlerta,
                      size: 30,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Autor: ${livro['autor'] ?? 'Autor não disponível'}',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                SizedBox(height: 8),
                Text(
                  'Descrição: ${livro['descricao'] ?? 'Descrição não disponível'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                if (dataDevolucao != null)
                  Text(
                    'Data de Devolução: ${DateFormat('dd/MM/yyyy').format(dataDevolucao)}',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: corAlerta.withOpacity(0.1),
                    border: Border.all(color: corAlerta),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: corAlerta),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          mensagemAlerta,
                          style: TextStyle(
                            fontSize: 14,
                            color: corAlerta,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilaEsperaTab() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _reservas.length,
            itemBuilder: (context, index) {
              final reserva = _reservas[index];
              final dataReserva = DateTime.parse(reserva['data_reserva']);
              final posicaoFila = reserva['posicao_fila'] != null
                  ? reserva['posicao_fila']
                      .toString() // Garantindo que mostre a posição correta
                  : 'Indefinida';
              final dataDevolucao = reserva['data_devolucao'] != 'Não devolvido'
                  ? DateTime.parse(reserva['data_devolucao'])
                  : null;

              // Lógica de cores e mensagens baseadas na posição
              Color corAlerta;
              String mensagemAlerta =
                  'Você está na posição $posicaoFila da fila';

              if (posicaoFila == '1') {
                corAlerta = Colors.green;
              } else if (posicaoFila == '2' || posicaoFila == '3') {
                corAlerta = Colors.orange;
              } else {
                corAlerta = Colors.red;
              }

              return Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              reserva['nome_livro'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.hourglass_bottom,
                            color: corAlerta,
                            size: 30,
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Data de Reserva: ${DateFormat('dd/MM/yyyy').format(dataReserva)}',
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                      if (dataDevolucao != null) ...[
                        SizedBox(height: 8),
                        Text(
                          'Data de Devolução: ${DateFormat('dd/MM/yyyy').format(dataDevolucao)}',
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ],
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: corAlerta.withOpacity(0.1),
                          border: Border.all(color: corAlerta),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: corAlerta),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                mensagemAlerta,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: corAlerta,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Erro'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sucesso'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
