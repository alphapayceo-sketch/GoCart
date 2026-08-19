import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/services/auth_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen(
      {super.key, required this.email, required this.nextRoute});

  final String email;
  final String nextRoute;

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _codeController = TextEditingController();
  final _authService = const AuthService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!RegExp(r'^\d{6}$').hasMatch(_codeController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Enter the six-digit code from your email.')));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await _authService.verifyEmail(
          email: widget.email, code: _codeController.text);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
          context, widget.nextRoute, (route) => false);
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _resend() async {
    try {
      await _authService.resendVerification(widget.email);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verification code sent.')));
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify email')),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Check ${widget.email}',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: defaultPadding),
          const Text(
              'Enter the six-digit verification code we sent to your email.'),
          const SizedBox(height: defaultPadding * 1.5),
          TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration:
                  const InputDecoration(labelText: 'Verification code')),
          const SizedBox(height: defaultPadding),
          SizedBox(
              width: double.infinity,
              child: FilledButton(
                  onPressed: _isSubmitting ? null : _verify,
                  child:
                      Text(_isSubmitting ? 'Verifying...' : 'Verify email'))),
          TextButton(
              onPressed: _isSubmitting ? null : _resend,
              child: const Text('Resend code')),
          TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, signUpScreenRoute),
              child: const Text('Use a different email')),
        ]),
      ),
    );
  }
}
