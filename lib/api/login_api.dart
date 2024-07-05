import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginApi {
  static const String _baseUrl = 'http://192.168.1.4/api';

  // Method to handle user login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Successful login
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return {
        'success': responseData['success'],
        'user': responseData['user'],
        'token': responseData['token'],
        'message': 'Login successful',
      };
    } else if (response.statusCode == 400 || response.statusCode == 422) {
      // Login failed or validation errors
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return {
        'success': responseData['success'] ?? false,
        'message': responseData['message'] ?? 'Login failed',
        'errors': responseData['errors'] ?? {},
      };
    } else {
      // Unexpected error
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  // Method to handle user logout
  static Future<Map<String, dynamic>> logout(String token) async {
    final url = Uri.parse('$_baseUrl/logout');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Successful logout
      return {
        'success': true,
        'message': 'Logout successful',
      };
    } else {
      // Logout failed
      return {
        'success': false,
        'message': 'Logout failed',
      };
    }
  }
}
