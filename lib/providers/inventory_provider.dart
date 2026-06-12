import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/inventory_models.dart';
import '../services/inventory_repository.dart';

// Provider to hold the currently selected Fridge ID
class SelectedFridgeIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setId(String id) {
    state = id;
  }
}

final selectedFridgeIdProvider = NotifierProvider<SelectedFridgeIdNotifier, String?>(() {
  return SelectedFridgeIdNotifier();
});

// FutureProvider to fetch the user's fridges
final userFridgesProvider = FutureProvider<List<Fridge>>((ref) async {
  final fridges = await inventoryRepository.getUserFridges();
  
  // Auto-select the first fridge if none is selected
  if (fridges.isNotEmpty) {
    // We use a microtask to avoid modifying providers during build phase
    Future.microtask(() {
       if(ref.read(selectedFridgeIdProvider) == null) {
          ref.read(selectedFridgeIdProvider.notifier).setId(fridges.first.id);
       }
    });
  }
  return fridges;
});

// FutureProvider to fetch inventory items based on the selected fridge
// It automatically recalculates if selectedFridgeIdProvider changes.
final inventoryProvider = FutureProvider<List<InventoryItem>>((ref) async {
  final fridgeId = ref.watch(selectedFridgeIdProvider);
  if (fridgeId == null) return [];
  
  return await inventoryRepository.getInventoryItems(fridgeId);
});

// A simple notifier to handle CRUD actions and trigger refreshes
class InventoryNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> addManualItem(String name, DateTime expiry, {String? masterProductId}) async {
    final fridgeId = ref.read(selectedFridgeIdProvider);
    if (fridgeId == null) throw Exception("No fridge selected");

    await inventoryRepository.addManualItem(
      fridgeId: fridgeId,
      itemName: name,
      expirationDate: expiry,
      masterProductId: masterProductId,
    );
    // Invalidate the provider to force a re-fetch of the list
    ref.invalidate(inventoryProvider);
  }

  Future<void> consumeItem(String id) async {
    await inventoryRepository.consumeItem(id);
    ref.invalidate(inventoryProvider);
  }

  Future<void> deleteItem(String id) async {
    await inventoryRepository.deleteItem(id);
    ref.invalidate(inventoryProvider);
  }
}

final inventoryActionProvider = NotifierProvider<InventoryNotifier, void>(() {
  return InventoryNotifier();
});
