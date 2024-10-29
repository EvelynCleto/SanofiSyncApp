import 'dart:typed_data'; // Import necessário para Uint8List
import 'dart:convert'; // Import necessário para base64Decode
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class GestaoLivrosWidget extends StatefulWidget {
  final String usuarioId;

  const GestaoLivrosWidget({Key? key, required this.usuarioId})
      : super(key: key);

  @override
  _GestaoLivrosWidgetState createState() => _GestaoLivrosWidgetState();
}

class _GestaoLivrosWidgetState extends State<GestaoLivrosWidget> {
  List<Map<String, dynamic>> _livros = [];
  List<Map<String, dynamic>> _assinaturas = [];
  List<Map<String, dynamic>> _filaEspera = [];
  bool _isLoading = true;
  String? _livroIdParaEditar;

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _autorController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _anoPublicacaoController =
      TextEditingController();

  DateTime? _dataExpiracao;
  DateTime? _dataPublicacao;

  @override
  void initState() {
    super.initState();
    _loadLivros();
    _loadAssinaturas();
    _loadFilaEspera();
  }

  Future<void> _adicionarLivro() async {
    if (_tituloController.text.isEmpty ||
        _autorController.text.isEmpty ||
        _quantidadeController.text.isEmpty ||
        _anoPublicacaoController.text.isEmpty) {
      _showErrorDialog("Preencha todos os campos!");
      return;
    }

    final response = await Supabase.instance.client.from('livros').insert({
      'titulo': _tituloController.text,
      'autor': _autorController.text,
      'quantidade': int.parse(_quantidadeController.text),
      'descricao': _descricaoController.text,
      'data_expiracao':
          _dataExpiracao != null ? _dataExpiracao!.toIso8601String() : null,
      'ano_publicacao': _anoPublicacaoController.text,
      'status': 'disponivel'
    }).execute();

    if (response.status == 201) {
      _loadLivros(); // Recarregar a lista de livros
      _clearForm();
      _showSuccessDialog("Livro adicionado com sucesso!");
    } else {
      _showErrorDialog("Erro ao adicionar livro: ${response.status}");
    }
  }

  Future<void> _definirDataDevolucao(String reservaId) async {
    DateTime? dataDevolucao = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (dataDevolucao == null) {
      _showErrorDialog("Por favor, selecione uma data válida.");
      return;
    }

    String dataFormatada = DateFormat('yyyy-MM-dd').format(dataDevolucao);
    print(
        "Tentando definir data de devolução: $dataFormatada para reserva: $reservaId");

    final response = await Supabase.instance.client
        .from('livros_reservas')
        .update({
          'data_devolucao': dataFormatada,
        })
        .eq('id', reservaId) // Usa o ID da reserva
        .execute();

    print('Response da atualização de data de devolução: ${response.status}');
    print('Dados da resposta: ${response.data}');

    if (response.status == 200 || response.status == 204) {
      _showSuccessDialog("Data de devolução definida com sucesso!");
      await _loadAssinaturas(); // Atualiza a lista de assinaturas
    } else {
      _showErrorDialog("Erro ao definir data de devolução.");
    }
  }

