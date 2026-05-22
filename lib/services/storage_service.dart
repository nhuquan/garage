import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../database/app_database.dart';
import 'package:drift/drift.dart';

class StorageService {
  final AppDatabase _db;
  final _secureStorage = const FlutterSecureStorage();
  static const _userIdKey = 'userId';

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
}
