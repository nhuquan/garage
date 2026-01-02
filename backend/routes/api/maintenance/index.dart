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
      return _getMaintenanceItems(context, conn, userId);
    case HttpMethod.post:
      return _createMaintenanceItem(context, conn, userId);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _getMaintenanceItems(RequestContext context, Connection conn, String userId) async {
  final vehicleId = context.request.uri.queryParameters['vehicleId'];
  
  if (vehicleId == null) {
     final result = await conn.execute(
      '''
      SELECT m.id, m.vehicle_id, m.title, m.date, m.cost, m.mileage_at_service, m.notes 
      FROM maintenance_items m
      JOIN vehicles v ON m.vehicle_id = v.id
      WHERE v.user_id = \u00241
      ORDER BY m.date DESC
      ''',
      parameters: [userId],
    );
     return _mapToResponse(result);
  } else {
    final verify = await conn.execute(
      'SELECT id FROM vehicles WHERE id = \u00241 AND user_id = \u00242',
      parameters: [vehicleId, userId],
    );
    if (verify.isEmpty) {
      return Response(statusCode: HttpStatus.forbidden);
    }

    final result = await conn.execute(
      '''
      SELECT id, vehicle_id, title, date, cost, mileage_at_service, notes 
      FROM maintenance_items 
      WHERE vehicle_id = \u00241
      ORDER BY date DESC
      ''',
      parameters: [vehicleId],
    );
    return _mapToResponse(result);
  }
}

Response _mapToResponse(Result result) {
  final items = result.map((row) {
    final columns = row.toColumnMap();
    return {
      'id': columns['id'],
      'vehicleId': columns['vehicle_id'],
      'title': columns['title'],
      'date': (columns['date'] as DateTime).toIso8601String(),
      'cost': columns['cost'],
      'mileageAtService': columns['mileage_at_service'],
      'notes': columns['notes'],
    };
  }).toList();

  return Response.json(body: items);
}

Future<Response> _createMaintenanceItem(RequestContext context, Connection conn, String userId) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final id = body['id'] as String;
  final vehicleId = body['vehicleId'] as String;
  final title = body['title'] as String;
  final date = DateTime.parse(body['date'] as String);
  final cost = (body['cost'] as num).toDouble();
  final mileageAtService = (body['mileageAtService'] as num).toDouble();
  final notes = body['notes'] as String?;

  final verify = await conn.execute(
    'SELECT id FROM vehicles WHERE id = \u00241 AND user_id = \u00242',
    parameters: [vehicleId, userId],
  );
  if (verify.isEmpty) {
    return Response(statusCode: HttpStatus.forbidden);
  }

  await conn.execute(
    '''
    INSERT INTO maintenance_items (id, vehicle_id, title, date, cost, mileage_at_service, notes)
    VALUES (\u00241, \u00242, \u00243, \u00244, \u00245, \u00246, \u00247)
    ''',
    parameters: [id, vehicleId, title, date, cost, mileageAtService, notes],
  );

  await conn.execute(
    '''
    UPDATE vehicles 
    SET current_mileage = GREATEST(current_mileage, \u00241)
    WHERE id = \u00242
    ''',
    parameters: [mileageAtService, vehicleId],
  );

  return Response.json(
    statusCode: HttpStatus.created,
    body: {'id': id},
  );
}
