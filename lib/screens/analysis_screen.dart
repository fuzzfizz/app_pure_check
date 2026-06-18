import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/analysis_controller.dart';
import '../services/upsert_service.dart';
import '../models/master_product.dart';

class AnalysisScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> extraData;
  const AnalysisScreen({super.key, required this.extraData});

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  bool _isSaving = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final barcode = widget.extraData['barcode'] as String?;
      final manualIngredients = widget.extraData['ingredientsText'] as String?;
      ref.read(analysisControllerProvider.notifier).analyzeProduct(
            barcode: barcode,
            manualIngredients: manualIngredients,
          );
    });
  }

  Future<void> _saveToDatabase() async {
    final barcode = widget.extraData['barcode'] as String?;
    final productName = widget.extraData['name'] as String?;
    final manualIngredients = widget.extraData['ingredientsText'] as String?;
    final product = widget.extraData['product'] as MasterProduct?;

    if (barcode == null || productName == null || manualIngredients == null || manualIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot save without barcode, name, and ingredients.')),
      );
      return;
    }

    // Do not re-save if it was a cache hit
    if (product != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product is already in the database.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref.read(upsertServiceProvider).saveProductToDatabase(
        barcode: barcode,
        productName: productName,
        brand: widget.extraData['brand'] as String?,
        ingredientsText: manualIngredients,
      );
      
      if (mounted) {
        setState(() {
          _isSaving = false;
          _isSaved = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thank you! Product saved to Master Database.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(analysisControllerProvider);
    final product = widget.extraData['product'] as MasterProduct?;
    final productName = product?.productName ?? widget.extraData['name'] as String? ?? 'Product';
    final isCacheHit = product != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Analysis Result'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(analysisControllerProvider.notifier).reset();
            context.go('/dashboard');
          },
        ),
      ),
      body: state.isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analyzing ingredients with AI...'),
                ],
              ),
            )
          : state.error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 60),
                        const SizedBox(height: 16),
                        Text(
                          'Analysis Failed:\n${state.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                             final barcode = widget.extraData['barcode'] as String?;
                             final manualIngredients = widget.extraData['ingredientsText'] as String?;
                             ref.read(analysisControllerProvider.notifier).analyzeProduct(
                                   barcode: barcode,
                                   manualIngredients: manualIngredients,
                                 );
                          },
                          child: const Text('Retry'),
                        )
                      ],
                    ),
                  ),
                )
              : state.result != null
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            productName,
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          _buildSuitabilityCard(state.result!.isSafe, state.result!.suitabilityScore),
                          const SizedBox(height: 24),
                          if (state.result!.flaggedAllergens.isNotEmpty)
                            _buildAllergensList(state.result!.flaggedAllergens),
                          const SizedBox(height: 24),
                          _buildProsCons(state.result!.pros, state.result!.cons),
                          const SizedBox(height: 24),
                          const Text('AI Reasoning', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 8),
                          Text(state.result!.reasoning),
                          const SizedBox(height: 32),
                          if (!isCacheHit) ...[
                            _isSaving 
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton.icon(
                                  onPressed: _isSaved ? null : _saveToDatabase,
                                  icon: Icon(_isSaved ? Icons.cloud_done : Icons.cloud_upload),
                                  label: Text(_isSaved ? 'Saved to Master Database' : 'Verify & Save to Database'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade100,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                            const SizedBox(height: 16),
                          ],
                          ElevatedButton(
                            onPressed: () {
                              ref.read(analysisControllerProvider.notifier).reset();
                              context.go('/dashboard');
                            },
                            child: const Text('Return to Dashboard'),
                          )
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
    );
  }

  Widget _buildSuitabilityCard(bool isSafe, int score) {
    return Card(
      color: isSafe ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              isSafe ? Icons.check_circle : Icons.warning,
              color: isSafe ? Colors.green : Colors.red,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              isSafe ? 'Safe to Use' : 'Not Recommended',
              style: TextStyle(
                color: isSafe ? Colors.green.shade900 : Colors.red.shade900,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text('Suitability Score: $score/100'),
          ],
        ),
      ),
    );
  }

  Widget _buildAllergensList(List<dynamic> allergens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Flagged Allergens/Irritants',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
        ),
        const SizedBox(height: 8),
        ...allergens.map((allergen) => ListTile(
              leading: const Icon(Icons.warning_amber_rounded, color: Colors.red),
              title: Text(allergen.ingredient, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(allergen.reason),
              contentPadding: EdgeInsets.zero,
            )),
      ],
    );
  }

  Widget _buildProsCons(List<String> pros, List<String> cons) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pros', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ...pros.map((p) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('• ', style: TextStyle(color: Colors.green)),
                    Expanded(child: Text(p)),
                  ])),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cons', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
              ...cons.map((c) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('• ', style: TextStyle(color: Colors.orange)),
                    Expanded(child: Text(c)),
                  ])),
            ],
          ),
        ),
      ],
    );
  }
}
