import 'dart:io';
import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/db.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.delete) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final userId = context.read<String>();
  final db = context.read<DbClient>();
  final conn = await db.connection;

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final password = body['password'] as String?;

    if (password == null || password.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Password is required'},
      );
    }

    final result = await conn.execute(
      'SELECT password_hash FROM users WHERE id = \u00241',
      parameters: [userId],
    );

    if (result.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'User not found'},
      );
    }

    final row = result.first.toColumnMap();
    final passwordHash = row['password_hash'] as String;

    if (!BCrypt.checkpw(password, passwordHash)) {
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: {'error': 'Invalid credentials'},
      );
    }

    await conn.execute(
      'DELETE FROM users WHERE id = \u00241',
      parameters: [userId],
    );

    return Response(statusCode: HttpStatus.noContent);
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': e.toString()},
    );
  }
}
