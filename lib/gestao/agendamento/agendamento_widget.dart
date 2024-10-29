import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({Key? key}) : super(key: key);

  @override
  _DashboardWidgetState createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  String selectedDepartment = 'Todos os Departamentos';
  String selectedPeriod = 'Últimos 7 dias';
  int _selectedIndex = 0;
  String selectedTheme = 'Claro';
  bool notificationsEnabled = true;
  bool showProductivity = false;
  bool showSafety = false;
  bool showWellbeing = false;
  bool showPerformance = false;

  final List<String> departments = [
    'Todos os Departamentos',
    'Produção',
    'Qualidade',
    'Manutenção',
    'Segurança',
  ];

  final List<String> periods = [
    'Últimos 7 dias',
    'Último Mês',
    'Último Trimestre'
  ];

  // Dados fictícios para cada departamento e período, TODOS OS DADOS COMPLETOS
  Map<String, Map<String, dynamic>> data = {
    'Todos os Departamentos': {
      'Últimos 7 dias': {
        'hoursWorked': '120h',
        'production': '5000 unidades',
        'accidents': '2',
        'chartData': [
          FlSpot(0, 3),
          FlSpot(1, 1),
          FlSpot(2, 4),
          FlSpot(3, 3),
          FlSpot(4, 5)
        ],
        'tasksCompleted': '85%',
        'equipmentUtilization': '70%',
        'safetyIncidents': '2',
        'trainingCompliance': '95%',
      },
      'Último Mês': {
        'hoursWorked': '400h',
        'production': '20000 unidades',
        'accidents': '5',
        'chartData': [
          FlSpot(0, 6),
          FlSpot(1, 7),
          FlSpot(2, 8),
          FlSpot(3, 9),
          FlSpot(4, 10)
        ],
        'tasksCompleted': '80%',
        'equipmentUtilization': '75%',
        'safetyIncidents': '5',
        'trainingCompliance': '98%',
      },
      'Último Trimestre': {
        'hoursWorked': '1200h',
        'production': '50000 unidades',
        'accidents': '12',
        'chartData': [
          FlSpot(0, 10),
          FlSpot(1, 12),
          FlSpot(2, 14),
          FlSpot(3, 16),
          FlSpot(4, 18)
        ],
        'tasksCompleted': '78%',
        'equipmentUtilization': '80%',
        'safetyIncidents': '12',
        'trainingCompliance': '97%',
      },
    },
    'Produção': {
      'Últimos 7 dias': {
        'hoursWorked': '150h',
        'production': '7000 unidades',
        'accidents': '1',
        'chartData': [
          FlSpot(0, 5),
          FlSpot(1, 4),
          FlSpot(2, 7),
          FlSpot(3, 8),
          FlSpot(4, 9)
        ],
        'tasksCompleted': '90%',
        'equipmentUtilization': '78%',
        'safetyIncidents': '1',
        'trainingCompliance': '92%',
      },
      'Último Mês': {
        'hoursWorked': '500h',
        'production': '30000 unidades',
        'accidents': '4',
        'chartData': [
          FlSpot(0, 7),
          FlSpot(1, 6),
          FlSpot(2, 9),
          FlSpot(3, 11),
          FlSpot(4, 13)
        ],
        'tasksCompleted': '85%',
        'equipmentUtilization': '80%',
        'safetyIncidents': '4',
        'trainingCompliance': '94%',
      },
      'Último Trimestre': {
        'hoursWorked': '1400h',
        'production': '60000 unidades',
        'accidents': '10',
        'chartData': [
          FlSpot(0, 12),
          FlSpot(1, 15),
          FlSpot(2, 17),
          FlSpot(3, 19),
          FlSpot(4, 20)
        ],
        'tasksCompleted': '82%',
        'equipmentUtilization': '83%',
        'safetyIncidents': '10',
        'trainingCompliance': '96%',
      },
    },
    'Qualidade': {
      'Últimos 7 dias': {
        'hoursWorked': '100h',
        'production': '4500 unidades',
        'accidents': '0',
        'chartData': [
          FlSpot(0, 2),
          FlSpot(1, 2),
          FlSpot(2, 3),
          FlSpot(3, 2),
          FlSpot(4, 4)
        ],
        'tasksCompleted': '75%',
        'equipmentUtilization': '60%',
        'safetyIncidents': '0',
        'trainingCompliance': '88%',
      },
      'Último Mês': {
        'hoursWorked': '350h',
        'production': '16000 unidades',
        'accidents': '2',
        'chartData': [
          FlSpot(0, 5),
          FlSpot(1, 4),
          FlSpot(2, 6),
          FlSpot(3, 5),
          FlSpot(4, 8)
        ],
        'tasksCompleted': '78%',
        'equipmentUtilization': '65%',
        'safetyIncidents': '2',
        'trainingCompliance': '90%',
      },
      'Último Trimestre': {
        'hoursWorked': '900h',
        'production': '30000 unidades',
        'accidents': '5',
        'chartData': [
          FlSpot(0, 9),
          FlSpot(1, 8),
          FlSpot(2, 10),
          FlSpot(3, 11),
          FlSpot(4, 12)
        ],
        'tasksCompleted': '80%',
        'equipmentUtilization': '68%',
        'safetyIncidents': '5',
        'trainingCompliance': '93%',
      },
    },
    'Manutenção': {
      'Últimos 7 dias': {
        'hoursWorked': '130h',
        'production': '5000 unidades',
        'accidents': '3',
        'chartData': [
          FlSpot(0, 4),
          FlSpot(1, 5),
          FlSpot(2, 4),
          FlSpot(3, 5),
          FlSpot(4, 6)
        ],
        'tasksCompleted': '65%',
        'equipmentUtilization': '72%',
        'safetyIncidents': '3',
        'trainingCompliance': '89%',
      },
      'Último Mês': {
        'hoursWorked': '450h',
        'production': '18000 unidades',
        'accidents': '6',
        'chartData': [
          FlSpot(0, 6),
          FlSpot(1, 7),
          FlSpot(2, 5),
          FlSpot(3, 8),
          FlSpot(4, 9)
        ],
        'tasksCompleted': '70%',
        'equipmentUtilization': '75%',
        'safetyIncidents': '6',
        'trainingCompliance': '90%',
      },
      'Último Trimestre': {
        'hoursWorked': '1100h',
        'production': '45000 unidades',
        'accidents': '9',
        'chartData': [
          FlSpot(0, 10),
          FlSpot(1, 11),
          FlSpot(2, 12),
          FlSpot(3, 13),
          FlSpot(4, 15)
        ],
        'tasksCompleted': '72%',
        'equipmentUtilization': '78%',
        'safetyIncidents': '9',
        'trainingCompliance': '92%',
      },
    },
    'Segurança': {
      'Últimos 7 dias': {
        'hoursWorked': '160h',
        'production': '8000 unidades',
        'accidents': '0',
        'chartData': [
          FlSpot(0, 5),
          FlSpot(1, 3),
          FlSpot(2, 5),
          FlSpot(3, 4),
          FlSpot(4, 6)
        ],
        'tasksCompleted': '85%',
        'equipmentUtilization': '80%',
        'safetyIncidents': '0',
        'trainingCompliance': '100%',
      },
      'Último Mês': {
        'hoursWorked': '480h',
        'production': '24000 unidades',
        'accidents': '0',
        'chartData': [
          FlSpot(0, 8),
          FlSpot(1, 9),
          FlSpot(2, 8),
          FlSpot(3, 10),
          FlSpot(4, 11)
        ],
        'tasksCompleted': '90%',
        'equipmentUtilization': '85%',
        'safetyIncidents': '0',
        'trainingCompliance': '100%',
      },
      'Último Trimestre': {
        'hoursWorked': '1400h',
        'production': '50000 unidades',
        'accidents': '0',
        'chartData': [
          FlSpot(0, 13),
          FlSpot(1, 14),
          FlSpot(2, 15),
          FlSpot(3, 16),
          FlSpot(4, 18)
        ],
        'tasksCompleted': '92%',
        'equipmentUtilization': '88%',
        'safetyIncidents': '0',
        'trainingCompliance': '100%',
      },
    },
  };

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void updateDepartment(String? value) {
    setState(() {
      selectedDepartment = value!;
    });
  }

  void updatePeriod(String? value) {
    setState(() {
      selectedPeriod = value!;
    });
  }

  Widget buildDropdownButton({
    required String value,
    required ValueChanged<String?>? onChanged,
    required List<String> items,
  }) {
    return DropdownButton<String>(
      value: value,
      onChanged: onChanged,
      isExpanded: true,
      style: const TextStyle(color: Colors.black, fontSize: 16),
      underline: Container(
        height: 2,
        color: const Color(0xFF6A0DAD),
      ),
      items: items.map<DropdownMenuItem<String>>((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(item),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6A0DAD),
      ),
      body: _selectedIndex == 0
          ? buildDashboardContent()
          : (_selectedIndex == 1
              ? buildNewReportsContent() // Implementação do novo layout para relatórios
              : buildSettingsContent()),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Relatórios'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Configurações'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF6A0DAD),
        unselectedItemColor: Colors.grey,
        onTap: onItemTapped,
      ),
    );
  }

  Widget buildNewReportsContent() {
    var departmentData = data[selectedDepartment]?[selectedPeriod] ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seção de Produtividade e Eficiência
          buildSectionWithChart(
            title: 'Produtividade e Eficiência',
            chart: buildLineChart(),
            description:
                'A linha roxa representa a evolução da produção ao longo do tempo.',
            details: buildProductivitySection(departmentData),
          ),
          const SizedBox(height: 20),

          // Seção de Segurança e Conformidade
          buildSectionWithChart(
            title: 'Segurança e Conformidade',
            chart: buildBarChart(),
            description:
                'A barra roxa indica o uso de EPIs e a azul a conformidade com os treinamentos.',
            details: buildSafetySection(departmentData),
          ),
          const SizedBox(height: 20),

          // Seção de Bem-estar e Satisfação
          buildSectionWithChart(
            title: 'Bem-estar e Satisfação',
            chart: buildPieChart(),
            description:
                'Cores do gráfico:\n- Roxo (40%): Satisfação geral\n- Azul (30%): Nível de bem-estar\n- Verde (20%): Segurança percebida\n- Laranja (10%): Engajamento dos funcionários',
            details: buildWellbeingSection(departmentData),
          ),
          const SizedBox(height: 30),

          // Botão de exportar relatório
          buildReportExportButton(),
        ],
      ),
    );
  }

  Widget buildDashboardContent() {
    var departmentData = data[selectedDepartment]![selectedPeriod];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildDepartmentSelector(),
          const SizedBox(height: 20),
          buildMetricsOverview(departmentData),
          const SizedBox(height: 20),
          buildDetailedCharts(departmentData['chartData']),
          const SizedBox(height: 20),
          buildSafetyMetrics(departmentData),
          const SizedBox(height: 20),
          buildTrainingCompliance(departmentData),
        ],
      ),
    );
  }

  Widget buildDepartmentSelector() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF6A0DAD), width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: buildDropdownButton(
              value: selectedDepartment,
              onChanged: updateDepartment,
              items: departments,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF6A0DAD), width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: buildDropdownButton(
              value: selectedPeriod,
              onChanged: updatePeriod,
              items: periods,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildMetricsOverview(Map<String, dynamic> departmentData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Produtividade e Eficiência',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: buildMetricCard('Horas Trabalhadas',
                  departmentData['hoursWorked'], Icons.access_time),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: buildMetricCard(
                  'Produção', departmentData['production'], Icons.factory),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: buildMetricCard('Tarefas Concluídas',
                  departmentData['tasksCompleted'], Icons.check_circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: buildMetricCard('Utilização de Equipamentos',
                  departmentData['equipmentUtilization'], Icons.settings),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildSafetyMetrics(Map<String, dynamic> departmentData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Segurança e Conformidade',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: buildMetricCard('Ocorrências de Acidentes',
                  departmentData['safetyIncidents'], Icons.warning),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: buildMetricCard('Uso de EPI', '100%', Icons.security),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildTrainingCompliance(Map<String, dynamic> departmentData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Conformidade com Treinamentos',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: buildMetricCard('Treinamentos Concluídos',
                  departmentData['trainingCompliance'], Icons.school),
            ),
          ],
        ),
      ],
    );
  }

  // Exemplo de cartão de métricas refinado
  Widget buildMetricCard(String title, String value, IconData icon) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.grey.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(icon, size: 36, color: const Color(0xFF5A1DAD)),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5A1DAD),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDetailedCharts(List<FlSpot> chartData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gráficos Detalhados',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(show: true),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: chartData,
                  isCurved: true,
                  colors: [Colors.blue],
                  barWidth: 4,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                      show: true, colors: [Colors.blue.withOpacity(0.3)]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

// Gráfico de barras com legenda de cores
  Widget buildBarChart() {
    return BarChart(
      BarChartData(
        barGroups: [
          BarChartGroupData(x: 0, barRods: [
            BarChartRodData(y: 5, colors: [const Color(0xFF5A1DAD)]) // EPI
          ]),
          BarChartGroupData(x: 1, barRods: [
            BarChartRodData(y: 7, colors: [Colors.blue]) // Conformidade
          ]),
        ],
      ),
    );
  }

  Widget buildPieChart() {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: 40,
            color: const Color(0xFF5A1DAD),
            title: '40%',
          ),
          PieChartSectionData(
            value: 30,
            color: Colors.blue,
            title: '30%',
          ),
          PieChartSectionData(
            value: 20,
            color: Colors.green,
            title: '20%',
          ),
          PieChartSectionData(
            value: 10,
            color: Colors.orange,
            title: '10%',
          ),
        ],
      ),
    );
  }

  // Função para construir cartões de métricas
  Widget buildTopCards(Map<String, dynamic> departmentData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: buildMetricCard(
            'Produção',
            departmentData['production'],
            Icons.factory,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: buildMetricCard(
            'Tarefas Concluídas',
            departmentData['tasksCompleted'],
            Icons.check_circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: buildMetricCard(
            'Horas Trabalhadas',
            departmentData['hoursWorked'],
            Icons.access_time,
          ),
        ),
      ],
    );
  }

