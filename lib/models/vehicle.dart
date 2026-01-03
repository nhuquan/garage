import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../gen/assets.gen.dart';

class Vehicle extends Equatable {
  final String id;
  final String name;
  final String type; // 'Car', 'Motorcycle', 'Bicycle', 'Truck', 'Other'
  final int year;
  final double currentMileage;
  final String description;

  const Vehicle({
    required this.id,
    required this.name,
    required this.type,
    required this.year,
    required this.currentMileage,
    this.description = '',
  });

  Vehicle copyWith({
    String? id,
    String? name,
    String? type,
    int? year,
    double? currentMileage,
    String? description,
  }) {
    return Vehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      year: year ?? this.year,
      currentMileage: currentMileage ?? this.currentMileage,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'year': year,
      'currentMileage': currentMileage,
      'description': description,
    };
  }

  factory Vehicle.fromJson(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      year: map['year'] as int,
      currentMileage: (map['currentMileage'] as num).toDouble(),
      description: map['description'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name, type, year, currentMileage];

  AssetGenImage? get brandLogo {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('ford')) return Assets.logos.ford;
    if (lowerName.contains('toyota')) return Assets.logos.toyota;
    if (lowerName.contains('honda')) return Assets.logos.honda;
    if (lowerName.contains('suzuki')) return Assets.logos.suzuki;
    if (lowerName.contains('yamaha')) return Assets.logos.yamaha;
    if (lowerName.contains('peugeot')) return Assets.logos.peugeot;
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
