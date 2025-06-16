import 'package:flutter/material.dart';
import '../models/ligne.dart';

class ResultScreen extends StatelessWidget {
  final List<List<Ligne>> trajets;

  const ResultScreen({super.key, required this.trajets});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Résultats")),
      body: ListView.builder(
        itemCount: trajets.length,
        itemBuilder: (context, index) {
          final trajet = trajets[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(
                trajet.map((e) => e.line).join(" → "),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: trajet
                    .map((e) =>
                    Text("${e.from} → ${e.to} (${e.position})"))
                    .toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
