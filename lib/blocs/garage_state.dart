import 'package:equatable/equatable.dart';
import '../models/vehicle.dart';
import '../models/maintenance_item.dart';

enum GarageStatus { initial, loading, success, failure }

class GarageState extends Equatable {
  final GarageStatus status;
  final List<Vehicle> vehicles;
  final List<MaintenanceItem> maintenanceRecords;

  const GarageState({
    this.status = GarageStatus.initial,
    this.vehicles = const [],
    this.maintenanceRecords = const [],
  });

  GarageState copyWith({
    GarageStatus? status,
    List<Vehicle>? vehicles,
    List<MaintenanceItem>? maintenanceRecords,
  }) {
    return GarageState(
      status: status ?? this.status,
      vehicles: vehicles ?? this.vehicles,
      maintenanceRecords: maintenanceRecords ?? this.maintenanceRecords,
    );
  }

  @override
  List<Object?> get props => [status, vehicles, maintenanceRecords];
}