  Future<void> _loadLivros() async {
    final response =
        await Supabase.instance.client.from('livros').select().execute();

    if (response.status == 200 && response.data != null) {
      print('Raw Response Data: ${response.data}');

      setState(() {
        _livros = List<Map<String, dynamic>>.from(response.data.map((livro) {
          // Exibir no log a estrutura do livro, incluindo a data de devolução
          print('Livro Data: $livro');

          // Verificar e formatar a data de devolução se existir
          String? dataDevolucao = livro['data_disponibilidade'] != null
              ? livro['data_disponibilidade']
                  as String // Tentei usar a mesma lógica do log
              : null;

          // Formatar a data para exibição
          String dataFormatada = dataDevolucao != null
              ? DateFormat('dd/MM/yyyy').format(DateTime.parse(dataDevolucao))
              : 'Sem data de devolução';

          return {
            'id': livro['id'],
            'titulo': livro['titulo'],
            'autor': livro['autor'],
            'data_devolucao':
                dataFormatada, // Agora pegando corretamente a data
            // Outros campos...
          };
        }));
        _isLoading = false;
      });
    } else {
      _showErrorDialog("Erro ao carregar livros: ${response.status}");
    }
  }

// Função para carregar as assinaturas confirmadas
  Future<void> _loadAssinaturas() async {
    final response = await Supabase.instance.client
        .from('livros_reservas')
        .select(
            'id, usuario_nome, usuario_email, data_reserva, data_devolucao, assinatura_base64, livros!livros_reservas_livro_id_fkey(titulo, id)')
        .eq('status', 'Assinado') // Somente reservas assinadas
        .order('data_reserva', ascending: true) // Ordena pela data de reserva
        .execute();

    print('Response data: ${response.data}');

    if (response.status == 200 && response.data != null) {
      setState(() {
        _assinaturas =
            List<Map<String, dynamic>>.from(response.data.map((reserva) {
          print(
              'Data de Devolução para o livro ${reserva['livros']['titulo']}: ${reserva['data_devolucao']}');
          return {
            'id': reserva['id'], // Inclui o ID da reserva
            'nome': reserva['usuario_nome'] ?? 'Nome desconhecido',
            'email': reserva['usuario_email'] ?? 'E-mail desconhecido',
            'data_reserva': reserva['data_reserva']?.substring(0, 10) ??
                'Data indisponível',
            'data_devolucao':
                reserva['data_devolucao'], // Mantém a data original
            'assinatura':
                reserva['assinatura_base64'] ?? 'Assinatura indisponível',
            'livro': reserva['livros']['titulo'] ?? 'Livro desconhecido',
            'id_livro': reserva['livros']['id'] ?? '',
            'dias_restantes': _calcularDiasRestantes(reserva['data_devolucao']),
            'atrasado': _verificarAtraso(reserva['data_devolucao']),
          };
        }));
        _isLoading = false;
      });
    } else {
      _showErrorDialog("Erro ao carregar assinaturas: ${response.status}");
    }
  }

  int _calcularDiasRestantes(String? dataDevolucao) {
    print('Calculando dias restantes para: $dataDevolucao');
    if (dataDevolucao == null) {
      print('Data de devolução nula');
      return 0;
    }
    final DateTime data = DateTime.parse(dataDevolucao);
    return data.difference(DateTime.now()).inDays;
  }

  bool _verificarAtraso(String? dataDevolucao) {
    print('Verificando atraso para: $dataDevolucao');
    if (dataDevolucao == null) {
      print('Data de devolução nula para verificação de atraso');
      return false;
    }
    final DateTime data = DateTime.parse(dataDevolucao);
    return DateTime.now().isAfter(data);
  }

  Future<void> _loadFilaEspera() async {
    final response = await Supabase.instance.client
        .from('livros_reservas')
        .select(
            'id, usuario_nome, usuario_email, data_reserva, assinatura_base64, posicao_fila, livros!livros_reservas_livro_id_fkey(titulo)')
        .eq('status', 'Fila de Espera') // Apenas reservas em fila de espera
        .order('posicao_fila', ascending: true) // Ordena pela posição na fila
        .execute();

    if (response.status == 200 && response.data != null) {
      setState(() {
        _filaEspera =
            List<Map<String, dynamic>>.from(response.data.map((reserva) {
          return {
            'id': reserva['id'], // Inclui o id da reserva aqui
            'nome': reserva['usuario_nome'] ?? 'Nome desconhecido',
            'email': reserva['usuario_email'] ?? 'E-mail desconhecido',
            'livro': reserva['livros']['titulo'] ?? 'Livro desconhecido',
            'posicao_fila':
                reserva['posicao_fila']?.toString() ?? 'Posição desconhecida',
            'assinatura': reserva['assinatura_base64'] ?? '',
          };
        }));
        _isLoading = false;
      });
    } else {
      _showErrorDialog("Erro ao carregar fila de espera: ${response.status}");
    }
  }

