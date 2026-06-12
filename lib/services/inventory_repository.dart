import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/inventory_models.dart';

class InventoryRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Fridge>> getUserFridges() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('fridges')
          .select()
          .eq('owner_id', userId);
      
      return (response as List).map((e) => Fridge.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch fridges: $e');
    }
  }

  Future<List<InventoryItem>> getInventoryItems(String fridgeId) async {
    try {
      final response = await _supabase
          .from('inventory_items')
          .select()
          .eq('fridge_id', fridgeId)
          .eq('is_consumed', false)
          .order('expiration_date', ascending: true); // Core Feature: Closest expiry first
      
      return (response as List).map((e) => InventoryItem.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch inventory: $e');
    }
  }

  Future<void> addManualItem({
    required String fridgeId,
    required String itemName,
    required DateTime expirationDate,
    String? masterProductId,
  }) async {
    try {
       final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _supabase.from('inventory_items').insert({
        'fridge_id': fridgeId,
        'item_name': itemName,
        'expiration_date': expirationDate.toIso8601String(),
        'added_by': userId,
        'master_product_id': masterProductId,
      });
    } catch (e) {
      throw Exception('Failed to add item: $e');
    }
  }

  Future<void> consumeItem(String itemId) async {
    try {
      await _supabase
          .from('inventory_items')
          .update({'is_consumed': true})
          .eq('id', itemId);
    } catch (e) {
      throw Exception('Failed to consume item: $e');
    }
  }

  Future<void> deleteItem(String itemId) async {
     try {
      await _supabase
          .from('inventory_items')
          .delete()
          .eq('id', itemId);
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }
}

final inventoryRepository = InventoryRepository();
