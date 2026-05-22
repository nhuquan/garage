import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../database/app_database.dart';


enum GarageStatus { initial, loading, success, failure, unauthenticated, authenticating }

class GarageState extends Equatable {
  final GarageStatus status;
  final List<Vehicle> vehicles;
  final List<MaintenanceItem> maintenanceRecords;
  final String? errorMessage;
  final bool isAuthenticated;
  final ThemeMode themeMode;
  final Locale locale;
  final String? username;
  /// Global default maintenance interval in months (editable in Settings).
  final int maintenanceIntervalMonths;

  const GarageState({
    this.status = GarageStatus.initial,
    this.vehicles = const [],
    this.maintenanceRecords = const [],
    this.errorMessage,
    this.isAuthenticated = false,
    this.themeMode = ThemeMode.light,
    this.locale = const Locale('en'),
    this.username,
    this.maintenanceIntervalMonths = 6,
  });

  GarageState copyWith({
    GarageStatus? status,
    List<Vehicle>? vehicles,
    List<MaintenanceItem>? maintenanceRecords,
    String? errorMessage,
    bool? isAuthenticated,
    ThemeMode? themeMode,
    Locale? locale,
    String? username,
    int? maintenanceIntervalMonths,
  }) {
    return GarageState(
      status: status ?? this.status,
      vehicles: vehicles ?? this.vehicles,
      maintenanceRecords: maintenanceRecords ?? this.maintenanceRecords,
      errorMessage: errorMessage ?? this.errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      username: username ?? this.username,
      maintenanceIntervalMonths:
          maintenanceIntervalMonths ?? this.maintenanceIntervalMonths,
    );
  }

  @override
  List<Object?> get props => [
        status,
        vehicles,
        maintenanceRecords,
        errorMessage,
        isAuthenticated,
        themeMode,
        locale,
        username,
        maintenanceIntervalMonths,
      ];
}
