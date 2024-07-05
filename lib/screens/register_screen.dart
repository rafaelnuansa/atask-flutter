import 'package:atask/api/register_api.dart';
import 'package:atask/screens/task_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();
  bool _isLoading = false;

Future<void> _register() async {
  setState(() {
    _isLoading = true;
  });

  final name = _nameController.text;
  final email = _emailController.text;
  final password = _passwordController.text;
  final passwordConfirmation = _passwordConfirmationController.text;

  final response = await RegisterApi.register(
    name,
    email,
    password,
    passwordConfirmation,
  );

  setState(() {
    _isLoading = false;
  });

  if (response['success']) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', response['token']);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const TaskScreen()),
      (route) => false, // Removes all routes in the stack
    );
  } else {
    String errorMessage = response['message'];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _passwordConfirmationController,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _register,
                    child: const Text('Register'),
                  ),
          ],
        ),
      ),
    );
  }
}
