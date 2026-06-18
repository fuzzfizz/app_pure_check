import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final upsertServiceProvider = Provider<UpsertService>((ref) {
  return UpsertService(Supabase.instance.client);
});

class UpsertService {
  final SupabaseClient _supabase;

  UpsertService(this._supabase);

  Future<void> saveProductToDatabase({
    required String barcode,
    required String productName,
    String? brand,
    required String ingredientsText,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'upsert-product',
        body: {
          'barcode': barcode,
          'productName': productName,
          'brand': brand,
          'ingredientsText': ingredientsText,
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to save product: ${response.data?['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Database cache failed: $e');
    }
  }
}
