import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_database.dart';
import '../providers.dart';
import 'gym_form_screen.dart';

const gradeSystemLabels = {
  'grade': '級 / 段',
  'color': '色テープ',
  'v': 'V グレード',
};

class GymsTab extends ConsumerWidget {
  const GymsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gyms = ref.watch(gymsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('ジム')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const GymFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('ジムを追加'),
      ),
      body: gyms.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const _EmptyGyms();
          }
          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: list.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) => _GymTile(gym: list[i]),
          );
        },
      ),
    );
  }
}

class _GymTile extends StatelessWidget {
  const _GymTile({required this.gym});
  final Gym gym;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (gym.location != null && gym.location!.isNotEmpty) gym.location!,
      gradeSystemLabels[gym.gradeSystem] ?? gym.gradeSystem,
    ].join(' ・ ');
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.store)),
      title: Text(gym.name),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => GymFormScreen(gym: gym)),
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
            const Icon(Icons.store_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('通うジムを登録しましょう',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('右下の「ジムを追加」から登録できます',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
