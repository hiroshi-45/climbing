import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../stats/climb_stats.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
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
              child: Icon(Icons.workspace_premium, color: AppPalette.gold),
            ),
        ],
      ),
      body: AmbientBackground(
        child: isPremium
            ? _StatsDashboard(stats: stats)
            : _LockedStats(stats: stats),
      ),
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        _SummaryCard(stats: stats),
        const SizedBox(height: 16),
        _PremiumPromo(),
      ],
    );
  }
}

class _PremiumPromo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      gradientBorder: true,
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              gradient: AppGradients.sunset,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.insights, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            '詳しい分析はプレミアムで',
            style: TextStyle(
              color: AppPalette.textHigh,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '月別の完登推移・グレード別成功率・苦手な壁の分析を解放できます。',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppPalette.textMid),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PaywallScreen()),
              ),
              icon: const Icon(Icons.workspace_premium),
              label: const Text('プレミアムを見る'),
            ),
          ),
        ],
      ),
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
            style: TextStyle(color: AppPalette.textLow),
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        _SummaryCard(stats: stats),
        const SizedBox(height: 24),
        _SectionTitle('月別の完登数'),
        const SizedBox(height: 12),
        GlassCard(child: _MonthlyChart(monthly: stats.monthly)),
        const SizedBox(height: 24),
        _SectionTitle('グレード別の完登率'),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            children: [
              for (var i = 0; i < stats.grades.length; i++) ...[
                if (i > 0) const SizedBox(height: 14),
                _RateRow(stat: stats.grades[i]),
              ],
            ],
          ),
        ),
        if (stats.walls.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SectionTitle('壁の種類別の完登率（苦手な順）'),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              children: [
                for (var i = 0; i < stats.walls.length; i++) ...[
                  if (i > 0) const SizedBox(height: 14),
                  _RateRow(stat: stats.walls[i], rankWeak: i == 0),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.stats});
  final ClimbStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
      decoration: BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppPalette.sunsetMid.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Metric(value: stats.totalSends, label: '完登'),
          _Metric(value: stats.totalClimbs, label: '記録'),
          _Metric(value: stats.overallSendPercent, label: '完登率', suffix: '%'),
          _Metric(value: stats.totalAttempts, label: '総トライ'),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label, this.suffix = ''});
  final int value;
  final String label;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedCounter(
          value: value,
          suffix: suffix,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppPalette.textHigh,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _MonthlyChart extends StatelessWidget {
  const _MonthlyChart({required this.monthly});
  final List<MonthlyCount> monthly;

  @override
  Widget build(BuildContext context) {
    final maxSends = monthly.fold<int>(1, (m, e) => e.sends > m ? e.sends : m);

    return SizedBox(
      height: 168,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: monthly.map((m) {
          final ratio = m.sends / maxSends;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${m.sends}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppPalette.textHigh,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: ratio),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    height: 110 * v + 4,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [AppPalette.sunsetEnd, AppPalette.sunsetMid],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${m.month}月',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppPalette.textLow,
                  ),
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
  const _RateRow({required this.stat, this.rankWeak = false});
  final RateStat stat;

  /// 苦手ランク先頭を強調（オレンジ寄り）するか。
  final bool rankWeak;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (rankWeak)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.priority_high,
                  size: 16,
                  color: AppPalette.sunsetStart,
                ),
              ),
            Expanded(
              child: Text(
                stat.label,
                style: const TextStyle(
                  color: AppPalette.textHigh,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${stat.ratePercent}%',
              style: const TextStyle(
                color: AppPalette.textHigh,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '(${stat.sends}/${stat.total})',
              style: const TextStyle(color: AppPalette.textLow, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: stat.rate),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => Stack(
              children: [
                Container(height: 10, color: AppPalette.surfaceHigh),
                FractionallySizedBox(
                  widthFactor: v.clamp(0.0, 1.0),
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: rankWeak
                          ? const LinearGradient(
                              colors: [
                                AppPalette.sunsetStart,
                                AppPalette.sunsetMid,
                              ],
                            )
                          : AppGradients.sent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
