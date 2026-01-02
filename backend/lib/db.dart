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

    _connection = await Connection.open(
      Endpoint(
        host: 'localhost',
        port: 5433,
        database: 'garage_db',
        username: 'garage_user',
        password: 'garage_password',
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
        current_mileage DOUBLE PRECISION NOT NULL
      );
    ''');

    await conn.execute('''
      CREATE TABLE IF NOT EXISTS maintenance_items (
        id UUID PRIMARY KEY,
        vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
        title TEXT NOT NULL,
        date TIMESTAMP NOT NULL,
        cost DOUBLE PRECISION NOT NULL,
        mileage_at_service DOUBLE PRECISION NOT NULL,
        notes TEXT
      );
    ''');
  }
}
