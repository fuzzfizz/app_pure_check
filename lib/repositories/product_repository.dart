import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/master_product.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(Supabase.instance.client);
});

class ProductRepository {
  final SupabaseClient _supabase;

  ProductRepository(this._supabase);

  Future<MasterProduct?> getProductByBarcode(String barcode) async {
    try {
      final response = await _supabase
          .from('master_products')
          .select()
          .eq('barcode', barcode)
          .maybeSingle();

      if (response != null) {
        return MasterProduct.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  Future<void> insertProduct(MasterProduct product) async {
    try {
      await _supabase.from('master_products').insert(product.toJson());
    } catch (e) {
      throw Exception('Failed to insert product: $e');
    }
  }
}
