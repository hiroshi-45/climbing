import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_database.dart';
import '../providers.dart';
import 'gyms_tab.dart' show gradeSystemLabels;

class GymFormScreen extends ConsumerStatefulWidget {
  const GymFormScreen({super.key, this.gym});

  /// null なら新規追加、非nullなら編集。
  final Gym? gym;

  @override
  ConsumerState<GymFormScreen> createState() => _GymFormScreenState();
}

class _GymFormScreenState extends ConsumerState<GymFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _location;
  late String _gradeSystem;

  bool get _isEdit => widget.gym != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.gym?.name ?? '');
    _location = TextEditingController(text: widget.gym?.location ?? '');
    _gradeSystem = widget.gym?.gradeSystem ?? 'grade';
  }

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final db = ref.read(databaseProvider);
    final location = _location.text.trim();
    if (_isEdit) {
      await db.updateGym(
        GymsCompanion(
          id: Value(widget.gym!.id),
          name: Value(_name.text.trim()),
          location: Value(location.isEmpty ? null : location),
          gradeSystem: Value(_gradeSystem),
          createdAt: Value(widget.gym!.createdAt),
        ),
      );
    } else {
      await db.insertGym(
        GymsCompanion(
          name: Value(_name.text.trim()),
          location: Value(location.isEmpty ? null : location),
          gradeSystem: Value(_gradeSystem),
        ),
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ジムを削除'),
        content: const Text('このジムと、ひも付く登攀記録もすべて削除されます。よろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(databaseProvider).deleteGym(widget.gym!.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'ジムを編集' : 'ジムを追加'),
        actions: [
          if (_isEdit)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
              tooltip: '削除',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'ジム名 *',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'ジム名を入力してください' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _location,
              decoration: const InputDecoration(
                labelText: '場所（任意）',
                hintText: '例: 渋谷',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _gradeSystem,
              decoration: const InputDecoration(
                labelText: 'グレード体系',
                border: OutlineInputBorder(),
              ),
              items: gradeSystemLabels.entries
                  .map(
                    (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _gradeSystem = v ?? 'grade'),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: Text(_isEdit ? '保存' : '追加'),
            ),
          ],
        ),
      ),
    );
  }
}
