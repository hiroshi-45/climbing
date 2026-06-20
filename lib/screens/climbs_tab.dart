import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:table_calendar/table_calendar.dart';

import '../data/app_database.dart';
import '../data/export_service.dart';
import '../providers.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('登攀記録'),
        actions: [
          _RoundAction(
            icon: _calendarMode
                ? Icons.view_agenda_outlined
                : Icons.calendar_month,
            tooltip: _calendarMode ? 'リスト表示' : 'カレンダー表示',
            onPressed: () => setState(() => _calendarMode = !_calendarMode),
          ),
          _RoundAction(
            icon: Icons.ios_share,
            tooltip: 'CSVエクスポート',
            onPressed: _export,
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: _GradientFab(
        label: '記録する',
        icon: Icons.add,
        onPressed: gyms.isEmpty ? _needGym : _openNewClimb,
      ),
      body: AmbientBackground(
        child: climbs.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('エラー: $e')),
          data: (list) {
            if (_calendarMode) {
              final top = MediaQuery.of(context).padding.top + kToolbarHeight;
              return Padding(
                padding: EdgeInsets.only(top: top),
                child: _ClimbCalendar(climbs: list),
              );
            }
            return _ClimbList(climbs: list);
          },
        ),
      ),
    );
  }

  Future<void> _openNewClimb() async {
    final celebrated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const ClimbFormScreen()),
    );
    if (celebrated == true && mounted) showCelebration(context);
  }

  void _needGym() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('先に「ジム」タブでジムを登録してください')));
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
      return;
    }

    final db = ref.read(databaseProvider);
    final climbs = await db.getAllClimbs();
    if (climbs.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('エクスポートする記録がありません')));
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

/// 角丸の半透明アクションボタン（AppBar 用）。
class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Material(
        color: AppPalette.surface.withValues(alpha: 0.6),
        shape: const CircleBorder(),
        child: IconButton(
          icon: Icon(icon, size: 20),
          tooltip: tooltip,
          onPressed: onPressed,
        ),
      ),
    );
  }
}

