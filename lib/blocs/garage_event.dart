import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../models/maintenance_item.dart';

abstract class GarageEvent extends Equatable {
  const GarageEvent();

  @override
  List<Object?> get props => [];
}

class LoadGarage extends GarageEvent {}

class CheckAuth extends GarageEvent {}

class LoginUser extends GarageEvent {
  final String username;
  final String password;
  const LoginUser(this.username, this.password);
  @override
  List<Object?> get props => [username, password];
}

class RegisterUser extends GarageEvent {
  final String username;
  final String password;
  const RegisterUser(this.username, this.password);
  @override
  List<Object?> get props => [username, password];
}

class LogoutUser extends GarageEvent {}

class ChangeTheme extends GarageEvent {
  final ThemeMode themeMode;
  const ChangeTheme(this.themeMode);
  @override
  List<Object?> get props => [themeMode];
}

class ChangeLocale extends GarageEvent {
  final Locale locale;
  const ChangeLocale(this.locale);
  @override
  List<Object?> get props => [locale];
}

class InitSettings extends GarageEvent {}

// Vehicle Events
class AddVehicle extends GarageEvent {
  final Vehicle vehicle;
  const AddVehicle(this.vehicle);
  @override
  List<Object?> get props => [vehicle];
}

class UpdateVehicle extends GarageEvent {
  final Vehicle vehicle;
  const UpdateVehicle(this.vehicle);
  @override
  List<Object?> get props => [vehicle];
}

class DeleteVehicle extends GarageEvent {
  final String id;
  const DeleteVehicle(this.id);
  @override
  List<Object?> get props => [id];
}

// Maintenance Events
class AddMaintenanceRecord extends GarageEvent {
  final MaintenanceItem record;
  const AddMaintenanceRecord(this.record);
  @override
  List<Object?> get props => [record];
}

class DeleteMaintenanceRecord extends GarageEvent {
  final String id;
  const DeleteMaintenanceRecord(this.id);
  @override
  List<Object?> get props => [id];
}

class UpdateMaintenanceRecord extends GarageEvent {
  final MaintenanceItem record;
  const UpdateMaintenanceRecord(this.record);
  @override
  List<Object?> get props => [record];
}
