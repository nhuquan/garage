import 'dart:io';
import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:uuid/uuid.dart';
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
      'SELECT id FROM users WHERE username = \u00241',
      parameters: [username],
    );

    if (result.isNotEmpty) {
      return Response.json(
        statusCode: HttpStatus.conflict,
        body: {'error': 'Username already exists'},
      );
    }

    final id = const Uuid().v4();
    final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

    await conn.execute(
      '''
      INSERT INTO users (id, username, password_hash) 
      VALUES (\u00241, \u00242, \u00243)
      ''',
      parameters: [id, username, passwordHash],
    );

    return Response.json(
      statusCode: HttpStatus.created,
      body: {'message': 'User registered successfully', 'userId': id},
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': e.toString()},
    );
  }
}
