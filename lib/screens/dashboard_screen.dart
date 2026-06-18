import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PureCheck Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
          )
        ],
      ),
      body: profileState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Skin Profile', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text('Type: ${profileState.profile?.skinType ?? 'Unknown'}'),
                          Text('Concerns: ${profileState.profile?.skinConcerns.join(', ') ?? 'None'}'),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.push('/profile-edit'),
                              child: const Text('Edit Profile'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Known Allergens', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          if (profileState.userAllergens.isEmpty)
                            const Text('No allergens selected.')
                          else
                            Wrap(
                              spacing: 8,
                              children: profileState.userAllergens
                                  .map((a) => Chip(label: Text(a.name)))
                                  .toList(),
                            ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.push('/allergens'),
                              child: const Text('Manage Allergens'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/scanner'),
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scan Product'),
      ),
    );
  }
}
