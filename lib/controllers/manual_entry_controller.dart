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
    bool isReview = false,
    MasterProduct? existingProduct,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // In Phase 4, we no longer insert the product directly from the client.
      // We pass the data to the Analysis screen, and if the user is happy
      // with the AI's analysis, they can choose to save it to the master database.
      
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