/// サンセットグラデーションをまとった拡張 FAB。
class _GradientFab extends StatelessWidget {
  const _GradientFab({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.sunset,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppPalette.sunsetMid.withValues(alpha: 0.45),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 一覧トップのヒーローヘッダー。連続記録・完登数・完登率を映える形で見せる。
class _HeroHeader extends ConsumerWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(climbStatsProvider);
    final hour = DateTime.now().hour;
    final greeting = hour < 5
        ? '夜更かしクライマー'
        : hour < 11
            ? 'おはよう'
            : hour < 17
                ? 'こんにちは'
                : '今日もお疲れさま';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppPalette.sunsetMid.withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                greeting,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _StreakBadge(streak: stats.currentStreak),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedCounter(
                value: stats.totalSends,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '完登',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              _HeroStat(label: '記録', value: '${stats.totalClimbs}'),
              const SizedBox(width: 18),
              _HeroStat(label: '完登率', value: '${stats.overallSendPercent}%'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department,
              color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            streak > 0 ? '$streak日連続' : '今日から登ろう',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// 日付ごとにグループ化したリスト表示。先頭にヒーローヘッダーを差し込む。
class _ClimbList extends StatelessWidget {
  const _ClimbList({required this.climbs});
  final List<Climb> climbs;

  @override
  Widget build(BuildContext context) {
    final groups = <DateTime, List<Climb>>{};
    for (final c in climbs) {
      final key = DateTime(c.date.year, c.date.month, c.date.day);
      groups.putIfAbsent(key, () => []).add(c);
    }
    final dates = groups.keys.toList()..sort((a, b) => b.compareTo(a));
    // 記録がある時だけロケール依存の整形を行う（空状態では生成しない）。
    final dateFmt = dates.isEmpty ? null : DateFormat('M月d日 (E)', 'ja_JP');

    final topInset = MediaQuery.of(context).padding.top + kToolbarHeight;

    return ListView.builder(
      padding: EdgeInsets.only(top: topInset, bottom: 100),
      itemCount: dates.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return climbs.isEmpty
              ? const Column(
                  children: [_HeroHeader(), _EmptyClimbs()],
                )
              : const _HeroHeader();
        }
        final date = dates[i - 1];
        final dayClimbs = groups[date]!;
        final sentCount = dayClimbs.where((c) => c.isSent).length;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
                child: Row(
                  children: [
                    Text(
                      dateFmt!.format(date),
                      style: const TextStyle(
                        color: AppPalette.textHigh,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    Pill(
                      label: '完登 $sentCount / ${dayClimbs.length}',
                      color:
                          sentCount > 0 ? AppPalette.sent : AppPalette.textLow,
                      filled: true,
                    ),
                  ],
                ),
              ),
              ...dayClimbs.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ClimbItem(climb: c),
                ),
              ),
            ],
          ),
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
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: AppPalette.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppPalette.stroke),
          ),
          child: TableCalendar<Climb>(
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
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: AppPalette.textHigh,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
              leftChevronIcon:
                  Icon(Icons.chevron_left, color: AppPalette.textMid),
              rightChevronIcon:
                  Icon(Icons.chevron_right, color: AppPalette.textMid),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: AppPalette.textLow, fontSize: 12),
              weekendStyle: TextStyle(color: AppPalette.textLow, fontSize: 12),
            ),
            calendarStyle: CalendarStyle(
              defaultTextStyle: const TextStyle(color: AppPalette.textHigh),
              weekendTextStyle: const TextStyle(color: AppPalette.textMid),
              outsideTextStyle: const TextStyle(color: AppPalette.textLow),
              markerDecoration: const BoxDecoration(
                gradient: AppGradients.sunset,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppPalette.sunsetMid.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              todayTextStyle: const TextStyle(color: AppPalette.textHigh),
              selectedDecoration: const BoxDecoration(
                gradient: AppGradients.sunset,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
          child: Row(
            children: [
              Text(
                headerFmt.format(selected),
                style: const TextStyle(
                  color: AppPalette.textHigh,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              if (dayClimbs.isNotEmpty)
                Pill(
                  label:
                      '完登 ${dayClimbs.where((c) => c.isSent).length} / ${dayClimbs.length}',
                  color: AppPalette.sent,
                  filled: true,
                ),
            ],
          ),
        ),
        Expanded(
          child: dayClimbs.isEmpty
              ? const Center(
                  child: Text(
                    'この日の記録はありません',
                    style: TextStyle(color: AppPalette.textLow),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  children: dayClimbs
                      .map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ClimbItem(climb: c),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );
  }
}

/// 記録1件分のカード。写真・ジム・壁の情報をプロバイダから引いて描画。
class ClimbItem extends ConsumerWidget {
  const ClimbItem({super.key, required this.climb});
  final Climb climb;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gymMap = ref.watch(gymMapProvider);
    final wallMap = ref.watch(wallTypeMapProvider);
    final photos = ref.watch(photosByClimbProvider)[climb.id];
    final wallType =
        climb.wallTypeId == null ? null : wallMap[climb.wallTypeId];

    final hasPhoto = photos != null && photos.isNotEmpty;
    final accent = climb.isSent ? AppPalette.sent : AppPalette.projecting;

    return GlassCard(
      padding: const EdgeInsets.all(12),
      gradientBorder: climb.isSent,
      onTap: () async {
        final celebrated = await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (_) => ClimbFormScreen(climb: climb)),
        );
        if (celebrated == true && context.mounted) showCelebration(context);
      },
      child: Row(
        children: [
          _Leading(
            grade: climb.grade,
            isSent: climb.isSent,
            photoPath: hasPhoto ? photos.first.path : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        climb.grade,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppPalette.textHigh,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Pill(
                      label: climb.isSent ? '完登' : '挑戦中',
                      color: accent,
                      filled: true,
                      icon: climb.isSent ? Icons.check_circle : Icons.adjust,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _Meta(
                      icon: Icons.store_outlined,
                      text: gymMap[climb.gymId]?.name ?? '(削除されたジム)',
                    ),
                    if (wallType != null)
                      _Meta(
                          icon: Icons.landscape_outlined, text: wallType.name),
                    _Meta(
                      icon: Icons.replay,
                      text: '${climb.attempts}トライ',
                    ),
                    if (photos != null && photos.length > 1)
                      _Meta(
                        icon: Icons.photo_library_outlined,
                        text: '${photos.length}',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Leading extends StatelessWidget {
  const _Leading({
    required this.grade,
    required this.isSent,
    required this.photoPath,
  });
  final String grade;
  final bool isSent;
  final String? photoPath;

  @override
  Widget build(BuildContext context) {
    if (photoPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.file(
          File(photoPath!),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: isSent ? AppGradients.sent : null,
        color: isSent ? null : AppPalette.surfaceHigh,
        borderRadius: BorderRadius.circular(14),
        border: isSent ? null : Border.all(color: AppPalette.stroke),
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          grade,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSent ? const Color(0xFF06241B) : AppPalette.textMid,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppPalette.textLow),
        const SizedBox(width: 3),
        Text(
          text,
          style: const TextStyle(color: AppPalette.textMid, fontSize: 12),
        ),
      ],
    );
  }
}

class _EmptyClimbs extends StatelessWidget {
  const _EmptyClimbs();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: AppGradients.sunset,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppPalette.sunsetMid.withValues(alpha: 0.4),
                  blurRadius: 28,
                ),
              ],
            ),
            child: const Icon(Icons.terrain, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text(
            'まだ記録がありません',
            style: TextStyle(
              color: AppPalette.textHigh,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '右下の「記録する」から、最初の一本を残そう',
            style: TextStyle(color: AppPalette.textMid),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
