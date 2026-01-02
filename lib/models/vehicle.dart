import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

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

  @override
  List<Object?> get props => [id, name, type, year, currentMileage];
}

class VehicleAdapter extends TypeAdapter<Vehicle> {
  @override
  final int typeId = 0;

  @override
  Vehicle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Vehicle(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as String,
      year: fields[3] as int,
      currentMileage: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Vehicle obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.year)
      ..writeByte(4)
      ..write(obj.currentMileage);
  }
}
