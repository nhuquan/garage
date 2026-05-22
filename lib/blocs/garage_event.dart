import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../database/app_database.dart';

abstract class GarageEvent extends Equatable {
  const GarageEvent();

  @override
  List<Object?> get props => [];
}

class LoadGarage extends GarageEvent {}

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

class ChangeMaintenanceInterval extends GarageEvent {
  final int months;
  const ChangeMaintenanceInterval(this.months);
  @override
  List<Object?> get props => [months];
}

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
