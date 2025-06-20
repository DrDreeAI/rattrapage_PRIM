import '../models/ligne.dart';

String normalize(String s) {
  return s
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r"\s+"), " ")
      .replaceAll(RegExp(r"[’'`´]"), "'")
      .replaceAll(RegExp(r"[-‐‑‒–—―]"), "-")
      .replaceAll(RegExp(r"[éèêë]"), "e")
      .replaceAll(RegExp(r"[àâä]"), "a")
      .replaceAll(RegExp(r"[îï]"), "i")
      .replaceAll(RegExp(r"[ôö]"), "o")
      .replaceAll(RegExp(r"[ùûü]"), "u")
      .replaceAll(RegExp(r"[ç]"), "c");
}

Map<String, Set<String>> computeStationsPerLine(List<Ligne> data) {
  final Map<String, Set<String>> ligneToStations = {};
  for (final l in data) {
    if (l.fromType == "stop_point") {
      ligneToStations.putIfAbsent(l.lineName, () => {}).add(normalize(l.fromName));
    }
    if (l.toType == "stop_point") {
      ligneToStations.putIfAbsent(l.lineName, () => {}).add(normalize(l.toName));
    }
  }
  return ligneToStations;
}

Map<String, Set<String>> computeLinesPerStation(List<Ligne> data) {
  final Map<String, Set<String>> stationToLignes = {};
  for (final l in data) {
    if (l.fromType == "stop_point") {
      stationToLignes.putIfAbsent(normalize(l.fromName), () => {}).add(l.lineName);
    }
    if (l.toType == "stop_point") {
      stationToLignes.putIfAbsent(normalize(l.toName), () => {}).add(l.lineName);
    }
  }
  return stationToLignes;
}

List<List<List<String>>> findMultipleTrajets(String start, String end, List<Ligne> data, {int maxResults = 5}) {
  final ligneToStations = computeStationsPerLine(data);
  final stationToLignes = computeLinesPerStation(data);

  final normStart = normalize(start);
  final normEnd = normalize(end);

  final lignesStart = stationToLignes[normStart] ?? {};
  final lignesEnd = stationToLignes[normEnd] ?? {};

  final List<List<List<String>>> results = [];
  final Set<String> seen = {};

  for (final ligne in lignesStart) {
    if (lignesEnd.contains(ligne)) {
      final hash = "$start-$end-$ligne";
      if (!seen.contains(hash)) {
        results.add([
          [start, end, ligne]
        ]);
        seen.add(hash);
      }
    }
    if (results.length >= maxResults) return results;
  }

  for (final ligneStart in lignesStart) {
    for (final ligneEnd in lignesEnd) {
      if (ligneStart == ligneEnd) continue;
      final stationsStart = ligneToStations[ligneStart]!;
      final stationsEnd = ligneToStations[ligneEnd]!;
      final inter = stationsStart.intersection(stationsEnd);
      for (final s in inter) {
        if (s != normStart && s != normEnd) {
          final hash = "$start-$s-$ligneStart-$s-$end-$ligneEnd";
          if (!seen.contains(hash)) {
            results.add([
              [start, s, ligneStart],
              [s, end, ligneEnd],
            ]);
            seen.add(hash);
          }
        }
        if (results.length >= maxResults) return results;
      }
    }
  }

  for (final ligneStart in lignesStart) {
    for (final midLigne in ligneToStations.keys) {
      if (midLigne == ligneStart) continue;
      final stationsStart = ligneToStations[ligneStart]!;
      final stationsMid = ligneToStations[midLigne]!;

      final interStartMid = stationsStart.intersection(stationsMid);
      for (final midStation in interStartMid) {
        if (midStation == normStart) continue;
        final lignesMidStation = stationToLignes[midStation] ?? {};
        for (final ligneEnd in lignesEnd) {
          if (ligneEnd == ligneStart || ligneEnd == midLigne) continue;
          final stationsEnd = ligneToStations[ligneEnd]!;
          final interMidEnd = stationsMid.intersection(stationsEnd);
          for (final finalStation in interMidEnd) {
            if (finalStation == normStart || finalStation == normEnd || finalStation == midStation) continue;
            final hash = "$start-$midStation-$ligneStart-$midStation-$finalStation-$midLigne-$finalStation-$end-$ligneEnd";
            if (!seen.contains(hash)) {
              results.add([
                [start, midStation, ligneStart],
                [midStation, finalStation, midLigne],
                [finalStation, end, ligneEnd],
              ]);
              seen.add(hash);
            }
            if (results.length >= maxResults) return results;
          }
        }
      }
    }
  }

  return results;
}
