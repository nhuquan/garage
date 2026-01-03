import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

enum MaintenanceType {
  oil,
  brake,
  coolant,
  tire,
  filter,
  other;

  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case MaintenanceType.oil:
        return l10n.oil;
      case MaintenanceType.brake:
        return l10n.brake;
      case MaintenanceType.coolant:
        return l10n.coolant;
      case MaintenanceType.tire:
        return l10n.tire;
      case MaintenanceType.filter:
        return l10n.filter;
      case MaintenanceType.other:
        return l10n.other;
    }
  }

  String get displayName {
    switch (this) {
      case MaintenanceType.oil:
        return 'Oil Change';
      case MaintenanceType.brake:
        return 'Brake Service';
      case MaintenanceType.coolant:
        return 'Coolant Flush';
      case MaintenanceType.tire:
        return 'Tire Rotation/Change';
      case MaintenanceType.filter:
        return 'Filter Replacement';
      case MaintenanceType.other:
        return 'Other';
    }
  }

  Icon get icon {
    switch (this) {
      case MaintenanceType.oil:
        return Icon(Icons.oil_barrel_outlined, color: Colors.orange);
      case MaintenanceType.brake:
        return Icon(Icons.settings_backup_restore, color: Colors.red);
      case MaintenanceType.coolant:
        return Icon(Icons.water_drop_outlined, color: Colors.blue);
      case MaintenanceType.tire:
        return Icon(Icons.tire_repair_outlined, color: Colors.lightGreen);
      case MaintenanceType.filter:
        return Icon(Icons.air_outlined, color: Colors.green);
      case MaintenanceType.other:
        return Icon(Icons.build_outlined, color: Colors.blueGrey);
    }
  }

  static MaintenanceType fromString(String? value) {
    return MaintenanceType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MaintenanceType.other,
    );
  }
}
