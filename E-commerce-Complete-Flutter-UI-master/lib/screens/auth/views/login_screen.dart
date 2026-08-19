import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/services/auth_service.dart';
import 'package:shop/services/biometric_auth_service.dart';

import 'components/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = const AuthService();
  bool _isSubmitting = false;
  bool _biometricEnabled = false;
  bool _biometricSupported = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricAvailability();
  }

  Future<void> _loadBiometricAvailability() async {
    final isSupported = await BiometricAuthService.isSupportedOnDevice();
    final isEnabled = await BiometricAuthService.isEnabled();

    if (!mounted) {
      return;
    }

    setState(() {
      _biometricSupported = isSupported;
      _biometricEnabled = isEnabled;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AuthService.isMerchant
            ? merchantDashboardScreenRoute
            : entryPointScreenRoute,
        ModalRoute.withName(logInScreenRoute),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _loginWithBiometrics() async {
    if (!_biometricSupported || !_biometricEnabled || _isSubmitting) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authenticated = await BiometricAuthService.authenticate();
      if (!authenticated) {
        throw Exception('Biometric authentication failed.');
      }

      final credentials = await BiometricAuthService.getSavedCredentials();
      final email = credentials['email'] ?? '';
      final password = credentials['password'] ?? '';

      if (email.isEmpty || password.isEmpty) {
        throw Exception('No saved credentials found for biometric sign-in.');
      }

      await _authService.login(email: email, password: password);

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AuthService.isMerchant
            ? merchantDashboardScreenRoute
            : entryPointScreenRoute,
        ModalRoute.withName(logInScreenRoute),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              "assets/images/login_dark.png",
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back!",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text(
                    "Log in with your data that you intered during your registration.",
                  ),
                  const SizedBox(height: defaultPadding),
                  LogInForm(
                    formKey: _formKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                  ),
                  Align(
                    child: TextButton(
                      child: const Text("Forgot password"),
                      onPressed: () {
                        Navigator.pushNamed(
                            context, passwordRecoveryScreenRoute);
                      },
                    ),
                  ),
                  SizedBox(
                    height:
                        size.height > 700 ? size.height * 0.1 : defaultPadding,
                  ),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _login,
                    child: Text(_isSubmitting ? "Logging in..." : "Log in"),
                  ),
                  if (_biometricSupported && _biometricEnabled) ...[
                    const SizedBox(height: defaultPadding / 2),
                    OutlinedButton.icon(
                      onPressed: _isSubmitting ? null : _loginWithBiometrics,
                      icon: const Icon(Icons.fingerprint),
                      label: const Text("Use biometrics"),
                    ),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, signUpScreenRoute);
                        },
                        child: const Text("Sign up"),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
