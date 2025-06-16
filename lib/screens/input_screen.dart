import 'package:flutter/material.dart';
import '../data/ratp_data.dart';
import '../models/ligne.dart';
import '../services/trajet_service.dart';
import 'result_screen.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();

  List<String> _stations = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    final data = await loadRatpData();
    final stationSet = <String>{};
    for (var ligne in data) {
      stationSet.add(ligne.from);
      stationSet.add(ligne.to);
    }
    setState(() {
      _stations = stationSet.toList()..sort();
    });
  }

  bool get isValid =>
      _startController.text.isNotEmpty && _endController.text.isNotEmpty;

  Future<void> _rechercher() async {
    setState(() => _loading = true);

    final data = await loadRatpData();
    final trajets = findTrajets(
      _startController.text.trim(),
      _endController.text.trim(),
      data,
    );

    setState(() => _loading = false);

    if (trajets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aucun trajet trouvé.")),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(trajets: trajets)),
      );
    }
  }

  Widget _buildAutocomplete(TextEditingController controller, String label) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue value) {
        if (value.text.isEmpty) return const Iterable.empty();
        return _stations.where((s) =>
            s.toLowerCase().contains(value.text.toLowerCase()));
      },
      onSelected: (selection) {
        controller.text = selection;
        setState(() {});
      },
      fieldViewBuilder: (context, fieldController, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(labelText: label),
          onChanged: (_) => setState(() {}),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recherche de trajet')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _stations.isEmpty || _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            _buildAutocomplete(_startController, 'Station de départ'),
            const SizedBox(height: 16),
            _buildAutocomplete(_endController, 'Station d’arrivée'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: isValid ? _rechercher : null,
              child: const Text('Rechercher'),
            ),
          ],
        ),
      ),
    );
  }
}
