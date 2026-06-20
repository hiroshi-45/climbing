import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../stats/climb_stats.dart';
import 'paywall_screen.dart';

class StatsTab extends ConsumerWidget {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(premiumProvider);
    final stats = ref.watch(climbStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('統計'),
        actions: [
          if (isPremium)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.workspace_premium, color: Colors.amber),
            ),
        ],
      ),
      body: isPremium
          ? _StatsDashboard(stats: stats)
          : _LockedStats(stats: stats),
    );
  }
}

/// 無料ユーザー向け。サマリだけ見せ、詳細は課金で解放する。
class _LockedStats extends StatelessWidget {
  const _LockedStats({required this.stats});
  final ClimbStats stats;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SummaryCard(stats: stats),
        const SizedBox(height: 16),
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.lock_outline, size: 40),
                const SizedBox(height: 12),
                Text(
                  '詳しい分析はプレミアムで',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  '月別の完登推移・グレード別成功率・苦手な壁の分析を解放できます。',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PaywallScreen()),
                  ),
                  icon: const Icon(Icons.workspace_premium),
                  label: const Text('プレミアムを見る'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsDashboard extends StatelessWidget {
  const _StatsDashboard({required this.stats});
  final ClimbStats stats;

  @override
  Widget build(BuildContext context) {
    if (stats.totalClimbs == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            '記録が貯まると、ここに分析が表示されます',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SummaryCard(stats: stats),
        const SizedBox(height: 24),
        _SectionTitle('月別の完登数'),
        const SizedBox(height: 8),
        _MonthlyChart(monthly: stats.monthly),
        const SizedBox(height: 24),
        _SectionTitle('グレード別の完登率'),
        const SizedBox(height: 8),
        ...stats.grades.map((g) => _RateRow(stat: g)),
        if (stats.walls.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SectionTitle('壁の種類別の完登率（苦手な順）'),
          const SizedBox(height: 8),
          ...stats.walls.map((w) => _RateRow(stat: w)),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.stats});
  final ClimbStats stats;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Metric(value: '${stats.totalSends}', label: '完登'),
            _Metric(value: '${stats.totalClimbs}', label: '記録'),
            _Metric(value: '${stats.overallSendPercent}%', label: '完登率'),
            _Metric(value: '${stats.totalAttempts}', label: '総トライ'),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _MonthlyChart extends StatelessWidget {
  const _MonthlyChart({required this.monthly});
  final List<MonthlyCount> monthly;

  @override
  Widget build(BuildContext context) {
    final maxSends = monthly.fold<int>(1, (m, e) => e.sends > m ? e.sends : m);
    final primary = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: monthly.map((m) {
          final ratio = m.sends / maxSends;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('${m.sends}', style: const TextStyle(fontSize: 11)),
                const SizedBox(height: 4),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 110 * ratio + 2,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${m.month}月',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RateRow extends StatelessWidget {
  const _RateRow({required this.stat});
  final RateStat stat;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  stat.label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${stat.ratePercent}%  (${stat.sends}/${stat.total})',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: stat.rate,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
            ),
          ),
        ],
      ),
    );
  }
}
