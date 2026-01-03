import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

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

  String? get brandLogo {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('ford')) return 'assets/logos/ford.png';
    if (lowerName.contains('toyota')) return 'assets/logos/toyota.png';
    if (lowerName.contains('honda')) return 'assets/logos/honda.png';
    if (lowerName.contains('suzuki')) return 'assets/logos/suzuki.png';
    if (lowerName.contains('yamaha')) return 'assets/logos/yamaha.png';
    if (lowerName.contains('peugeot')) return 'assets/logos/peugeot.png';
    return null;
  }

  IconData get vehicleIcon {
    switch (type.toLowerCase()) {
      case 'car':
        return Icons.directions_car_rounded;
      case 'motorcycle':
      case 'moto':
        return Icons.two_wheeler_rounded;
      case 'bicycle':
      case 'bike':
        return Icons.pedal_bike_rounded;
      case 'truck':
        return Icons.local_shipping_rounded;
      default:
        return Icons.more_horiz_rounded;
    }
  }
}
