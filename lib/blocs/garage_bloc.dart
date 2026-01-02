import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/vehicle.dart';
import '../models/maintenance_item.dart';
import '../services/api_service.dart';
import 'garage_event.dart';
import 'garage_state.dart';

class GarageBloc extends Bloc<GarageEvent, GarageState> {
  final ApiService _apiService = ApiService();

  GarageBloc() : super(const GarageState()) {
    on<CheckAuth>(_onCheckAuth);
    on<LoginUser>(_onLoginUser);
    on<RegisterUser>(_onRegisterUser);
    on<LogoutUser>(_onLogoutUser);
    on<LoadGarage>(_onLoadGarage);
    on<AddVehicle>(_onAddVehicle);
    on<UpdateVehicle>(_onUpdateVehicle);
    on<DeleteVehicle>(_onDeleteVehicle);
    on<AddMaintenanceRecord>(_onAddMaintenanceRecord);
    on<UpdateMaintenanceRecord>(_onUpdateMaintenanceRecord);
    on<DeleteMaintenanceRecord>(_onDeleteMaintenanceRecord);
  }

  Future<void> _onCheckAuth(CheckAuth event, Emitter<GarageState> emit) async {
    final isLoggedIn = await _apiService.isLoggedIn();
    if (isLoggedIn) {
      emit(state.copyWith(isAuthenticated: true, status: GarageStatus.success));
      add(LoadGarage());
    } else {
      emit(state.copyWith(isAuthenticated: false, status: GarageStatus.unauthenticated));
    }
  }

  Future<void> _onLoginUser(LoginUser event, Emitter<GarageState> emit) async {
    emit(state.copyWith(status: GarageStatus.authenticating));
    try {
      await _apiService.login(event.username, event.password);
      emit(state.copyWith(isAuthenticated: true, status: GarageStatus.success));
      add(LoadGarage());
    } catch (e) {
      emit(state.copyWith(status: GarageStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onRegisterUser(RegisterUser event, Emitter<GarageState> emit) async {
    emit(state.copyWith(status: GarageStatus.authenticating));
    try {
      await _apiService.register(event.username, event.password);
      // Automatically login after register or just let them login manually
      // For simplicity, let's just emit success and let them login or show a message
       emit(state.copyWith(status: GarageStatus.unauthenticated, errorMessage: 'Registered successfully! Please login.'));
    } catch (e) {
      emit(state.copyWith(status: GarageStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onLogoutUser(LogoutUser event, Emitter<GarageState> emit) async {
    await _apiService.logout();
    emit(const GarageState(status: GarageStatus.unauthenticated, isAuthenticated: false));
  }

  Future<void> _onLoadGarage(LoadGarage event, Emitter<GarageState> emit) async {
    emit(state.copyWith(status: GarageStatus.loading));
    try {
      final vehiclesJson = await _apiService.getVehicles();
      final vehicles = vehiclesJson.map((v) => Vehicle.fromJson(v)).toList();
      
      // Load all maintenance records could be heavy, but let's do it for now or load on demand
      // For simplicity in the Bloc, let's load them when needed or just get all
      // Let's assume we want to load them into the state
      final List<MaintenanceItem> allRecords = [];
      for (var v in vehicles) {
        final recordsJson = await _apiService.getMaintenanceRecords(v.id);
        allRecords.addAll(recordsJson.map((r) => MaintenanceItem.fromJson(r)));
      }

      emit(state.copyWith(
        status: GarageStatus.success,
        vehicles: vehicles,
        maintenanceRecords: allRecords,
      ));
    } catch (e) {
      emit(state.copyWith(status: GarageStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onAddVehicle(AddVehicle event, Emitter<GarageState> emit) async {
    try {
      await _apiService.addVehicle(event.vehicle.toJson());
      add(LoadGarage());
    } catch (e) {
       emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateVehicle(UpdateVehicle event, Emitter<GarageState> emit) async {
    try {
      await _apiService.updateVehicle(event.vehicle.id, event.vehicle.toJson());
      add(LoadGarage());
    } catch (e) {
       emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteVehicle(DeleteVehicle event, Emitter<GarageState> emit) async {
    try {
      await _apiService.deleteVehicle(event.id);
      add(LoadGarage());
    } catch (e) {
       emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onAddMaintenanceRecord(AddMaintenanceRecord event, Emitter<GarageState> emit) async {
    try {
      await _apiService.addMaintenanceRecord(event.record.toJson());
      add(LoadGarage());
    } catch (e) {
       emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateMaintenanceRecord(UpdateMaintenanceRecord event, Emitter<GarageState> emit) async {
    try {
      await _apiService.updateMaintenanceRecord(event.record.id, event.record.toJson());
      add(LoadGarage());
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteMaintenanceRecord(DeleteMaintenanceRecord event, Emitter<GarageState> emit) async {
    try {
      await _apiService.deleteMaintenanceRecord(event.id);
      add(LoadGarage());
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
