import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:backend/db.dart';

Handler middleware(Handler handler) {
  return (context) async {
    final authHeader = context.request.headers['Authorization'];
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return Response(statusCode: HttpStatus.unauthorized);
    }

    final token = authHeader.substring(7);
    try {
      final jwt = JWT.verify(token, SecretKey('super-secret-key'));
      final userId = (jwt.payload as Map)['userId'] as String;
      
      return handler(
        context.provide<String>(() => userId),
      );
    } catch (e) {
      return Response(statusCode: HttpStatus.unauthorized);
    }
  };
}
