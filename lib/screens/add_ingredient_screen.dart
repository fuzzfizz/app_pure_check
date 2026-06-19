import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../repositories/ingredient_repository.dart';

class AddIngredientScreen extends ConsumerStatefulWidget {
  const AddIngredientScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddIngredientScreen> createState() => _AddIngredientScreenState();
}

class _AddIngredientScreenState extends ConsumerState<AddIngredientScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _commonNamesController = TextEditingController();
  bool _isAllergen = false;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final commonNames = _commonNamesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      await ref.read(ingredientRepositoryProvider).insertIngredient(
        _nameController.text.trim(),
        _descriptionController.text.trim(),
        commonNames,
        _isAllergen,
      );
      if (mounted) {
        context.pop(); // Go back
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingredient proposed!')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Ingredient')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController, 
              decoration: const InputDecoration(labelText: 'Name of the ingredient *')
            ),
            CheckboxListTile(
              title: const Text('Alert me if this is in my skincare'),
              value: _isAllergen,
              onChanged: (val) => setState(() => _isAllergen = val!),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text('Add more details (optional)', style: TextStyle(fontSize: 14)),
              children: [
                TextField(
                  controller: _descriptionController, 
                  decoration: const InputDecoration(labelText: 'Description/Notes')
                ),
                TextField(
                  controller: _commonNamesController, 
                  decoration: const InputDecoration(labelText: 'Other names for this ingredient (comma separated)')
                ),
              ],
            ),
            const SizedBox(height: 32),
            _isLoading 
              ? const CircularProgressIndicator() 
              : ElevatedButton(
                  onPressed: _submit, 
                  child: const Text('Submit'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                ),
          ],
        ),
      ),
    );
  }
}
