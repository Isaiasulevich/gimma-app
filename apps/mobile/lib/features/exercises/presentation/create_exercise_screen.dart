import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/photo_service.dart';
import 'exercise_list_screen.dart' show exerciseRepositoryProvider;
import 'widgets/muscle_picker.dart';

final _photoServiceProvider = Provider<PhotoService>((ref) => PhotoService());

class CreateExerciseScreen extends ConsumerStatefulWidget {
  const CreateExerciseScreen({super.key});

  @override
  ConsumerState<CreateExerciseScreen> createState() => _CreateExerciseScreenState();
}

class _CreateExerciseScreenState extends ConsumerState<CreateExerciseScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _primary;
  final _secondary = <String>{};
  String _equipment = 'barbell';
  bool _isUnilateral = false;
  String? _photoPath;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final photoService = ref.read(_photoServiceProvider);
    final path = await photoService.pickAndStage();
    if (path != null) {
      setState(() => _photoPath = path);
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty || _primary == null) return;
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _saving = true);
    final repo = ref.read(exerciseRepositoryProvider);
    await repo.createExercise(
      ownerUserId: userId,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      primaryMuscle: _primary!,
      secondaryMuscles: _secondary.toList(),
      equipment: _equipment,
      isUnilateral: _isUnilateral,
      localPhotoPath: _photoPath,
    );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New exercise')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(labelText: 'Description (optional)'),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _pickPhoto,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _photoPath == null
                  ? const Center(child: Text('+ Add reference image'))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_photoPath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Primary muscle', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          MusclePicker(
            selected: _primary == null ? <String>{} : <String>{_primary!},
            onChanged: (s) => setState(() => _primary = s.isEmpty ? null : s.first),
          ),
          const SizedBox(height: 16),
          const Text('Secondary muscles', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          MusclePicker(
            selected: _secondary,
            multi: true,
            onChanged: (s) => setState(() {
              _secondary
                ..clear()
                ..addAll(s);
            }),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _equipment,
            decoration: const InputDecoration(labelText: 'Equipment'),
            items: const [
              DropdownMenuItem(value: 'barbell', child: Text('Barbell')),
              DropdownMenuItem(value: 'dumbbell', child: Text('Dumbbell')),
              DropdownMenuItem(value: 'machine', child: Text('Machine')),
              DropdownMenuItem(value: 'cable', child: Text('Cable')),
              DropdownMenuItem(value: 'bodyweight', child: Text('Bodyweight')),
              DropdownMenuItem(value: 'band', child: Text('Band')),
              DropdownMenuItem(value: 'kettlebell', child: Text('Kettlebell')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            onChanged: (v) => setState(() => _equipment = v!),
          ),
          SwitchListTile(
            title: const Text('Unilateral (single limb)'),
            value: _isUnilateral,
            onChanged: (v) => setState(() => _isUnilateral = v),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