// Função para criar um título de seção elegante
  Widget buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF6A0DAD),
      ),
    );
  }

// Função que cria seções expansíveis para organização
  Widget buildExpandableSection(
      {required String title, required Widget content}) {
    return ExpansionTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4A148C),
        ),
      ),
      children: [content],
    );
  }

  // Design melhorado para a seção de segurança
  Widget buildSafetySection(Map<String, dynamic> departmentData) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildInfoRow(
            label: 'Incidentes de Segurança',
            value: '${departmentData['safetyIncidents']}',
            icon: Icons.warning_amber_rounded,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 8),
          buildInfoRow(
            label: 'Uso de Equipamentos de Proteção',
            value: '${departmentData['equipmentUtilization']}%',
            icon: Icons.security,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

// Design melhorado para a seção de bem-estar
  Widget buildWellbeingSection(Map<String, dynamic> departmentData) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildInfoRow(
            label: 'Satisfação dos Funcionários',
            value: '${departmentData['trainingCompliance']}%',
            icon: Icons.sentiment_satisfied_alt,
            color: const Color(0xFF5A1DAD),
          ),
          const SizedBox(height: 8),
          buildInfoRow(
            label: 'Turnover',
            value: '${departmentData['turnover'] ?? 'N/A'}',
            icon: Icons.trending_down,
            color: const Color(0xFF6A0DAD),
          ),
        ],
      ),
    );
  }

