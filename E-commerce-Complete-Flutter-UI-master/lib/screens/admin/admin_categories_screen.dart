import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop/constants.dart';
import 'package:shop/data/admin_repository.dart';
import 'package:shop/models/category_model.dart';
import 'package:shop/route/route_constants.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  bool _isLoading = true;
  List<CategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final categories = await AdminRepository.getAdminCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
      });
    } catch (_) {
      if (!mounted) return;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteCategory(String id) async {
    try {
      await AdminRepository.deleteCategory(id);
      await _loadCategories();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category deleted successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.pushNamed(
                context,
                adminCreateCategoryScreenRoute,
              );
              await _loadCategories();
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _categories.isEmpty
                ? const Center(child: Text('No categories found.'))
                : ListView.separated(
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return ListTile(
                        leading:
                            category.image != null && category.image!.isNotEmpty
                                ? Image.network(category.image!,
                                    width: 48, height: 48, fit: BoxFit.cover)
                                : const Icon(Icons.category_outlined),
                        title: Text(category.title),
                        subtitle: Text(category.image ?? 'No image'),
                        onTap: () async {
                          if (category.id == null) return;
                          final controller =
                              TextEditingController(text: category.title);
                          final image = await ImagePicker().pickImage(
                              source: ImageSource.gallery, imageQuality: 80);
                          final name = await showDialog<String>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Edit category'),
                              content: TextField(
                                  controller: controller,
                                  decoration: const InputDecoration(
                                      labelText: 'Category name')),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel')),
                                FilledButton(
                                    onPressed: () => Navigator.pop(
                                        context, controller.text.trim()),
                                    child: const Text('Save')),
                              ],
                            ),
                          );
                          controller.dispose();
                          if (name == null || name.isEmpty) return;
                          try {
                            await AdminRepository.updateCategory(
                                category.id!, name);
                            if (image != null)
                              await AdminRepository.updateCategoryImage(
                                  category.id!, File(image.path));
                            await _loadCategories();
                          } catch (error) {
                            if (mounted)
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(error.toString())));
                          }
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            if (category.id != null) {
                              _deleteCategory(category.id!);
                            }
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
