import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/services/api_client.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid email address.')));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await ApiClient.postJson('/api/auth/forgot-password', {'email': email});
      if (mounted)
        Navigator.of(context).pushNamed(otpScreenRoute, arguments: email);
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Password Recovery"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            const Text(
              "Enter your email address and we will send you a code to reset your password.",
              textAlign: TextAlign.center,
              style: TextStyle(color: blackColor40),
            ),
            const SizedBox(height: defaultPadding * 2),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email Address",
                hintText: "Enter your email",
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: defaultPadding * 2),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _sendCode,
              child: Text(_isSubmitting ? 'Sending...' : "Send Code"),
            ),
          ],
        ),
      ),
    );
  }
}
