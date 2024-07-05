import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atask/api/task_api.dart';
import 'package:atask/models/task_model.dart';
import 'task_create_screen.dart'; // Import TaskCreateScreen
import 'task_detail_screen.dart'; // Import TaskDetailScreen (suggestion)

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  TaskScreenState createState() => TaskScreenState();
}

class TaskScreenState extends State<TaskScreen> {
  List<Task> _tasks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await TaskApi.fetchTasks(token);

      setState(() {
        _isLoading = false;
      });

      if (response['success']) {
        List<Task> fetchedTasks = [];
        for (var taskData in response['data']) {
          Task task = Task.fromJson(taskData);
          fetchedTasks.add(task);
        }
        setState(() {
          _tasks = fetchedTasks;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch tasks: $e')),
      );
      print(e);
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _showTaskCreateScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TaskCreateScreen()),
    );
  }

  Future<void> _refreshTasks() async {
    await _fetchTasks();
  }

  void _navigateToTaskDetail(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshTasks,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildTaskList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTaskCreateScreen,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList() {
    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return ListTile(
          title: Text(task.title),
          subtitle: Text(task.date.toString().substring(0, 10)), // Format date display
          trailing: Text(task.priority), // Display priority as string
          onTap: () => _navigateToTaskDetail(task), // Navigate to detail screen
        );
      },
    );
  }
}
