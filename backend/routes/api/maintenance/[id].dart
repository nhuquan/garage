import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:backend/db.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final userId = context.read<String>();
  final db = context.read<DbClient>();
  final conn = await db.connection;

  switch (context.request.method) {
    case HttpMethod.put:
      return _updateMaintenanceItem(context, conn, userId, id);
    case HttpMethod.delete:
      return _deleteMaintenanceItem(context, conn, userId, id);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _updateMaintenanceItem(RequestContext context, Connection conn, String userId, String id) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final title = body['title'] as String;
  final type = body['type'] as String? ?? 'other';
  final date = DateTime.parse(body['date'] as String);
  final cost = (body['cost'] as num).toDouble();
  final mileageAtService = (body['mileageAtService'] as num).toDouble();
  final notes = body['notes'] as String?;

  // Verify ownership via join
  final verify = await conn.execute(
    '''
    SELECT m.id FROM maintenance_items m
    JOIN vehicles v ON m.vehicle_id = v.id
    WHERE m.id = \$1 AND v.user_id = \$2
    ''',
    parameters: [id, userId],
  );

  if (verify.isEmpty) {
    return Response(statusCode: HttpStatus.notFound);
  }

  await conn.execute(
    '''
    UPDATE maintenance_items 
    SET title = \$1, type = \$2, date = \$3, cost = \$4, mileage_at_service = \$5, notes = \$6
    WHERE id = \$7
    ''',
    parameters: [title, type, date, cost, mileageAtService, notes, id],
  );

  return Response(statusCode: HttpStatus.noContent);
}

Future<Response> _deleteMaintenanceItem(RequestContext context, Connection conn, String userId, String id) async {
  // Verify ownership
  final verify = await conn.execute(
    '''
    SELECT m.id FROM maintenance_items m
    JOIN vehicles v ON m.vehicle_id = v.id
    WHERE m.id = \$1 AND v.user_id = \$2
    ''',
    parameters: [id, userId],
  );

  if (verify.isEmpty) {
    return Response(statusCode: HttpStatus.notFound);
  }

  await conn.execute(
    'DELETE FROM maintenance_items WHERE id = \$1',
    parameters: [id],
  );

  return Response(statusCode: HttpStatus.noContent);
}
