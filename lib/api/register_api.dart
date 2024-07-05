import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterApi {
  static const String _baseUrl = 'http://192.168.1.4/api';

  static Future<Map<String, dynamic>> register(String name, String email,
      String password, String passwordConfirmation) async {
    final url = Uri.parse('$_baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return {
        'success': true,
        'user': responseData[
            'user'], // Update based on your backend response structure
        'token': responseData['token'],
      };
    } else if (response.statusCode == 422) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return {
        'success': false,
        'message': 'Validation errors',
        'errors': responseData[
            'errors'], // Assuming your backend sends validation errors
      };
    } else {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }
}