  Future<void> _atualizarPosicaoFila(String reservaId, int novaPosicao) async {
    if (reservaId.isEmpty) {
      _showErrorDialog('ID da reserva não encontrado.');
      return;
    }

    final response = await Supabase.instance.client
        .from('livros_reservas')
        .update({'posicao_fila': novaPosicao})
        .eq('id', reservaId)
        .execute();

    if (response.status == 200 || response.status == 204) {
      await _loadFilaEspera(); // Atualiza a lista de espera após a mudança
      _showSuccessDialog('Posição da fila atualizada com sucesso!');
    } else {
      _showErrorDialog('Erro ao atualizar a posição da fila.');
    }
  }

  Future<void> _alterarDisponibilidade(String livroId, bool disponivel) async {
    final response = await Supabase.instance.client
        .from('livros')
        .update({'status': disponivel ? 'disponivel' : 'indisponivel'})
        .eq('id', livroId)
        .execute();

    if (response.status == 200 || response.status == 204) {
      await _loadLivros(); // Recarrega a lista de livros após a alteração
      _showSuccessDialog(disponivel
          ? "Livro marcado como disponível!"
          : "Livro marcado como indisponível!");
    } else {
      _showErrorDialog("Erro ao alterar disponibilidade: ${response.status}");
    }
  }

// Função para excluir o livro
  Future<void> _removerLivro(String livroId) async {
    final response = await Supabase.instance.client
        .from('livros')
        .delete()
        .eq('id', livroId)
        .execute();

    if (response.status == 200 || response.status == 204) {
      _loadLivros();
      _showSuccessDialog("Livro removido com sucesso!");
    } else {
      _showErrorDialog("Erro ao remover o livro: ${response.status}");
    }
  }

// Função para editar o livro
  Future<void> _editarLivro(String livroId) async {
    if (_tituloController.text.isEmpty ||
        _autorController.text.isEmpty ||
        _quantidadeController.text.isEmpty) {
      _showErrorDialog("Preencha todos os campos!");
      return;
    }

    // Certifique-se de que a data de expiração está sendo passada corretamente
    final response = await Supabase.instance.client
        .from('livros')
        .update({
          'titulo': _tituloController.text,
          'autor': _autorController.text,
          'quantidade': int.parse(_quantidadeController.text),
          'descricao': _descricaoController.text.isNotEmpty
              ? _descricaoController.text
              : null,
          'data_expiracao': _dataExpiracao != null
              ? _dataExpiracao!.toIso8601String()
              : null, // Tratando a data de expiração corretamente
          'data_publicacao': _dataPublicacao != null
              ? _dataPublicacao!.toIso8601String()
              : null,
        })
        .eq('id', livroId)
        .execute();

    if (response.status == 200 || response.status == 204) {
      _loadLivros(); // Recarregar a lista de livros após a edição
      _clearForm(); // Limpa o formulário
      _showSuccessDialog("Livro editado com sucesso!");
    } else {
      _showErrorDialog("Erro ao editar o livro: ${response.status}");
    }
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
                Navigator.pop(context); // Fecha o diálogo ao pressionar "OK"
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    _livroIdParaEditar = null;
    _tituloController.clear();
    _autorController.clear();
    _quantidadeController.clear();
    _descricaoController.clear();
    _anoPublicacaoController.clear();
    _dataExpiracao = null;
    _dataPublicacao = null;
    setState(() {});
  }

  void _preencherCamposLivro(Map<String, dynamic> livro) {
    setState(() {
      _livroIdParaEditar = livro['id'] != null
          ? livro['id']
          : ''; // Tratamento para valores nulos
      _tituloController.text =
          livro['titulo'] ?? ''; // Se for nulo, preenche com string vazia
      _autorController.text = livro['autor'] ?? '';
      _quantidadeController.text = livro['quantidade']?.toString() ??
          '0'; // Certifica-se de que o valor é válido
      _descricaoController.text = livro['descricao'] ?? '';
      _dataExpiracao = livro['data_expiracao'] != null
          ? DateTime.tryParse(livro['data_expiracao'])
          : null;
      _dataPublicacao = livro['data_publicacao'] != null
          ? DateTime.tryParse(livro['data_publicacao'])
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Gestão de Livros'),
          backgroundColor: Colors.deepPurple,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Assinaturas'),
              Tab(text: 'Fila de Espera'),
              Tab(text: 'Gerenciar Livros'),
              Tab(text: 'Adicionar Livro'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAssinaturasTab(),
            _buildFilaEsperaTab(),
            _buildGerenciarLivrosTab(),
            _buildAdicionarLivroTab(),
          ],
        ),
      ),
    );
  }

  // Essa lógica deve estar presente na aba de Fila de Espera
  String _formatarDataDevolucao(String? dataDevolucao) {
    if (dataDevolucao == null || dataDevolucao.isEmpty) {
      return 'Data de devolução não definida';
    }

    try {
      DateTime parsedDate = DateTime.parse(dataDevolucao);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return 'Data inválida';
    }
  }

