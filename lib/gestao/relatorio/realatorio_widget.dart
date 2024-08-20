import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class RelatoriosWidget extends StatefulWidget {
  final List<Map<String, dynamic>> treinamentos;

  RelatoriosWidget({Key? key, required this.treinamentos}) : super(key: key);

  @override
  _RelatoriosWidgetState createState() => _RelatoriosWidgetState();
}

class _RelatoriosWidgetState extends State<RelatoriosWidget> {
  @override
  Widget build(BuildContext context) {
    int totalTreinamentos = widget.treinamentos.length;
    int totalFuncionarios = widget.treinamentos.map((t) => t['id_funcionario']).toSet().length;
    double mediaProgresso = widget.treinamentos.isNotEmpty
        ? widget.treinamentos.map((t) => t['progresso'] ?? 0).reduce((a, b) => a + b) / totalTreinamentos
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios de Desempenho'),
        backgroundColor: const Color(0xFFB751F6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informações gerais com estilo profissional
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: const LinearGradient(
                  colors: [Color(0xFFB751F6), Color(0xFFD47BFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total de Treinamentos',
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                      fontFamily: 'Readex Pro',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$totalTreinamentos',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Funcionários Treinados',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Readex Pro',
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '$totalFuncionarios',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Média de Progresso',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Readex Pro',
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${mediaProgresso.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Listagem de treinamentos com gráfico
            Expanded(
              child: ListView.builder(
                itemCount: widget.treinamentos.length,
                itemBuilder: (context, index) {
                  final treinamento = widget.treinamentos[index];
                  final progresso = treinamento['progresso'] ?? 0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Card(
                      color: const Color(0xFFD47BFF),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Treinamento: ${treinamento['descricao']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Progresso: $progresso%',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Funcionário ID: ${treinamento['id_funcionario']}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Gráfico de Barras simplificado
                            SizedBox(
                              height: 150,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: 100,
                                  titlesData: FlTitlesData(
                                    leftTitles: SideTitles(
                                      showTitles: true,
                                      interval: 20,
                                      getTitles: (value) => '${value.toInt()}%',
                                    ),
                                    bottomTitles: SideTitles(
                                      showTitles: true,
                                      getTitles: (value) => 'T${value.toInt() + 1}',
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barGroups: [
                                    BarChartGroupData(
                                      x: index,
                                      barRods: [
                                        BarChartRodData(
                                          y: progresso.toDouble(),
                                          colors: [Colors.yellowAccent],
                                          width: 20,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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
  }
}
