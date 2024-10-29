import 'package:flutter/material.dart';
import '../../gestao/gestao/gestao_widget.dart';
import '../../home/treinamentos/treinamentos_widget.dart';
import '../../gestao/relatorio/realatorio_widget.dart';
import '../../login_cadastro/login/login_widget.dart'; // Certifique-se de que o caminho está correto

class FuncionarioHomeWidget extends StatefulWidget {
  final bool isFuncionario;
  final bool isGestor;

  const FuncionarioHomeWidget({
    Key? key,
    required this.isFuncionario,
    required this.isGestor,
  }) : super(key: key);

  @override
  _FuncionarioHomeWidgetState createState() => _FuncionarioHomeWidgetState();
}

class _FuncionarioHomeWidgetState extends State<FuncionarioHomeWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Inicializando o TabController com 3 abas
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    // Dispose do TabController quando a tela for fechada
    _tabController.dispose();
    super.dispose();
  }

  void _logout(BuildContext context) {
    // Implementa o logout e redireciona para a tela de login
    Navigator.of(context).pushReplacementNamed('login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treinamento - Navegação Restrita'),
        backgroundColor: Colors.purple,
        automaticallyImplyLeading: false, // Remove o ícone de navegação
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _logout(context), // Função de logout
          ),
        ],
        bottom: TabBar(
          controller: _tabController, // Vinculando o TabController
          tabs: const [
            Tab(text: 'Cadastro de Treinamento'), // Primeira aba
            Tab(text: 'Relatórios/Dashboard'), // Segunda aba
            Tab(text: 'Treinamentos Cadastrados'), // Terceira aba
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController, // Vinculando o TabController ao TabBarView
        children: [
          // Primeira aba: Cadastro de Treinamentos
          GestaoWidget(),

          // Segunda aba: Dashboard/Relatórios
          RelatoriosWidget(),

          // Terceira aba: Treinamentos Cadastrados
          // Vamos adicionar uma modificação visual diretamente no Widget
          Stack(
            children: [
              TreinamentosWidget(), // O widget de treinamentos original

              // Sobrepomos um container para esconder os elementos indesejados
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 60, // Altura da barra inferior a ser escondida
                child: Container(
                  color: const Color(0xFFBB4CFF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
