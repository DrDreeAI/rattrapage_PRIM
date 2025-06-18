class Ligne {
  final String lineName;
  final String fromName;
  final String toName;
  final String? positionAverage;
  final String? fromType;
  final int? fromId;
  final String? toType;
  final int? toId;
  final String? lineId;
  final int? position;
  final int? positionMax;
  final String? equipmentType;

  Ligne({
    required this.lineName,
    required this.fromName,
    required this.toName,
    this.positionAverage,
    this.fromType,
    this.fromId,
    this.toType,
    this.toId,
    this.lineId,
    this.position,
    this.positionMax,
    this.equipmentType,
  });

  factory Ligne.fromJson(Map<String, dynamic> json) {
    return Ligne(
      lineName: json['line_name'] ?? '',
      fromName: json['from_name'] ?? '',
      toName: json['to_name'] ?? '',
      positionAverage: json['position_average'],
      fromType: json['from_type'],
      fromId: json['from_id'],
      toType: json['to_type'],
      toId: json['to_id'],
      lineId: json['line_id'],
      position: json['position'],
      positionMax: json['position_max'],
      equipmentType: json['equipment_type'],
    );
  }
}
