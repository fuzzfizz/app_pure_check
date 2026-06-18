import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/profile_controller.dart';
import 'package:go_router/go_router.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  String _selectedSkinType = 'unknown';
  final _concernsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profileState = ref.read(profileControllerProvider);
    if (profileState.profile != null) {
      _selectedSkinType = profileState.profile!.skinType;
      _concernsController.text = profileState.profile!.skinConcerns.join(', ');
    }
  }

  void _save() {
    final concerns = _concernsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    ref.read(profileControllerProvider.notifier).updateProfile(
      skinType: _selectedSkinType,
      skinConcerns: concerns,
    );
    
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: profileState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Skin Type'),
                  DropdownButton<String>(
                    value: _selectedSkinType,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'unknown', child: Text('Unknown')),
                      DropdownMenuItem(value: 'dry', child: Text('Dry')),
                      DropdownMenuItem(value: 'oily', child: Text('Oily')),
                      DropdownMenuItem(value: 'combination', child: Text('Combination')),
                      DropdownMenuItem(value: 'sensitive', child: Text('Sensitive')),
                      DropdownMenuItem(value: 'normal', child: Text('Normal')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedSkinType = val);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _concernsController,
                    decoration: const InputDecoration(
                      labelText: 'Skin Concerns (comma separated)',
                      hintText: 'Acne, Wrinkles, Redness',
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save Profile'),
                  ),
                ],
              ),
            ),
    );
  }
}
