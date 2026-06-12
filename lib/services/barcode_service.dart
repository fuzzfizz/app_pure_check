import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/master_product.dart';

class BarcodeService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Dio _dio = Dio();

  Future<MasterProduct?> lookupBarcode(String barcode) async {
    // Tier 1: Check Local Cache (Supabase master_products)
    try {
      final localResponse = await _supabase
          .from('master_products')
          .select()
          .eq('barcode', barcode)
          .maybeSingle();

      if (localResponse != null) {
        return MasterProduct.fromJson(localResponse);
      }
    } catch (e) {
      print('Error querying local master_products: $e');
    }

    // Tier 2: Check External API (Open Food Facts)
    try {
      final offUrl = 'https://world.openfoodfacts.org/api/v0/product/$barcode.json';
      final offResponse = await _dio.get(offUrl);

      if (offResponse.statusCode == 200 && offResponse.data['status'] == 1) {
        final productData = offResponse.data['product'];
        
        final name = productData['product_name'] ?? 'Unknown Product';
        final brand = productData['brands']?.toString().split(',').first;
        final category = productData['categories']?.toString().split(',').first;
        final imageUrl = productData['image_url'];

        // Tier 2b: Cache in local database
        final insertResponse = await _supabase.from('master_products').insert({
          'barcode': barcode,
          'name': name,
          'brand': brand,
          'category': category,
          'image_url': imageUrl,
          'data_source': 'open_food_facts',
        }).select().single();

        return MasterProduct.fromJson(insertResponse);
      }
    } catch (e) {
       print('Error querying Open Food Facts: $e');
    }

    // Tier 3: Not found anywhere (Return null to trigger crowdsourcing in UI)
    return null; 
  }
  
  // Tier 4: Crowdsourcing (User adds product manually to Master DB)
  Future<MasterProduct> crowdsourceProduct({
     required String barcode,
     required String name,
     String? imageUrl,
  }) async {
      final insertResponse = await _supabase.from('master_products').insert({
          'barcode': barcode,
          'name': name,
          'image_url': imageUrl,
          'data_source': 'user_crowdsourced',
      }).select().single();
      
      return MasterProduct.fromJson(insertResponse);
  }
}

final barcodeService = BarcodeService();
