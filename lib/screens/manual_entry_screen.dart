import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/manual_entry_controller.dart';
import '../models/master_product.dart';

class ManualEntryScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? extraData;
  const ManualEntryScreen({super.key, this.extraData});

  @override
  ConsumerState<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends ConsumerState<ManualEntryScreen> {
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _ingredientsController = TextEditingController();
  
  String? _barcode;
  MasterProduct? _product;
  bool _isReview = false;

  @override
  void initState() {
    super.initState();
    if (widget.extraData != null) {
      _barcode = widget.extraData!['barcode'];
      _product = widget.extraData!['product'] as MasterProduct?;
      _isReview = widget.extraData!['is_review'] ?? false;

      if (_product != null) {
        _nameController.text = _product!.productName;
        _brandController.text = _product!.brand ?? '';
      }
    }
  }

  void _saveItem() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a product name.')),
      );
      return;
    }
    if (_ingredientsController.text.trim().isEmpty && !_isReview) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the ingredients.')),
      );
      return;
    }

    if (_barcode == null) {
      // In a real app we might generate a fake barcode or require one
      _barcode = 'MANUAL-${DateTime.now().millisecondsSinceEpoch}';
    }

    ref.read(manualEntryControllerProvider.notifier).submitProduct(
      barcode: _barcode!,
      name: _nameController.text.trim(),
      brand: _brandController.text.trim(),
      ingredientsText: _ingredientsController.text.trim(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(manualEntryControllerProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${next.error}')),
        );
      }
      if (next.isSuccess && !(previous?.isSuccess ?? false)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product submitted successfully.')),
        );
        context.go('/'); // Return to dashboard or previous screen
      }
    });

    final state = ref.watch(manualEntryControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isReview ? 'Confirm Details' : 'Manual Entry'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_barcode != null && !_isReview)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 16),
                color: Colors.amber.shade100,
                child: const Text(
                  'Barcode not found. Please enter the details manually and provide the ingredients to help verify this product!',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Product Name *'),
              enabled: !_isReview,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _brandController,
              decoration: const InputDecoration(labelText: 'Brand (Optional)'),
              enabled: !_isReview,
            ),
            const SizedBox(height: 16),
            if (!_isReview) ...[
              const Text(
                'Ingredients List',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _ingredientsController,
                decoration: const InputDecoration(
                  hintText: 'Type or paste the ingredients list here...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                   // Future Phase: Take photo and run OCR
                   ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('OCR feature coming in future update.')),
                   );
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo of Ingredients (Coming Soon)'),
                style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.grey.shade200,
                   foregroundColor: Colors.black87,
                ),
              ),
            ],
            const SizedBox(height: 32),
            state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _saveItem,
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: Text(_isReview ? 'Proceed to Analysis' : 'Submit Product'),
                  )
          ],
        ),
      ),
    );
  }
}
