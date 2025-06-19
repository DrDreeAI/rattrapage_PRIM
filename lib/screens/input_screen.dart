import 'package:flutter/material.dart';
import '../data/ratp_data.dart';
import '../services/trajet_service.dart';
import 'result_screen.dart';

const Color ratpLightGreen = Color(0xFF59E2C1);
const Color ratpGreen = Color(0xFF23D5AB);
const Color inputBg = Color(0xFFF9F9F9);

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
    } catch (e) {
      setState(() {
        _error = "Erreur de chargement des données.";
        _loading = false;
      });
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

    final trajets = findMultipleTrajets(start, end, data, maxResults: 5);
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

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color iconColor,
    bool isSuggestion = false,
  }) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue value) {
        if (value.text.isEmpty) return const Iterable.empty();
        return _stations.where((station) => normalize(station).contains(normalize(value.text)));
      },
      displayStringForOption: (option) => option,
      onSelected: (selection) {
        controller.text = selection;
        setState(() {});
      },
      fieldViewBuilder: (context, fieldController, focusNode, onFieldSubmitted) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFFA9B1B3),
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              focusNode: focusNode,
              style: const TextStyle(fontSize: 17),
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: iconColor, size: 24),
                hintText: hint,
                hintStyle: TextStyle(
                  color: iconColor,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: ratpLightGreen,
                    width: 1.7,
                  ),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 3,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 320,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: options
                    .map((option) => ListTile(
                  leading: Icon(Icons.fiber_manual_record, color: ratpLightGreen, size: 18),
                  title: Text(
                    option,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () => onSelected(option),
                ))
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 250,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: ratpLightGreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: _loading
                  ? const Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(color: ratpGreen),
              )
                  : _error != null
                  ? Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 18),
                ),
              )
                  : Container(
                width: 350,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.09),
                      blurRadius: 26,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Nouveau trajet",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _inputField(
                      controller: _startController,
                      label: "Station de départ",
                      hint: "Ex : Gare Saint Lazare",
                      icon: Icons.radio_button_checked,
                      iconColor: ratpGreen,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: SizedBox(
                        height: 36,
                        child: CustomPaint(
                          painter: _DashedLinePainter(),
                          child: const SizedBox(width: 1, height: 36),
                        ),
                      ),
                    ),
                    _inputField(
                      controller: _endController,
                      label: "Station d'arrivée",
                      hint: "Ex : République",
                      icon: Icons.location_on,
                      iconColor: Colors.pink,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isValid ? _rechercher : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ratpLightGreen,
                          disabledBackgroundColor: Colors.white,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: ratpLightGreen,
                              width: 1.5,
                            ),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          "Rechercher",
                          style: TextStyle(
                            color: isValid ? Colors.white : ratpLightGreen,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) => false;
}
