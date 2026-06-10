import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth.dart';
import '../home_screen/home_screen.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _auth = AuthService();
  bool _isLoading = false;

  Future<void> _handleSignUp() async {
    setState(() => _isLoading = true);
    User? user = await _auth.signUpWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nameController.text.trim(),
    );
    setState(() => _isLoading = false);
    if (user != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('সাইনআপ ব্যর্থ, আবার চেষ্টা করুন')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(hintText: 'Full Name')),
            TextField(controller: _emailController, decoration: const InputDecoration(hintText: 'Email')),
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(hintText: 'Password (min 6 chars)')),
            const SizedBox(height: 24),
            _isLoading ? const CircularProgressIndicator() : ElevatedButton(onPressed: _handleSignUp, child: const Text('Sign Up')),
          ],
        ),
      ),
    );
  }
}
