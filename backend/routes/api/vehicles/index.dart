import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:backend/db.dart';

Future<Response> onRequest(RequestContext context) async {
  final userId = context.read<String>();
  final db = context.read<DbClient>();
  final conn = await db.connection;

  switch (context.request.method) {
    case HttpMethod.get:
      return _getVehicles(conn, userId);
    case HttpMethod.post:
      return _createVehicle(context, conn, userId);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _getVehicles(Connection conn, String userId) async {
  final result = await conn.execute(
    'SELECT id, name, type, year, current_mileage FROM vehicles WHERE user_id = \u00241',
    parameters: [userId],
  );

  final vehicles = result.map((row) {
    final columns = row.toColumnMap();
    return {
      'id': columns['id'],
      'name': columns['name'],
      'type': columns['type'],
      'year': columns['year'],
      'currentMileage': columns['current_mileage'],
    };
  }).toList();

  return Response.json(body: vehicles);
}

Future<Response> _createVehicle(RequestContext context, Connection conn, String userId) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final id = body['id'] as String;
  final name = body['name'] as String;
  final type = body['type'] as String;
  final year = body['year'] as int;
  final currentMileage = (body['currentMileage'] as num).toDouble();

  await conn.execute(
    '''
    INSERT INTO vehicles (id, user_id, name, type, year, current_mileage)
    VALUES (\u00241, \u00242, \u00243, \u00244, \u00245, \u00246)
    ''',
    parameters: [id, userId, name, type, year, currentMileage],
  );

  return Response.json(
    statusCode: HttpStatus.created,
    body: {'id': id},
  );
}
