import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/inventory_provider.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fridgesAsync = ref.watch(userFridgesProvider);
    final inventoryAsync = ref.watch(inventoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Fridge'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
            },
          )
        ],
      ),
      body: fridgesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (fridges) {
          if (fridges.isEmpty) {
            return const Center(child: Text('No fridge found.'));
          }

          return inventoryAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (items) {
              if (items.isEmpty) {
                return const Center(
                  child: Text('Your fridge is empty.\nTap + to add items.'),
                );
              }

              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isExpired = item.expirationDate.isBefore(DateTime.now());
                  final formattedDate = DateFormat('MMM dd, yyyy').format(item.expirationDate);

                  return ListTile(
                    title: Text(
                      item.itemName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isExpired ? Colors.red : null,
                      ),
                    ),
                    subtitle: Text('Expires: $formattedDate'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isExpired)
                          const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Chip(
                              label: Text('Expired', style: TextStyle(color: Colors.white, fontSize: 10)),
                              backgroundColor: Colors.red,
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                          onPressed: () {
                             ref.read(inventoryActionProvider.notifier).consumeItem(item.id);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                             ref.read(inventoryActionProvider.notifier).deleteItem(item.id);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'scan_btn',
            onPressed: () => context.push('/scanner'),
            child: const Icon(Icons.barcode_reader),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'manual_btn',
            onPressed: () => context.push('/manual-entry'),
            child: const Icon(Icons.edit),
          ),
        ],
      ),
    );
  }
}
