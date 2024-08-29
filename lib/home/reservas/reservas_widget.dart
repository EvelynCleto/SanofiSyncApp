import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReservasWidget extends StatefulWidget {
  final String usuarioId;

  const ReservasWidget({Key? key, required this.usuarioId}) : super(key: key);

  @override
  _ReservasWidgetState createState() => _ReservasWidgetState();
}

class _ReservasWidgetState extends State<ReservasWidget> {
  List<Map<String, dynamic>> reservas = [];
  final TextEditingController participantesController = TextEditingController();
  final TextEditingController qrCodeController = TextEditingController();
  final TextEditingController dataController = TextEditingController();
  String tipoSala = 'Selecionar Sala';
  String predioSelecionado = 'Selecionar Prédio';
  String? qrCodeResult = '';

  @override
  void initState() {
    super.initState();
    _loadReservas();
  }

  Future<void> _loadReservas() async {
    final response = await Supabase.instance.client
        .from('reservas')
        .select()
        .eq('usuario_id', widget.usuarioId)
        .execute();

    if (response.data != null) {
      setState(() {
        reservas = List<Map<String, dynamic>>.from(response.data);
      });
    }
  }

  Future<void> _addReserva() async {
    final String qrCodeSafe = qrCodeResult ?? '';
    final String tipoSalaSafe =
        tipoSala != 'Selecionar Sala' ? tipoSala : 'Não selecionado';
    final String predioSelecionadoSafe =
        predioSelecionado != 'Selecionar Prédio'
            ? predioSelecionado
            : 'Não selecionado';

    if (participantesController.text.isNotEmpty &&
        tipoSalaSafe != 'Não selecionado' &&
        predioSelecionadoSafe != 'Não selecionado' &&
        dataController.text.isNotEmpty) {
      final Map<String, dynamic> novaReserva = {
        'usuario_id': widget.usuarioId,
        'tipo_sala': tipoSalaSafe,
        'predio': predioSelecionadoSafe,
        'participantes': int.parse(
            participantesController.text), // Certificando-se de que é número
        'qr_code': qrCodeSafe,
        'data_reserva': dataController.text,
        'status': 'pendente',
      };

      final response = await Supabase.instance.client
          .from('reservas')
          .insert(novaReserva)
          .execute();

      if (response.data == null) {
        setState(() {
          reservas.add(novaReserva);
        });

        // Limpar campos após a adição da reserva
        tipoSala = 'Selecionar Sala';
        predioSelecionado = 'Selecionar Prédio';
        participantesController.clear();
        qrCodeController.clear();
        dataController.clear();
        qrCodeResult = '';

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Erro ao salvar reserva: ${response.data!.message}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, preencha todos os campos obrigatórios.')),
      );
    }
  }

  Future<void> _showDatePicker() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        dataController.text = selectedDate.toIso8601String();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Expanded(
              child:
                  reservas.isEmpty ? _buildEmptyState() : _buildReservasList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddReservaModal();
        },
        backgroundColor: const Color(0xFF6A1B9A),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Reservas',
        style: TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color(0xFF4A148C),
      centerTitle: true,
      elevation: 4,
    );
  }

  void _showAddReservaModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Adicionar Reserva',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A148C),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildDropdownFormField(
                  label: 'Tipo de Sala',
                  value: tipoSala,
                  items: [
                    'Selecionar Sala',
                    'Sala de Reunião',
                    'Auditório',
                    'Sala de Aula'
                  ],
                  onChanged: (newValue) {
                    setState(() {
                      tipoSala = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildDropdownFormField(
                  label: 'Prédio',
                  value: predioSelecionado,
                  items: [
                    'Selecionar Prédio',
                    'Prédio A',
                    'Prédio B',
                    'Prédio C'
                  ],
                  onChanged: (newValue) {
                    setState(() {
                      predioSelecionado = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: participantesController,
                  label: 'Participantes (somente números)',
                  keyboardType:
                      TextInputType.number, // Limita a entrada a números
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dataController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Data',
                    border: OutlineInputBorder(),
                  ),
                  onTap: _showDatePicker,
                ),
                const SizedBox(height: 16),
                _buildQRCodeButton(),
                const SizedBox(height: 24),
                _buildSubmitButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdownFormField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildQRCodeButton() {
    return ElevatedButton.icon(
      onPressed: _openQRCodeScanner,
      icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
      label: const Text(
        "Ler QR Code da Sala",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4A148C),
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _addReserva,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6A1B9A),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Adicionar Reserva',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildReservasList() {
    return ListView.builder(
      itemCount: reservas.length,
      itemBuilder: (context, index) {
        final reserva = reservas[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          child: ListTile(
            leading: Icon(Icons.meeting_room, color: Colors.purpleAccent),
            title: Text(reserva['tipo_sala'] ?? 'Não informado'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Prédio Selecionado: ${reserva['predio'] ?? 'Não informado'}'),
                Text(
                    'Participantes: ${reserva['participantes'] ?? 'Não informado'}'),
                Text('QR Code: ${reserva['qr_code'] ?? 'Não informado'}'),
                Text('Data: ${reserva['data_reserva'] ?? 'Não informada'}'),
                Text('Status: ${reserva['status'] ?? 'Pendente'}'),
              ],
            ),
            contentPadding: const EdgeInsets.all(16.0),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.event_note_outlined, color: Colors.grey[400], size: 120),
        const SizedBox(height: 16),
        const Text(
          'Nenhuma reserva encontrada',
          style: TextStyle(
              fontSize: 18, color: Colors.black54, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        const Text(
          'Toque no botão "+" abaixo para adicionar uma nova reserva.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.black45),
        ),
      ],
    );
  }

  void _openQRCodeScanner() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Ler QR Code',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6A1B9A),
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Abra o leitor de QR Code no navegador e cole o código abaixo:',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: qrCodeController,
                  decoration: const InputDecoration(
                    hintText: 'Cole o QR Code aqui',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      qrCodeResult = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      qrCodeResult = qrCodeController.text;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Salvar QR Code',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _removeReserva(int index) {
    final reserva = reservas[index];
    final String reservaId = reserva['id'] ?? '';

    Supabase.instance.client
        .from('reservas')
        .delete()
        .eq('id', reservaId)
        .execute()
        .then((response) {
      if (response.data == null) {
        setState(() {
          reservas.removeAt(index);
        });
      }
    });
  }
}
