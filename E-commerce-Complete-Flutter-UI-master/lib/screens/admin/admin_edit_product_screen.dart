import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop/constants.dart';
import 'package:shop/data/admin_repository.dart';
import 'package:shop/models/category_model.dart';
import 'package:shop/models/product_model.dart';

class AdminEditProductScreen extends StatefulWidget {
  final ProductModel product;

  const AdminEditProductScreen({super.key, required this.product});

  @override
  State<AdminEditProductScreen> createState() => _AdminEditProductScreenState();
}

class _AdminEditProductScreenState extends State<AdminEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _priceController;
  late final TextEditingController _priceAfterDiscountController;
  late final TextEditingController _discountPercentController;
  late final TextEditingController _stockController;

  final List<XFile> _selectedImages = [];
  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.title);
    _brandController = TextEditingController(text: widget.product.brandName);
    _priceController =
        TextEditingController(text: widget.product.price.toString());
    _priceAfterDiscountController = TextEditingController(
      text: widget.product.priceAfetDiscount?.toString() ?? '',
    );
    _discountPercentController = TextEditingController(
      text: widget.product.dicountpercent?.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: widget.product.stockQuantity?.toString() ?? '',
    );
    _selectedCategoryId = widget.product.categoryId;
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _priceAfterDiscountController.dispose();
    _discountPercentController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await AdminRepository.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
      });
    } catch (_) {
      if (!mounted) return;
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(imageQuality: 80);

    if (!mounted) return;
    if (images.isEmpty) return;

    setState(() {
      _selectedImages.clear();
      _selectedImages.addAll(images);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final fields = <String, String>{
        'name': _nameController.text.trim(),
        'brand_name': _brandController.text.trim(),
        'price': _priceController.text.trim(),
        'price_after_discount': _priceAfterDiscountController.text.trim(),
        'discount_percent': _discountPercentController.text.trim(),
        'stock_quantity': _stockController.text.trim(),
      };

      if (_selectedCategoryId != null && _selectedCategoryId!.isNotEmpty) {
        fields['category_id'] = _selectedCategoryId!;
      }

      final imageFiles = _selectedImages.map((e) => File(e.path)).toList();
      await AdminRepository.updateProduct(
          widget.product.id!, fields, imageFiles);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully.')),
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
        title: const Text('Edit Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Brand Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter brand name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _priceAfterDiscountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price After Discount (optional)',
                ),
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _discountPercentController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Discount Percent'),
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stock Quantity'),
              ),
              const SizedBox(height: defaultPadding),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategoryId,
                items: _categories
                    .where((category) => category.id != null)
                    .map(
                      (category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(category.title),
                      ),
                    )
                    .toList(),
                decoration: const InputDecoration(labelText: 'Category'),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
              ),
              const SizedBox(height: defaultPadding),
              if (widget.product.imageUrls.isNotEmpty &&
                  _selectedImages.isEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Current image preview'),
                    const SizedBox(height: 8),
                    Image.network(
                      widget.product.image,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: defaultPadding),
                  ],
                ),
              ElevatedButton(
                onPressed: _pickImages,
                child: const Text('Pick New Images'),
              ),
              const SizedBox(height: defaultPadding),
              if (_selectedImages.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedImages
                      .map(
                        (image) => Image.file(
                          File(image.path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      )
                      .toList(),
                ),
              if (_selectedImages.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: defaultPadding),
                  child: Text(
                    'No new images selected. Existing images will remain unchanged.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              const SizedBox(height: defaultPadding * 2),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Update Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
