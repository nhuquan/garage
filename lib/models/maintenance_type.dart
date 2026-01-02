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

  IconData get icon {
    switch (this) {
      case MaintenanceType.oil:
        return Icons.oil_barrel_rounded;
      case MaintenanceType.brake:
        return Icons.minor_crash_rounded; // Or icons.settings_backup_restore
      case MaintenanceType.coolant:
        return Icons.water_drop_rounded;
      case MaintenanceType.tire:
        return Icons.tire_repair_rounded;
      case MaintenanceType.filter:
        return Icons.air_rounded;
      case MaintenanceType.other:
        return Icons.build_circle_rounded;
    }
  }

  static MaintenanceType fromString(String? value) {
    return MaintenanceType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MaintenanceType.other,
    );
  }
}
