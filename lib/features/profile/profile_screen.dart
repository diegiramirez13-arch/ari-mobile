import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _occupationController = TextEditingController();
  bool _isProUser = false;

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref.read(profileControllerProvider.notifier).saveProfile(
          name: _nameController.text,
          bio: _bioController.text,
          occupation: _occupationController.text,
          isProUser: _isProUser,
        );

    if (!mounted) {
      return;
    }

    final error = ref.read(profileErrorProvider);
    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil guardado correctamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final profileError = ref.watch(profileErrorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
      ),
      body: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ProfileForm(
          formKey: _formKey,
          nameController: _nameController,
          bioController: _bioController,
          occupationController: _occupationController,
          isSaving: false,
          errorMessage: profileError ?? 'No se pudo cargar el perfil.',
          isProUser: _isProUser,
          onProModeChanged: (value) => setState(() => _isProUser = value),
          onSave: _saveProfile,
        ),
        data: (profile) {
          if (_nameController.text.isEmpty) {
            _nameController.text = profile?.name ?? '';
            _bioController.text = profile?.bio ?? '';
            _occupationController.text = profile?.occupation ?? '';
            _isProUser = profile?.isProUser ?? false;
          }

          return _ProfileForm(
            formKey: _formKey,
            nameController: _nameController,
            bioController: _bioController,
            occupationController: _occupationController,
            isSaving: profileState.isLoading,
            errorMessage: profileError,
            isProUser: _isProUser,
            onProModeChanged: (value) => setState(() => _isProUser = value),
            onSave: _saveProfile,
          );
        },
      ),
    );
  }
}

class _ProfileForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController bioController;
  final TextEditingController occupationController;
  final bool isSaving;
  final String? errorMessage;
  final bool isProUser;
  final ValueChanged<bool> onProModeChanged;
  final VoidCallback onSave;

  const _ProfileForm({
    required this.formKey,
    required this.nameController,
    required this.bioController,
    required this.occupationController,
    required this.isSaving,
    required this.errorMessage,
    required this.isProUser,
    required this.onProModeChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (errorMessage != null) ...[
                Text(
                  errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: occupationController,
                decoration: const InputDecoration(
                  labelText: 'Profesión u ocupación',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: bioController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  hintText: 'Cuéntale a ARI sobre ti (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Modo Pro'),
                subtitle: const Text(
                  'Habilita IA avanzada para este usuario cuando haya API key.',
                ),
                value: isProUser,
                onChanged: isSaving ? null : onProModeChanged,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: isSaving ? null : onSave,
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(isSaving ? 'Guardando...' : 'Guardar perfil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
