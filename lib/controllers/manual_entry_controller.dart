import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/product_repository.dart';
import '../states/manual_entry_state.dart';
import '../models/master_product.dart';

final manualEntryControllerProvider = NotifierProvider<ManualEntryController, ManualEntryState>(() {
  return ManualEntryController();
});

class ManualEntryController extends Notifier<ManualEntryState> {
  late final ProductRepository _productRepo;

  @override
  ManualEntryState build() {
    _productRepo = ref.watch(productRepositoryProvider);
    return const ManualEntryState();
  }

  Future<void> submitProduct({
    required String barcode,
    required String name,
    String? brand,
    required String ingredientsText,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final product = MasterProduct(
        barcode: barcode,
        productName: name,
        brand: brand,
        source: 'user_submitted',
        isVerified: false,
      );

      // Insert basic product info (Phase 2 schema doesn't have a raw text column for ingredients,
      // this will be sent to the Edge Function in Phase 3/4)
      await _productRepo.insertProduct(product);

      // In a real app we might pass the ingredientsText to a phase 3 analysis screen here
      
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
