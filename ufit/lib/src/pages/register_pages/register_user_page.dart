import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ufit/src/pages/auth.pages/auth_service.dart';
import 'package:ufit/src/pages/main_page.dart';

class UserRegistrationData {
  String nome = '';
  String sobrenome = '';
  String email = '';
  String senha = '';
  String confirmarSenha = '';
  String cpf = '';
  String idade = '';
  String endereco = '';
  String genero = '';
  String objetivo = '';
  List<String> metas = [];
  String biotipo = '';
  String peso = '';
  String altura = '';
  String localTreino = '';
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int _currentStep = 0;
  final PageController _controller = PageController();
  final UserRegistrationData userData = UserRegistrationData();

  final List<GlobalKey<FormState>> _formKeys = List.generate(
    4,
    (_) => GlobalKey<FormState>(),
  );

  void register() async {
    try {
      await authService.value.createAccount(
        email: userData.email,
        password: userData.senha,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        print("Erro ao registrar: ${e.message}");
        // errorMessage = e.message ?? 'Erro desconhecido';
      });
    }
  }

  void _nextStep() {
    if (true) {
      setState(() {
        if (_currentStep < 3) {
          _currentStep++;
          _controller.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          );
        } else {
          register();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
          // Última etapa -> Enviar ou salvar os dados
        }
      });
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _controller.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro'), centerTitle: true),
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Step1UserData(formKey: _formKeys[0], userData: userData),
          Step2Goals(formKey: _formKeys[1], userData: userData),
          Step3BodyType(formKey: _formKeys[2], userData: userData),
          Step4Conditioning(formKey: _formKeys[3], userData: userData),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep > 0)
                TextButton.icon(
                  onPressed: _prevStep,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Voltar"),
                ),
              TextButton.icon(
                onPressed: _nextStep,
                icon: const Icon(Icons.arrow_forward),
                label: Text(_currentStep < 3 ? "Próximo" : "Concluir"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Step1UserData extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final UserRegistrationData userData;

  const Step1UserData({
    super.key,
    required this.formKey,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 47),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Informações Pessoais",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 27),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Nome'),
                  initialValue: userData.nome,
                  onChanged: (value) => userData.nome = value,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Campo obrigatório'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Sobrenome'),
                  initialValue: userData.sobrenome,
                  onChanged: (value) => userData.sobrenome = value,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Campo obrigatório'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  initialValue: userData.email,
                  onChanged: (value) => userData.email = value,
                  validator: (value) => value != null && value.contains('@')
                      ? null
                      : 'Email inválido',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Senha'),
                  onChanged: (value) => userData.senha = value,
                  validator: (value) => value != null && value.length >= 6
                      ? null
                      : 'Mínimo 6 caracteres',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar Senha',
                  ),
                  onChanged: (value) => userData.confirmarSenha = value,
                  validator: (value) => value != null && value == userData.senha
                      ? null
                      : 'Senhas não coincidem',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'CPF'),
                  initialValue: userData.cpf,
                  onChanged: (value) => userData.cpf = value,
                  validator: (value) => value == null || value.length != 11
                      ? 'CPF inválido'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Idade'),
                  initialValue: userData.idade,
                  onChanged: (value) => userData.idade = value,
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Campo obrigatório'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Endereço'),
                  initialValue: userData.endereco,
                  onChanged: (value) => userData.endereco = value,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Campo obrigatório'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Gênero'),
                  value: userData.genero.isNotEmpty ? userData.genero : null,
                  onChanged: (value) => userData.genero = value ?? '',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Selecione uma opção'
                      : null,
                  items: const [
                    DropdownMenuItem(
                      value: 'masculino',
                      child: Text('Masculino'),
                    ),
                    DropdownMenuItem(
                      value: 'feminino',
                      child: Text('Feminino'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Step2Goals extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final UserRegistrationData userData;

  const Step2Goals({super.key, required this.formKey, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 47),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Metas e Objetivos",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 27),
                CheckboxListTile(
                  title: const Text("Perder Peso"),
                  value: userData.metas.contains("perder_peso"),
                  onChanged: (value) {
                    if (value == true) {
                      userData.metas.add("perder_peso");
                    } else {
                      userData.metas.remove("perder_peso");
                    }
                  },
                ),
                CheckboxListTile(
                  title: const Text("Ganhar Massa Muscular"),
                  value: userData.metas.contains("ganhar_massa"),
                  onChanged: (value) {
                    if (value == true) {
                      userData.metas.add("ganhar_massa");
                    } else {
                      userData.metas.remove("ganhar_massa");
                    }
                  },
                ),
                CheckboxListTile(
                  title: const Text("Definição Muscular"),
                  value: userData.metas.contains("definicao"),
                  onChanged: (value) {
                    if (value == true) {
                      userData.metas.add("definicao");
                    } else {
                      userData.metas.remove("definicao");
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Objetivo Principal',
                  ),
                  value: userData.objetivo.isNotEmpty
                      ? userData.objetivo
                      : null,
                  onChanged: (value) => userData.objetivo = value ?? '',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Selecione uma opção'
                      : null,
                  items: const [
                    DropdownMenuItem(
                      value: 'emagrecer',
                      child: Text('Emagrecer'),
                    ),
                    DropdownMenuItem(
                      value: 'hipertrofia',
                      child: Text('Hipertrofia'),
                    ),
                    DropdownMenuItem(
                      value: 'condicionamento',
                      child: Text('Condicionamento Físico'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Step3BodyType extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final UserRegistrationData userData;

  const Step3BodyType({
    super.key,
    required this.formKey,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 47),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Biotipo Corporal",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 27),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Biotipo'),
                  value: userData.biotipo.isNotEmpty ? userData.biotipo : null,
                  onChanged: (value) => userData.biotipo = value ?? '',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Escolha um biotipo'
                      : null,
                  items: const [
                    DropdownMenuItem(
                      value: 'ectomorfo',
                      child: Text('Ectomorfo'),
                    ),
                    DropdownMenuItem(
                      value: 'endomorfo',
                      child: Text('Endomorfo'),
                    ),
                    DropdownMenuItem(
                      value: 'mesomorfo',
                      child: Text('Mesomorfo'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Peso (kg)'),
                  initialValue: userData.peso,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => userData.peso = value,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Informe o peso' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Altura (cm)'),
                  initialValue: userData.altura,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => userData.altura = value,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Informe a altura'
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Step4Conditioning extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final UserRegistrationData userData;

  const Step4Conditioning({
    super.key,
    required this.formKey,
    required this.userData,
  });

  @override
  State<Step4Conditioning> createState() => _Step4ConditioningState();
}

class _Step4ConditioningState extends State<Step4Conditioning> {
  bool showGymList = false;

  // Simulação de academias próximas, com distância em km
  final List<Map<String, dynamic>> academias = [
    {'nome': 'Academia Fit Plus', 'distancia': 1.2},
    {'nome': 'Academia Power Gym', 'distancia': 2.5},
    {'nome': 'Academia Elite Fitness', 'distancia': 3.8},
    {'nome': 'Academia Saúde Total', 'distancia': 5.0},
  ];

  String? academiaSelecionada;

  @override
  void initState() {
    super.initState();
    showGymList = widget.userData.localTreino == 'academia';
    academiaSelecionada = null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 47),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Condicionamento Físico",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 27),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Onde você pretende treinar?',
                  ),
                  value: widget.userData.localTreino.isNotEmpty
                      ? widget.userData.localTreino
                      : null,
                  onChanged: (value) {
                    setState(() {
                      widget.userData.localTreino = value ?? '';
                      showGymList = (value == 'academia');
                      if (!showGymList) {
                        academiaSelecionada = null;
                        widget.userData.objetivo =
                            ''; // opcional limpar campo relacionado se desejar
                      }
                    });
                  },
                  validator: (value) => value == null || value.isEmpty
                      ? 'Selecione uma opção'
                      : null,
                  items: const [
                    DropdownMenuItem(value: 'casa', child: Text('Em casa')),
                    DropdownMenuItem(
                      value: 'academia',
                      child: Text('Na academia'),
                    ),
                  ],
                ),
                if (showGymList) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Selecione a academia',
                    ),
                    value: academiaSelecionada,
                    onChanged: (value) {
                      setState(() {
                        academiaSelecionada = value;
                        widget.userData.objetivo = value ?? '';
                      });
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'Selecione uma academia'
                        : null,
                    items: academias
                        .map(
                          (academia) => DropdownMenuItem<String>(
                            value: academia['nome'],
                            child: Text(
                              '${academia['nome']} - ${academia['distancia'].toStringAsFixed(1)} km',
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
