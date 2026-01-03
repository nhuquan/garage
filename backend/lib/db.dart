import 'dart:io';
import 'package:postgres/postgres.dart';

class DbClient {
  static final DbClient _instance = DbClient._internal();
  factory DbClient() => _instance;
  DbClient._internal();

  Connection? _connection;

  Future<Connection> get connection async {
    if (_connection != null && _connection!.isOpen) {
      return _connection!;
    }

    final host = Platform.environment['DB_HOST'] ?? 'localhost';
    final port = int.parse(Platform.environment['DB_PORT'] ?? '5433');
    final database = Platform.environment['DB_NAME'] ?? 'garage_db';
    final username = Platform.environment['DB_USER'] ?? 'garage_user';
    final password = Platform.environment['DB_PASSWORD'] ?? 'garage_password';

    _connection = await Connection.open(
      Endpoint(
        host: host,
        port: port,
        database: database,
        username: username,
        password: password,
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );

    return _connection!;
  }

  Future<void> init() async {
    final conn = await connection;

    await conn.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY,
        username TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL
      );
    ''');

    await conn.execute('''
      CREATE TABLE IF NOT EXISTS vehicles (
        id UUID PRIMARY KEY,
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        year INTEGER NOT NULL,
        current_mileage DOUBLE PRECISION NOT NULL,
        description TEXT NOT NULL DEFAULT ''
      );
    ''');

    await conn.execute('''
      CREATE TABLE IF NOT EXISTS maintenance_items (
        id UUID PRIMARY KEY,
        vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
        title TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'other',
        date TIMESTAMP NOT NULL,
        cost DOUBLE PRECISION NOT NULL,
        mileage_at_service DOUBLE PRECISION NOT NULL,
        notes TEXT
      );
    ''');

    await conn.execute('''
      ALTER TABLE maintenance_items ADD COLUMN IF NOT EXISTS type TEXT NOT NULL DEFAULT 'other';
    ''');

    await conn.execute('''
      ALTER TABLE vehicles ADD COLUMN IF NOT EXISTS description TEXT NOT NULL DEFAULT '';
    ''');
  }
}
