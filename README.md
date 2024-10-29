<h1 align="center">🚀 Sanofi Sync</h1>

<p align="center">
  <strong>Sanofi Sync</strong> é uma plataforma projetada para transformar a gestão de treinamentos, controle de horas, reservas de salas e de livros, e o acompanhamento de produtividade dos colaboradores na Medley. Esta solução moderna substitui métodos manuais e obsoletos, como planilhas em Excel e registros em papel, tornando os processos mais seguros, precisos e acessíveis.
</p>

---

## 🎉 Motivação e Desafios Enfrentados

Durante o desenvolvimento do Sanofi Sync, enfrentamos desafios que foram além do código. A Sanofi Medley, que até então geria treinamentos e reservas manualmente por meio de planilhas e registros físicos, nos desafiou a desenvolver uma solução digital robusta que eliminasse fraudes, aumentasse a confiabilidade e otimizasse o tempo dos gestores e colaboradores. Tivemos que desenvolver uma plataforma que fosse altamente segura, flexível e adaptável ao fluxo de trabalho da empresa, superando a limitação das ferramentas anteriores.

---

<h2 align="center">🎥 Nossa Apresentação</h2>

<p align="center">
  <img src="ppt.gif" alt="Sanofi Sync - Demonstração do Aplicativo" width="600"/>
</p>

---

<h2 align="center">🎥 Demonstração do Aplicativo</h2>

<p align="center">
  <img src="demo.gif" alt="Sanofi Sync - Demonstração do Aplicativo"/>
</p>

---

## 💡 Funcionalidades Destacadas

### 📲 Acesso e Cadastro Seguro
- **Login e Cadastro**: Diferencia funcionários e gestores, com controle de acesso seguro.
- **Esqueci Minha Senha**: Recuperação de senha simplificada.
- **Logout**: Saída rápida e segura do aplicativo.
- **Notificações**: Lembretes de treinamentos, reservas e prazos de devolução de livros.

### 🕓 Gestão de Ponto e Horas Trabalhadas
- **Registrar Ponto**: Registro de ponto via QR code, evitando fraudes e garantindo precisão.
- **Horas Trabalhadas e Controle Mensal**: Exibição de entradas, saídas e horas totalizadas.
- **Calendário com Controle de Horas**: Monitoramento da jornada de trabalho para melhor gerenciamento de tempo.

### 📅 Treinamentos e Assinaturas Digitais
- **Confirmação de Presença**: Treinamentos podem ser confirmados apenas no local e 5 minutos antes de começar, evitando fraudes.
- **Assinatura Digital**: Necessária para confirmar presença e para justificar ausência, que é enviada automaticamente ao gestor.
- **Controle de Tempo para Início**: Caso o colaborador tente confirmar presença antes do tempo permitido, o app mostra o tempo restante.
- **Gestão de Treinamentos**: Gestores podem cadastrar treinamentos, definindo departamentos, níveis de participação, horário, data e local.

### 📊 Dashboard e Feedback
- **Dashboard Completo**: Visualização de presença, assinaturas e treinamentos ativos.
- **Análise de Produtividade**: Dados de horas trabalhadas, tarefas concluídas, utilização de equipamentos e feedbacks.
- **Indicadores de Desempenho e Eficiência**: Relatórios detalhados de desempenho e cumprimento de treinamentos.

### 📚 Reserva de Livros e Controle de Devolução
- **Gestão de Livros**: Cadastro e status de disponibilidade de livros.
- **Reserva e Fila de Espera**: Sistema de reservas e fila, com controle de posição para quem assinou.
- **Controle de Atraso**: Notificações automáticas para livros com devolução pendente.
- **Informações Detalhadas**: Exibe assinatura e dias restantes para devolução, além de status de atraso.

