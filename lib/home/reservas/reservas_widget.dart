import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ReservasWidget extends StatefulWidget {
  final String usuarioId;
  final String usuarioNome;
  final String localizacao;

  const ReservasWidget({
    Key? key,
    required this.usuarioId,
    required this.usuarioNome,
    required this.localizacao,
  }) : super(key: key);

  @override
  _ReservasWidgetState createState() => _ReservasWidgetState();
}

class _ReservasWidgetState extends State<ReservasWidget>
    with TickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  Map<String, dynamic>? _originalReservation; // Reserva original
  Map<String, dynamic>? _negotiationReservation; // Reserva em negociação

  List<DateTime> _disabledDays = [];
  List<DateTime> _markedDays = [];
  bool _showOnlyReserved = false;
  bool _showAllDates = false;
  List<bool> _expandedCards = [];
  TimeOfDay? _selectedTime;
  int _currentStep = 0;
  bool _isNegotiationPending =
      false; // Controle para verificar se há uma negociação pendente
  String? _negotiationMotivo;
  String? _negotiationDescricao;

  @override
  void initState() {
    super.initState();
    _loadReservas();
  }

  Future<void> _loadReservas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? storedEvents = prefs.getString('stored_events');
    final String? storedDisabledDays = prefs.getString('disabled_days');
    final String? storedMarkedDays = prefs.getString('marked_days');

    if (storedEvents != null) {
      setState(() {
        _events = (json.decode(storedEvents) as Map<String, dynamic>).map(
          (key, value) => MapEntry(
            DateTime.parse(key),
            List<Map<String, dynamic>>.from(
                value.map((item) => Map<String, dynamic>.from(item))),
          ),
        );
      });
    }

    // Carregar os dias bloqueados e marcados ao inicializar
    if (storedDisabledDays != null) {
      setState(() {
        _disabledDays = (json.decode(storedDisabledDays) as List<dynamic>)
            .map((e) => DateTime.parse(e as String))
            .toList();
      });
    }

    if (storedMarkedDays != null) {
      setState(() {
        _markedDays = (json.decode(storedMarkedDays) as List<dynamic>)
            .map((e) => DateTime.parse(e as String))
            .toList();
      });
    }

    // Certifique-se de que os eventos estejam atualizados corretamente
    setState(() {
      _updateCalendarState();
    });
  }

  void _updateCalendarState() {
    setState(() {
      _markedDays = _events.keys.toList();

      // Verificar se o dia selecionado ainda está marcado
      if (!_markedDays.contains(_selectedDay)) {
        _selectedDay = DateTime.now(); // Ou escolha o primeiro dia marcado
      }
    });
  }

  Future<void> _saveEventsLocally() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final eventsAsString = json.encode(_events.map(
      (key, value) => MapEntry(
        key.toIso8601String(),
        value.map((e) => Map<String, dynamic>.from(e)).toList(),
      ),
    ));
    await prefs.setString('stored_events', eventsAsString);

    // Salvando dias bloqueados e marcados localmente
    final disabledDaysAsString =
        json.encode(_disabledDays.map((e) => e.toIso8601String()).toList());
    await prefs.setString('disabled_days', disabledDaysAsString);

    final markedDaysAsString =
        json.encode(_markedDays.map((e) => e.toIso8601String()).toList());
    await prefs.setString('marked_days', markedDaysAsString);
  }

  void _blockWeek(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    for (var i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      if (!_disabledDays.contains(day)) {
        _disabledDays.add(day);
      }
    }

    // Salvar localmente os dias bloqueados
    _saveEventsLocally();
  }

  void _addReserva() async {
    // Verifica se já existe uma reserva na mesma semana
    final DateTime startOfWeek =
        _selectedDay.subtract(Duration(days: _selectedDay.weekday - 1));
    final DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

    final response = await Supabase.instance.client
        .from('reservas')
        .select()
        .gte('data_reserva', startOfWeek.toIso8601String())
        .lte('data_reserva', endOfWeek.toIso8601String())
        .execute();

    if (response.status == 200 && response.data.isNotEmpty) {
      // Caso já exista uma reserva na semana, não permitir outra reserva
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Já existe uma reserva nesta semana. Escolha outra semana.')),
      );
    } else {
      _startNewReservation();
    }
  }

  // Método para negociação de data já reservada
  void _startNegotiation(Map<String, dynamic> existingReservation) {
    final TextEditingController nomeFuncionarioController =
        TextEditingController();
    final TextEditingController emailFuncionarioController =
        TextEditingController();
    final TextEditingController contatoFuncionarioController =
        TextEditingController();
    final TextEditingController tipoReservaController = TextEditingController();
    final TextEditingController descricaoReservaController =
        TextEditingController(); // Para a descrição
    final TextEditingController predioController = TextEditingController();
    final TextEditingController participantesController =
        TextEditingController();
    final TextEditingController motivoController =
        TextEditingController(); // Para o motivo da negociação

    setState(() {
      _originalReservation = existingReservation;
      _currentStep = 0;
    });

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stepper(
                currentStep: _currentStep,
                onStepTapped: (int step) {
                  if (step >= 0 && step < 4) {
                    setState(() {
                      _currentStep = step;
                    });
                  }
                },
                onStepContinue: () {
                  if (_currentStep < 3) {
                    setState(() {
                      _currentStep += 1;
                    });
                  } else {
                    // Aqui você coleta os valores corretamente antes de submeter a negociação
                    final String motivo = motivoController.text.trim();
                    final String descricao =
                        descricaoReservaController.text.trim();

                    if (motivo.isNotEmpty && descricao.isNotEmpty) {
                      _submitNegotiation(
                        nomeFuncionarioController.text.trim(),
                        emailFuncionarioController.text.trim(),
                        contatoFuncionarioController.text.trim(),
                        tipoReservaController.text.trim(),
                        descricao, // Passa a descrição corretamente
                        predioController.text.trim(),
                        int.parse(participantesController.text.trim()),
                        motivo, // Passa
                      );
                      Navigator.of(context)
                          .pop(); // Fecha o modal após a submissão
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Por favor, preencha o motivo e a descrição.')),
                      );
                    }
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() {
                      _currentStep -= 1;
                    });
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                steps: <Step>[
                  Step(
                    title: const Text('Informações do Funcionário'),
                    content: Column(
                      children: [
                        TextField(
                          controller: nomeFuncionarioController,
                          decoration: const InputDecoration(
                            labelText: 'Nome do Funcionário',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: emailFuncionarioController,
                          decoration: const InputDecoration(
                            labelText: 'Email do Funcionário',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: contatoFuncionarioController,
                          decoration: const InputDecoration(
                            labelText: 'Contato do Funcionário',
                          ),
                        ),
                      ],
                    ),
                    isActive: _currentStep >= 0,
                  ),
                  Step(
                    title: const Text('Detalhes da Reserva'),
                    content: Column(
                      children: [
                        TextField(
                          controller: tipoReservaController,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de Reserva',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: descricaoReservaController,
                          decoration: const InputDecoration(
                            labelText: 'Descrição',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: predioController,
                          decoration: const InputDecoration(
                            labelText: 'Prédio',
                          ),
                        ),
                      ],
                    ),
                    isActive: _currentStep >= 1,
                  ),
                  Step(
                    title: const Text('Participantes e Horário'),
                    content: Column(
                      children: [
                        TextField(
                          controller: participantesController,
                          decoration: const InputDecoration(
                            labelText: 'Número de Participantes',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: motivoController,
                          decoration: const InputDecoration(
                            labelText: 'Motivo da Negociação (Urgência)',
                          ),
                        ),
                      ],
                    ),
                    isActive: _currentStep >= 2,
                  ),
                  Step(
                    title: const Text('Confirmação'),
                    content:
                        const Text('Revise as informações antes de confirmar.'),
                    isActive: _currentStep >= 3,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _submitNegotiation(
      String nomeFuncionario,
      String emailFuncionario,
      String contatoFuncionario,
      String tipoReserva,
      String descricao,
      String predio,
      int participantes,
      String motivo, // Motivo da negociação
      {String?
          reservaOriginalId} // ID da reserva original, opcional para quando for negociação
      ) async {
    final negociacao = {
      'usuario_id': widget.usuarioId,
      'nome_funcionario': nomeFuncionario,
      'email_funcionario': emailFuncionario,
      'contato_funcionario': contatoFuncionario,
      'tipo_sala': tipoReserva,
      'descricao': descricao,
      'predio': predio,
      'participantes': participantes,
      'motivo': motivo,
      'data_reserva': _selectedDay.toIso8601String(),
      'status': reservaOriginalId != null
          ? 'Em Negociação'
          : 'Confirmado', // Define o status conforme o caso
    };

    // Submeter a negociação ou nova reserva
    final response = await Supabase.instance.client
        .from('reservas')
        .insert(negociacao)
        .execute();

    if (response.status == 201) {
      setState(() {
        _isNegotiationPending = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Negociação enviada com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao enviar negociação: ${response.status}')),
      );
    }
  }

  void _approveNegotiation(
      Map<String, dynamic> originalReservation,
      Map<String, dynamic> negotiationReservation,
      bool aprovado // true se aprovado, false se rejeitado
      ) async {
    if (aprovado) {
      // Atualizar a reserva original como cancelada
      await Supabase.instance.client
          .from('reservas')
          .update({
            'status': 'Cancelada',
            'descricao':
                '~~${originalReservation['descricao']}~~' // Mostrar como cancelada
          })
          .eq('id', originalReservation['id'])
          .execute();

      // Atualizar a negociação como confirmada
      await Supabase.instance.client
          .from('reservas')
          .update({'status': 'Confirmado'})
          .eq('id', negotiationReservation['id'])
          .execute();

      // Atualizar a interface, removendo a reserva antiga e mostrando a nova
      setState(() {
        _events[DateTime.parse(originalReservation['data_reserva'])]!
            .remove(originalReservation);
        _events[DateTime.parse(negotiationReservation['data_reserva'])]!
            .add(negotiationReservation);
        _isNegotiationPending = false;
      });
    } else {
      // Rejeitar negociação
      await Supabase.instance.client
          .from('reservas')
          .update({'status': 'Negociação Rejeitada'})
          .eq('id', negotiationReservation['id'])
          .execute();

      setState(() {
        _isNegotiationPending = false;
      });
    }

    // Atualizar a visualização do calendário e reservas
    _loadReservas();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              aprovado ? 'Negociação aprovada!' : 'Negociação rejeitada!')),
    );
  }

  // Exibir a negociação pendente e permitir que o responsável original aceite ou rejeite

  // Método para iniciar uma nova reserva
  void _startNewReservation() {
    final TextEditingController nomeFuncionarioController =
        TextEditingController();
    final TextEditingController emailFuncionarioController =
        TextEditingController();
    final TextEditingController contatoFuncionarioController =
        TextEditingController();
    final TextEditingController tipoReservaController = TextEditingController();
    final TextEditingController descricaoReservaController =
        TextEditingController();
    final TextEditingController predioController = TextEditingController();
    final TextEditingController participantesController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stepper(
                currentStep: _currentStep,
                onStepTapped: (int step) {
                  setState(() {
                    _currentStep = step;
                  });
                },
                onStepContinue: () {
                  if (_currentStep < 3) {
                    setState(() {
                      _currentStep += 1;
                    });
                  } else {
                    _submitForm(
                      nomeFuncionarioController.text,
                      emailFuncionarioController.text,
                      contatoFuncionarioController.text,
                      tipoReservaController.text,
                      descricaoReservaController.text,
                      predioController.text,
                      int.parse(participantesController.text),
                      _selectedTime,
                    );
                    Navigator.of(context).pop();
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() {
                      _currentStep -= 1;
                    });
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                steps: <Step>[
                  Step(
                    title: const Text('Informações do Funcionário'),
                    content: Column(
                      children: [
                        TextField(
                          controller: nomeFuncionarioController,
                          decoration: const InputDecoration(
                            labelText: 'Nome do Funcionário',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: emailFuncionarioController,
                          decoration: const InputDecoration(
                            labelText: 'Email do Funcionário',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: contatoFuncionarioController,
                          decoration: const InputDecoration(
                            labelText: 'Contato do Funcionário',
                          ),
                        ),
                      ],
                    ),
                    isActive: _currentStep >= 0,
                  ),
                  Step(
                    title: const Text('Detalhes da Reserva'),
                    content: Column(
                      children: [
                        TextField(
                          controller: tipoReservaController,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de Reserva',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: descricaoReservaController,
                          decoration: const InputDecoration(
                            labelText: 'Descrição',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: predioController,
                          decoration: const InputDecoration(
                            labelText: 'Prédio',
                          ),
                        ),
                      ],
                    ),
                    isActive: _currentStep >= 1,
                  ),
                  Step(
                    title: const Text('Participantes e Horário'),
                    content: Column(
                      children: [
                        TextField(
                          controller: participantesController,
                          decoration: const InputDecoration(
                            labelText: 'Número de Participantes',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            final TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (pickedTime != null) {
                              setState(() {
                                _selectedTime = pickedTime;
                              });
                            }
                          },
                          child: Text(
                            _selectedTime == null
                                ? 'Selecionar Horário'
                                : 'Horário: ${_selectedTime!.format(context)}',
                          ),
                        ),
                      ],
                    ),
                    isActive: _currentStep >= 2,
                  ),
                  Step(
                    title: const Text('Confirmação'),
                    content:
                        const Text('Revise as informações antes de confirmar.'),
                    isActive: _currentStep >= 3,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Método para submissão do formulário de reserva
  void _submitForm(
    String nomeFuncionario,
    String emailFuncionario,
    String contatoFuncionario,
    String tipoReserva,
    String descricao,
    String predio,
    int participantes,
    TimeOfDay? horario,
  ) async {
    if (horario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um horário.')),
      );
      return;
    }

    final novaReserva = {
      'usuario_id': widget.usuarioId,
      'nome_funcionario': nomeFuncionario,
      'email_funcionario': emailFuncionario,
      'contato_funcionario': contatoFuncionario,
      'tipo_sala': tipoReserva,
      'descricao': descricao,
      'predio': predio,
      'participantes': participantes,
      'data_reserva': _selectedDay.toIso8601String(),
      'horario': horario.format(context),
      'status': 'Confirmado',
    };

    final response = await Supabase.instance.client
        .from('reservas')
        .insert(novaReserva)
        .execute();

    if (response.status == 201) {
      setState(() {
        // Adiciona a nova reserva ao mapa de eventos
        if (_events[_selectedDay] == null) {
          _events[_selectedDay] = [];
        }
        _events[_selectedDay]!.add(novaReserva);

        // Marca o dia selecionado, se ainda não estiver marcado
        if (!_markedDays.contains(_selectedDay)) {
          _markedDays.add(_selectedDay);
        }

        // Bloqueia a semana conforme a regra
        _blockWeek(_selectedDay);

        // Salva os eventos e marcações localmente
        _saveEventsLocally();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva adicionada com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao adicionar reserva: ${response.status}')),
      );
    }
  }

  // Exibir lista de todas as datas reservadas
  Widget _buildAllReservationsList() {
    final allReservations = _events.entries
        .expand((entry) => entry.value)
        .toList()
      ..sort((a, b) => DateTime.parse(a['data_reserva'])
          .compareTo(DateTime.parse(b['data_reserva'])));

    return ListView.builder(
      itemCount: allReservations.length,
      itemBuilder: (context, index) {
        final evento = allReservations[index];
        return AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.15),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple,
              child: Icon(Icons.event, color: Colors.white),
            ),
            title: Text(
              evento['descricao'] ?? 'Reserva sem descrição',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(evento['data_reserva']))}',
                  style: TextStyle(color: Colors.black54),
                ),
                Text(
                  'Prédio: ${evento['predio']}',
                  style: TextStyle(color: Colors.black54),
                ),
                Text(
                  'Participantes: ${evento['participantes']}',
                  style: TextStyle(color: Colors.black54),
                ),
                Text(
                  'Status: ${evento['status'] ?? 'Pendente'}',
                  style: TextStyle(
                    color: evento['status'] == 'Confirmado'
                        ? Colors.green
                        : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Calendário de Reservas'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: Icon(
              _showAllDates ? Icons.calendar_today : Icons.filter_alt,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showAllDates = !_showAllDates;
              });
            },
            tooltip: _showAllDates
                ? 'Voltar ao Calendário'
                : 'Mostrar Todas as Reservas',
          ),
        ],
      ),
      body: _showAllDates
          ? _buildAllReservationsList()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10.0),
                  child: TableCalendar(
                    focusedDay: _focusedDay,
                    firstDay: DateTime(2022),
                    lastDay: DateTime(2030),
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) =>
                        _markedDays.contains(day) ||
                        isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    eventLoader: (day) {
                      // Exibe os eventos apenas se o dia estiver marcado
                      return _events[day] ?? [];
                    },
                    calendarStyle: CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: Colors.purple,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      markerDecoration: BoxDecoration(
                        color: Colors.purple,
                        shape: BoxShape.circle,
                      ),
                      disabledDecoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      disabledTextStyle: TextStyle(color: Colors.grey),
                      markersMaxCount: 1,
                      markersAlignment: Alignment.bottomCenter,
                      outsideDaysVisible: false,
                      weekendTextStyle: const TextStyle(color: Colors.black),
                      defaultTextStyle: const TextStyle(color: Colors.black),
                    ),
                    enabledDayPredicate: (day) {
                      // Permite a seleção do dia marcado, mesmo que ele esteja na lista de dias bloqueados
                      if (_markedDays.contains(day)) {
                        return true;
                      }
                      // Bloqueia os dias que estão na lista de dias desabilitados
                      return !_disabledDays.contains(day);
                    },
                    headerStyle: HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      formatButtonDecoration: BoxDecoration(
                        color: Colors.purpleAccent,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      formatButtonTextStyle:
                          const TextStyle(color: Colors.white),
                      titleTextStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      leftChevronIcon:
                          Icon(Icons.chevron_left, color: Colors.black),
                      rightChevronIcon:
                          Icon(Icons.chevron_right, color: Colors.black),
                    ),
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                  ),
                ),
                Expanded(child: _buildEventListView()),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addReserva,
        backgroundColor: Colors.purpleAccent,
        child: const Icon(Icons.add, color: Colors.white),
        elevation: 8,
        tooltip: 'Adicionar Reserva',
      ),
    );
  }

  Widget _buildEventListView() {
    final eventos = _events[_selectedDay] ?? [];

    return eventos.isEmpty
        ? const Center(child: Text('Nenhuma reserva para este dia.'))
        : ListView.builder(
            itemCount: eventos.length,
            itemBuilder: (context, index) {
              final evento = eventos[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _expandedCards[index] = !_expandedCards[index];
                  });
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.15),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple,
                          child: Icon(Icons.event, color: Colors.white),
                        ),
                        title: Text(
                          evento['descricao'] ?? 'Reserva sem descrição',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Data: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(evento['data_reserva']))}',
                              style: TextStyle(color: Colors.black54),
                            ),
                            Text(
                              'Prédio: ${evento['predio'] ?? 'Não especificado'}',
                              style: TextStyle(color: Colors.black54),
                            ),
                            Text(
                              'Participantes: ${evento['participantes'] ?? 'Não especificado'}',
                              style: TextStyle(color: Colors.black54),
                            ),
                            Text(
                              'Status: ${evento['status'] ?? 'Pendente'}',
                              style: TextStyle(
                                color: evento['status'] == 'Confirmado'
                                    ? Colors.green
                                    : Colors.redAccent,
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
}
