import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:backend/db.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final userId = context.read<String>();
  final db = context.read<DbClient>();
  final conn = await db.connection;

  final verify = await conn.execute(
    'SELECT id FROM vehicles WHERE id = \u00241 AND user_id = \u00242',
    parameters: [id, userId],
  );

  if (verify.isEmpty) {
    return Response(statusCode: HttpStatus.notFound);
  }

  switch (context.request.method) {
    case HttpMethod.delete:
      await conn.execute(
        'DELETE FROM vehicles WHERE id = \u00241', 
        parameters: [id],
      );
      return Response(statusCode: HttpStatus.noContent);
    case HttpMethod.put:
      final body = await context.request.json() as Map<String, dynamic>;
      await conn.execute(
        '''
        UPDATE vehicles 
        SET name = \u00241, type = \u00242, year = \u00243, current_mileage = \u00244
        WHERE id = \u00245
        ''',
        parameters: [
          body['name'],
          body['type'],
          body['year'],
          body['currentMileage'],
          id,
        ],
      );
      return Response(statusCode: HttpStatus.noContent);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}
