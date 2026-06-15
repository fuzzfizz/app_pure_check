import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/inventory_provider.dart';
import '../models/master_product.dart';
import '../services/barcode_service.dart';
import 'package:intl/intl.dart';

class ManualEntryScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? extraData;
  const ManualEntryScreen({super.key, this.extraData});

  @override
  ConsumerState<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends ConsumerState<ManualEntryScreen> {
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;
  String? _barcode;
  MasterProduct? _product;

  @override
  void initState() {
    super.initState();
    if (widget.extraData != null) {
      _barcode = widget.extraData!['barcode'];
      _product = widget.extraData!['product'] as MasterProduct?;

      if (_product != null) {
        _nameController.text = _product!.name;
      }
    }
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000), 
      lastDate: DateTime(2100),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  void _saveItem() async {
    if (_nameController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name and select a date.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? masterProductId = _product?.id;

      // Tier 4: Crowdsourcing Fallback
      if (masterProductId == null && _barcode != null) {
        final newProduct = await barcodeService.crowdsourceProduct(
          barcode: _barcode!,
          name: _nameController.text.trim(),
        );
        masterProductId = newProduct.id;
      }

      await ref.read(inventoryActionProvider.notifier).addManualItem(
            _nameController.text.trim(),
            _selectedDate!,
            masterProductId: masterProductId,
          );
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
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
        title: Text(_product != null ? 'Confirm Details' : 'Add Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_barcode != null && _product == null)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 16),
                color: Colors.amber.shade100,
                child: const Text(
                  'Barcode not found in database. Please enter the details manually to help build our database!',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
              maxLength: 255, 
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'No Date Chosen!'
                        : 'Expires: ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}',
                  ),
                ),
                TextButton(
                  onPressed: _presentDatePicker,
                  child: const Text('Choose Expiration Date'),
                )
              ],
            ),
            const Spacer(),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _saveItem,
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Save Item'),
                  )
          ],
        ),
      ),
    );
  }
}
