import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl = 'http://localhost:8080';
  final _storage = const FlutterSecureStorage();

  Future<String?> get _token async => await _storage.read(key: 'token');

  Future<Map<String, String>> _headers() async {
    final token = await _token;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Auth
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      body: jsonEncode({'username': username, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.write(key: 'token', value: data['token']);
      await _storage.write(key: 'userId', value: data['userId']);
      return data;
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to login');
    }
  }

  Future<void> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      body: jsonEncode({'username': username, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 201) {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to register');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'userId');
  }

  Future<bool> isLoggedIn() async {
    return (await _token) != null;
  }

  // Vehicles
  Future<List<dynamic>> getVehicles() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/vehicles'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load vehicles');
    }
  }

  Future<void> addVehicle(Map<String, dynamic> vehicle) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/vehicles'),
      headers: await _headers(),
      body: jsonEncode(vehicle),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add vehicle');
    }
  }

  Future<void> updateVehicle(String id, Map<String, dynamic> vehicle) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/vehicles/$id'),
      headers: await _headers(),
      body: jsonEncode(vehicle),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to update vehicle');
    }
  }

  Future<void> deleteVehicle(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/vehicles/$id'),
      headers: await _headers(),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete vehicle');
    }
  }

  // Maintenance
  Future<List<dynamic>> getMaintenanceRecords(String vehicleId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/maintenance?vehicleId=$vehicleId'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load records');
    }
  }

  Future<void> addMaintenanceRecord(Map<String, dynamic> record) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/maintenance'),
      headers: await _headers(),
      body: jsonEncode(record),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add record');
    }
  }

  Future<void> updateMaintenanceRecord(String id, Map<String, dynamic> record) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/maintenance/$id'),
      headers: await _headers(),
      body: jsonEncode(record),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to update record');
    }
  }

  Future<void> deleteMaintenanceRecord(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/maintenance/$id'),
      headers: await _headers(),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete record');
    }
  }
}
