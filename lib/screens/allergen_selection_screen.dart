import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/profile_controller.dart';

class AllergenSelectionScreen extends ConsumerWidget {
  const AllergenSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);

    if (profileState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final allIngredients = profileState.allIngredients;
    final userAllergenIds = profileState.userAllergens.map((e) => e.id).toSet();

    return Scaffold(
      appBar: AppBar(title: const Text('Select Allergens')),
      body: ListView.builder(
        itemCount: allIngredients.length,
        itemBuilder: (context, index) {
          final ingredient = allIngredients[index];
          final isSelected = userAllergenIds.contains(ingredient.id);

          return CheckboxListTile(
            title: Text(ingredient.name),
            subtitle: ingredient.description != null ? Text(ingredient.description!) : null,
            value: isSelected,
            onChanged: (val) {
              if (val != null) {
                ref.read(profileControllerProvider.notifier).toggleAllergen(ingredient.id, val);
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-ingredient'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
