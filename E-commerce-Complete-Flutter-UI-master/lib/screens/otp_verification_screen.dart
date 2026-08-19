import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/services/api_client.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key, this.email});

  final String? email;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  bool _isSubmitting = false;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _verify() async {
    final email = widget.email?.trim();
    final code = _controllers.map((controller) => controller.text).join();
    if (email == null || email.isEmpty || code.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter the four-digit code.')));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final response = await ApiClient.postJson(
          '/api/auth/verify-otp', {'email': email, 'code': code});
      final resetToken = response['resetToken']?.toString();
      if (resetToken == null || resetToken.isEmpty)
        throw Exception('Reset token was not returned.');
      if (mounted)
        Navigator.of(context).pushReplacementNamed(newPasswordScreenRoute,
            arguments: resetToken);
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _resend() async {
    final email = widget.email?.trim();
    if (email == null || email.isEmpty) return;
    try {
      await ApiClient.postJson('/api/auth/resend-otp', {'email': email});
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('A new code was sent.')));
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OTP Verification"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            const Text(
              "We have sent a 4-digit code to your email. Please enter it below.",
              textAlign: TextAlign.center,
              style: TextStyle(color: blackColor40),
            ),
            const SizedBox(height: defaultPadding * 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return SizedBox(
                  width: 60,
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    controller: _controllers[index],
                    decoration: const InputDecoration(counterText: ""),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                );
              }),
            ),
            const SizedBox(height: defaultPadding * 2),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _verify,
              child: Text(_isSubmitting ? 'Verifying...' : "Verify"),
            ),
            TextButton(
              onPressed: _resend,
              child: const Text("Resend Code"),
            ),
          ],
        ),
      ),
    );
  }
}
