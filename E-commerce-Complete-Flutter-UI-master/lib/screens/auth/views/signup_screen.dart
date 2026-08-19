import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/screens/auth/views/components/sign_up_form.dart';
import 'package:shop/services/auth_service.dart';

import '../../../constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = const AuthService();
  bool _acceptedTerms = false;
  bool _isSubmitting = false;
  String _accountType = 'customer';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) {
      return;
    }

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please accept the terms and privacy policy."),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _authService.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _accountType,
      );

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        _accountType == 'merchant'
            ? emailVerificationScreenRoute
            : entryPointScreenRoute,
        (route) => false,
        arguments: _accountType == 'merchant'
            ? {
                'email': _emailController.text.trim(),
                'nextRoute': merchantOnboardingScreenRoute,
              }
            : null,
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
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              "assets/images/signUp_dark.png",
              height: MediaQuery.of(context).size.height * 0.35,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Let's get started!",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text(
                    "Please enter your valid data in order to create an account.",
                  ),
                  const SizedBox(height: defaultPadding),
                  SignUpForm(
                    formKey: _formKey,
                    firstNameController: _firstNameController,
                    lastNameController: _lastNameController,
                    phoneNumberController: _phoneNumberController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                  ),
                  const SizedBox(height: defaultPadding),
                  Text('Account type',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: defaultPadding / 2),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                          value: 'customer',
                          label: Text('Shop as customer'),
                          icon: Icon(Icons.shopping_bag_outlined)),
                      ButtonSegment(
                          value: 'merchant',
                          label: Text('Sell as merchant'),
                          icon: Icon(Icons.storefront_outlined)),
                    ],
                    selected: {_accountType},
                    onSelectionChanged: (selection) =>
                        setState(() => _accountType = selection.first),
                  ),
                  const SizedBox(height: defaultPadding),
                  Row(
                    children: [
                      Checkbox(
                        onChanged: (value) {
                          setState(() {
                            _acceptedTerms = value ?? false;
                          });
                        },
                        value: _acceptedTerms,
                      ),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: "I agree with the",
                            children: [
                              TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushNamed(
                                      context,
                                      termsOfServicesScreenRoute,
                                    );
                                  },
                                text: " Terms of service ",
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const TextSpan(
                                text: "& privacy policy.",
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: defaultPadding * 2),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _signUp,
                    child: Text(
                      _isSubmitting ? "Creating account..." : "Continue",
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Do you have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, logInScreenRoute);
                        },
                        child: const Text("Log in"),
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
