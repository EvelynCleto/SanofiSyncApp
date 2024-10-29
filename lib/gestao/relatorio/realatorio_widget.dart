import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class RelatoriosWidget extends StatefulWidget {
  @override
  _RelatoriosWidgetState createState() => _RelatoriosWidgetState();
}

class _RelatoriosWidgetState extends State<RelatoriosWidget> {
  final Map<String, dynamic> dadosDepartamentos = {
    "RH": {
      "treinamentos": 10,
      "progresso": 80,
      "assinaturas": 6,
      "alertas": 2,
      "diasAtraso": 3
    },
    "TI": {
      "treinamentos": 8,
      "progresso": 65,
      "assinaturas": 5,
      "alertas": 1,
      "diasAtraso": 0
    },
    "Financeiro": {
      "treinamentos": 5,
      "progresso": 90,
      "assinaturas": 4,
      "alertas": 0,
      "diasAtraso": 0
    },
    "Operações": {
      "treinamentos": 7,
      "progresso": 50,
      "assinaturas": 3,
      "alertas": 3,
      "diasAtraso": 7
    },
    "Vendas": {
      "treinamentos": 6,
      "progresso": 75,
      "assinaturas": 5,
      "alertas": 0,
      "diasAtraso": 0
    },
  };

  String departamentoSelecionado = "Financeiro";

  // Lista de feedbacks fictícios
  List<Map<String, dynamic>> feedbacks = [
    {"nome": "João Silva", "nota": 4.5, "comentario": "Excelente desempenho!"},
    {
      "nome": "Maria Souza",
      "nota": 3.8,
      "comentario": "Bom, mas pode melhorar."
    },
    {
      "nome": "Pedro Oliveira",
      "nota": 4.0,
      "comentario": "Muito bom, fez o treinamento dentro do prazo."
    }
  ];

