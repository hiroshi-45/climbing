import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:table_calendar/table_calendar.dart';

import '../data/app_database.dart';
import '../data/export_service.dart';
import '../providers.dart';
import 'climb_form_screen.dart';
import 'paywall_screen.dart';

class ClimbsTab extends ConsumerStatefulWidget {
  const ClimbsTab({super.key});

  @override
  ConsumerState<ClimbsTab> createState() => _ClimbsTabState();
}

class _ClimbsTabState extends ConsumerState<ClimbsTab> {
  bool _calendarMode = false;

  @override
  Widget build(BuildContext context) {
    final climbs = ref.watch(climbsProvider);
    final gyms = ref.watch(gymsProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('登攀記録'),
        actions: [
          IconButton(
            onPressed: () => setState(() => _calendarMode = !_calendarMode),
            icon: Icon(_calendarMode ? Icons.view_list : Icons.calendar_month),
            tooltip: _calendarMode ? 'リスト表示' : 'カレンダー表示',
          ),
          IconButton(
            onPressed: _export,
            icon: const Icon(Icons.ios_share),
            tooltip: 'CSVエクスポート',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: gyms.isEmpty
            ? _needGym
            : () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ClimbFormScreen()),
                ),
        icon: const Icon(Icons.add),
        label: const Text('記録する'),
      ),
      body: climbs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
        data: (list) {
          // カレンダーは空でも表示（月送り可）。リストは空状態を案内する。
          if (_calendarMode) return _ClimbCalendar(climbs: list);
          if (list.isEmpty) return const _EmptyClimbs();
          return _ClimbList(climbs: list);
        },
      ),
    );
  }

  void _needGym() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('先に「ジム」タブでジムを登録してください')),
    );
  }

  Future<void> _export() async {
    if (!ref.read(premiumProvider)) {
      final go = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('エクスポートはプレミアム機能'),
          content: const Text('記録をCSVで書き出して、バックアップや共有ができます。'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('閉じる')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('プレミアムを見る')),
          ],
        ),
      );
      if (go == true && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PaywallScreen()),
        );
      }
      return;
    }

    final db = ref.read(databaseProvider);
    final climbs = await db.getAllClimbs();
    if (climbs.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('エクスポートする記録がありません')),
        );
      }
      return;
    }
    final file = await buildClimbsCsv(
      climbs,
      ref.read(gymMapProvider),
      ref.read(wallTypeMapProvider),
    );
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: 'Climb Log エクスポート'),
    );
  }
}

/// 日付ごとにグループ化したリスト表示。
class _ClimbList extends StatelessWidget {
  const _ClimbList({required this.climbs});
  final List<Climb> climbs;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('M月d日 (E)', 'ja_JP');

    final groups = <DateTime, List<Climb>>{};
    for (final c in climbs) {
      final key = DateTime(c.date.year, c.date.month, c.date.day);
      groups.putIfAbsent(key, () => []).add(c);
    }
    final dates = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: dates.length,
      itemBuilder: (_, i) {
        final date = dates[i];
        final dayClimbs = groups[date]!;
        final sentCount = dayClimbs.where((c) => c.isSent).length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(
                children: [
                  Text(dateFmt.format(date),
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('完登 $sentCount / ${dayClimbs.length}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            ...dayClimbs.map((c) => ClimbItem(climb: c)),
            const Divider(height: 1),
          ],
        );
      },
    );
  }
}

/// 月カレンダー表示。日ごとのマーカー＋選択日の記録リスト。
class _ClimbCalendar extends StatefulWidget {
  const _ClimbCalendar({required this.climbs});
  final List<Climb> climbs;

  @override
  State<_ClimbCalendar> createState() => _ClimbCalendarState();
}

class _ClimbCalendarState extends State<_ClimbCalendar> {
  late Map<DateTime, List<Climb>> _events;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _events = _buildEvents();
  }

  @override
  void didUpdateWidget(covariant _ClimbCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.climbs != widget.climbs) {
      setState(() => _events = _buildEvents());
    }
  }

  Map<DateTime, List<Climb>> _buildEvents() {
    final map = <DateTime, List<Climb>>{};
    for (final c in widget.climbs) {
      final key = DateTime(c.date.year, c.date.month, c.date.day);
      map.putIfAbsent(key, () => []).add(c);
    }
    return map;
  }

  List<Climb> _eventsFor(DateTime day) =>
      _events[DateTime(day.year, day.month, day.day)] ?? const [];

  @override
  Widget build(BuildContext context) {
    final selected = _selectedDay ?? _focusedDay;
    final dayClimbs = _eventsFor(selected);
    final headerFmt = DateFormat('M月d日 (E)', 'ja_JP');

    return Column(
      children: [
        TableCalendar<Climb>(
          locale: 'ja_JP',
          firstDay: DateTime.utc(2015, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: CalendarFormat.month,
          availableCalendarFormats: const {CalendarFormat.month: '月'},
          startingDayOfWeek: StartingDayOfWeek.monday,
          selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
          eventLoader: _eventsFor,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          calendarStyle: CalendarStyle(
            markerDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Text(headerFmt.format(selected),
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              if (dayClimbs.isNotEmpty)
                Text('完登 ${dayClimbs.where((c) => c.isSent).length} / ${dayClimbs.length}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        Expanded(
          child: dayClimbs.isEmpty
              ? const Center(
                  child: Text('この日の記録はありません',
                      style: TextStyle(color: Colors.grey)))
              : ListView(
                  padding: const EdgeInsets.only(bottom: 88),
                  children: dayClimbs.map((c) => ClimbItem(climb: c)).toList(),
                ),
        ),
      ],
    );
  }
}

/// 記録1件分のリストタイル。写真・ジム・壁の情報をプロバイダから引いて描画。
class ClimbItem extends ConsumerWidget {
  const ClimbItem({super.key, required this.climb});
  final Climb climb;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gymMap = ref.watch(gymMapProvider);
    final wallMap = ref.watch(wallTypeMapProvider);
    final photos = ref.watch(photosByClimbProvider)[climb.id];
    final wallType = climb.wallTypeId == null ? null : wallMap[climb.wallTypeId];

    final meta = [
      gymMap[climb.gymId]?.name ?? '(削除されたジム)',
      if (wallType != null) wallType.name,
      'トライ ${climb.attempts}',
      if (photos != null && photos.length > 1) '写真 ${photos.length}',
    ].join(' ・ ');

    final hasPhoto = photos != null && photos.isNotEmpty;

    return ListTile(
      leading: hasPhoto
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(File(photos.first.path),
                  width: 48, height: 48, fit: BoxFit.cover),
            )
          : CircleAvatar(
              backgroundColor: climb.isSent
                  ? Colors.green.shade100
                  : Colors.grey.shade200,
              child: Text(climb.grade,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis),
            ),
      title: Row(
        children: [
          Text(climb.grade,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          if (climb.isSent)
            const Icon(Icons.check_circle, color: Colors.green, size: 18)
          else
            Icon(Icons.radio_button_unchecked,
                color: Colors.grey.shade400, size: 18),
        ],
      ),
      subtitle: Text(meta),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ClimbFormScreen(climb: climb)),
      ),
    );
  }
}

class _EmptyClimbs extends StatelessWidget {
  const _EmptyClimbs();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.terrain_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('まだ記録がありません',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('右下の「記録する」から登攀を記録しましょう',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
