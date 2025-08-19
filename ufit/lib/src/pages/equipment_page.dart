import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Equipamento {
  final String nome;
  final String categoria;

  Equipamento({required this.nome, required this.categoria});

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'categoria': categoria,
    };
  }

  factory Equipamento.fromMap(Map<String, dynamic> map) {
    return Equipamento(
      nome: map['nome'],
      categoria: map['categoria'],
    );
  }

  static String encodeList(List<Equipamento> equipamentos) {
    return jsonEncode(equipamentos.map((e) => e.toMap()).toList());
  }

  static List<Equipamento> decodeList(String encoded) {
    final List<dynamic> decoded = jsonDecode(encoded);
    return decoded.map((item) => Equipamento.fromMap(item)).toList();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Equipamento &&
        other.nome == nome &&
        other.categoria == categoria;
  }

  @override
  int get hashCode => nome.hashCode ^ categoria.hashCode;
}

class EquipmentPage extends StatefulWidget {
  const EquipmentPage({Key? key}) : super(key: key);

  @override
  State<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends State<EquipmentPage> {
  final List<Equipamento> _todosEquipamentos = [];
  final List<Equipamento> _selecionados = [];

  final TextEditingController _nomeController = TextEditingController();
  String _categoriaSelecionada = 'Cardio';

  final List<String> _categorias = ['Cardio', 'Força', 'Funcional', 'Mobilidade'];

  static const String _storageKey = 'equipamentos_salvos';

  @override
  void initState() {
    super.initState();
    _carregarEquipamentosSalvos();
  }

  Future<void> _carregarEquipamentosSalvos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dados = prefs.getString(_storageKey);

    if (dados != null) {
      final equipamentos = Equipamento.decodeList(dados);
      setState(() {
        _todosEquipamentos.addAll(equipamentos);
      });
    }
  }

  Future<void> _salvarEquipamentos() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = Equipamento.encodeList(_todosEquipamentos);
    await prefs.setString(_storageKey, encoded);
  }

  void _adicionarEquipamento() {
    final nome = _nomeController.text.trim();
    if (nome.isEmpty) return;

    final novoEquipamento = Equipamento(
      nome: nome,
      categoria: _categoriaSelecionada,
    );

    if (!_todosEquipamentos.contains(novoEquipamento)) {
      setState(() {
        _todosEquipamentos.add(novoEquipamento);
        _nomeController.clear();
      });

      _salvarEquipamentos();
    }
  }

  void _alternarSelecao(Equipamento equipamento) {
    setState(() {
      if (_selecionados.contains(equipamento)) {
        _selecionados.remove(equipamento);
      } else {
        _selecionados.add(equipamento);
      }
    });
  }

  void _removerEquipamento(Equipamento equipamento) {
    setState(() {
      _todosEquipamentos.remove(equipamento);
      _selecionados.remove(equipamento);
    });

    _salvarEquipamentos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Equipamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, _selecionados);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do equipamento',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _categoriaSelecionada,
                  onChanged: (String? novaCategoria) {
                    if (novaCategoria != null) {
                      setState(() {
                        _categoriaSelecionada = novaCategoria;
                      });
                    }
                  },
                  items: _categorias
                      .map((cat) => DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  ))
                      .toList(),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _adicionarEquipamento,
                )
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            Expanded(
              child: _todosEquipamentos.isEmpty
                  ? const Center(child: Text('Nenhum equipamento adicionado.'))
                  : ListView.builder(
                itemCount: _todosEquipamentos.length,
                itemBuilder: (context, index) {
                  final equipamento = _todosEquipamentos[index];
                  final selecionado = _selecionados.contains(equipamento);

                  return ListTile(
                    title: Text(equipamento.nome),
                    subtitle: Text('Categoria: ${equipamento.categoria}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            selecionado ? Icons.check_box : Icons.check_box_outline_blank,
                            color: selecionado ? Colors.blue : null,
                          ),
                          onPressed: () => _alternarSelecao(equipamento),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removerEquipamento(equipamento),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _selecionados);
              },
              child: const Text('Salvar e Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}