// Função auxiliar para construir as linhas de informação com ícone e design aprimorado
  Widget buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget buildRegulationComplianceSection(Map<String, dynamic> departmentData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Conformidade com Regulamentações',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: buildMetricCard('Certificações Concluídas',
                  departmentData['certifications'] ?? 'N/A', Icons.verified),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: buildMetricCard('Compliance Treinamentos',
                  departmentData['trainingCompliance'], Icons.library_books),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildPerformanceSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('KPIs: 85%', style: TextStyle(fontSize: 16)),
          Text('Tempo de Inatividade: 5%', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget buildPerformanceMonitoringSection(
      Map<String, dynamic> departmentData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Monitoramento de Performance',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: buildMetricCard(
                  'KPIs', departmentData['kpis'] ?? 'N/A', Icons.bar_chart),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: buildMetricCard('Tempo de Inatividade',
                  departmentData['downtime'] ?? 'N/A', Icons.power_off),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: buildMetricCard('Eficiência Operacional (OEE)',
                  departmentData['OEE'] ?? 'N/A', Icons.speed),
            ),
          ],
        ),
      ],
    );
  }

  // Função que cria os cards sempre abertos, sem comportamento de expansão
  Widget buildSectionWithChart({
    required String title,
    required Widget chart,
    required String description,
    required Widget details,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título da seção
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5A1DAD),
              ),
            ),
            const SizedBox(height: 10),

            // Gráfico
            Container(
              height: 200,
              child: chart,
            ),
            const SizedBox(height: 10),

            // Explicação estilizada sobre as cores do gráfico
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 10),

            // Detalhes sobre as métricas
            details,
          ],
        ),
      ),
    );
  }
  // Seções de detalhesd

