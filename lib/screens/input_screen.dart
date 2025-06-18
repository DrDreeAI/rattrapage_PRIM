import 'package:flutter/material.dart';
import '../data/ratp_data.dart';
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
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    try {
      final data = await loadRatpData();
      final stationSet = <String>{};
      for (var ligne in data) {
        if (ligne.fromType == "stop_point") stationSet.add(ligne.fromName.trim());
        if (ligne.toType == "stop_point") stationSet.add(ligne.toName.trim());
      }
      setState(() {
        _stations = stationSet.toList()..sort();
        _loading = false;
      });
      print("✅ ${_stations.length} stations chargées.");
    } catch (e) {
      setState(() {
        _error = "Erreur de chargement des données.";
        _loading = false;
      });
      print("❌ Erreur de chargement : $e");
    }
  }

  bool _stationExists(String input) {
    final normInput = normalize(input);
    return _stations.any((s) => normalize(s) == normInput);
  }

  bool get isValid =>
      _startController.text.trim().isNotEmpty &&
          _endController.text.trim().isNotEmpty &&
          normalize(_startController.text.trim()) != normalize(_endController.text.trim());

  Future<void> _rechercher() async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    final data = await loadRatpData();
    final start = _startController.text.trim();
    final end = _endController.text.trim();

    if (!_stationExists(start)) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🚫 Station de départ introuvable : « $start »")),
      );
      return;
    }
    if (!_stationExists(end)) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🚫 Station d’arrivée introuvable : « $end »")),
      );
      return;
    }

    print("🔍 Recherche depuis '$start' → '$end'");
    final steps = findSimpleTrajet(start, end, data);
    setState(() => _loading = false);

    if (steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aucun trajet trouvé.")),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(steps: steps)),
      );
    }
  }

  Widget _buildAutocomplete(TextEditingController controller, String label) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue value) {
        if (value.text.isEmpty) return const Iterable.empty();
        return _stations.where((station) =>
            normalize(station).contains(normalize(value.text)));
      },
      onSelected: (selection) {
        controller.text = selection;
        setState(() {});
      },
      fieldViewBuilder: (context, fieldController, focusNode, _) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
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
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.red),
          ),
        )
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
