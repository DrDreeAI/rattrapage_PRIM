import '../models/ligne.dart';

List<List<Ligne>> findTrajets(String start, String end, List<Ligne> data) {
  List<List<Ligne>> results = [];

  // Trajets directs
  for (var ligne in data) {
    if (ligne.from == start && ligne.to == end) {
      results.add([ligne]);
    }
  }

  // Trajets avec 1 correspondance
  for (var l1 in data) {
    if (l1.from == start) {
      for (var l2 in data) {
        if (l1.to == l2.from && l2.to == end && l1.line != l2.line) {
          results.add([l1, l2]);
        }
      }
    }
  }

  results.sort((a, b) => a.length.compareTo(b.length));
  return results.take(5).toList();
}
