import 'package:flutter/rendering.dart';

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'gestao_model.dart';
export 'gestao_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../relatorio/realatorio_widget.dart';
import '../agendamento/agendamento_widget.dart';
import '../dados/dados_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

TimeOfDay? horarioInicio;
TimeOfDay? horarioFim;

class GestaoWidget extends StatefulWidget {
  const GestaoWidget({super.key});

  @override
  State<GestaoWidget> createState() => _GestaoWidget();
}

class _GestaoWidget extends State<GestaoWidget> {
  late GestaoModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  bool _isFilterBarVisible = true;

  TextEditingController searchController = TextEditingController();
  TextEditingController feedbackController = TextEditingController();
  TextEditingController descricaoController = TextEditingController();
  TextEditingController localizacaoController = TextEditingController();
  TextEditingController departamentoController = TextEditingController();

  String? selectedFuncionarioEmail;
  String? selectedFuncionarioId;
  String? selectedFormato;
  DateTime? dataInicio;
  DateTime? dataFim;
  String? selectedDepartamento;
  String? selectedStatus;
  String? searchQuery;

  bool isLoading = false;
  bool isDescending = true;

  // Controla a visibilidade do dashboard
  bool isDashboardVisible = false;

  List<Map<String, dynamic>> treinamentosParaFuncionario = [];
  List<String> departamentos = [
    'Todos os Departamentos',
    'RH',
    'TI',
    'Financeiro',
    'Operações',
    'Vendas'
  ];
  List<Map<String, dynamic>> treinamentos = [];
  List<Map<String, dynamic>> treinamentosFiltrados = [];
  List<Map<String, dynamic>> funcionarios = [];
  List<String> tiposParticipantes = [
    "Todos",
    "Pleno",
    "Estagiário",
    "Júnior",
    "Senior"
  ];
  List<String> participantesSelecionados = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    carregarFuncionarios();
    carregarTreinamentos();
    carregarDepartamentos(); // Carrega os departamentos do banco
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void filtrarPorDepartamento(String? departamento) {
    if (departamento == null ||
        departamento.isEmpty ||
        departamento == 'Todos os Departamentos') {
      treinamentosFiltrados = treinamentosParaFuncionario;
    } else {
      treinamentosFiltrados = treinamentosParaFuncionario.where((treinamento) {
        return treinamento['departamento'] == departamento;
      }).toList();
    }

    setState(() {});
  }

// Método _buildDashboardCard refinado
  Widget _buildDashboardCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 30.0, color: color),
              SizedBox(width: 10.0),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[900],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return Colors.orange;
      case 'concluído':
        return Colors.green;
      case 'ativo':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  TextStyle _getTitleTextStyle() {
    return const TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.bold,
      fontSize: 18.0,
      color: Color(0xFF6A1B9A),
    );
  }

  TextStyle _getSubtitleTextStyle() {
    return const TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.normal,
      fontSize: 14.0,
      color: Colors.black54,
    );
  }

  TextStyle _getButtonTextStyle() {
    return const TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.bold,
      fontSize: 14.0,
      color: Colors.blue,
    );
  }

  TextStyle _getDeleteButtonTextStyle() {
    return const TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.bold,
      fontSize: 14.0,
      color: Colors.red,
    );
  }

  void exibirDialogoAdicionarFuncionario(BuildContext context) {
    TextEditingController nomeController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController cargoController = TextEditingController();
    TextEditingController setorController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              title: const Text(
                'Cadastrar Novo Funcionário',
                style: TextStyle(color: Color(0xFF6A1B9A)),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: nomeController,
                      decoration: InputDecoration(
                        labelText: 'Nome',
                        labelStyle: const TextStyle(color: Color(0xFF6A1B9A)),
                        filled: true,
                        fillColor: Colors.grey[200],
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide:
                              const BorderSide(color: Color(0xFF6A1B9A)),
                        ),
                      ),
                      style: const TextStyle(color: Color(0xFF6A1B9A)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Color(0xFF6A1B9A)),
                        filled: true,
                        fillColor: Colors.grey[200],
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide:
                              const BorderSide(color: Color(0xFF6A1B9A)),
                        ),
                      ),
                      style: const TextStyle(color: Color(0xFF6A1B9A)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: cargoController,
                      decoration: InputDecoration(
                        labelText: 'Cargo',
                        labelStyle: const TextStyle(color: Color(0xFF6A1B9A)),
                        filled: true,
                        fillColor: Colors.grey[200],
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide:
                              const BorderSide(color: Color(0xFF6A1B9A)),
                        ),
                      ),
                      style: const TextStyle(color: Color(0xFF6A1B9A)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: setorController,
                      decoration: InputDecoration(
                        labelText: 'Setor',
                        labelStyle: const TextStyle(color: Color(0xFF6A1B9A)),
                        filled: true,
                        fillColor: Colors.grey[200],
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide:
                              const BorderSide(color: Color(0xFF6A1B9A)),
                        ),
                      ),
                      style: const TextStyle(color: Color(0xFF6A1B9A)),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar',
                      style: TextStyle(color: Colors.black54)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Cadastrar',
                          style: TextStyle(
                              color: Color(0xFF6A1B9A),
                              fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    if (nomeController.text.isEmpty ||
                        emailController.text.isEmpty ||
                        cargoController.text.isEmpty ||
                        setorController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Por favor, preencha todos os campos.')),
                      );
                      return;
                    }

                    await cadastrarNovoFuncionario(
                      nomeController.text,
                      cargoController.text,
                      emailController.text,
                      Uuid().v4(),
                      true,
                    );

                    await carregarFuncionarios();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _selecionarHorarioInicio(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: horarioInicio ?? TimeOfDay.now(),
    );
    if (picked != null && picked != horarioInicio) {
      setState(() {
        horarioInicio = picked;
      });
    }
  }

  Future<void> _selecionarHorarioFim(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: horarioFim ?? TimeOfDay.now(),
    );
    if (picked != null && picked != horarioFim) {
      setState(() {
        horarioFim = picked;
      });
    }
  }

  Future<List<Map<String, dynamic>>> carregarFuncionariosPorDepartamento(
      String departamento) async {
    final response = await Supabase.instance.client
        .from('funcionarios')
        .select('*')
        .eq('departamento', departamento)
        .execute();

    if (response.status == 200 && response.data != null) {
      return List<Map<String, dynamic>>.from(response.data);
    } else {
      print(
          'Erro ao carregar funcionários. Código de status: ${response.status}');
      return [];
    }
  }

  Future<void> carregarDepartamentos() async {
    final response = await Supabase.instance.client
        .from('departamentos')
        .select('nome')
        .execute();

    if (response.status == 200 && response.data != null) {
      setState(() {
        departamentos = List<String>.from(
            response.data.map((dept) => dept['nome'] as String));
        // Inclua a opção "Todos os Departamentos"
        departamentos.insert(0, 'Todos os Departamentos');
        selectedDepartamento = departamentos.first;
      });
    } else {
      print('Erro ao carregar departamentos: ${response.data?.message}');
    }
  }

  Future<void> cadastrarNovoFuncionario(String nome, String cargo, String email,
      String senha, bool isGestor) async {
    try {
      setState(() {
        isLoading = true;
      });

      // Gerar um UUID para o usuário
      final String userId = Uuid().v4();

      // Fazer o hash da senha para armazenar de forma segura
      final String hashedPassword = simpleHashPassword(senha);

      // Inserir o novo funcionário na tabela 'Acesso Geral'
      final responseAcessoGeral =
          await Supabase.instance.client.from('Acesso Geral').insert({
        'id_usuario': userId,
        'email': email,
        'senha': hashedPassword,
        'is_gestor': isGestor,
      }).execute();

      // Verificar se o funcionário foi inserido com sucesso na tabela 'Acesso Geral'
      if (responseAcessoGeral.status == 201) {
        // Inserir os dados adicionais na tabela 'funcionarios'
        final responseFuncionario =
            await Supabase.instance.client.from('funcionarios').insert({
          'id_usuario': userId,
          'nome': nome,
          'cargo': cargo,
          'email': email,
          'is_ativo': true,
        }).execute();

        // Verificar se a inserção na tabela 'funcionarios' foi bem-sucedida
        if (responseFuncionario.status == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Funcionário cadastrado com sucesso!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Erro ao cadastrar na tabela funcionarios: ${responseFuncionario.data?.message}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Erro ao cadastrar no Acesso Geral: ${responseAcessoGeral.data?.message}')),
        );
      }
    } catch (e) {
      // Exibir uma mensagem de erro caso haja uma exceção
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Ocorreu um erro ao cadastrar o funcionário: $e')),
      );
    } finally {
      // Parar o indicador de carregamento após a conclusão do processo
      setState(() {
        isLoading = false;
      });
    }
  }

  // Função simples para fazer "hash" da senha (não segura, apenas demonstração)
  String simpleHashPassword(String senha) {
    return senha.split('').reversed.join('');
  }

  // Função para carregar os funcionários da base de dados, associados a seus departamentos
  Future<void> carregarFuncionarios() async {
    final response = await Supabase.instance.client
        .from('funcionarios')
        .select('*')
        .execute();

    if (response.status == 200 && response.data != null) {
      setState(() {
        funcionarios = List<Map<String, dynamic>>.from(response.data);
      });
    } else {
      print(
          'Erro ao carregar funcionários. Código de status: ${response.status}');
    }
  }

  // Função para carregar treinamentos da base de dados
  Future<void> carregarTreinamentos() async {
    final response = await Supabase.instance.client
        .from('treinamentos')
        .select('*')
        .order('data_inicio', ascending: true)
        .execute();

    if (response.status == 200 && response.data != null) {
      setState(() {
        treinamentos = List<Map<String, dynamic>>.from(response.data);
        treinamentosFiltrados = treinamentos;
      });
      print('Treinamentos carregados com sucesso: ${response.data}');
    } else {
      print(
          'Erro ao carregar treinamentos. Código de status: ${response.status}');
    }
  }

  // Função para enviar feedback do funcionário
  Future<void> enviarFeedback({
    String? idFuncionario,
    String? departamento,
    double ratingGeral = 3,
    double desempenho = 3,
    double pontualidade = 3,
    double trabalhoEquipe = 3,
    required String feedbackText,
  }) async {
    setState(() {
      isLoading = true;
    });

    try {
      if (departamento != null) {
        final responseFuncionarios =
            await carregarFuncionariosPorDepartamento(departamento);

        for (var funcionario in responseFuncionarios) {
          await Supabase.instance.client.from('feedbacks').insert({
            'id_funcionario': funcionario['id_usuario'],
            'rating_geral': ratingGeral,
            'desempenho': desempenho,
            'pontualidade': pontualidade,
            'trabalho_equipe': trabalhoEquipe,
            'feedback_text': feedbackText,
            'departamento': departamento,
            'data_feedback': DateTime.now().toIso8601String(),
          }).execute();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Feedback enviado para todo o departamento!')),
        );
      } else if (idFuncionario != null) {
        final response =
            await Supabase.instance.client.from('feedbacks').insert({
          'id_funcionario': idFuncionario,
          'rating_geral': ratingGeral,
          'desempenho': desempenho,
          'pontualidade': pontualidade,
          'trabalho_equipe': trabalhoEquipe,
          'feedback_text': feedbackText,
          'data_feedback': DateTime.now().toIso8601String(),
        }).execute();

        if (response.status == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Feedback enviado com sucesso!')),
          );
        } else {
          throw Exception('Erro ao enviar feedback: ${response.data?.message}');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocorreu um erro ao enviar feedback: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Função para adicionar um novo treinamento
  Future<void> adicionarTreinamento(
      String descricao,
      String localizacao,
      DateTime dataInicio,
      DateTime dataFim,
      String departamento,
      String formato,
      TimeOfDay horarioInicio,
      TimeOfDay horarioFim) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Flutter Flow: Formatar os horários para 'HH:mm:ss' usando funções do Flutter Flow
      final String horarioInicioFormatado =
          '${horarioInicio.hour.toString().padLeft(2, '0')}:${horarioInicio.minute.toString().padLeft(2, '0')}:00';
      final String horarioFimFormatado =
          '${horarioFim.hour.toString().padLeft(2, '0')}:${horarioFim.minute.toString().padLeft(2, '0')}:00';

      // Construir as strings completas com data e hora no formato correto para o banco
      final String horarioInicioCompleto =
          '${dataInicio.toIso8601String().split('T')[0]} $horarioInicioFormatado';
      final String horarioFimCompleto =
          '${dataFim.toIso8601String().split('T')[0]} $horarioFimFormatado';

      // Dados do treinamento a serem inseridos
      final treinamento = {
        'descricao': descricao,
        'localizacao': localizacao,
        'data_inicio': dataInicio.toIso8601String(),
        'data_fim': dataFim.toIso8601String(),
        'horario_inicio': horarioInicioCompleto, // Data e horário de início
        'horario_fim': horarioFimCompleto, // Data e horário de término
        'departamento': departamento,
        'formato': formato,
        'participantes': participantesSelecionados.join(', '),
        'status': 'Ativo',
      };

      // Usando Supabase para inserir o treinamento
      final insertResponse = await Supabase.instance.client
          .from('treinamentos')
          .insert(treinamento)
          .execute();

      // Verifica se a resposta é um sucesso (status 201)
      if (insertResponse.status == 201) {
        print('Treinamento inserido com sucesso: ${insertResponse.data}');
        await carregarTreinamentos(); // Carregar treinamentos após a inserção bem-sucedida
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Treinamento adicionado com sucesso!')),
        );
      } else {
        print(
            'Erro ao inserir treinamento. Código de status: ${insertResponse.status}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao adicionar o treinamento.')),
        );
      }
    } catch (e) {
      print('Erro durante a inserção do treinamento: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocorreu um erro: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Função para buscar ID do funcionário com base no email
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
      return null;
    }
  }

  String formatarHorario(TimeOfDay horario) {
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, horario.hour, horario.minute);
    return DateFormat('HH:mm:ss').format(dateTime); // Converte para 'HH:mm:ss'
  }

  // Função para excluir um treinamento
  Future<void> excluirTreinamento(String idTreinamento) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Excluir os registros relacionados na tabela 'check_ins' usando a coluna correta 'id_treinamento'
      final responseCheckIns = await Supabase.instance.client
          .from('check_ins')
          .delete()
          .eq('id_treinamento', idTreinamento)
          .execute();

      // Log do status da resposta de exclusão em 'check_ins'
      print('Status da exclusão em check_ins: ${responseCheckIns.status}');

      // Verifica se a exclusão foi bem-sucedida pelo status da resposta
      if (responseCheckIns.status != 200 && responseCheckIns.status != 204) {
        throw Exception(
            'Erro ao excluir registros em check-ins: Status ${responseCheckIns.status}');
      }

      // Excluir o treinamento da tabela 'treinamentos'
      final responseTreinamento = await Supabase.instance.client
          .from('treinamentos')
          .delete()
          .eq('id', idTreinamento)
          .execute();

      // Log do status da resposta de exclusão em 'treinamentos'
      print(
          'Status da exclusão em treinamentos: ${responseTreinamento.status}');

      // Verifica se a exclusão foi bem-sucedida pelo status da resposta
      if (responseTreinamento.status == 200 ||
          responseTreinamento.status == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Treinamento excluído com sucesso!')),
        );
        // Recarrega os treinamentos para refletir a exclusão
        carregarTreinamentos();
      } else {
        throw Exception(
            'Erro ao excluir o treinamento: Status ${responseTreinamento.status}');
      }
    } catch (e) {
      // Log do erro
      print('Erro ao excluir treinamento: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir treinamento: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void exibirDialogoAdicionarTreinamento(BuildContext context) {
    List<String> departamentos = [
      'Todos os Departamentos',
      'RH',
      'TI',
      'Financeiro',
      'Operações',
      'Vendas'
    ];

    TimeOfDay? horarioInicio;
    TimeOfDay? horarioFim;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              title: const Text(
                'Novo Treinamento',
                style: TextStyle(
                  color: Color(0xFF6A1B9A),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: descricaoController,
                      style: const TextStyle(color: Color(0xFF6A1B9A)),
                      decoration: InputDecoration(
                        labelText: 'Descrição do Treinamento',
                        labelStyle: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 16.0,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide:
                              const BorderSide(color: Color(0xFF6A1B9A)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: localizacaoController,
                      style: const TextStyle(color: Color(0xFF6A1B9A)),
                      decoration: InputDecoration(
                        labelText: 'Localização',
                        labelStyle: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 16.0,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide:
                              const BorderSide(color: Color(0xFF6A1B9A)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    // Dropdown para selecionar o departamento
                    DropdownButtonFormField<String>(
                      value: selectedDepartamento,
                      decoration: InputDecoration(
                        labelText: 'Departamento',
                        labelStyle: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 16.0,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide:
                              const BorderSide(color: Color(0xFF6A1B9A)),
                        ),
                      ),
                      items: departamentos
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedDepartamento = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      value: selectedFormato,
                      decoration: InputDecoration(
                        labelText: 'Formato do Treinamento',
                        labelStyle: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 16.0,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide:
                              const BorderSide(color: Color(0xFF6A1B9A)),
                        ),
                      ),
                      items: ['Presencial', 'Online', 'Híbrido']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedFormato = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16.0),
                    // Campo de Participantes
                    const Text(
                      'Participantes do Departamento',
                      style: TextStyle(
                        color: Color(0xFF6A1B9A),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 10.0,
                      children: tiposParticipantes.map((participante) {
                        return ChoiceChip(
                          label: Text(participante),
                          selected:
                              participantesSelecionados.contains(participante),
                          onSelected: (bool selected) {
                            setState(() {
                              if (participante == "Todos") {
                                if (selected) {
                                  participantesSelecionados =
                                      List.from(tiposParticipantes);
                                } else {
                                  participantesSelecionados.clear();
                                }
                              } else {
                                if (selected) {
                                  participantesSelecionados.add(participante);
                                  if (participantesSelecionados.length ==
                                      tiposParticipantes.length - 1) {
                                    participantesSelecionados.add("Todos");
                                  }
                                } else {
                                  participantesSelecionados
                                      .remove(participante);
                                  participantesSelecionados.remove("Todos");
                                }
                              }
                            });
                          },
                          selectedColor: Color(0xFF6A1B9A),
                          backgroundColor: Colors.grey[200],
                          labelStyle: TextStyle(
                            color:
                                participantesSelecionados.contains(participante)
                                    ? Colors.white
                                    : Color(0xFF6A1B9A),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),
                    // Seção para selecionar datas
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: dataInicio ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  dataInicio = pickedDate;
                                });
                              }
                            },
                            child: Text(
                              dataInicio != null
                                  ? 'Início: ${DateFormat('dd/MM/yyyy').format(dataInicio!)}'
                                  : 'Selecionar Data de Início',
                              style: const TextStyle(color: Color(0xFF6A1B9A)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: dataFim ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  dataFim = pickedDate;
                                });
                              }
                            },
                            child: Text(
                              dataFim != null
                                  ? 'Término: ${DateFormat('dd/MM/yyyy').format(dataFim!)}'
                                  : 'Selecionar Data de Término',
                              style: const TextStyle(color: Color(0xFF6A1B9A)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    // Campo para selecionar o horário de início
                    TextButton(
                      onPressed: () async {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: horarioInicio ?? TimeOfDay.now(),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF6A1B9A),
                                  onPrimary: Colors.white,
                                  onSurface: Color(0xFF6A1B9A),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedTime != null) {
                          setState(() {
                            horarioInicio = pickedTime;
                          });
                        }
                      },
                      child: Text(
                        horarioInicio != null
                            ? 'Horário de Início: ${horarioInicio!.format(context)}'
                            : 'Selecionar Horário de Início',
                        style: const TextStyle(color: Color(0xFF6A1B9A)),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    // Campo para selecionar o horário de término
                    TextButton(
                      onPressed: () async {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: horarioFim ?? TimeOfDay.now(),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF6A1B9A),
                                  onPrimary: Colors.white,
                                  onSurface: Color(0xFF6A1B9A),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedTime != null) {
                          setState(() {
                            horarioFim = pickedTime;
                          });
                        }
                      },
                      child: Text(
                        horarioFim != null
                            ? 'Horário de Término: ${horarioFim!.format(context)}'
                            : 'Selecionar Horário de Término',
                        style: const TextStyle(color: Color(0xFF6A1B9A)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Color(0xFF6A1B9A)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Adicionar',
                          style: TextStyle(
                            color: Color(0xFF6A1B9A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  onPressed: () async {
                    if (descricaoController.text.isEmpty ||
                        localizacaoController.text.isEmpty ||
                        dataInicio == null ||
                        dataFim == null ||
                        selectedDepartamento == null ||
                        selectedFormato == null ||
                        participantesSelecionados.isEmpty ||
                        horarioInicio == null ||
                        horarioFim == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Por favor, preencha todos os campos.')),
                      );
                      return;
                    }

                    await adicionarTreinamento(
                      descricaoController.text,
                      localizacaoController.text,
                      dataInicio!,
                      dataFim!,
                      selectedDepartamento ?? 'Todos os Departamentos',
                      selectedFormato!,
                      horarioInicio!, // Passar o TimeOfDay diretamente
                      horarioFim!, // Passar o TimeOfDay diretamente
                    );

                    setState(() {
                      descricaoController.clear();
                      localizacaoController.clear();
                      dataInicio = null;
                      dataFim = null;
                      selectedDepartamento = null;
                      selectedFormato = null;
                      participantesSelecionados.clear();
                      horarioInicio = null;
                      horarioFim = null;
                    });

                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void filtrarTreinamentos() {
    setState(() {
      treinamentosFiltrados = treinamentos.where((treinamento) {
        // Verifica se o treinamento é para "Todos os Departamentos" ou se é específico para o departamento selecionado
        final matchDepartamento = selectedDepartamento == null ||
            selectedDepartamento == 'Todos os Departamentos' ||
            treinamento['departamento'] == selectedDepartamento ||
            treinamento['departamento'] == 'Todos os Departamentos';

        final matchParticipante = participantesSelecionados.isEmpty ||
            participantesSelecionados.any((participante) =>
                treinamento['participantes'].contains(participante));

        final matchPesquisa = searchController.text.isEmpty ||
            treinamento['descricao']
                .toString()
                .toLowerCase()
                .contains(searchController.text.toLowerCase());

        return matchDepartamento && matchParticipante && matchPesquisa;
      }).toList();
    });
  }

  void exibirDialogoPesquisarTreinamentos(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Text(
            'Pesquisar Treinamentos',
            style: TextStyle(
              color: Color(0xFF6A1B9A),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Digite para pesquisar...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 15.0),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: const BorderSide(color: Color(0xFF6A1B9A)),
                  ),
                ),
                onChanged: (value) {
                  filtrarTreinamentos();
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Fechar',
                style: TextStyle(color: Color(0xFF6A1B9A)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void exibirDialogoFeedback(BuildContext context) {
    String? selectedDepartamento;
    double desempenho = 3;
    double pontualidade = 3;
    double trabalhoEquipe = 3;
    TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: BorderSide(
                  color: Color(0xFF6A1B9A),
                  width: 2.0,
                ),
              ),
              title: const Text(
                'Fornecer Feedback',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A1B9A),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Escolha o Departamento:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedDepartamento,
                      items: ['RH', 'TI', 'Financeiro', 'Operações', 'Vendas']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6A1B9A),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedDepartamento = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 14.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.black54,
                            width: 1.5,
                          ),
                        ),
                      ),
                      dropdownColor: Colors.white,
                    ),
                    const SizedBox(height: 25),
                    _buildRatingSection('Desempenho:', desempenho, (newValue) {
                      setState(() {
                        desempenho = newValue;
                      });
                    }),
                    const SizedBox(height: 15),
                    _buildRatingSection('Pontualidade:', pontualidade,
                        (newValue) {
                      setState(() {
                        pontualidade = newValue;
                      });
                    }),
                    const SizedBox(height: 15),
                    _buildRatingSection('Trabalho em Equipe:', trabalhoEquipe,
                        (newValue) {
                      setState(() {
                        trabalhoEquipe = newValue;
                      });
                    }),
                    const SizedBox(height: 25),
                    TextField(
                      controller: feedbackController,
                      maxLines: 4,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6A1B9A),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Feedback',
                        labelStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 16.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.black54,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text(
                    'Enviar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A1B9A),
                    ),
                  ),
                  onPressed: () async {
                    // Inserir o feedback no banco de dados com referência ao departamento
                    final response = await Supabase.instance.client
                        .from('feedbacks')
                        .insert({
                      'departamento': selectedDepartamento,
                      'rating_geral':
                          (desempenho + pontualidade + trabalhoEquipe) / 3,
                      'desempenho': desempenho,
                      'pontualidade': pontualidade,
                      'trabalho_equipe': trabalhoEquipe,
                      'feedback_text': feedbackController.text,
                      'data_feedback': DateTime.now().toIso8601String(),
                    }).execute();

                    if (response.status == 201) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Feedback enviado com sucesso!')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Erro ao enviar feedback: ${response.data?.message}')),
                      );
                    }

                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEngajamentoChart(Map<String, dynamic> treinamento) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  y: _calcularEngajamento(treinamento).toDouble(),
                  colors: [Colors.blue],
                  width: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressoChart(Map<String, dynamic> treinamento) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, 0),
                FlSpot(1, _calcularProgresso(treinamento).toDouble()),
                FlSpot(2, 1),
              ],
              isCurved: true,
              colors: [Colors.blue],
              barWidth: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPISummary() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Resumo de Treinamentos',
                style: _getTitleTextStyle(),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildKPIItem(
                      'Treinamentos Ativos', _getAtivosCount(), Colors.blue),
                  _buildKPIItem('Treinamentos Pendentes', _getPendentesCount(),
                      Colors.orange),
                  _buildKPIItem('Treinamentos Concluídos',
                      _getConcluidosCount(), Colors.green),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKPIItem(String title, int value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: _getSubtitleTextStyle(),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  int _getAtivosCount() {
    return treinamentosFiltrados.where((t) => t['status'] == 'Ativo').length;
  }

  int _getPendentesCount() {
    return treinamentosFiltrados.where((t) => t['status'] == 'Pendente').length;
  }

  int _getConcluidosCount() {
    return treinamentosFiltrados
        .where((t) => t['status'] == 'Concluído')
        .length;
  }

  Widget _buildResumoRelatorio(Map<String, dynamic> treinamento) {
    return Container(
      padding: EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: Text(
        'Resumo do Relatório:\n'
        'Departamento: ${treinamento['departamento'] ?? 'Sem departamento'}\n'
        'Participantes: ${treinamento['participantes'] ?? 'Nenhum participante'}\n'
        'Formato: ${treinamento['formato'] ?? 'Formato não informado'}\n'
        'Status: ${treinamento['status'] ?? 'Status desconhecido'}',
        style: TextStyle(fontSize: 16, color: Color(0xFF6A1B9A)),
      ),
    );
  }

  void _exibirRelatorioDetalhado(
      BuildContext context, Map<String, dynamic> treinamento) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Text(
            'Relatório Detalhado',
            style: TextStyle(
              color: Color(0xFF6A1B9A),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRelatorioSection(
                  title: 'Informações Gerais',
                  children: [
                    _buildRelatorioRow(
                        'Título', treinamento['descricao'] ?? 'Sem título'),
                    _buildRelatorioRow(
                        'Período',
                        (treinamento['data_inicio'] != null &&
                                treinamento['data_fim'] != null)
                            ? '${DateFormat('dd/MM/yyyy').format(DateTime.parse(treinamento['data_inicio']))} - ${DateFormat('dd/MM/yyyy').format(DateTime.parse(treinamento['data_fim']))}'
                            : 'Período não informado'),
                    _buildRelatorioRow('Status',
                        treinamento['status'] ?? 'Status desconhecido'),
                    _buildRelatorioRow(
                      'Horário de Início',
                      treinamento['horario_inicio'] ?? 'Horário não informado',
                    ),
                    _buildRelatorioRow(
                      'Horário de Fim',
                      treinamento['horario_fim'] ?? 'Horário não informado',
                    ),
                  ],
                ),
                const Divider(),
                _buildRelatorioSection(
                  title: 'Detalhes do Treinamento',
                  children: [
                    _buildRelatorioRow('Departamento',
                        treinamento['departamento'] ?? 'Sem departamento'),
                    _buildRelatorioRow('Formato',
                        treinamento['formato'] ?? 'Formato não informado'),
                    _buildRelatorioRow('Localização',
                        treinamento['localizacao'] ?? 'Local não informado'),
                    _buildRelatorioRow('Participantes',
                        treinamento['participantes'] ?? 'Nenhum participante'),
                  ],
                ),
                const Divider(),
                _buildRelatorioSection(
                  title: 'Engajamento e Progresso',
                  children: [
                    _buildRelatorioRow('Engajamento',
                        '${_calcularEngajamento(treinamento) ?? 0}%'),
                    _buildRelatorioRow('Progresso',
                        '${_calcularProgresso(treinamento) ?? 0}%'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Fechar',
                style: TextStyle(color: Color(0xFF6A1B9A)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildRelatorioSection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF6A1B9A),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          Column(children: children),
        ],
      ),
    );
  }

  Widget _buildRelatorioRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 150, // Largura fixa para o rótulo
            child: Text(
              label,
              style: TextStyle(
                color: Color(0xFF6A1B9A),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  double _calcularEngajamento(Map<String, dynamic> treinamento) {
    // Função para calcular o engajamento do treinamento
    // Substitua este cálculo por sua lógica específica
    return 75.0;
  }

  double _calcularProgresso(Map<String, dynamic> treinamento) {
    // Função para calcular o progresso do treinamento
    // Substitua este cálculo por sua lógica específica
    return 85.0;
  }

  Widget _buildRatingSection(
      String title, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6A1B9A),
          ),
        ),
        Slider(
          value: value,
          min: 0,
          max: 5,
          divisions: 5,
          label: value.round().toString(),
          activeColor: Color(0xFF6A1B9A),
          inactiveColor: Colors.grey[300],
          onChanged: onChanged,
        ),
      ],
    );
  }

  // Função para ocultar ou mostrar a barra de filtros conforme a rolagem
  void _onScroll() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_isFilterBarVisible) {
        setState(() {
          _isFilterBarVisible = false;
        });
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_isFilterBarVisible) {
        setState(() {
          _isFilterBarVisible = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      drawer: Drawer(
          child: ListView(padding: EdgeInsets.zero, children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: Color(0xFF6A1B9A),
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(20.0),
              bottomLeft: Radius.circular(20.0),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              CircleAvatar(
                radius: 40.0,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.business_center_outlined,
                  size: 40.0,
                  color: Color(0xFF6A1B9A),
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                'Área de Gestão',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        ),
        ListTile(
          leading:
              const Icon(Icons.feedback_outlined, color: Color(0xFF6A1B9A)),
          title: const Text(
            'Fornecer Feedback',
            style: TextStyle(
              color: Color(0xFF6A1B9A),
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
          onTap: () {
            exibirDialogoFeedback(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.person_add, color: Color(0xFF6A1B9A)),
          title: const Text(
            'Cadastrar Funcionário',
            style: TextStyle(
              color: Color(0xFF6A1B9A),
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
          onTap: () {
            exibirDialogoAdicionarFuncionario(context);
          },
        ),

// Linha separadora entre "Cadastrar Funcionário" e "Fornecer Feedback" e os demais itens
        Divider(color: Colors.grey[300], thickness: 1.0),

        ListTile(
          leading:
              const Icon(Icons.data_usage_rounded, color: Color(0xFF6A1B9A)),
          title: const Text(
            'Dados Gerais',
            style: TextStyle(
              color: Color(0xFF6A1B9A),
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DadosWidget(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.calendar_today_rounded,
              color: Color(0xFF6A1B9A)),
          title: const Text(
            'Dashboard',
            style: TextStyle(
              color: Color(0xFF6A1B9A),
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardWidget(),
              ),
            );
          },
        ),

// Linha separadora entre "Dados Gerais", "Agendamentos" e "Relatórios"
        Divider(color: Colors.grey[300], thickness: 1.0),

        ListTile(
          leading:
              const Icon(Icons.insert_chart_outlined, color: Color(0xFF6A1B9A)),
          title: const Text(
            'Relatórios',
            style: TextStyle(
              color: Color(0xFF6A1B9A),
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RelatoriosWidget(),
              ),
            );
          },
        ),
      ])),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 0.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  FlutterFlowIconButton(
                    borderColor: Colors.transparent,
                    borderRadius: 20.0,
                    borderWidth: 1.0,
                    buttonSize: 40.0,
                    icon: const Icon(
                      Icons.density_medium,
                      color: Color(0xFF6A1B9A),
                      size: 24.0,
                    ),
                    onPressed: () {
                      scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'MONITORAMENTO',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: Color(0xFF6A1B9A),
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 1.0), // Ajuste de padding
                    child: FlutterFlowIconButton(
                      borderColor: Colors.transparent,
                      borderRadius: 20.0,
                      borderWidth: 1.0,
                      buttonSize: 40.0,
                      icon: const Icon(
                        Icons.search,
                        color: Color(0xFF6A1B9A),
                        size: 24.0,
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20.0)),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 10.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: searchController,
                                    decoration: InputDecoration(
                                      hintText: 'Digite para pesquisar...',
                                      hintStyle:
                                          TextStyle(color: Colors.grey[600]),
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 15.0,
                                        horizontal: 20.0,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        borderSide: const BorderSide(
                                            color: Color(0xFF6A1B9A)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      filtrarTreinamentos();
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Fecha o BottomSheet
                                    },
                                    child: Text('Fechar'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF6A1B9A),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 1.0), // Ajuste de padding
                    child: IconButton(
                      icon: Icon(
                        Icons.dashboard_customize_outlined,
                        color: Colors.blueGrey[900],
                        size: 18.0,
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.white.withOpacity(0.98),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16.0),
                            ),
                          ),
                          isScrollControlled:
                              true, // Permite que o modal seja rolável
                          builder: (BuildContext context) {
                            return SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0, vertical: 24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Visão Geral de Treinamentos',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey[900],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.close,
                                              color: Colors.blueGrey[700]),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20.0),
                                    Divider(
                                      color: Colors.grey[300],
                                      thickness: 1.2,
                                    ),
                                    GridView.count(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 16.0,
                                      mainAxisSpacing: 16.0,
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      children: [
                                        _buildDashboardCard('Participantes',
                                            '120', Icons.group, Colors.blue),
                                        _buildDashboardCard('Presença', '95%',
                                            Icons.check_circle, Colors.green),
                                        _buildDashboardCard('Assinaturas',
                                            '110', Icons.edit, Colors.orange),
                                        _buildDashboardCard(
                                            'Treinamentos Ativos',
                                            '15',
                                            Icons.playlist_add_check,
                                            Colors.purple),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filtrar por Departamento',
                    style: _getTitleTextStyle(),
                  ),
                  const SizedBox(height: 8.0),
                  Center(
                    child: Container(
                      width: 240.0,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedDepartamento,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFF6A6A6A),
                            size: 24.0,
                          ),
                          dropdownColor: const Color(0xFFF5F5F5),
                          style: const TextStyle(
                            color: Color(0xFF6A6A6A),
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Roboto',
                          ),
                          isExpanded: true,
                          borderRadius: BorderRadius.circular(12.0),
                          items: [
                            {
                              'label': 'Todos os Departamentos',
                              'icon': Icons.apartment
                            },
                            {'label': 'RH', 'icon': Icons.people},
                            {'label': 'TI', 'icon': Icons.computer},
                            {'label': 'Financeiro', 'icon': Icons.attach_money},
                            {'label': 'Operações', 'icon': Icons.settings},
                            {'label': 'Vendas', 'icon': Icons.shopping_cart},
                          ].map<DropdownMenuItem<String>>(
                              (Map<String, dynamic> item) {
                            return DropdownMenuItem<String>(
                              value: item['label'],
                              child: Row(
                                children: [
                                  Icon(
                                    item['icon'],
                                    color: const Color(0xFF6A6A6A),
                                    size: 16.0,
                                  ),
                                  const SizedBox(width: 6.0),
                                  Text(
                                    item['label'],
                                    style: const TextStyle(
                                      color: Color(0xFF6A6A6A),
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedDepartamento = newValue;
                              filtrarTreinamentos();
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: treinamentosFiltrados.length,
                itemBuilder: (context, index) {
                  final treinamento = treinamentosFiltrados[index];

                  String descricao =
                      treinamento['descricao'] ?? 'Sem descrição';
                  String localizacao =
                      treinamento['localizacao'] ?? 'Local não informado';
                  String departamento =
                      treinamento['departamento'] ?? 'Sem departamento';
                  String formato =
                      treinamento['formato'] ?? 'Formato não informado';
                  String participantes =
                      treinamento['participantes'] ?? 'Nenhum participante';

                  String status =
                      treinamento['status'] ?? 'Status desconhecido';

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16.0,
                    ),
                    elevation: 4,
                    child: ExpansionTile(
                      title: Text(descricao, style: _getTitleTextStyle()),
                      subtitle: Text(
                        'Período: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(treinamento['data_inicio']))} '
                        '- ${DateFormat('dd/MM/yyyy').format(DateTime.parse(treinamento['data_fim']))}\n'
                        'Horário: ${treinamento['horario_inicio']} - ${treinamento['horario_fim']}',
                        style: _getSubtitleTextStyle(),
                      ),
                      trailing: Text(
                        status,
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      children: [
                        ListTile(
                          title: Text('Formato: $formato',
                              style: _getSubtitleTextStyle()),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 16.0, color: Color(0xFF6A1B9A)),
                                  SizedBox(width: 4.0),
                                  Text(localizacao,
                                      style: _getSubtitleTextStyle()),
                                ],
                              ),
                              SizedBox(height: 4.0),
                              Text('Departamento: $departamento',
                                  style: _getSubtitleTextStyle()),
                              SizedBox(height: 4.0),
                              Text('Participantes: $participantes',
                                  style: _getSubtitleTextStyle()),
                            ],
                          ),
                        ),
                        ButtonBar(
                          alignment: MainAxisAlignment.start,
                          children: [
                            TextButton(
                              onPressed: () {
                                _exibirRelatorioDetalhado(context, treinamento);
                              },
                              child: Text('Visualizar Relatório',
                                  style: _getButtonTextStyle()),
                            ),
                            TextButton(
                              onPressed: () {
                                exibirDialogoEditarTreinamento(
                                    context, treinamento);
                              },
                              child:
                                  Text('Editar', style: _getButtonTextStyle()),
                            ),
                            TextButton(
                              onPressed: () {
                                excluirTreinamento(treinamento['id']);
                              },
                              child: Text('Excluir',
                                  style: _getDeleteButtonTextStyle()),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          exibirDialogoAdicionarTreinamento(context);
        },
        backgroundColor: Color(0xFF6A1B9A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showDashboardModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.98),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.0),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Visão Geral de Treinamentos',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[900],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.blueGrey[700]),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              Divider(color: Colors.grey[300], thickness: 1.2),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildDashboardCard(
                      'Participantes', '120', Icons.group, Colors.blue),
                  _buildDashboardCard(
                      'Presença', '95%', Icons.check_circle, Colors.green),
                  _buildDashboardCard(
                      'Assinaturas', '110', Icons.edit, Colors.orange),
                  _buildDashboardCard('Treinamentos Ativos', '15',
                      Icons.playlist_add_check, Colors.purple),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void exibirDialogoEditarTreinamento(
      BuildContext context, Map<String, dynamic> treinamento) {
    TextEditingController descricaoController =
        TextEditingController(text: treinamento['descricao']);
    TextEditingController localizacaoController =
        TextEditingController(text: treinamento['localizacao']);
    DateTime dataInicio = DateTime.parse(treinamento['data_inicio']);
    DateTime dataFim = DateTime.parse(treinamento['data_fim']);
    String? selectedFormato = treinamento['formato'];
    String? selectedDepartamento = treinamento['departamento'];
    List<String> participantesSelecionados =
        treinamento['participantes'] != null
            ? treinamento['participantes'].split(', ')
            : [];
    TimeOfDay? horarioInicio;
    TimeOfDay? horarioFim;

    // Defina os departamentos fixos
    List<String> departamentos = [
      'Todos os Departamentos',
      'RH',
      'TI',
      'Financeiro',
      'Operações',
      'Vendas'
    ];

    List<String> todosParticipantes = [
      'Estagiário',
      'Júnior',
      'Pleno',
      'Sênior'
    ];

    bool todosSelecionados =
        participantesSelecionados.length == todosParticipantes.length;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              title: const Text(
                'Editar Treinamento',
                style: TextStyle(
                  color: Color(0xFF6A1B9A),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: descricaoController,
                      style: const TextStyle(color: Color(0xFF6A1B9A)),
                      decoration: InputDecoration(
                        labelText: 'Descrição do Treinamento',
                        labelStyle: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 16.0,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide:
                              const BorderSide(color: Color(0xFF6A1B9A)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: localizacaoController,
                      style: const TextStyle(color: Color(0xFF6A1B9A)),
                      decoration: InputDecoration(
                        labelText: 'Localização',
                        labelStyle: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 16.0,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide:
                              const BorderSide(color: Color(0xFF6A1B9A)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      value: selectedDepartamento,
                      decoration: InputDecoration(
                        labelText: 'Departamento',
                        labelStyle: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 16.0,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide:
                              const BorderSide(color: Color(0xFF6A1B9A)),
                        ),
                      ),
                      items: departamentos
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedDepartamento = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      value: selectedFormato,
                      decoration: InputDecoration(
                        labelText: 'Formato do Treinamento',
                        labelStyle: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 16.0,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide:
                              const BorderSide(color: Color(0xFF6A1B9A)),
                        ),
                      ),
                      items: ['Presencial', 'Online', 'Híbrido']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedFormato = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: dataInicio,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Color(0xFF6A1B9A),
                                        onPrimary: Colors.white,
                                        onSurface: Color(0xFF6A1B9A),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  dataInicio = pickedDate;
                                });
                              }
                            },
                            child: Text(
                              'Início: ${DateFormat('dd/MM/yyyy').format(dataInicio)}',
                              style: const TextStyle(color: Color(0xFF6A1B9A)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: dataFim,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Color(0xFF6A1B9A),
                                        onPrimary: Colors.white,
                                        onSurface: Color(0xFF6A1B9A),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  dataFim = pickedDate;
                                });
                              }
                            },
                            child: Text(
                              'Término: ${DateFormat('dd/MM/yyyy').format(dataFim)}',
                              style: const TextStyle(color: Color(0xFF6A1B9A)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                context: context,
                                initialTime: horarioInicio ?? TimeOfDay.now(),
                                builder: (BuildContext context, Widget? child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Color(0xFF6A1B9A),
                                        onPrimary: Colors.white,
                                        onSurface: Color(0xFF6A1B9A),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  horarioInicio = pickedTime;
                                });
                              }
                            },
                            child: Text(
                              horarioInicio != null
                                  ? 'Horário de Início: ${horarioInicio!.format(context)}'
                                  : 'Selecionar Horário de Início',
                              style: const TextStyle(color: Color(0xFF6A1B9A)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                context: context,
                                initialTime: horarioFim ?? TimeOfDay.now(),
                                builder: (BuildContext context, Widget? child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Color(0xFF6A1B9A),
                                        onPrimary: Colors.white,
                                        onSurface: Color(0xFF6A1B9A),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  horarioFim = pickedTime;
                                });
                              }
                            },
                            child: Text(
                              horarioFim != null
                                  ? 'Horário de Término: ${horarioFim!.format(context)}'
                                  : 'Selecionar Horário de Término',
                              style: const TextStyle(color: Color(0xFF6A1B9A)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Participantes do Departamento',
                      style: TextStyle(
                        color: Color(0xFF6A1B9A),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 10.0,
                      children: [
                        ChoiceChip(
                          label: const Text('Todos'),
                          selected: todosSelecionados,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                participantesSelecionados =
                                    List.from(todosParticipantes);
                              } else {
                                participantesSelecionados.clear();
                              }
                              todosSelecionados = selected;
                            });
                          },
                          selectedColor: Color(0xFF6A1B9A),
                          backgroundColor: Colors.grey[200],
                          labelStyle: TextStyle(
                            color: todosSelecionados
                                ? Colors.white
                                : Color(0xFF6A1B9A),
                          ),
                        ),
                        ...todosParticipantes.map((participante) {
                          return ChoiceChip(
                            label: Text(participante),
                            selected: participantesSelecionados
                                .contains(participante),
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) {
                                  participantesSelecionados.add(participante);
                                } else {
                                  participantesSelecionados
                                      .remove(participante);
                                }
                                todosSelecionados =
                                    participantesSelecionados.length ==
                                        todosParticipantes.length;
                              });
                            },
                            selectedColor: Color(0xFF6A1B9A),
                            backgroundColor: Colors.grey[200],
                            labelStyle: TextStyle(
                              color: participantesSelecionados
                                      .contains(participante)
                                  ? Colors.white
                                  : Color(0xFF6A1B9A),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Color(0xFF6A1B9A)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text(
                    'Salvar',
                    style: TextStyle(
                      color: Color(0xFF6A1B9A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    if (selectedFormato != null &&
                        selectedDepartamento != null) {
                      _salvarEdicaoTreinamento(
                        treinamento['id'],
                        descricaoController.text,
                        localizacaoController.text,
                        dataInicio,
                        dataFim,
                        horarioInicio,
                        horarioFim,
                        selectedDepartamento!,
                        selectedFormato!,
                        participantesSelecionados.join(', '),
                      );
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Por favor, preencha todos os campos.')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _salvarEdicaoTreinamento(
    String id,
    String descricao,
    String localizacao,
    DateTime dataInicio,
    DateTime dataFim,
    TimeOfDay? horarioInicio,
    TimeOfDay? horarioFim,
    String departamento,
    String formato,
    String participantes,
  ) async {
    // Função para converter TimeOfDay em String no formato 'HH:mm'
    String formatarHorario(TimeOfDay? time) {
      if (time == null) return "";
      final now = DateTime.now();
      final DateTime dateTime =
          DateTime(now.year, now.month, now.day, time.hour, time.minute);
      return DateFormat('HH:mm:ss').format(dateTime);
    }

    String? horarioInicioFormatado = formatarHorario(horarioInicio);
    String? horarioFimFormatado = formatarHorario(horarioFim);

    print('Salvando treinamento com os seguintes dados:');
    print('ID: $id');
    print('Descrição: $descricao');
    print('Localização: $localizacao');
    print('Data Início: $dataInicio');
    print('Data Fim: $dataFim');
    print('Horário Início: $horarioInicioFormatado');
    print('Horário Fim: $horarioFimFormatado');
    print('Departamento: $departamento');
    print('Formato: $formato');
    print('Participantes: $participantes');

    // Verifica se o departamento é "Todos"
    if (departamento == 'Todos') {
      // Função para carregar todos os departamentos
      final responseDepartamentos = await Supabase.instance.client
          .from('departamentos')
          .select('nome')
          .execute();

      if (responseDepartamentos.status == 200 &&
          responseDepartamentos.data != null) {
        List<String> todosDepartamentos = List<String>.from(
            responseDepartamentos.data.map((dep) => dep['nome']));

        for (var dep in todosDepartamentos) {
          final response =
              await Supabase.instance.client.from('treinamentos').insert({
            'descricao': descricao,
            'localizacao': localizacao,
            'data_inicio': dataInicio.toIso8601String(),
            'data_fim': dataFim.toIso8601String(),
            'horario_inicio': horarioInicioFormatado,
            'horario_fim': horarioFimFormatado,
            'departamento': dep,
            'formato': formato,
            'participantes': participantes,
          }).execute();

          if (response.status != 201) {
            print('Erro ao adicionar treinamento para o departamento: $dep');
          }
        }
        print('Treinamento adicionado para todos os departamentos.');
      } else {
        print('Erro ao carregar departamentos.');
      }
    } else {
      // Adiciona apenas para o departamento específico
      final response = await Supabase.instance.client
          .from('treinamentos')
          .update({
            'descricao': descricao,
            'localizacao': localizacao,
            'data_inicio': dataInicio.toIso8601String(),
            'data_fim': dataFim.toIso8601String(),
            'horario_inicio': horarioInicio != null
                ? horarioInicio.format(context)
                : null, // Certifique-se que isso não seja nulo
            'horario_fim': horarioFim != null
                ? horarioFim.format(context)
                : null, // Certifique-se que isso não seja nulo
            'departamento': departamento,
            'formato': formato,
            'participantes': participantes,
          })
          .eq('id', id)
          .execute();

      if (response.status == 204) {
        print('Treinamento atualizado com sucesso!');
        await carregarTreinamentos(); // Certifique-se de que esta função easteja funcionando corretamente
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Treinamento atualizado com sucesso!')),
        );
      } else {
        print('Erro ao atualizar o treinamento');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao atualizar o treinamento.')),
        );
      }
    }
  }
}
