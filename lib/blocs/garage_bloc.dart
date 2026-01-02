import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/vehicle.dart';
import '../models/maintenance_item.dart';
import 'garage_event.dart';
import 'garage_state.dart';

class GarageBloc extends Bloc<GarageEvent, GarageState> {
  late Box<Vehicle> _vehicleBox;
  late Box<MaintenanceItem> _maintenanceBox;

  GarageBloc() : super(const GarageState()) {
    on<LoadGarage>(_onLoadGarage);
    on<AddVehicle>(_onAddVehicle);
    on<UpdateVehicle>(_onUpdateVehicle);
    on<DeleteVehicle>(_onDeleteVehicle);
    on<AddMaintenanceRecord>(_onAddMaintenanceRecord);
    on<UpdateMaintenanceRecord>(_onUpdateMaintenanceRecord);
    on<DeleteMaintenanceRecord>(_onDeleteMaintenanceRecord);
  }

  Future<void> _onLoadGarage(LoadGarage event, Emitter<GarageState> emit) async {
    emit(state.copyWith(status: GarageStatus.loading));
    try {
      _vehicleBox = await Hive.openBox<Vehicle>('vehicles');
      _maintenanceBox = await Hive.openBox<MaintenanceItem>('maintenance');
      
      emit(state.copyWith(
        status: GarageStatus.success,
        vehicles: _vehicleBox.values.toList(),
        maintenanceRecords: _maintenanceBox.values.toList(),
      ));
    } catch (_) {
      emit(state.copyWith(status: GarageStatus.failure));
    }
  }

  Future<void> _onAddVehicle(AddVehicle event, Emitter<GarageState> emit) async {
    await _vehicleBox.put(event.vehicle.id, event.vehicle);
    emit(state.copyWith(vehicles: _vehicleBox.values.toList()));
  }

  Future<void> _onUpdateVehicle(UpdateVehicle event, Emitter<GarageState> emit) async {
    await _vehicleBox.put(event.vehicle.id, event.vehicle);
    emit(state.copyWith(vehicles: _vehicleBox.values.toList()));
  }

  Future<void> _onDeleteVehicle(DeleteVehicle event, Emitter<GarageState> emit) async {
    await _vehicleBox.delete(event.id);
    
    // Also delete associated maintenance items from Hive
    final idsToRemove = _maintenanceBox.values
        .where((item) => item.vehicleId == event.id)
        .map((e) => e.id)
        .toList();
    
    for (var id in idsToRemove) {
      await _maintenanceBox.delete(id);
    }

    emit(state.copyWith(
      vehicles: _vehicleBox.values.toList(),
      maintenanceRecords: _maintenanceBox.values.toList(),
    ));
  }

  Future<void> _onAddMaintenanceRecord(AddMaintenanceRecord event, Emitter<GarageState> emit) async {
    await _maintenanceBox.put(event.record.id, event.record);
    
    // Update vehicle mileage if this record has higher mileage
    final vehicle = _vehicleBox.get(event.record.vehicleId);
    if (vehicle != null && event.record.mileageAtService > vehicle.currentMileage) {
      final updatedVehicle = vehicle.copyWith(currentMileage: event.record.mileageAtService);
      await _vehicleBox.put(updatedVehicle.id, updatedVehicle);
    }

    emit(state.copyWith(
      vehicles: _vehicleBox.values.toList(),
      maintenanceRecords: _maintenanceBox.values.toList(),
    ));
  }

  Future<void> _onUpdateMaintenanceRecord(UpdateMaintenanceRecord event, Emitter<GarageState> emit) async {
    await _maintenanceBox.put(event.record.id, event.record);
    
    // Update vehicle mileage if needed
    final vehicle = _vehicleBox.get(event.record.vehicleId);
    if (vehicle != null && event.record.mileageAtService > vehicle.currentMileage) {
      final updatedVehicle = vehicle.copyWith(currentMileage: event.record.mileageAtService);
      await _vehicleBox.put(updatedVehicle.id, updatedVehicle);
    }

    emit(state.copyWith(
      vehicles: _vehicleBox.values.toList(),
      maintenanceRecords: _maintenanceBox.values.toList(),
    ));
  }

  Future<void> _onDeleteMaintenanceRecord(DeleteMaintenanceRecord event, Emitter<GarageState> emit) async {
    await _maintenanceBox.delete(event.id);
    emit(state.copyWith(maintenanceRecords: _maintenanceBox.values.toList()));
  }
}
