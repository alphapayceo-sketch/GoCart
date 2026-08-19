import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/data/review_repository.dart';
import 'package:shop/models/product_model.dart';

class WriteReviewScreen extends StatefulWidget {
  const WriteReviewScreen({super.key, this.productId, this.product});

  final String? productId;
  final ProductModel? product;

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  int selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Write a Review"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Rating", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () => setState(() => selectedRating = index + 1),
                  icon: Icon(
                    index < selectedRating ? Icons.star : Icons.star_border,
                    color: index < selectedRating ? warningColor : blackColor20,
                    size: 40,
                  ),
                );
              }),
            ),
            const SizedBox(height: defaultPadding),
            Text("Comment", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _commentController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Tell us what you think about this product...",
              ),
            ),
            const SizedBox(height: defaultPadding * 2),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: Text(_isSubmitting ? 'Submitting...' : "Submit Review"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final productId = widget.productId ?? widget.product?.id;
    if (productId == null ||
        productId.isEmpty ||
        selectedRating == 0 ||
        _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Select a rating and write a comment.')));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await const ReviewRepository().addReview(
          productId: productId,
          rating: selectedRating,
          comment: _commentController.text.trim());
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
