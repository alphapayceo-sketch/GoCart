import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/services/api_client.dart';

class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({super.key, this.resetToken});

  final String? resetToken;

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final password = _passwordController.text;
    if (widget.resetToken == null ||
        widget.resetToken!.isEmpty ||
        password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Use a valid reset session and a password of at least 8 characters.')));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await ApiClient.postJson('/api/auth/reset-password', {
        'token': widget.resetToken,
        'new_password': password,
      });
      if (mounted)
        Navigator.of(context)
            .pushNamedAndRemoveUntil(logInScreenRoute, (route) => false);
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
      appBar: AppBar(title: const Text('Set New Password')),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New password'),
            ),
            const SizedBox(height: defaultPadding * 2),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _resetPassword,
                child: Text(_isSubmitting ? 'Updating...' : 'Update password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