// Função para exibir os detalhes dos livros e a data de devolução
  Widget _buildAssinaturasTab() {
    return ListView.builder(
      itemCount: _assinaturas.length,
      itemBuilder: (context, index) {
        final assinatura = _assinaturas[index];

        String nome = assinatura['nome'] ?? 'Nome não disponível';
        String email = assinatura['email'] ?? 'Email não disponível';
        String dataReserva = assinatura['data_reserva']?.substring(0, 10) ??
            'Data de reserva não disponível';
        String livro = assinatura['livro'] ?? 'Livro não disponível';

        // Usar a mesma lógica de formatação da aba Fila de Espera
        String dataDevolucao =
            _formatarDataDevolucao(assinatura['data_devolucao']);

        int diasRestantes =
            _calcularDiasRestantes(assinatura['data_devolucao']);
        bool atrasado = _verificarAtraso(assinatura['data_devolucao']);
        Uint8List? assinaturaImagem;

        // Decodificando assinatura, se aplicável
        try {
          assinaturaImagem = base64Decode(assinatura['assinatura']);
        } catch (e) {
          print('Erro ao decodificar a assinatura: $e');
        }

        return Card(
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
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
                  'Livro: $livro',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 8),
                Text('Reservado por: $nome'),
                Text('E-mail: $email'),
                Text('Data de Reserva: $dataReserva'),
                // Exibindo a data de devolução usando a lógica de formatação
                Text('Data de Devolução: $dataDevolucao'),
                Text(
                  atrasado
                      ? '⚠️ Atrasado! Devolver o quanto antes.'
                      : 'Dias restantes: $diasRestantes',
                  style: TextStyle(
                    color: atrasado ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                assinaturaImagem != null
                    ? ExpansionTile(
                        title: Text(
                          'Clique para ver a assinatura',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            child: Image.memory(
                              assinaturaImagem,
                              height: 150,
                            ),
                          ),
                        ],
                      )
                    : Text('Assinatura indisponível'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilaEsperaTab() {
    return ListView.builder(
      itemCount: _filaEspera.length,
      itemBuilder: (context, index) {
        final reserva = _filaEspera[index];

        Uint8List? assinaturaImagem;

        // Verifica se a assinatura existe e não é nula
        if (reserva['assinatura'] != null && reserva['assinatura'].isNotEmpty) {
          try {
            assinaturaImagem = base64Decode(reserva['assinatura']);
          } catch (e) {
            print('Erro ao decodificar a assinatura: $e');
          }
        }

        // Garantir que posicao_fila seja um número inteiro válido
        int posicaoFilaAtual = reserva['posicao_fila'] != null
            ? int.tryParse(reserva['posicao_fila'].toString()) ?? 1
            : 1; // Valor padrão caso posicao_fila seja nulo ou inválido

        return Card(
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
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
                  'Livro: ${reserva['livro'] ?? 'Livro desconhecido'}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 8),
                Text('Usuário: ${reserva['nome'] ?? 'Nome desconhecido'}'),
                Text('E-mail: ${reserva['email'] ?? 'E-mail desconhecido'}'),
                Text('Posição atual na Fila: $posicaoFilaAtual'),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text('Definir nova posição:'),
                    SizedBox(width: 10),
                    DropdownButton<int>(
                      value: posicaoFilaAtual,
                      items: List.generate(
                        10, // Ajustável conforme necessário
                        (i) => DropdownMenuItem<int>(
                          value: i + 1,
                          child: Text((i + 1).toString()),
                        ),
                      ),
                      onChanged: (novaPosicao) {
                        if (novaPosicao != null && reserva['id'] != null) {
                          _atualizarPosicaoFila(reserva['id'],
                              novaPosicao); // Usa o ID da reserva
                        } else {
                          _showErrorDialog('ID da reserva não encontrado.');
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10),
                assinaturaImagem != null
                    ? ExpansionTile(
                        title: Text(
                          'Clique para ver a assinatura',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            child: Image.memory(
                              assinaturaImagem,
                              height: 150,
                            ),
                          ),
                        ],
                      )
                    : Text('Assinatura indisponível'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGerenciarLivrosTab() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _livros.length,
            itemBuilder: (context, index) {
              final livro = _livros[index];
              bool isEditing = livro['id'] == _livroIdParaEditar;

              return Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isEditing
                          ? Column(
                              children: [
                                _buildTextField("Título", _tituloController),
                                _buildTextField("Autor", _autorController),
                                _buildTextField(
                                    "Quantidade", _quantidadeController,
                                    isNumeric: true),
                                _buildTextField("Ano de Publicação",
                                    _anoPublicacaoController,
                                    isNumeric: true),
                                _buildTextField(
                                    "Descrição", _descricaoController),
                                _buildDateField("Data de Expiração"),
                                ElevatedButton(
                                  onPressed: () {
                                    _editarLivro(livro[
                                        'id']); // Salva a edição diretamente
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: Text('Salvar'),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Título: ${livro['titulo'] ?? "Título não disponível"}'),
                                Text(
                                    'Autor: ${livro['autor'] ?? "Autor não disponível"}'),
                                Text(
                                    'Quantidade: ${livro['quantidade']?.toString() ?? "Quantidade não disponível"}'),
                                Text(
                                    'Descrição: ${livro['descricao'] ?? "Descrição não disponível"}'),
                                Text(
                                    'Data de Expiração: ${livro['data_expiracao'] ?? "Data não disponível"}'),
                              ],
                            ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Botão de remoção do livro
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _removerLivro(
                                  livro['id']); // Função para remover o livro
                            },
                          ),

                          // Botão para alterar a disponibilidade do livro (disponível/indisponível)
                          IconButton(
                            icon: Icon(
                              livro['status'] == 'disponivel'
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: livro['status'] == 'disponivel'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            onPressed: () async {
                              bool novoStatusDisponivel =
                                  livro['status'] != 'disponivel';

                              await _alterarDisponibilidade(
                                  livro['id'], novoStatusDisponivel);

                              // Atualiza o estado para garantir que a interface seja atualizada corretamente
                              setState(() {
                                _livros[index]['status'] = novoStatusDisponivel
                                    ? 'disponivel'
                                    : 'indisponivel';
                              });
                            },
                          ),

                          // Botão para editar o livro
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.deepPurple),
                            onPressed: () {
                              _preencherCamposLivro(
                                  livro); // Preenche os campos com os dados do livro selecionado para edição
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildAdicionarLivroTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        // Adicionado para evitar overflow
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Adicionar Novo Livro',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildTextField("Título", _tituloController),
            SizedBox(height: 15),
            _buildTextField("Autor", _autorController),
            SizedBox(height: 15),
            _buildTextField("Quantidade", _quantidadeController,
                isNumeric: true),
            SizedBox(height: 15),
            _buildTextField("Ano de Publicação", _anoPublicacaoController,
                isNumeric: true),
            SizedBox(height: 15),
            _buildTextField("Descrição", _descricaoController),
            SizedBox(height: 15),
            _buildDateField("Data de Publicação"),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _adicionarLivro,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Adicionar Livro',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDateField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: _dataExpiracao ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          );
          if (pickedDate != null) {
            setState(() {
              _dataExpiracao = pickedDate;
            });
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            _dataExpiracao == null
                ? label
                : DateFormat('dd/MM/yyyy').format(_dataExpiracao!),
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ),
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
}
