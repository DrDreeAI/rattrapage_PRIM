import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final List<List<String>> steps;

  const ResultScreen({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trajet trouvé")),
      body: ListView.separated(
        itemCount: steps.length,
        separatorBuilder: (context, i) => const Divider(),
        itemBuilder: (context, index) {
          final etape = steps[index];
          return ListTile(
            leading: const Icon(Icons.directions_transit),
            title: Text(
              "Prendre la ligne ${etape[2]} de ${etape[0]} à ${etape[1]}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}
