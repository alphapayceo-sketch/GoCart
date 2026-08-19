import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/data/user_repository.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _line1Controller = TextEditingController();
  final TextEditingController _line2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _line1Controller.dispose();
    _line2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await UserRepository.addAddress({
        'address_line1': _line1Controller.text.trim(),
        'address_line2': _line2Controller.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'postal_code': _postalCodeController.text.trim(),
        'country': _countryController.text.trim(),
        'is_default': true,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address saved successfully.')),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', ''))),
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
      appBar: AppBar(
        title: const Text('Add New Address'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _line1Controller,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Address Line 1 is required';
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: 'Address Line 1'),
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _line2Controller,
                decoration: const InputDecoration(
                  labelText: 'Address Line 2 (Optional)',
                ),
              ),
              const SizedBox(height: defaultPadding),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'City is required';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(labelText: 'City'),
                    ),
                  ),
                  const SizedBox(width: defaultPadding),
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'State is required';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(labelText: 'State'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: defaultPadding),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _postalCodeController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Zip Code is required';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(labelText: 'Zip Code'),
                    ),
                  ),
                  const SizedBox(width: defaultPadding),
                  Expanded(
                    child: TextFormField(
                      controller: _countryController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Country is required';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(labelText: 'Country'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: defaultPadding * 2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _saveAddress,
                  child: Text(
                      _isSubmitting ? 'Saving address...' : 'Save Address'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