  // Lista de funcionários ausentes
  List<Map<String, dynamic>> funcionariosAusentes = [
    {
      "nome": "Carlos Pereira",
      "treinamento": "Segurança no Trabalho",
      "data": "2024-09-10",
      "horario": "10:00"
    },
    {
      "nome": "Ana Clara",
      "treinamento": "Normas TI",
      "data": "2024-09-11",
      "horario": "14:00"
    },
    {
      "nome": "Mariana Silva",
      "treinamento": "Ética Empresarial",
      "data": "2024-09-12",
      "horario": "16:00"
    },
    {
      "nome": "Roberto Dias",
      "treinamento": "Atendimento ao Cliente",
      "data": "2024-09-13",
      "horario": "9:00"
    },
    {
      "nome": "Fernanda Costa",
      "treinamento": "Boas Práticas de TI",
      "data": "2024-09-15",
      "horario": "11:00"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        backgroundColor: Colors.purple[900],
        actions: [
          IconButton(
            icon: Icon(Icons.file_download, color: Colors.white),
            onPressed: () {
              _baixarRelatorio();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFiltroSeccao(),
              SizedBox(height: 20),
              _buildCardsDepartamentos(),
              SizedBox(height: 20),
              _buildPerformanceIndicator(),
              SizedBox(height: 20),
              _buildFeedbackSection(),
              SizedBox(height: 20),
              _buildAlertSection(),
            ],
          ),
        ),
      ),
    );
  }

  // Seção de Filtros com Dropdown
  Widget _buildFiltroSeccao() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DropdownButton<String>(
          value: departamentoSelecionado,
          dropdownColor: Colors.white,
          style: TextStyle(color: Colors.black),
          iconEnabledColor: Colors.black,
          items: dadosDepartamentos.keys.map((String key) {
            return DropdownMenuItem<String>(
              value: key,
              child: Text(key, style: TextStyle(color: Colors.black)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              departamentoSelecionado = value!;
            });
          },
        ),
        SizedBox(width: 10),
        ElevatedButton.icon(
          icon: Icon(Icons.filter_list, color: Colors.white),
          onPressed: () {
            _aplicarFiltro();
          },
          label: Text("Filtrar", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  // Cards por departamento
  Widget _buildCardsDepartamentos() {
    return Wrap(
      spacing: 16.0,
      runSpacing: 16.0,
      children: dadosDepartamentos.keys.map((departamento) {
        return GestureDetector(
          onTap: () {
            _mostrarDetalhesDepartamento(departamento);
          },
          child: _buildDepartmentCard(departamento),
        );
      }).toList(),
    );
  }

  void _mostrarDetalhesDepartamento(String departamento) {
    // Relatórios fictícios específicos para cada departamento
    var relatorios = {
      "RH": {
        "Treinamentos": [
          _buildTrainingDetail(
              "Segurança no Trabalho", "01/09/2024", "Realizado"),
          _buildTrainingDetail(
              "Política de Inclusão", "10/09/2024", "Pendente"),
          _buildTrainingDetail(
              "Treinamento de Liderança", "15/09/2024", "Em andamento"),
        ],
        "Progresso":
            "O departamento de RH está com 60% dos treinamentos completos.",
        "Assinaturas": "4 assinaturas realizadas com sucesso.",
        "Alertas": [
          _buildAlertDetail("Treinamento de Inclusão atrasado.", "10/09/2024"),
          _buildAlertDetail("Treinamento de Liderança pendente.", "15/09/2024"),
        ],
        "Dias de Atraso":
            "O departamento teve 5 dias de atraso nos treinamentos."
      },
      "TI": {
        "Treinamentos": [
          _buildTrainingDetail(
              "Normas de Segurança de TI", "02/09/2024", "Realizado"),
          _buildTrainingDetail(
              "Atualizações de Software", "12/09/2024", "Pendente"),
        ],
        "Progresso":
            "O departamento de TI está com 75% dos treinamentos completos.",
        "Assinaturas": "6 assinaturas realizadas com sucesso.",
        "Alertas": [
          _buildAlertDetail("Treinamento de Software atrasado.", "12/09/2024"),
        ],
        "Dias de Atraso": "O departamento teve 3 dias de atraso."
      },
      "Financeiro": {
        "Treinamentos": [
          _buildTrainingDetail(
              "Boas Práticas Financeiras", "01/09/2024", "Realizado"),
          _buildTrainingDetail("Gestão de Riscos", "10/09/2024", "Pendente"),
        ],
        "Progresso":
            "O departamento financeiro está com 80% dos treinamentos completos.",
        "Assinaturas": "5 assinaturas realizadas com sucesso.",
        "Alertas": [
          _buildAlertDetail("Gestão de Riscos atrasado.", "10/09/2024"),
        ],
        "Dias de Atraso": "O departamento teve 2 dias de atraso."
      },
      "Operações": {
        "Treinamentos": [
          _buildTrainingDetail(
              "Procedimentos Operacionais", "01/09/2024", "Realizado"),
          _buildTrainingDetail(
              "Treinamento de Equipamentos", "08/09/2024", "Pendente"),
        ],
        "Progresso":
            "O departamento de Operações está com 55% dos treinamentos completos.",
        "Assinaturas": "3 assinaturas realizadas.",
        "Alertas": [
          _buildAlertDetail(
              "Treinamento de Equipamentos atrasado.", "08/09/2024"),
        ],
        "Dias de Atraso": "O departamento teve 7 dias de atraso."
      },
      "Vendas": {
        "Treinamentos": [
          _buildTrainingDetail("Técnicas de Vendas", "05/09/2024", "Realizado"),
          _buildTrainingDetail(
              "Treinamento de Atendimento", "12/09/2024", "Pendente"),
        ],
        "Progresso":
            "O departamento de Vendas está com 65% dos treinamentos completos.",
        "Assinaturas": "5 assinaturas realizadas.",
        "Alertas": [
          _buildAlertDetail(
              "Treinamento de Atendimento atrasado.", "12/09/2024"),
        ],
        "Dias de Atraso": "O departamento teve 4 dias de atraso."
      }
    };

    // Detalhes do departamento selecionado
    var detalhes = relatorios[departamento];

    if (detalhes == null) {
      return; // Caso não existam detalhes para o departamento selecionado
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Center(
            child: Text(
              "Detalhes - $departamento",
              style: TextStyle(
                color: Colors.purple[900],
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionCard("Treinamentos",
                    detalhes["Treinamentos"] as List<Widget>? ?? []),
                SizedBox(height: 10),
                _buildSectionCard("Progresso", [
                  _buildTextDetail(detalhes["Progresso"] as String? ??
                      "Sem detalhes de progresso"),
                ]),
                SizedBox(height: 10),
                _buildSectionCard("Assinaturas", [
                  _buildTextDetail(detalhes["Assinaturas"] as String? ??
                      "Sem detalhes de assinaturas"),
                ]),
                SizedBox(height: 10),
                _buildSectionCard(
                    "Alertas", detalhes["Alertas"] as List<Widget>? ?? []),
                SizedBox(height: 10),
                _buildSectionCard("Dias de Atraso", [
                  _buildTextDetail(
                      detalhes["Dias de Atraso"] as String? ?? "Sem atrasos"),
                ]),
              ],
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Fechar",
                  style: TextStyle(
                    color: Colors.purple[900],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

// Função para exibir seções com cartões
  Widget _buildSectionCard(String title, List<Widget> content) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple[900],
              ),
            ),
            Divider(color: Colors.grey[300]),
            SizedBox(height: 5),
            ...content,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.purple[900],
          ),
        ),
        ...content,
      ],
    );
  }

  Widget _buildTrainingDetail(String training, String date, String status) {
    Color statusColor = status == "Realizado"
        ? Colors.green
        : (status == "Pendente" ? Colors.orange : Colors.blue);
    IconData statusIcon = status == "Realizado"
        ? Icons.check_circle
        : (status == "Pendente" ? Icons.warning : Icons.hourglass_bottom);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.book, color: Colors.purple[900]),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(training, style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Data: $date", style: TextStyle(color: Colors.grey[600])),
                Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 18),
                    SizedBox(width: 5),
                    Text(
                      "Status: $status",
                      style: TextStyle(
                          color: statusColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextDetail(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildAlertDetail(String alert, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.red),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert, style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Data: $date", style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Função auxiliar para exibir detalhes com ícones e texto
  Widget _buildDetailItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple[900]),
          SizedBox(width: 10),
          Text(
            "$title: ",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Text(value, style: TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }

  // Card individual de cada departamento
// Card individual de cada departamento com melhorias e informações relevantes
  Widget _buildDepartmentCard(String departamento) {
    var dados = dadosDepartamentos[departamento];
    return Container(
      width: MediaQuery.of(context).size.width *
          0.42, // Mantém os cards lado a lado
      height:
          190, // Ajusta a altura para incluir todas as informações de forma clara
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nome do departamento em destaque
              Text(
                departamento,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                overflow: TextOverflow
                    .ellipsis, // Evita que o texto ultrapasse o limite
              ),
              SizedBox(height: 8),

              // Treinamentos concluídos
              Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: Colors.green, size: 18),
                  SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      "Concluídos: ${dados['assinaturas']}",
                      style: TextStyle(color: Colors.grey[800], fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),

              // Treinamentos pendentes
              Row(
                children: [
                  Icon(Icons.pending_actions,
                      color: Colors.orange[800], size: 18),
                  SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      "Pendentes: ${dados['treinamentos'] - dados['assinaturas']}",
                      style: TextStyle(color: Colors.grey[800], fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),

              // Assinaturas realizadas
              Row(
                children: [
                  Icon(Icons.assignment_turned_in,
                      color: Colors.blue[800], size: 18),
                  SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      "Assinaturas: ${dados['assinaturas']}",
                      style: TextStyle(color: Colors.grey[800], fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),

              // Dias de atraso (se houver)
              if (dados['diasAtraso'] > 0)
                Row(
                  children: [
                    Icon(Icons.timer_off, color: Colors.redAccent, size: 18),
                    SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        "Dias de Atraso: ${dados['diasAtraso']}",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 5),

              // Alertas críticos (se houver)
              if (dados['alertas'] > 0)
                Row(
                  children: [
                    Icon(Icons.warning, color: Colors.redAccent, size: 18),
                    SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        "Alertas: ${dados['alertas']}",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Indicadores de Performance
  Widget _buildPerformanceIndicator() {
    var dados = dadosDepartamentos[departamentoSelecionado];
    return Card(
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Indicadores de Performance",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            SizedBox(height: 10),
            Divider(color: Colors.grey[300]),
            SizedBox(height: 10),
            Text(
              "Progresso: ${dados['progresso']}%",
              style: TextStyle(color: Colors.black),
            ),
            Text(
              "Assinaturas: ${dados['assinaturas']}",
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  // Seção de Feedbacks com modal
  Widget _buildFeedbackSection() {
    return Card(
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Feedback e Notas",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            SizedBox(height: 10),
            Divider(color: Colors.grey[300]),
            SizedBox(height: 10),
            if (feedbacks.isNotEmpty)
              Column(
                children: [
                  Text(
                    "${feedbacks.length} feedback(s) recebidos.",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.purple[900]),
                  ),
                  TextButton(
                    onPressed: () {
                      _mostrarFeedbacks();
                    },
                    child: Text("Ver Detalhes",
                        style: TextStyle(color: Colors.purple[900])),
                  )
                ],
              )
            else
              Text("Nenhum feedback disponível.",
                  style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
  }

  // Função para exibir modal de feedbacks
  void _mostrarFeedbacks() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Feedbacks Recebidos"),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: feedbacks.length,
              itemBuilder: (context, index) {
                var feedback = feedbacks[index];
                return ListTile(
                  title: Text(feedback['nome'],
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black)),
                  subtitle: Text(
                      "Nota: ${feedback['nota']}\nComentário: ${feedback['comentario']}",
                      style: TextStyle(color: Colors.black)),
                  leading: Icon(Icons.feedback, color: Colors.purple[900]),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Fechar"),
            ),
          ],
        );
      },
    );
  }

  // Seção de Alertas com modal de funcionários ausentes
  Widget _buildAlertSection() {
    return Card(
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Alertas e Notificações",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            SizedBox(height: 10),
            Divider(color: Colors.grey[300]),
            SizedBox(height: 10),
            if (funcionariosAusentes.isNotEmpty)
              Column(
                children: [
                  Text(
                    "${funcionariosAusentes.length} funcionários não completaram o treinamento.",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  TextButton(
                    onPressed: () {
                      _mostrarFuncionariosAusentes();
                    },
                    child: Text("Ver Detalhes",
                        style: TextStyle(color: Colors.purple[900])),
                  )
                ],
              )
            else
              Text("Nenhum alerta no momento.",
                  style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
  }

  // Função para exibir modal de funcionários ausentes
  void _mostrarFuncionariosAusentes() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Center(
            child: Text(
              "Funcionários Ausentes",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: funcionariosAusentes.length,
              itemBuilder: (context, index) {
                var funcionario = funcionariosAusentes[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning, color: Colors.red),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                funcionario['nome'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                overflow:
                                    TextOverflow.ellipsis, // Evita overflow
                              ),
                            ),
                          ],
                        ),
                        Divider(color: Colors.grey),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.book, color: Colors.grey[700]),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Treinamento: ${funcionario['treinamento']}",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black54),
                                overflow:
                                    TextOverflow.ellipsis, // Evita overflow
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.grey[700]),
                            SizedBox(width: 8),
                            Text(
                              "Data: ${funcionario['data']}",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black54),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time, color: Colors.grey[700]),
                            SizedBox(width: 8),
                            Text(
                              "Horário: ${funcionario['horario']}",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black54),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Divider(color: Colors.grey),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              _selecionarDataHorario(
                                  context, funcionario, index);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple[900],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              "Remandar",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Fechar",
                  style: TextStyle(
                    color: Colors.purple[900],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

// Função para selecionar nova data e horários de entrada e saída com calendário e relógio estilizados
  void _selecionarDataHorario(
      BuildContext context, Map<String, dynamic> funcionario, int index) {
    DateTime? selectedDate;
    TimeOfDay? selectedEntryTime;
    TimeOfDay? selectedExitTime;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            "Remandar Treinamento",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("Escolha a nova data",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Icon(Icons.calendar_today, color: Colors.purple[900]),
                onTap: () async {
                  DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2022),
                    lastDate: DateTime(2030),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          primaryColor: Colors.purple[900],
                          colorScheme: ColorScheme.light(
                              primary: const Color.fromARGB(255, 74, 20, 140)),
                          buttonTheme: ButtonThemeData(
                              textTheme: ButtonTextTheme.primary),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (date != null) {
                    setState(() {
                      selectedDate = date;
                    });
                  }
                },
              ),
              ListTile(
                title: Text("Horário de Entrada",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Icon(Icons.access_time, color: Colors.purple[900]),
                onTap: () async {
                  TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          primaryColor: Colors.purple[900],
                          timePickerTheme: TimePickerThemeData(
                            hourMinuteColor: Colors.purple[100],
                            dialHandColor: Colors.purple[900],
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (time != null) {
                    setState(() {
                      selectedEntryTime = time;
                    });
                  }
                },
              ),
              ListTile(
                title: Text("Horário de Saída",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Icon(Icons.exit_to_app, color: Colors.purple[900]),
                onTap: () async {
                  TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          primaryColor: Colors.purple[900],
                          timePickerTheme: TimePickerThemeData(
                            hourMinuteColor: Colors.purple[100],
                            dialHandColor: Colors.purple[900],
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (time != null) {
                    setState(() {
                      selectedExitTime = time;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancelar",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedDate != null &&
                    selectedEntryTime != null &&
                    selectedExitTime != null) {
                  setState(() {
                    funcionariosAusentes
                        .removeAt(index); // Remove o funcionário ausente
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Treinamento remandado para ${funcionario['nome']} no dia ${selectedDate!.toString().split(' ')[0]} das ${selectedEntryTime!.format(context)} às ${selectedExitTime!.format(context)}.",
                      ),
                    ),
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Por favor, escolha data e horários."),
                    ),
                  );
                }
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.purple[900]),
              child: Text(
                "Confirmar",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // Função para remandar treinamento e remover da lista
  void _remandarTreinamento(Map<String, dynamic> funcionario, int index) {
    setState(() {
      funcionariosAusentes.removeAt(index); // Remove o funcionário ausente
    });
    print(
        "Treinamento '${funcionario['treinamento']}' remandado para ${funcionario['nome']}.");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Treinamento remandado para ${funcionario['nome']}!"),
    ));
  }

  Future<void> _baixarRelatorio() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text("Desempenho - $departamentoSelecionado"),
        ),
      ),
    );

    final directory = await getExternalStorageDirectory();
    final file =
        File('${directory!.path}/relatorio_$departamentoSelecionado.pdf');
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Relatório baixado com sucesso!"),
    ));
  }

  void _aplicarFiltro() {
    print("Filtro aplicado para o departamento: $departamentoSelecionado");
  }
}