### 🏢 Reserva de Salas e Gestão de Calendário
- **Calendário de Reserva de Salas**: Substituindo o Excel, agora com bloqueio para evitar que um mesmo usuário reserve mais de uma sala por semana.
- **Informações de Reserva**: Exibe detalhes de quem reservou, data e propósito da reserva.
- **Gerenciamento Seguro e Confiável**: Cada reserva é mantida em um calendário seguro, evitando perda de dados e conflitos de agendamento.

---

## 🛠️ Tecnologias Utilizadas

Para alcançar o desempenho e a escalabilidade desejada, utilizamos as seguintes tecnologias:

<p align="center">

| Tecnologia           | Descrição                                                        |
|----------------------|------------------------------------------------------------------|
| **Frontend**         | Flutter (Dart) – Interface moderna e responsiva                 |
| **Backend**          | Node.js e Express – Processamento rápido e eficiente            |
| **Banco de Dados**   | Firebase Firestore e PostgreSQL – Armazenamento seguro em tempo real |
| **CI/CD**            | GitHub Actions – Automatização de deploys                       |

</p>

---

## 📂 Estrutura do Projeto

A estrutura do Sanofi Sync foi organizada para escalabilidade e fácil manutenção:

```
SanofiSyncApp/
├── lib/                  # Código principal do aplicativo (Flutter)
│   ├── screens/          # Telas do aplicativo
│   ├── components/       # Componentes reutilizáveis
│   ├── models/           # Modelos de dados
│   └── services/         # Comunicação com o backend e APIs
├── server/               # Código backend (Node.js e Express)
│   ├── routes/           # Rotas da API
│   ├── controllers/      # Lógicas de negócios
│   └── models/           # Estrutura do banco de dados
└── README.md             # Documentação do projeto
```

---

## 🌟 Como Executar o Projeto

### Pré-requisitos

- **Node.js** e **npm**
- **Flutter** configurado em seu ambiente

### Passo a Passo

1. **Clone o Repositório**:
   ```bash
   git clone https://github.com/EvelynCleto/SanofiSyncApp.git
   cd SanofiSyncApp
   ```

2. **Instale as Dependências do Backend**:
   ```bash
   cd server
   npm install
   ```

3. **Instale as Dependências do Flutter**:
   ```bash
   cd ..
   flutter pub get
   ```

4. **Execute o Backend**:
   ```bash
   cd server
   npm start
   ```

5. **Execute o Aplicativo Flutter**:
   ```bash
   flutter run
   ```

---

## 📊 Planos de Expansão e Melhorias Futuras

Com a visão de continuar aprimorando o Sanofi Sync, já temos ideias para novas funcionalidades:

- **Base de Dados Expandida e Análise Histórica**: Relatórios de desempenho de longo prazo e métricas detalhadas.
- **Inteligência Artificial**: IA para análise de dados, personalização de treinamentos e recomendação de atividades.
- **Sistema de Notificações Avançado**: Lembretes para treinamentos, prazos de devolução de livros e reuniões futuras.
- **Expansão Multissetorial**: Adaptabilidade para atender a diferentes setores e unidades.

---

## 🤝 Contribuição

Quer contribuir? Adoraríamos ter você conosco! Siga o fluxo abaixo para contribuir:

1. Faça um Fork do projeto
2. Crie uma nova branch:
   ```bash
   git checkout -b minha-branch
   ```
3. Faça suas alterações e commit:
   ```bash
   git commit -m 'Minha contribuição'
   ```
4. Envie para o repositório remoto:
   ```bash
   git push origin minha-branch
   ```
5. Abra um Pull Request para revisão.

---

## 📬 Contato

Para mais informações sobre o Sanofi Sync ou para colaborações, entre em contato:

- **LinkedIn**: [Evelyn Cleto](https://www.linkedin.com/in/evelyncleto)
- **GitHub**: [EvelynCleto](https://github.com/EvelynCleto)

---

<h3 align="center"><strong>Sanofi Sync</strong> – Desenvolvido para simplificar e revolucionar a gestão na Medley, transformando desafios em soluções digitais seguras e eficientes.</h3>


