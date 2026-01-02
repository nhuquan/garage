import 'package:dart_frog/dart_frog.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:backend/db.dart';

final _dbClient = DbClient();
bool _dbInitialized = false;

Handler middleware(Handler handler) {
  return (context) async {
    if (!_dbInitialized) {
      await _dbClient.init();
      _dbInitialized = true;
    }
    return handler
        .use(requestLogger())
        .use(
          provider<DbClient>((context) => _dbClient),
        )
        .use(
          fromShelfMiddleware(
            corsHeaders(
              headers: {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
                'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
              },
            ),
          ),
        )(context);
  };
}
