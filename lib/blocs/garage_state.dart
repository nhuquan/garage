import 'package:equatable/equatable.dart';
import '../models/vehicle.dart';
import '../models/maintenance_item.dart';

enum GarageStatus { initial, loading, success, failure, unauthenticated, authenticating }

class GarageState extends Equatable {
  final GarageStatus status;
  final List<Vehicle> vehicles;
  final List<MaintenanceItem> maintenanceRecords;
  final String? errorMessage;
  final bool isAuthenticated;

  const GarageState({
    this.status = GarageStatus.initial,
    this.vehicles = const [],
    this.maintenanceRecords = const [],
    this.errorMessage,
    this.isAuthenticated = false,
  });

  GarageState copyWith({
    GarageStatus? status,
    List<Vehicle>? vehicles,
    List<MaintenanceItem>? maintenanceRecords,
    String? errorMessage,
    bool? isAuthenticated,
  }) {
    return GarageState(
      status: status ?? this.status,
      vehicles: vehicles ?? this.vehicles,
      maintenanceRecords: maintenanceRecords ?? this.maintenanceRecords,
      errorMessage: errorMessage ?? this.errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  @override
  List<Object?> get props => [status, vehicles, maintenanceRecords, errorMessage, isAuthenticated];
}
