import 'package:equatable/equatable.dart';

class MaintenanceItem extends Equatable {
  final String id;
  final String vehicleId;
  final String title;
  final DateTime date;
  final double cost;
  final double mileageAtService;
  final String notes;

  const MaintenanceItem({
    required this.id,
    required this.vehicleId,
    required this.title,
    required this.date,
    required this.cost,
    required this.mileageAtService,
    required this.notes,
  });

  MaintenanceItem copyWith({
    String? id,
    String? vehicleId,
    String? title,
    DateTime? date,
    double? cost,
    double? mileageAtService,
    String? notes,
  }) {
    return MaintenanceItem(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      title: title ?? this.title,
      date: date ?? this.date,
      cost: cost ?? this.cost,
      mileageAtService: mileageAtService ?? this.mileageAtService,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'title': title,
      'date': date.toIso8601String(),
      'cost': cost,
      'mileageAtService': mileageAtService,
      'notes': notes,
    };
  }

  factory MaintenanceItem.fromJson(Map<String, dynamic> map) {
    return MaintenanceItem(
      id: map['id'] as String,
      vehicleId: map['vehicleId'] as String,
      title: map['title'] as String,
      date: DateTime.parse(map['date'] as String),
      cost: (map['cost'] as num?)?.toDouble() ?? 0.0,
      mileageAtService: (map['mileageAtService'] as num).toDouble(),
      notes: map['notes'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, vehicleId, title, date, cost, mileageAtService, notes];
}
