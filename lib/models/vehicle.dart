import 'package:equatable/equatable.dart';

class Vehicle extends Equatable {
  final String id;
  final String name;
  final String type; // 'Car', 'Motorcycle', 'Bicycle', 'Truck', 'Other'
  final int year;
  final double currentMileage;

  const Vehicle({
    required this.id,
    required this.name,
    required this.type,
    required this.year,
    required this.currentMileage,
  });

  Vehicle copyWith({
    String? id,
    String? name,
    String? type,
    int? year,
    double? currentMileage,
  }) {
    return Vehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      year: year ?? this.year,
      currentMileage: currentMileage ?? this.currentMileage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'year': year,
      'currentMileage': currentMileage,
    };
  }

  factory Vehicle.fromJson(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      year: map['year'] as int,
      currentMileage: (map['currentMileage'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, name, type, year, currentMileage];
}
