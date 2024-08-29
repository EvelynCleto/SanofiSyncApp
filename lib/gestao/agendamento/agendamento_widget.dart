import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AgendamentoWidget extends StatefulWidget {
  const AgendamentoWidget({Key? key}) : super(key: key);

  @override
  _AgendamentoWidgetState createState() => _AgendamentoWidgetState();
}

class _AgendamentoWidgetState extends State<AgendamentoWidget>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  List<Map<String, dynamic>> agendamentosPendentes = [];
  List<Map<String, dynamic>> agendamentosAprovados = [];
  List<Map<String, dynamic>> agendamentosDesaprovados = [];

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    carregarAgendamentos();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> carregarAgendamentos() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response =
          await Supabase.instance.client.from('reservas').select().execute();

      if (response.status >= 200 &&
          response.status < 300 &&
          response.data != null) {
        final allAgendamentos =
            List<Map<String, dynamic>>.from(response.data as List);
        setState(() {
          agendamentosPendentes = allAgendamentos
              .where((item) => item['status'] == 'pendente')
              .toList();
          agendamentosAprovados = allAgendamentos
              .where((item) => item['status'] == 'aprovado')
              .toList();
          agendamentosDesaprovados = allAgendamentos
              .where((item) => item['status'] == 'desaprovado')
              .toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nenhum agendamento encontrado.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar agendamentos: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> atualizarStatusAgendamento(int id, String status) async {
    try {
      final response = await Supabase.instance.client
          .from('reservas')
          .update({'status': status})
          .eq('id', id)
          .execute();

      if (response.status >= 200 && response.status < 300) {
        await carregarAgendamentos();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status atualizado com sucesso.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar status.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar status: $e')),
      );
    }
  }

  void showUpdateDialog(Map<String, dynamic> agendamento) {
    showDialog(
      context: context,
      builder: (context) {
        List<Widget> actions = [];

        // Define as opções de ação com base no status
        if (agendamento['status'] == 'pendente') {
          actions = [
            TextButton.icon(
              onPressed: () async {
                await atualizarStatusAgendamento(
                    agendamento['id'] as int, 'aprovado');
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.check_circle, color: Colors.green[600]),
              label: Text('Aprovar'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                await atualizarStatusAgendamento(
                    agendamento['id'] as int, 'desaprovado');
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.cancel, color: Colors.red[600]),
              label: Text('Reprovar'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ];
        } else if (agendamento['status'] == 'aprovado') {
          actions = [
            TextButton.icon(
              onPressed: () async {
                await atualizarStatusAgendamento(
                    agendamento['id'] as int, 'pendente');
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.refresh, color: Colors.orange[600]),
              label: Text('Pendente'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                await atualizarStatusAgendamento(
                    agendamento['id'] as int, 'desaprovado');
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.cancel, color: Colors.red[600]),
              label: Text('Reprovar'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ];
        } else if (agendamento['status'] == 'desaprovado') {
          actions = [
            TextButton.icon(
              onPressed: () async {
                await atualizarStatusAgendamento(
                    agendamento['id'] as int, 'aprovado');
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.check_circle, color: Colors.green[600]),
              label: Text('Aprovar'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                await atualizarStatusAgendamento(
                    agendamento['id'] as int, 'pendente');
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.refresh, color: Colors.orange[600]),
              label: Text('Pendente'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ];
        }

        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Center(
            child: Text(
              'Editar Agendamento',
              style: TextStyle(
                color: Colors.purple[900],
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(color: Colors.purple[200]),
              ListTile(
                leading: Icon(Icons.meeting_room,
                    color: Colors.purple[800], size: 28),
                title: Text(
                  'Sala: ${agendamento['tipo_sala']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.purple[800],
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.location_city,
                    color: Colors.purple[800], size: 28),
                title: Text(
                  'Prédio: ${agendamento['predio']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.purple[800],
                  ),
                ),
              ),
              ListTile(
                leading:
                    Icon(Icons.people, color: Colors.purple[800], size: 28),
                title: Text(
                  'Participantes: ${agendamento['participantes']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.purple[800],
                  ),
                ),
              ),
              ListTile(
                leading:
                    Icon(Icons.qr_code, color: Colors.purple[800], size: 28),
                title: Text(
                  'QR Code: ${agendamento['qr_code']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.purple[800],
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.calendar_today,
                    color: Colors.purple[800], size: 28),
                title: Text(
                  'Data: ${agendamento['data_reserva']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.purple[800],
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.info_outline,
                    color: Colors.purple[800], size: 28),
                title: Text(
                  'Status: ${agendamento['status']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.purple[800],
                  ),
                ),
              ),
              Divider(color: Colors.purple[200]),
            ],
          ),
          actions: actions,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple[800],
          title: Text('Agendamentos',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.purple[100],
            indicatorColor: Colors.white,
            indicatorWeight: 3.0,
            tabs: [
              Tab(icon: Icon(Icons.pending_actions), text: 'Pendentes'),
              Tab(icon: Icon(Icons.check), text: 'Aprovados'),
              Tab(icon: Icon(Icons.cancel), text: 'Reprovados'),
            ],
          ),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(color: Colors.purple[800]))
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: TabBarView(
                  children: [
                    buildListView(agendamentosPendentes),
                    buildListView(agendamentosAprovados),
                    buildListView(agendamentosDesaprovados),
                  ],
                ),
              ),
      ),
    );
  }

  Widget buildListView(List<Map<String, dynamic>> agendamentos) {
    return ListView.builder(
      itemCount: agendamentos.length,
      itemBuilder: (context, index) {
        final agendamento = agendamentos[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: Icon(Icons.meeting_room, color: Colors.purple[800]),
            title: Text(
              agendamento['tipo_sala'],
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[900]),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              'Prédio: ${agendamento['predio']} - Data: ${agendamento['data_reserva']}',
              style: TextStyle(color: Colors.purple[700]),
            ),
            trailing: Icon(Icons.edit, color: Colors.purple[800]),
            onTap: () => showUpdateDialog(agendamento),
          ),
        );
      },
    );
  }
}
