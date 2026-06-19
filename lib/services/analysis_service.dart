import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/analysis_model.dart';

final analysisServiceProvider = Provider<AnalysisService>((ref) {
  return AnalysisService(Supabase.instance.client);
});

class AnalysisService {
  final SupabaseClient _supabase;

  AnalysisService(this._supabase);

  Future<AnalysisModel> analyzeProduct({
    String? barcode,
    String? manualIngredients,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'analyze-ingredients',
        body: {
          'barcode': barcode,
          'manualIngredients': manualIngredients,
        },
      );

      if (response.status == 200 && response.data != null) {
        return AnalysisModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to analyze product: ${response.data?['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Analysis failed: $e');
    }
  }

  Future<Map<String, dynamic>?> fetchExternalProduct(String barcode) async {
    try {
      final response = await _supabase.functions.invoke(
        'fetch-external-product',
        body: {'barcode': barcode},
      );

      if (response.status == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
