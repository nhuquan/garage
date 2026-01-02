import 'dart:io';
import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:backend/db.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final body = await context.request.json() as Map<String, dynamic>;
  final username = body['username'] as String?;
  final password = body['password'] as String?;

  if (username == null || password == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'Username and password are required'},
    );
  }

  final db = context.read<DbClient>();
  final conn = await db.connection;

  try {
    final result = await conn.execute(
      'SELECT id, password_hash FROM users WHERE username = \u00241',
      parameters: [username],
    );

    if (result.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: {'error': 'Invalid credentials'},
      );
    }

    final row = result.first.toColumnMap();
    final userId = row['id'] as String;
    final passwordHash = row['password_hash'] as String;

    if (!BCrypt.checkpw(password, passwordHash)) {
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: {'error': 'Invalid credentials'},
      );
    }

    final jwt = JWT({'userId': userId});
    final token = jwt.sign(SecretKey('super-secret-key'));

    return Response.json(
      body: {'token': token, 'userId': userId},
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': e.toString()},
    );
  }
}
