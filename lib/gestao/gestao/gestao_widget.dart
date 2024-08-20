import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'gestao_model.dart';
export 'gestao_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:uuid/uuid.dart';
import '../relatorio/realatorio_widget.dart';
import '../dados/dados_widget.dart';

class GestaoWidget extends StatefulWidget {
  const GestaoWidget({super.key});

  @override
  State<GestaoWidget> createState() => _GestaoWidgetState();
}

class _GestaoWidgetState extends State<GestaoWidget> {
  late GestaoModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController searchController = TextEditingController();
  TextEditingController feedbackController = TextEditingController();
  TextEditingController descricaoController = TextEditingController();
  TextEditingController localizacaoController = TextEditingController();

  String? selectedFuncionarioEmail;
  String? selectedFuncionarioId;
  DateTime? dataInicio;
  DateTime? dataFim;

  bool isLoading = false;
  bool isDescending = true;

  List<Map<String, dynamic>> treinamentosParaFuncionario = [];
  List<Map<String, dynamic>> treinamentosFiltrados = [];
  List<Map<String, dynamic>> funcionarios = [];

  @override
  void initState() {
    super.initState();
    carregarFuncionarios();
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
              backgroundColor: const Color(0xFFB751F6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              title: const Text(
                'Cadastrar Novo Funcionário',
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: nomeController,
                      decoration: InputDecoration(
                        labelText: 'Nome',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFFB751F6).withOpacity(0.1),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFFB751F6).withOpacity(0.1),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: cargoController,
                      decoration: InputDecoration(
                        labelText: 'Cargo',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFFB751F6).withOpacity(0.1),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: setorController,
                      decoration: InputDecoration(
                        labelText: 'Setor',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFFB751F6).withOpacity(0.1),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Cadastrar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    if (nomeController.text.isEmpty ||
                        emailController.text.isEmpty ||
                        cargoController.text.isEmpty ||
                        setorController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
                      );
                      return;
                    }

                    await cadastrarNovoFuncionario(
                      nomeController.text,
                      cargoController.text,
                      emailController.text,
                      Uuid().v4(),
                      true, // ou false, dependendo do caso para isGestor
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

  Future<void> cadastrarNovoFuncionario(
    String nome, String cargo, String email, String senha, bool isGestor) async {
    try {
      setState(() {
        isLoading = true;
      });

      // Gerar um UUID para o usuário
      final String userId = Uuid().v4();

      // Fazer o hash da senha para armazenar de forma segura
      final String hashedPassword = simpleHashPassword(senha);

      // Inserir o novo funcionário na tabela 'Acesso Geral'
      final responseAcessoGeral = await Supabase.instance.client
          .from('Acesso Geral')
          .insert({
            'id_usuario': userId,
            'email': email,
            'senha': hashedPassword,
            'is_gestor': isGestor,
          })
          .execute();

      // Verificar se o funcionário foi inserido com sucesso na tabela 'Acesso Geral'
      if (responseAcessoGeral.status == 201) {
        // Inserir os dados adicionais na tabela 'funcionarios'
        final responseFuncionario = await Supabase.instance.client
            .from('funcionarios')
            .insert({
              'id_usuario': userId,
              'nome': nome,
              'cargo': cargo,
              'email': email,
              'is_ativo': true,
            })
            .execute();

        // Verificar se a inserção na tabela 'funcionarios' foi bem-sucedida
        if (responseFuncionario.status == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Funcionário cadastrado com sucesso!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao cadastrar na tabela funcionarios: ${responseFuncionario.data?.message}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar no Acesso Geral: ${responseAcessoGeral.data?.message}')),
        );
      }
    } catch (e) {
      // Exibir uma mensagem de erro caso haja uma exceção
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocorreu um erro ao cadastrar o funcionário: $e')),
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

  // Função para carregar os funcionários da base de dados
  Future<void> carregarFuncionarios() async {
    final response = await Supabase.instance.client
        .from('Acesso Geral')
        .select('id_usuario, email')
        .execute();

    if (response.status == 200) {
      setState(() {
        funcionarios = List<Map<String, dynamic>>.from(response.data);
      });
    } else {
      print('Erro ao carregar funcionários: ${response.data?.message}');
    }
  }

  // Função que carrega os treinamentos de um funcionário
  Future<void> carregarTreinamentosFuncionario(String idFuncionario) async {
    final response = await Supabase.instance.client
        .from('treinamentos')
        .select('*')
        .eq('id_funcionario', idFuncionario)
        .order('data_inicio', ascending: !isDescending)
        .execute();

    if (response.status == 200) {
      setState(() {
        treinamentosParaFuncionario = List<Map<String, dynamic>>.from(response.data);
        treinamentosFiltrados = treinamentosParaFuncionario;
      });
    } else {
      print('Erro ao carregar treinamentos: ${response.data?.message}');
    }
  }

  // Função para enviar feedback do funcionário
  Future<void> enviarFeedback(
    String idFuncionario,
    double ratingGeral,
    double desempenho,
    double pontualidade,
    double trabalhoEquipe,
    String feedbackText,
  ) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await Supabase.instance.client.from('feedbacks').insert({
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar feedback: ${response.data?.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocorreu um erro: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Função para adicionar um novo treinamento
  Future<void> adicionarTreinamento(
    String emailFuncionario,
    String descricaoTreinamento,
    String localizacaoTreinamento,
    DateTime dataInicio,
    DateTime dataFim,
  ) async {
    String? funcionarioId = await buscarIdFuncionario(emailFuncionario);

    if (funcionarioId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Funcionário não encontrado.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await Supabase.instance.client.from('treinamentos').insert({
        'descricao': descricaoTreinamento,
        'localizacao': localizacaoTreinamento,
        'id_funcionario': funcionarioId,
        'data_inicio': dataInicio.toIso8601String(),
        'data_fim': dataFim.toIso8601String(),
      }).execute();

      if (response.status == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Treinamento adicionado com sucesso!')),
        );
        await carregarTreinamentosFuncionario(funcionarioId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar treinamento: ${response.data?.message}')),
        );
      }
    } catch (e) {
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

  // Função para excluir um treinamento
  Future<void> excluirTreinamento(String idTreinamento) async {
    setState(() {
      isLoading = true;
    });

    final response = await Supabase.instance.client
        .from('treinamentos')
        .delete()
        .eq('id', idTreinamento)
        .execute();

    if (response.status == 204) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Treinamento excluído com sucesso!')),
      );
      if (selectedFuncionarioId != null) {
        carregarTreinamentosFuncionario(selectedFuncionarioId!);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir treinamento: ${response.data?.message}')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  void exibirDialogoAdicionarTreinamento(
      BuildContext context, String emailFuncionario, [Map<String, dynamic>? treinamentoExistente]) {
    // Preencher campos com dados existentes (se for editar)
    if (treinamentoExistente != null) {
      descricaoController.text = treinamentoExistente['descricao'];
      localizacaoController.text = treinamentoExistente['localizacao'];
      dataInicio = DateTime.parse(treinamentoExistente['data_inicio']);
      dataFim = DateTime.parse(treinamentoExistente['data_fim']);
    } else {
      descricaoController.clear();
      localizacaoController.clear();
      dataInicio = null;
      dataFim = null;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFB751F6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              title: Text(
                treinamentoExistente == null ? 'Novo Treinamento' : 'Editar Treinamento',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Campo de Descrição
                    TextField(
                      controller: descricaoController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Descrição',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFFB751F6).withOpacity(0.2),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Campo de Localização
                    TextField(
                      controller: localizacaoController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Localização',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFFB751F6).withOpacity(0.2),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Botão de Seleção de Data de Início
                    TextButton(
                      onPressed: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: dataInicio ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFFB751F6),
                                  onPrimary: Colors.white,
                                  onSurface: Color(0xFFB751F6),
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
                        dataInicio != null
                            ? 'Data de Início: ${DateFormat('dd/MM/yyyy').format(dataInicio!)}'
                            : 'Selecionar Data de Início',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),

                    // Botão de Seleção de Data de Término
                    TextButton(
                      onPressed: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: dataFim ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFFB751F6),
                                  onPrimary: Colors.white,
                                  onSurface: Color(0xFFB751F6),
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
                        dataFim != null
                            ? 'Data de Término: ${DateFormat('dd/MM/yyyy').format(dataFim!)}'
                            : 'Selecionar Data de Término',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                // Botão Cancelar
                TextButton(
                  child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),

                // Botão de Salvar/Adicionar
                TextButton(
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : Text(treinamentoExistente == null ? 'Adicionar' : 'Salvar',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    // Verificação dos campos obrigatórios
                    if (descricaoController.text.isEmpty ||
                        localizacaoController.text.isEmpty ||
                        dataInicio == null ||
                        dataFim == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
                      );
                      return;
                    }

                    // Chamando a função para adicionar ou editar o treinamento
                    await adicionarTreinamento(
                      emailFuncionario,
                      descricaoController.text,
                      localizacaoController.text,
                      dataInicio!,
                      dataFim!,
                    );

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

  void exibirDialogoFeedback(BuildContext context, String nomeFuncionario) {
    double ratingGeral = 0;
    double desempenho = 3;
    double pontualidade = 3;
    double trabalhoEquipe = 3;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFB751F6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              title: Text(
                'Avaliação e Feedback - $nomeFuncionario',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'Avalie o Funcionário',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            Icons.business_center,
                            color: index < ratingGeral ? Colors.yellow : Colors.white24,
                          ),
                          onPressed: () {
                            setState(() {
                              ratingGeral = index + 1.0;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Desempenho:',
                      style: TextStyle(color: Colors.white),
                    ),
                    Slider(
                      value: desempenho,
                      min: 0,
                      max: 5,
                      divisions: 5,
                      activeColor: Colors.yellow,
                      inactiveColor: Colors.white24,
                      onChanged: (value) {
                        setState(() {
                          desempenho = value;
                        });
                      },
                    ),
                    const Text(
                      'Pontualidade:',
                      style: TextStyle(color: Colors.white),
                    ),
                    Slider(
                      value: pontualidade,
                      min: 0,
                      max: 5,
                      divisions: 5,
                      activeColor: Colors.yellow,
                      inactiveColor: Colors.white24,
                      onChanged: (value) {
                        setState(() {
                          pontualidade = value;
                        });
                      },
                    ),
                    const Text(
                      'Trabalho em Equipe:',
                      style: TextStyle(color: Colors.white),
                    ),
                    Slider(
                      value: trabalhoEquipe,
                      min: 0,
                      max: 5,
                      divisions: 5,
                      activeColor: Colors.yellow,
                      inactiveColor: Colors.white24,
                      onChanged: (value) {
                        setState(() {
                          trabalhoEquipe = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: feedbackController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Escreva um feedback',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFFE6EEF0).withOpacity(0.2),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(color: Colors.white70),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(color: Colors.white),
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
                    style: TextStyle(color: Colors.white54),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Enviar Avaliação',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  onPressed: () async {
                    if (feedbackController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, escreva um feedback.')),
                      );
                      return;
                    }

                    // Envia o feedback com o ID do funcionário selecionado
                    if (selectedFuncionarioId != null) {
                      await enviarFeedback(
                        selectedFuncionarioId!,
                        ratingGeral,
                        desempenho,
                        pontualidade,
                        trabalhoEquipe,
                        feedbackController.text,
                      );

                      // Limpar o campo de feedback após o envio
                      setState(() {
                        feedbackController.clear();
                      });

                      Navigator.of(context).pop(); // Fechar o diálogo após enviar o feedback
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nenhum funcionário selecionado.')),
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

  void filtrarTreinamentos(String query) {
    final resultados = treinamentosParaFuncionario.where((treinamento) {
      final descricaoLower = treinamento['descricao'].toLowerCase();
      final queryLower = query.toLowerCase();
      return descricaoLower.contains(queryLower);
    }).toList();

    setState(() {
      treinamentosFiltrados = resultados;
    });
  }

  // Exibição do modal para selecionar funcionários
  void exibirFuncionarios(BuildContext context) async {
    await carregarFuncionarios();

    if (funcionarios.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum funcionário encontrado.')),
      );
    } else {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return DraggableScrollableSheet(
            expand: false,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFB751F6),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Funcionários Cadastrados',
                        style: FlutterFlowTheme.of(context).titleMedium.override(
                          fontFamily: 'Readex Pro',
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: funcionarios.length,
                          itemBuilder: (context, index) {
                            final funcionario = funcionarios[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  title: Text(
                                    funcionario['email'],
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'ID: ${funcionario['id_usuario']}',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontStyle: FontStyle.italic,
                                      fontSize: 14,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      selectedFuncionarioEmail = funcionario['email'];
                                      selectedFuncionarioId = funcionario['id_usuario'];
                                    });
                                    carregarTreinamentosFuncionario(selectedFuncionarioId!);
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFB751F6),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFB751F6), const Color(0xFFD47BFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
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
                      color: Color(0xFFB751F6),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Área de Gestão',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.feedback_outlined, color: Color(0xFFB751F6)),
              title: const Text(
                'Fornecer Feedback',
                style: TextStyle(
                  color: Color(0xFFB751F6),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                if (selectedFuncionarioEmail != null) {
                  exibirDialogoFeedback(context, selectedFuncionarioEmail!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, selecione um funcionário primeiro.')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add, color: Color(0xFFB751F6)),
              title: const Text(
                'Cadastrar Funcionário',
                style: TextStyle(
                  color: Color(0xFFB751F6),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                exibirDialogoAdicionarFuncionario(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_chart_outlined, color: Color(0xFFB751F6)),
              title: const Text(
                'Relatórios',
                style: TextStyle(
                  color: Color(0xFFB751F6),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          RelatoriosWidget(treinamentos: treinamentosParaFuncionario)),       
                );
              },
            ),
            ListTile(
            leading: const Icon(Icons.data_usage_rounded, color: Color(0xFFB751F6)), // Novo ícone para dados gerais
            title: const Text(
              'Dados Gerais',
              style: TextStyle(
                color: Color(0xFFB751F6),
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              if (selectedFuncionarioEmail != null && selectedFuncionarioEmail!.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DadosWidget(userEmail: selectedFuncionarioEmail!),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor, selecione um funcionário primeiro.')),
                );
              }
            },
          ),

          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 0.0),
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
                      color: Colors.white,
                      size: 24.0,
                    ),
                    onPressed: () {
                      scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.center,
                      child: Text(
                        'MONITORAMENTO',
                        textAlign: TextAlign.start,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Readex Pro',
                          color: Colors.white,
                          letterSpacing: 0.0,
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 2.0, 0.0, 0.0),
                    child: Icon(
                      Icons.location_history,
                      color: Color(0xFFE6EEF0),
                      size: 37.0,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 20.0),
              child: Container(
                width: double.infinity,
                height: 47.0,
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1ECEE),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.search,
                        color: Color(0xFFCCD3D4),
                        size: 24.0,
                      ),
                      onPressed: () {
                        filtrarTreinamentos(searchController.text);
                      },
                    ),
                    Expanded(
                      child: Text(
                        selectedFuncionarioEmail ?? 'Buscar Treinamentos',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Readex Pro',
                          color: const Color(0xFF999FA0),
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFF999FA0),
                        size: 24.0,
                      ),
                      onPressed: () {
                        exibirFuncionarios(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (selectedFuncionarioEmail != null) ...[
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20.0, 10.0, 20.0, 0.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Buscar Treinamentos',
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFB751F6).withOpacity(0.1),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: filtrarTreinamentos,
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20.0, 10.0, 20.0, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ordenar por data:',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Switch(
                      value: isDescending,
                      onChanged: (value) {
                        setState(() {
                          isDescending = value;
                          carregarTreinamentosFuncionario(selectedFuncionarioId!);
                        });
                      },
                      activeColor: Colors.white,
                      inactiveThumbColor: Colors.grey[400],
                      activeTrackColor: Colors.white.withOpacity(0.5),
                      inactiveTrackColor: Colors.grey[700],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  itemCount: treinamentosFiltrados.length,
                  itemBuilder: (context, index) {
                    final treinamento = treinamentosFiltrados[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFB751F6), Color(0xFFD47BFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 3,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Treinamento: ${treinamento['descricao']}',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'Readex Pro',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Localização: ${treinamento['localizacao']}',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'Readex Pro',
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Data de Início: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(treinamento['data_inicio']))}',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'Readex Pro',
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Data de Término: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(treinamento['data_fim']))}',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'Readex Pro',
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.white),
                                  onPressed: () {
                                    exibirDialogoAdicionarTreinamento(context, selectedFuncionarioEmail!, treinamento);
                                  },
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () {
                                    excluirTreinamento(treinamento['id']);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedFuncionarioEmail != null) {
            exibirDialogoAdicionarTreinamento(context, selectedFuncionarioEmail!);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Por favor, selecione um funcionário primeiro.')),
            );
          }
        },
        backgroundColor: const Color(0xFFB751F6),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Container(
        height: 53.0,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 20.0,
                buttonSize: 49.0,
                hoverIconColor: const Color(0xFFE0BAF7),
                icon: const Icon(
                  Icons.home,
                  color: Color(0xFFCCD3D4),
                  size: 25.0,
                ),
                onPressed: () {
                  context.pushNamed('home');
                },
              ),
              FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 20.0,
                borderWidth: 1.0,
                buttonSize: 49.0,
                hoverIconColor: const Color(0xFFE0BAF7),
                icon: const Icon(
                  Icons.access_time,
                  color: Color(0xFFCCD3D4),
                  size: 25.0,
                ),
                onPressed: () {
                  context.pushNamed('ponto');
                },
              ),
              FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 20.0,
                borderWidth: 1.0,
                buttonSize: 49.0,
                hoverIconColor: const Color(0xFFE0BAF7),
                icon: const Icon(
                  Icons.search,
                  color: Color(0xFFE0BAF7),
                  size: 25.0,
                ),
                onPressed: () {
                  context.pushNamed('pesquisa');
                },
              ),
              FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 20.0,
                borderWidth: 1.0,
                buttonSize: 49.0,
                hoverIconColor: const Color(0xFFE0BAF7),
                icon: const Icon(
                  Icons.person_outline_sharp,
                  color: Color(0xFFCCD3D4),
                  size: 25.0,
                ),
                onPressed: () {
                  context.pushNamed('treinamentos');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
