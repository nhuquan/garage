import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/database/app_database.dart';
import 'package:garage/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'garage_event.dart';
import 'garage_state.dart';

class GarageBloc extends Bloc<GarageEvent, GarageState> {
  final StorageService _storageService;

  GarageBloc(this._storageService) : super(const GarageState()) {
    on<LoadGarage>(_onLoadGarage);
    on<AddVehicle>(_onAddVehicle);
    on<UpdateVehicle>(_onUpdateVehicle);
    on<DeleteVehicle>(_onDeleteVehicle);
    on<AddMaintenanceRecord>(_onAddMaintenanceRecord);
    on<UpdateMaintenanceRecord>(_onUpdateMaintenanceRecord);
    on<DeleteMaintenanceRecord>(_onDeleteMaintenanceRecord);
    on<ChangeTheme>(_onChangeTheme);
    on<ChangeLocale>(_onChangeLocale);
    on<InitSettings>(_onInitSettings);
    on<ChangeMaintenanceInterval>(_onChangeMaintenanceInterval);
  }

  Future<void> _onInitSettings(InitSettings event, Emitter<GarageState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString('themeMode') ?? 'light';
    final localeStr = prefs.getString('locale') ?? 'en';
    final intervalMonths = prefs.getInt('maintenanceIntervalMonths') ?? 6;

    emit(state.copyWith(
      themeMode: themeStr == 'dark' ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(localeStr),
      maintenanceIntervalMonths: intervalMonths,
    ));
  }

  Future<void> _onChangeMaintenanceInterval(
    ChangeMaintenanceInterval event,
    Emitter<GarageState> emit,
  ) async {
    final months = event.months.clamp(1, 60);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('maintenanceIntervalMonths', months);
    emit(state.copyWith(maintenanceIntervalMonths: months));
  }

  Future<void> _onChangeTheme(ChangeTheme event, Emitter<GarageState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', event.themeMode == ThemeMode.dark ? 'dark' : 'light');
    emit(state.copyWith(themeMode: event.themeMode));
  }

  Future<void> _onChangeLocale(ChangeLocale event, Emitter<GarageState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', event.locale.languageCode);
    emit(state.copyWith(locale: event.locale));
  }

  Future<void> _onLoadGarage(LoadGarage event, Emitter<GarageState> emit) async {
    emit(state.copyWith(status: GarageStatus.loading));
    try {
      // Restore from Keychain backup if the local DB is empty (e.g. after reinstall).
      await _storageService.restoreFromBackupIfNeeded();

      final vehicles = await _storageService.getVehicles();

      final List<MaintenanceItem> allRecords = [];
      for (var v in vehicles) {
        final maintenanceItems = await _storageService.getMaintenanceItemForVehicle(v.id);
        allRecords.addAll(maintenanceItems);
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
      await _storageService.saveVehicle(event.vehicle);
      await _storageService.saveBackup();
      add(LoadGarage());
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateVehicle(UpdateVehicle event, Emitter<GarageState> emit) async {
    try {
      await _storageService.saveVehicle(event.vehicle);
      await _storageService.saveBackup();
      add(LoadGarage());
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteVehicle(DeleteVehicle event, Emitter<GarageState> emit) async {
    try {
      await _storageService.deleteVehicle(event.id);
      await _storageService.saveBackup();
      add(LoadGarage());
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onAddMaintenanceRecord(AddMaintenanceRecord event, Emitter<GarageState> emit) async {
    try {
      await _storageService.saveMaintenanceItem(event.record);
      await _storageService.saveBackup();
      add(LoadGarage());
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateMaintenanceRecord(UpdateMaintenanceRecord event, Emitter<GarageState> emit) async {
    try {
      await _storageService.saveMaintenanceItem(event.record);
      await _storageService.saveBackup();
      add(LoadGarage());
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteMaintenanceRecord(DeleteMaintenanceRecord event, Emitter<GarageState> emit) async {
    try {
      await _storageService.deleteMaintenanceItem(event.id);
      await _storageService.saveBackup();
      add(LoadGarage());
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
