import 'package:flutter/material.dart';
import 'equipment_page.dart';

class CreateTrainingPage extends StatefulWidget {
  final List<Equipamento> equipamentosSelecionados;

  const CreateTrainingPage({
    super.key,
    required this.equipamentosSelecionados,
  });

  @override
  State<CreateTrainingPage> createState() => _CreateTrainingPageState();
}

class _CreateTrainingPageState extends State<CreateTrainingPage> {
  String _localTreino = 'CASA';
  String _tipoTreino = 'FORÇA';
  int _duracao = 30;

  final List<String> _areasSelecionadas = [];
  List<Equipamento> _equipamentos = [];

  final List<String> _locais = ['CASA', 'ACADEMIA'];
  final List<String> _tiposTreino = ['FORÇA', 'CARDIO', 'HIPERTROFIA', 'FUNCIONAL'];
  final List<String> _areas = ['Superiores', 'Inferiores', 'Abs'];
  final List<int> _duracoes = [5, 10, 15, 20, 30, 40, 60];

  @override
  void initState() {
    super.initState();
    _equipamentos = List.from(widget.equipamentosSelecionados);
  }

  Future<void> _selecionarEquipamentos() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EquipmentPage(),
      ),
    );

    if (resultado != null && resultado is List<Equipamento>) {
      setState(() {
        _equipamentos = resultado;
      });
    }
  }

  void _salvarTreino() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Treino Criado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Local: $_localTreino'),
            Text('Tipo: $_tipoTreino'),
            Text('Duração: $_duracao min'),
            Text('Áreas alvo: ${_areasSelecionadas.join(', ')}'),
            Text('Equipamentos: ${_equipamentos.map((e) => e.nome).join(', ')}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildChipSelector({
    required List<String> items,
    required String selectedItem,
    required ValueChanged<String> onSelected,
  }) {
    return Wrap(
      spacing: 8,
      children: items.map((item) {
        return ChoiceChip(
          label: Text(item),
          selected: selectedItem == item,
          onSelected: (_) => onSelected(item),
        );
      }).toList(),
    );
  }

  Widget _buildMultiSelectChips(List<String> options) {
    return Wrap(
      spacing: 8,
      children: options.map((area) {
        return FilterChip(
          label: Text(area),
          selected: _areasSelecionadas.contains(area),
          onSelected: (bool selecionado) {
            setState(() {
              if (selecionado) {
                _areasSelecionadas.add(area);
              } else {
                _areasSelecionadas.remove(area);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildEquipamentoChips() {
    if (_equipamentos.isEmpty) {
      return const Text('Nenhum equipamento selecionado.');
    }
    return Wrap(
      spacing: 8,
      children: _equipamentos
          .map((e) => Chip(label: Text('${e.nome} (${e.categoria})')))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Treino'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildSectionTitle('Local de treino'),
            _buildChipSelector(
              items: _locais,
              selectedItem: _localTreino,
              onSelected: (value) => setState(() => _localTreino = value),
            ),

            _buildSectionTitle('Tipo de treino'),
            _buildChipSelector(
              items: _tiposTreino,
              selectedItem: _tipoTreino,
              onSelected: (value) => setState(() => _tipoTreino = value),
            ),

            _buildSectionTitle('Equipamentos'),
            ElevatedButton(
              onPressed: _selecionarEquipamentos,
              child: const Text('Selecionar Equipamentos'),
            ),
            const SizedBox(height: 8),
            _buildEquipamentoChips(),

            _buildSectionTitle('Duração do treino'),
            DropdownButton<int>(
              value: _duracao,
              onChanged: (valor) => setState(() => _duracao = valor!),
              items: _duracoes
                  .map((d) => DropdownMenuItem(value: d, child: Text('$d minutos')))
                  .toList(),
            ),

            _buildSectionTitle('Áreas alvo'),
            _buildMultiSelectChips(_areas),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _salvarTreino,
              icon: const Icon(Icons.check),
              label: const Text('Salvar Treino'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
