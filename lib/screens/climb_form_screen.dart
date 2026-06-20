import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../data/app_database.dart';
import '../data/photo_storage.dart';
import '../providers.dart';
import 'paywall_screen.dart';
import 'photo_viewer_screen.dart';

/// 無料プランで1記録に添付できる写真の上限。
const _freePhotoLimit = 1;

/// フォーム上の写真1枚分の状態。
class _PhotoDraft {
  _PhotoDraft({this.id, required this.path});

  /// DB上のID（既存写真のみ。新規はnull）。
  final int? id;
  final String path;

  bool get isPersisted => id != null;
}

class ClimbFormScreen extends ConsumerStatefulWidget {
  const ClimbFormScreen({super.key, this.climb});

  /// null なら新規、非nullなら編集。
  final Climb? climb;

  @override
  ConsumerState<ClimbFormScreen> createState() => _ClimbFormScreenState();
}

class _ClimbFormScreenState extends ConsumerState<ClimbFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _grade;
  late final TextEditingController _memo;

  int? _gymId;
  int? _wallTypeId;
  late DateTime _date;
  int _attempts = 1;
  bool _isSent = false;
  bool _saving = false;

  final List<_PhotoDraft> _photos = [];
  // 保存成功時に消すファイル（削除した既存写真／差し替えた新規写真）
  final List<String> _filesToCleanup = [];
  final Set<int> _removedPersistedIds = {};

  bool get _isEdit => widget.climb != null;

  @override
  void initState() {
    super.initState();
    final c = widget.climb;
    _grade = TextEditingController(text: c?.grade ?? '');
    _memo = TextEditingController(text: c?.memo ?? '');
    _gymId = c?.gymId;
    _wallTypeId = c?.wallTypeId;
    _date = c?.date ?? DateTime.now();
    _attempts = c?.attempts ?? 1;
    _isSent = c?.isSent ?? false;
    if (_isEdit) _loadExistingPhotos();
  }

  Future<void> _loadExistingPhotos() async {
    final rows = await ref
        .read(databaseProvider)
        .getClimbPhotos(widget.climb!.id);
    if (!mounted) return;
    setState(() {
      _photos
        ..clear()
        ..addAll(rows.map((r) => _PhotoDraft(id: r.id, path: r.path)));
    });
  }

  @override
  void dispose() {
    _grade.dispose();
    _memo.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
      locale: const Locale('ja'),
    );
    if (picked != null) {
      setState(
        () => _date = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _date.hour,
          _date.minute,
        ),
      );
    }
  }

  Future<void> _addPhoto(ImageSource source) async {
    final isPremium = ref.read(premiumProvider);
    if (!isPremium && _photos.length >= _freePhotoLimit) {
      _promptPremiumForPhotos();
      return;
    }
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null) return;
    final saved = await savePhoto(picked.path);
    if (mounted) setState(() => _photos.add(_PhotoDraft(path: saved)));
  }

  void _removePhoto(_PhotoDraft draft) {
    setState(() {
      _photos.remove(draft);
      _filesToCleanup.add(draft.path); // 保存時にファイル削除
      if (draft.id != null) _removedPersistedIds.add(draft.id!);
    });
  }

  Future<void> _promptPremiumForPhotos() async {
    final go = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('写真は1枚まで（無料）'),
        content: const Text('プレミアムにすると1つの課題に何枚でも写真を残せます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('閉じる'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('プレミアムを見る'),
          ),
        ],
      ),
    );
    if (go == true && mounted) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const PaywallScreen()));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_gymId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ジムを選択してください')));
      return;
    }
    setState(() => _saving = true);
    final db = ref.read(databaseProvider);
    final memo = _memo.text.trim();

    int climbId;
    if (_isEdit) {
      climbId = widget.climb!.id;
      await db.updateClimb(
        ClimbsCompanion(
          id: Value(climbId),
          gymId: Value(_gymId!),
          date: Value(_date),
          grade: Value(_grade.text.trim()),
          wallTypeId: Value(_wallTypeId),
          attempts: Value(_attempts),
          isSent: Value(_isSent),
          memo: Value(memo.isEmpty ? null : memo),
          createdAt: Value(widget.climb!.createdAt),
        ),
      );
    } else {
      climbId = await db.insertClimb(
        ClimbsCompanion(
          gymId: Value(_gymId!),
          date: Value(_date),
          grade: Value(_grade.text.trim()),
          wallTypeId: Value(_wallTypeId),
          attempts: Value(_attempts),
          isSent: Value(_isSent),
          memo: Value(memo.isEmpty ? null : memo),
        ),
      );
    }

    // 削除された既存写真の行を削除
    for (final id in _removedPersistedIds) {
      await db.deleteClimbPhoto(id);
    }
    // 新規写真を挿入（並び順は現在の表示順）
    for (var i = 0; i < _photos.length; i++) {
      final p = _photos[i];
      if (!p.isPersisted) {
        await db.insertClimbPhoto(climbId, p.path, i);
      }
    }
    // 不要になったファイルを掃除
    for (final path in _filesToCleanup) {
      await deletePhoto(path);
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('記録を削除'),
        content: const Text('この登攀記録を削除しますか？'),
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
    final db = ref.read(databaseProvider);
    // 添付写真のファイルを掃除（行はカスケード削除される）
    final photos = await db.getClimbPhotos(widget.climb!.id);
    for (final p in photos) {
      await deletePhoto(p.path);
    }
    await db.deleteClimb(widget.climb!.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final gyms = ref.watch(gymsProvider).value ?? const [];
    final wallTypes = ref.watch(wallTypesProvider).value ?? const [];
    final isPremium = ref.watch(premiumProvider);
    final dateFmt = DateFormat('yyyy年M月d日 (E)', 'ja_JP');

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? '記録を編集' : '記録する'),
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
            DropdownButtonFormField<int>(
              initialValue: _gymId,
              decoration: const InputDecoration(
                labelText: 'ジム *',
                border: OutlineInputBorder(),
              ),
              items: gyms
                  .map(
                    (g) => DropdownMenuItem(value: g.id, child: Text(g.name)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _gymId = v),
              validator: (v) => v == null ? 'ジムを選択してください' : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
              ),
              leading: const Icon(Icons.calendar_today),
              title: Text(dateFmt.format(_date)),
              trailing: const Icon(Icons.edit),
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _grade,
              decoration: const InputDecoration(
                labelText: 'グレード *',
                hintText: '例: 二級 / 赤 / V4',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'グレードを入力してください' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              initialValue: _wallTypeId,
              decoration: const InputDecoration(
                labelText: '壁の種類（任意）',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('未指定')),
                ...wallTypes.map(
                  (w) => DropdownMenuItem(value: w.id, child: Text(w.name)),
                ),
              ],
              onChanged: (v) => setState(() => _wallTypeId = v),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('トライ数'),
                const Spacer(),
                IconButton.filledTonal(
                  onPressed: _attempts > 1
                      ? () => setState(() => _attempts--)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '$_attempts',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => setState(() => _attempts++),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('完登した'),
              value: _isSent,
              onChanged: (v) => setState(() => _isSent = v),
            ),
            const SizedBox(height: 8),
            _PhotoGallery(
              photos: _photos,
              isPremium: isPremium,
              onAdd: _addPhoto,
              onRemove: _removePhoto,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _memo,
              decoration: const InputDecoration(
                labelText: 'メモ・ベータ（任意）',
                hintText: 'ムーブや攻略のメモ',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.check),
              label: Text(_isEdit ? '保存' : '記録する'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoGallery extends StatelessWidget {
  const _PhotoGallery({
    required this.photos,
    required this.isPremium,
    required this.onAdd,
    required this.onRemove,
  });

  final List<_PhotoDraft> photos;
  final bool isPremium;
  final void Function(ImageSource) onAdd;
  final void Function(_PhotoDraft) onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('写真', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            if (!isPremium)
              Text(
                '（無料は1枚まで）',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 96,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...photos.asMap().entries.map(
                (e) => _Thumb(
                  path: e.value.path,
                  onRemove: () => onRemove(e.value),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PhotoViewerScreen(
                        paths: photos.map((p) => p.path).toList(),
                        initialIndex: e.key,
                      ),
                    ),
                  ),
                ),
              ),
              _AddButtons(onAdd: onAdd),
            ],
          ),
        ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.path,
    required this.onRemove,
    required this.onTap,
  });
  final String path;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          GestureDetector(
            onTap: onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(path),
                width: 96,
                height: 96,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: onRemove,
              child: const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.black54,
                child: Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddButtons extends StatelessWidget {
  const _AddButtons({required this.onAdd});
  final void Function(ImageSource) onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _AddTile(
          icon: Icons.photo_camera_outlined,
          label: '撮影',
          onTap: () => onAdd(ImageSource.camera),
        ),
        const SizedBox(width: 8),
        _AddTile(
          icon: Icons.photo_library_outlined,
          label: '選択',
          onTap: () => onAdd(ImageSource.gallery),
        ),
      ],
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 80,
        height: 96,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey.shade700),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