// Design melhorado para a seção de produtividade
  Widget buildProductivitySection(Map<String, dynamic> departmentData) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildInfoRow(
            label: 'Horas Trabalhadas',
            value: '${departmentData['hoursWorked']}',
            icon: Icons.access_time,
            color: Colors.blueAccent,
          ),
          const SizedBox(height: 8),
          buildInfoRow(
            label: 'Produção',
            value: '${departmentData['production']} ',
            icon: Icons.factory_rounded,
            color: Colors.orangeAccent,
          ),
          const SizedBox(height: 8),
          buildInfoRow(
            label: 'Eficiência',
            value: '${departmentData['tasksCompleted']}%',
            icon: Icons.check_circle_outline,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  // Exemplo de gráfico de linhas com cores explicativas
  Widget buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, 1),
              FlSpot(1, 3),
              FlSpot(2, 2),
              FlSpot(3, 5),
              FlSpot(4, 3),
            ],
            isCurved: true,
            colors: [const Color(0xFF5A1DAD)], // Cor da linha roxa
            barWidth: 4,
            belowBarData: BarAreaData(
              show: true,
              colors: [const Color(0xFF5A1DAD).withOpacity(0.3)],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLineChartSection(List<FlSpot> lineChartData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Evolução da Produção',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(show: true),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: lineChartData,
                  isCurved: true,
                  colors: [Colors.blue],
                  barWidth: 4,
                  belowBarData: BarAreaData(
                      show: true, colors: [Colors.blue.withOpacity(0.3)]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildBarChartSection(Map<String, dynamic> departmentData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Produção por Departamento',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: BarChart(
            BarChartData(
              barGroups: [
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(y: 8.0, colors: [Colors.purple])
                  ],
                ),
                BarChartGroupData(
                  x: 2,
                  barRods: [
                    BarChartRodData(y: 10.0, colors: [Colors.purple])
                  ],
                ),
                BarChartGroupData(
                  x: 3,
                  barRods: [
                    BarChartRodData(y: 12.0, colors: [Colors.purple])
                  ],
                ),
              ],
              borderData: FlBorderData(show: true),
              titlesData: FlTitlesData(show: true),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPieChartSection(Map<String, dynamic> departmentData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Distribuição de Incidentes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: 40,
                  color: Colors.blue,
                  title: '40%',
                ),
                PieChartSectionData(
                  value: 30,
                  color: Colors.orange,
                  title: '30%',
                ),
                PieChartSectionData(
                  value: 20,
                  color: Colors.red,
                  title: '20%',
                ),
                PieChartSectionData(
                  value: 10,
                  color: Colors.purple,
                  title: '10%',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildReportExportButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          Fluttertoast.showToast(
            msg: "Relatório Exportado com Sucesso!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: const Color(0xFF5A1DAD),
            textColor: Colors.white,
          );
        },
        icon: const Icon(Icons.file_download, size: 28, color: Colors.white),
        label: const Text('Exportar Relatório'),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFF5A1DAD),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
  ///////////////// aquiiiiiiiii

  Widget buildSettingsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configurações do Dashboard',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6A0DAD),
            ),
          ),
          const SizedBox(height: 24),

          // Seção: Produtividade e Eficiência
          buildSectionTitle('Produtividade e Eficiência'),
          const SizedBox(height: 10),
          buildSettingTile(
            icon: Icons.access_time,
            title: 'Horas Trabalhadas por Turno',
            subtitle: 'Configurações de horas trabalhadas.',
            onTap: () => openHoursWorkedModal(context),
          ),
          const SizedBox(height: 16),
          buildSettingTile(
            icon: Icons.factory,
            title: 'Produção por Funcionário',
            subtitle: 'Configurações de produção por colaborador.',
            onTap: () => openProductionModal(context),
          ),
          const SizedBox(height: 16),
          buildSettingTile(
            icon: Icons.build,
            title: 'Utilização de Equipamentos',
            subtitle: 'Percentual de utilização de máquinas.',
            onTap: () => openEquipmentUtilizationModal(context),
          ),
          const SizedBox(height: 16),
          buildSettingTile(
            icon: Icons.check_circle_outline,
            title: 'Tarefas Concluídas vs Planejadas',
            subtitle: 'Eficiência de tarefas.',
            onTap: () => openTaskCompletionModal(context),
          ),
          const SizedBox(height: 30),

          // Seção: Segurança e Conformidade
          buildSectionTitle('Segurança e Conformidade'),
          const SizedBox(height: 10),
          buildSettingTile(
            icon: Icons.warning_amber_rounded,
            title: 'Ocorrências de Acidentes',
            subtitle: 'Registros de incidentes.',
            onTap: () => openAccidentsModal(context),
          ),
          const SizedBox(height: 16),
          buildSettingTile(
            icon: Icons.security,
            title: 'Uso de Equipamentos de Proteção (EPI)',
            subtitle: 'Percentual de conformidade.',
            onTap: () => openEpiUsageModal(context),
          ),
          const SizedBox(height: 16),
          buildSettingTile(
            icon: Icons.school,
            title: 'Treinamentos de Segurança',
            subtitle: 'Configurações de treinamentos de segurança.',
            onTap: () => openSafetyTrainingModal(context),
          ),
          const SizedBox(height: 30),

          // Botão para salvar preferências gerais
          Center(
            child: ElevatedButton(
              onPressed: _savePreferences,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: const Color(0xFF6A0DAD),
              ),
              child: const Text(
                'Salvar Preferências',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  } // Função para abrir modal de Tarefas Concluídas vs Planejadas

  void openTaskCompletionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Container(
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configurações de Tarefas Concluídas vs Planejadas',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A0DAD),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Defina a eficiência esperada (%):'),
                Slider(
                  value: 85.0, // valor inicial (exemplo)
                  min: 50.0,
                  max: 100.0,
                  divisions: 10,
                  label: '85%',
                  onChanged: (value) {
                    setState(() {
                      // Atualizar eficiência
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Salvar configuração de tarefas
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: const Color(0xFF6A0DAD),
                  ),
                  child: const Text(
                    'Salvar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  void openAccidentsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Container(
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configurações de Ocorrências de Acidentes',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A0DAD),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Defina o limite de acidentes por período:'),
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Limite de Acidentes',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    // Atualizar limite de acidentes
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Salvar configuração de acidentes
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: const Color(0xFF6A0DAD),
                  ),
                  child: const Text(
                    'Salvar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  void openEpiUsageModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Container(
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configurações de Uso de EPIs',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A0DAD),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Defina o percentual de uso de EPIs esperado:'),
                Slider(
                  value: 90.0, // valor inicial (exemplo)
                  min: 50.0,
                  max: 100.0,
                  divisions: 10,
                  label: '90%',
                  onChanged: (value) {
                    setState(() {
                      // Atualizar uso de EPI
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Salvar configuração de uso de EPIs
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: const Color(0xFF6A0DAD),
                  ),
                  child: const Text(
                    'Salvar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  void openSafetyTrainingModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Container(
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configurações de Treinamentos de Segurança',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A0DAD),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Defina a frequência de treinamentos (dias):'),
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Frequência de Treinamentos',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    // Atualizar frequência de treinamentos
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Salvar configuração de treinamentos
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: const Color(0xFF6A0DAD),
                  ),
                  child: const Text(
                    'Salvar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

// Função para abrir modal de Utilização de Equipamentos
  void openEquipmentUtilizationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Container(
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configurações de Utilização de Equipamentos',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A0DAD),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Defina a taxa de utilização ideal (%):'),
                Slider(
                  value: 80.0, // valor inicial (exemplo)
                  min: 50.0,
                  max: 100.0,
                  divisions: 10,
                  label: '80%',
                  onChanged: (value) {
                    setState(() {
                      // Atualizar valor de utilização
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Salvar configuração de utilização
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: const Color(0xFF6A0DAD),
                  ),
                  child: const Text(
                    'Salvar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  // Função para abrir modal de Horas Trabalhadas por Turno
  void openHoursWorkedModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Container(
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configurações de Horas Trabalhadas',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A0DAD),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Defina a quantidade de horas por turno:'),
                Slider(
                  value: 8.0, // valor inicial (exemplo)
                  min: 4.0,
                  max: 12.0,
                  divisions: 8,
                  label: '8h',
                  onChanged: (value) {
                    setState(() {
                      // Atualizar valor de horas
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Salvar configuração de horas
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: const Color(0xFF6A0DAD),
                  ),
                  child: const Text(
                    'Salvar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

// Função para abrir modal de Produção por Funcionário
  void openProductionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Container(
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configurações de Produção por Funcionário',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A0DAD),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Defina a meta de produção diária (unidades):'),
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Meta de Produção',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    // Atualizar meta de produção
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Salvar configuração de produção
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: const Color(0xFF6A0DAD),
                  ),
                  child: const Text(
                    'Salvar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  // Função para criar um tile de configuração elegante
  Widget buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Function onTap,
  }) {
    return GestureDetector(
      onTap: () {
        // Ao clicar no card, abrir modal bonito e minimalista
        openModal(context, title);
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFF6A0DAD), size: 28),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
          trailing: const Icon(Icons.chevron_right, color: Color(0xFF6A0DAD)),
        ),
      ),
    );
  }

  void openModal(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A0DAD),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Aqui estão os detalhes sobre a métrica selecionada. Informações adicionais podem ser exibidas aqui.',
                  style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: const Color(0xFF6A0DAD),
                  ),
                  child: const Text(
                    'Fechar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

// Função para salvar as preferências
  void _savePreferences() {
    Fluttertoast.showToast(
      msg: "Preferências salvas com sucesso!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  void _showHoursWorkedDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Horas Trabalhadas por Turno'),
          content:
              const Text('Aqui estão os detalhes das horas trabalhadas...'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}
