import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/data/admin_repository.dart';

class AdminCreateCategoryScreen extends StatefulWidget {
  const AdminCreateCategoryScreen({super.key});

  @override
  State<AdminCreateCategoryScreen> createState() =>
      _AdminCreateCategoryScreenState();
}

class _AdminCreateCategoryScreenState extends State<AdminCreateCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _svgSrcController = TextEditingController();
  final _parentIdController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    _svgSrcController.dispose();
    _parentIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AdminRepository.createCategory(
        _nameController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        svgSrc: _svgSrcController.text.trim(),
        parentId: _parentIdController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category created successfully.')),
      );
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Category'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Category Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a category name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _svgSrcController,
                decoration: const InputDecoration(labelText: 'SVG Source'),
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _parentIdController,
                decoration:
                    const InputDecoration(labelText: 'Parent Category ID'),
              ),
              const SizedBox(height: defaultPadding * 2),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Create Category'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
