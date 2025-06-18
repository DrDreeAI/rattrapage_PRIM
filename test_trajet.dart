import 'dart:convert';
import 'dart:io';
import 'lib/models/ligne.dart';
import 'lib/services/trajet_service.dart';

void main() async {
  // Charge les données (seulement les vraies liaisons station <-> station)
  final file = File('assets/ratp_data.json');
  final content = await file.readAsString();
  final jsonList = json.decode(content) as List;
  final lignes = jsonList
      .map((e) => Ligne.fromJson(e))
      .where((l) => l.fromType == 'stop_point' && l.toType == 'stop_point')
      .toList();

  print("✅ Données chargées : ${lignes.length} lignes");


  // Toutes les stations différentes (normalisées)
  final stations = {
    for (final l in lignes) ...[normalize(l.fromName), normalize(l.toName)]
  };
  print("✅ ${stations.length} stations différentes dans le graphe");

  // Paramètres du test
  final start = "Bagneux - Lucie Aubrac";
  final end = "Richard-Lenoir";

  // Fonction pour afficher les voisins d'une station
  void printVoisins(String station) {
    final voisins = <String>{};
    for (var l in lignes) {
      if (matchStations(l.fromName, station)) voisins.add(l.toName);
      if (matchStations(l.toName, station)) voisins.add(l.fromName);
    }
    print("🌐 Voisins directs de '$station' (${voisins.length}):");
    for (var v in voisins) {
      print("   → $v");
    }
    if (voisins.isEmpty) {
      print("❗ Aucun voisin trouvé pour '$station'. Vérifiez l'orthographe ou la normalisation !");
    }
  }

  // Affiche les voisins des stations de départ et d'arrivée
  printVoisins(start);
  printVoisins(end);

  // Lancement de la recherche
  print("\n🔍 Recherche console : '$start' → '$end'");

  // Recherche de trajets
  final trajets = findTrajets(start, end, lignes);

  // Fonction pour afficher le type de transport
  String typeTransport(Ligne l) {
    final ln = l.lineName.trim().toUpperCase();
    if ((l.equipmentType ?? '').toLowerCase().contains('bus') || ln.contains('BUS')) return '🚌 BUS';
    if (ln.startsWith('T')) return '🚊 TRAM';
    if (RegExp(r"^\d+$").hasMatch(ln)) return '🚇 METRO';
    if (['A', 'B', 'C', 'D', 'E'].contains(ln)) return '🚆 RER';
    return '🚏 AUTRE';
  }

  // Affichage des résultats
  if (trajets.isEmpty) {
    print("❌ Aucun trajet trouvé !");
    print("Conseil : Testez avec un voisin direct de '$start' pour vérifier.");
  } else {
    print("✅ ${trajets.length} trajet(s) trouvé(s) !");
    int n = 1;
    for (var trajet in trajets) {
      print("➤ Trajet $n : ${trajet.map((e) => "${typeTransport(e)} ${e.lineName}").join(" → ")}");
      for (var l in trajet) {
        print("   ${l.fromName} → ${l.toName} [${l.positionAverage ?? '-'}]");
      }
      print("");
      n++;
    }
  }

  // Debug normalisation
  print("🔧 normalize('$start') → '${normalize(start)}'");
  print("🔧 normalize('$end') → '${normalize(end)}'");
}
