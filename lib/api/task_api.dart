import 'dart:convert';
import 'package:http/http.dart' as http;

class TaskApi {
  static const String _baseUrl = 'http://192.168.1.4/api';

  // Method to fetch tasks for the authenticated user
  static Future<Map<String, dynamic>> fetchTasks(String token) async {
    final url = Uri.parse('$_baseUrl/tasks');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> tasks = jsonDecode(response.body)['data'];
      return {
        'success': true,
        'message': 'Tasks retrieved successfully',
        'data': tasks,
      };
    } else {
      return {
        'success': false,
        'message': 'Failed to retrieve tasks',
      };
    }
  }

  // Method to create a new task
  static Future<Map<String, dynamic>> createTask(String token, String title, String description, String date, String priority) async {
    final url = Uri.parse('$_baseUrl/tasks');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'date': date,
        'priority': priority,
      }),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> task = jsonDecode(response.body)['data'];
      return {
        'success': true,
        'message': 'Task created successfully',
        'data': task,
      };
    } else if (response.statusCode == 422) {
      final Map<String, dynamic> errors = jsonDecode(response.body)['errors'];
      return {
        'success': false,
        'message': 'Validation errors',
        'errors': errors,
      };
    } else {
      return {
        'success': false,
        'message': 'Failed to create task',
      };
    }
  }

  // Method to fetch a specific task
  static Future<Map<String, dynamic>> fetchTask(String token, int id) async {
    final url = Uri.parse('$_baseUrl/tasks/$id');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> task = jsonDecode(response.body)['data'];
      return {
        'success': true,
        'message': 'Task retrieved successfully',
        'data': task,
      };
    } else {
      return {
        'success': false,
        'message': 'Task not found',
      };
    }
  }

  // Method to update a specific task
  static Future<Map<String, dynamic>> updateTask(String token, int id, String title, String description, String date, String priority) async {
    final url = Uri.parse('$_baseUrl/tasks/$id');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'date': date,
        'priority': priority,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> task = jsonDecode(response.body)['data'];
      return {
        'success': true,
        'message': 'Task updated successfully',
        'data': task,
      };
    } else if (response.statusCode == 422) {
      final Map<String, dynamic> errors = jsonDecode(response.body)['errors'];
      return {
        'success': false,
        'message': 'Validation errors',
        'errors': errors,
      };
    } else {
      return {
        'success': false,
        'message': 'Failed to update task',
      };
    }
  }

  // Method to delete a specific task
  static Future<Map<String, dynamic>> deleteTask(String token, int id) async {
    final url = Uri.parse('$_baseUrl/tasks/$id');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': 'Task deleted successfully',
      };
    } else {
      return {
        'success': false,
        'message': 'Failed to delete task',
      };
    }
  }
}
