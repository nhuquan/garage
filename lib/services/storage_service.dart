import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../database/app_database.dart';
import 'package:drift/drift.dart';

class StorageService {
  final AppDatabase _db;
  final _secureStorage = const FlutterSecureStorage();
  static const _userIdKey = 'userId';
  static const _backupKey = 'xecare_data_backup';

  StorageService(this._db);

  // Returns existing userId or generates one on first launch
  Future<String> getOrCreateUserId() async {
    var userId = await _secureStorage.read(key: _userIdKey);
    if (userId == null) {
      userId = const Uuid().v4();
      await _secureStorage.write(key: _userIdKey, value: userId);
    }
    return userId;
  }

  // Vehicles
  Future<List<Vehicle>> getVehicles() async {
    final rows = await _db.select(_db.vehicles).get();
    return rows
        .map(
          (r) => Vehicle(
            id: r.id,
            name: r.name,
            type: r.type,
            year: r.year,
            currentKm: r.currentKm,
            description: r.description,
            maintenanceIntervalMonths: r.maintenanceIntervalMonths,
          ),
        )
        .toList();
  }

  Future<void> saveVehicle(Vehicle v) async {
    await _db
        .into(_db.vehicles)
        .insertOnConflictUpdate(
          VehiclesCompanion(
            id: Value(v.id),
            name: Value(v.name),
            type: Value(v.type),
            year: Value(v.year),
            currentKm: Value(v.currentKm),
            description: Value(v.description),
            maintenanceIntervalMonths: Value(v.maintenanceIntervalMonths),
          ),
        );
  }

  Future<void> deleteVehicle(String id) async {
    await (_db.delete(_db.vehicles)..where((t) => t.id.equals(id))).go();
  }

  // Maintenance
  Future<List<MaintenanceItem>> getMaintenanceItemForVehicle(
    String vehicleId,
  ) async {
    final rows = await (_db.select(
      _db.maintenanceItems,
    )..where((t) => t.vehicleId.equals(vehicleId))).get();

    return rows
        .map(
          (r) => MaintenanceItem(
            id: r.id,
            vehicleId: r.vehicleId,
            title: r.title,
            date: r.date,
            kmAtService: r.kmAtService,
            notes: r.notes,
          ),
        )
        .toList();
  }

  Future<void> saveMaintenanceItem(MaintenanceItem item) async {
    await _db
        .into(_db.maintenanceItems)
        .insertOnConflictUpdate(
          MaintenanceItemsCompanion(
            id: Value(item.id),
            vehicleId: Value(item.vehicleId),
            title: Value(item.title),
            date: Value(item.date),
            kmAtService: Value(item.kmAtService),
            notes: Value(item.notes),
          ),
        );
  }

  Future<void> deleteMaintenanceItem(String id) async {
    await (_db.delete(_db.maintenanceItems)..where((t) => t.id.equals(id))).go();
  }

  // ── Keychain backup ────────────────────────────────────────────────────────
  // The SQLite file is wiped when the app is deleted on iOS. The Keychain is
  // not. We keep a JSON snapshot there so data can be restored on reinstall.

  /// Serialise the entire dataset and write it to the Keychain.
  /// Called after every mutation so the snapshot stays current.
  Future<void> saveBackup() async {
    try {
      final vehicles = await getVehicles();

      final allMaintenance = <MaintenanceItem>[];
      for (final v in vehicles) {
        allMaintenance.addAll(await getMaintenanceItemForVehicle(v.id));
      }

      final payload = jsonEncode({
        'vehicles': vehicles
            .map((v) => {
                  'id': v.id,
                  'name': v.name,
                  'type': v.type,
                  'year': v.year,
                  'currentKm': v.currentKm,
                  'description': v.description,
                  'maintenanceIntervalMonths': v.maintenanceIntervalMonths,
                })
            .toList(),
        'maintenanceItems': allMaintenance
            .map((m) => {
                  'id': m.id,
                  'vehicleId': m.vehicleId,
                  'title': m.title,
                  'date': m.date.toIso8601String(),
                  'kmAtService': m.kmAtService,
                  'notes': m.notes,
                })
            .toList(),
      });

      await _secureStorage.write(key: _backupKey, value: payload);
    } catch (_) {
      // Backup is best-effort — never crash the app over it.
    }
  }

  /// If the local DB is empty and a Keychain backup exists, restore from it.
  /// Returns true if data was restored, false otherwise.
  Future<bool> restoreFromBackupIfNeeded() async {
    try {
      final existing = await getVehicles();
      if (existing.isNotEmpty) return false; // DB already has data, nothing to do.

      final payload = await _secureStorage.read(key: _backupKey);
      if (payload == null) return false; // First-ever install, no backup yet.

      final data = jsonDecode(payload) as Map<String, dynamic>;

      final vehiclesList = (data['vehicles'] as List<dynamic>? ?? []);
      final maintenanceList = (data['maintenanceItems'] as List<dynamic>? ?? []);

      for (final map in vehiclesList) {
        await saveVehicle(Vehicle(
          id: map['id'] as String,
          name: map['name'] as String,
          type: map['type'] as String,
          year: map['year'] as int,
          currentKm: (map['currentKm'] as num).toDouble(),
          description: map['description'] as String,
          maintenanceIntervalMonths: map['maintenanceIntervalMonths'] as int?,
        ));
      }

      for (final map in maintenanceList) {
        await saveMaintenanceItem(MaintenanceItem(
          id: map['id'] as String,
          vehicleId: map['vehicleId'] as String,
          title: map['title'] as String,
          date: DateTime.parse(map['date'] as String),
          kmAtService: (map['kmAtService'] as num).toDouble(),
          notes: map['notes'] as String?,
        ));
      }

      return vehiclesList.isNotEmpty;
    } catch (_) {
      return false; // Corrupt backup — start fresh rather than crash.
    }
  }
}
