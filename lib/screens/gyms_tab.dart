import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_database.dart';
import '../providers.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'gym_form_screen.dart';
import 'nearby_gyms_screen.dart';

const gradeSystemLabels = {'grade': '級 / 段', 'color': '色テープ', 'v': 'V グレード'};

class GymsTab extends ConsumerWidget {
  const GymsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gyms = ref.watch(gymsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('ジム'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NearbyGymsScreen()),
            ),
            icon: const Icon(Icons.travel_explore),
            tooltip: '近くのジムを探す',
          ),
        ],
      ),
      floatingActionButton: _GradientFab(
        label: 'ジムを追加',
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const GymFormScreen())),
      ),
      body: AmbientBackground(
        child: gyms.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('エラー: $e')),
          data: (list) {
            if (list.isEmpty) {
              return const _EmptyGyms();
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _GymTile(gym: list[i]),
            );
          },
        ),
      ),
    );
  }
}

class _GradientFab extends StatelessWidget {
  const _GradientFab({required this.label, required this.onPressed});
  final String label;
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
                const Icon(Icons.add, color: Colors.white, size: 22),
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

class _GymTile extends StatelessWidget {
  const _GymTile({required this.gym});
  final Gym gym;

  @override
  Widget build(BuildContext context) {
    final hasLocation = gym.location != null && gym.location!.isNotEmpty;
    return GlassCard(
      padding: const EdgeInsets.all(14),
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => GymFormScreen(gym: gym))),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppGradients.sunset,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.storefront, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gym.name,
                  style: const TextStyle(
                    color: AppPalette.textHigh,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (hasLocation) ...[
                      const Icon(
                        Icons.place_outlined,
                        size: 13,
                        color: AppPalette.textLow,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          gym.location!,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppPalette.textMid,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Pill(
                      label:
                          gradeSystemLabels[gym.gradeSystem] ?? gym.gradeSystem,
                      color: AppPalette.sunsetMid,
                      filled: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppPalette.textLow),
        ],
      ),
    );
  }
}

class _EmptyGyms extends StatelessWidget {
  const _EmptyGyms();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              child:
                  const Icon(Icons.storefront, size: 44, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              '通うジムを登録しましょう',
              style: TextStyle(
                color: AppPalette.textHigh,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '右下の「ジムを追加」から登録できます',
              style: TextStyle(color: AppPalette.textMid),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NearbyGymsScreen()),
              ),
              icon: const Icon(Icons.travel_explore),
              label: const Text('近くのジムを探す'),
            ),
          ],
        ),
      ),
    );
  }
}
