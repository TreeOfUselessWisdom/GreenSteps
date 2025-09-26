class CarbonEntryModel {
  final String id;
  final String userId;
  final DateTime date;
  final String category;
  final String subType;
  final double quantity;
  final String unit;
  final double co2eKg;
  final String? notes;

  const CarbonEntryModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.category,
    required this.subType,
    required this.quantity,
    required this.unit,
    required this.co2eKg,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.millisecondsSinceEpoch,
      'category': category,
      'subType': subType,
      'quantity': quantity,
      'unit': unit,
      'co2eKg': co2eKg,
      'notes': notes,
    };
  }

  factory CarbonEntryModel.fromJson(Map<String, dynamic> json) {
    return CarbonEntryModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(json['date'] ?? 0),
      category: json['category'] ?? '',
      subType: json['subType'] ?? '',
      quantity: (json['quantity'] ?? 0.0).toDouble(),
      unit: json['unit'] ?? '',
      co2eKg: (json['co2eKg'] ?? 0.0).toDouble(),
      notes: json['notes'],
    );
  }

  CarbonEntryModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? category,
    String? subType,
    double? quantity,
    String? unit,
    double? co2eKg,
    String? notes,
  }) {
    return CarbonEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      category: category ?? this.category,
      subType: subType ?? this.subType,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      co2eKg: co2eKg ?? this.co2eKg,
      notes: notes ?? this.notes,
    );
  }

  String get displayName {
    return subType.replaceAll('_', ' ').split(' ').map((word) => 
      word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  String get formattedCO2 {
    return '${co2eKg.toStringAsFixed(2)} kg CO₂e';
  }

  String get calculationFormula {
    return '${quantity.toStringAsFixed(1)} $unit × ${(co2eKg / quantity).toStringAsFixed(3)} = $formattedCO2';
  }
}
