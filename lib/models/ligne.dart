class Ligne {
  final String line;
  final String from;
  final String to;
  final String position;

  Ligne({
    required this.line,
    required this.from,
    required this.to,
    required this.position,
  });

  factory Ligne.fromJson(Map<String, dynamic> json) {
    return Ligne(
      line: json['line'],
      from: json['from'],
      to: json['to'],
      position: json['position_average'],
    );
  }
}
