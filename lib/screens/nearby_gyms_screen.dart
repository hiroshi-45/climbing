import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../data/app_database.dart';
import '../data/nearby_gym_service.dart';
import '../providers.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

/// 現在地周辺のボルダリング施設を地図とリストで探す画面。
///
/// データは OpenStreetMap (Overpass API)。気になる施設はその場で自分の
/// ジムとして登録できる。
class NearbyGymsScreen extends ConsumerStatefulWidget {
  const NearbyGymsScreen({super.key});

  @override
  ConsumerState<NearbyGymsScreen> createState() => _NearbyGymsScreenState();
}

class _NearbyGymsScreenState extends ConsumerState<NearbyGymsScreen> {
  final _mapController = MapController();

  bool _loading = true;
  String? _error;
  LatLng? _myLocation;
  List<NearbyGym> _gyms = const [];
  NearbyGym? _selected;

  static const _fallbackCenter = LatLng(35.681236, 139.767125); // 東京駅

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pos = await NearbyGymService.currentPosition();
      final here = LatLng(pos.latitude, pos.longitude);
      final found = await NearbyGymService.search(center: here);
      if (!mounted) return;
      setState(() {
        _myLocation = here;
        _gyms = found;
        _loading = false;
      });
      _mapController.move(here, 13);
    } on LocationException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = '施設の検索に失敗しました。通信環境を確認して再試行してください。';
        _loading = false;
      });
    }
  }

  void _focus(NearbyGym gym) {
    setState(() => _selected = gym);
    _mapController.move(gym.location, 15);
  }

  Future<void> _addAsGym(NearbyGym gym) async {
    await ref
        .read(databaseProvider)
        .insertGym(
          GymsCompanion(
            name: Value(gym.name),
            location: Value(gym.address ?? gym.name),
          ),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('「${gym.name}」をジムに追加しました')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 既存ジム名と突き合わせて「追加済み」を判定する。
    final existingNames = {
      for (final g in ref.watch(gymsProvider).value ?? const <Gym>[]) g.name,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('近くのジムを探す'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
            tooltip: '再検索',
          ),
        ],
      ),
      body: AmbientBackground(
        child: _error != null
            ? _ErrorView(message: _error!, onRetry: _load)
            : Stack(
                children: [
                  _map(),
                  if (_loading)
                    const Center(child: CircularProgressIndicator())
                  else
                    _resultsSheet(existingNames),
                ],
              ),
      ),
    );
  }

  Widget _map() {
    final markers = <Marker>[
      if (_myLocation != null)
        Marker(
          point: _myLocation!,
          width: 24,
          height: 24,
          child: const _MyLocationDot(),
        ),
      for (final g in _gyms)
        Marker(
          point: g.location,
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _focus(g),
            child: _GymPin(active: identical(g, _selected)),
          ),
        ),
    ];

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _myLocation ?? _fallbackCenter,
        initialZoom: 13,
        onTap: (_, _) => setState(() => _selected = null),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.maruno.climb_log',
        ),
        MarkerLayer(markers: markers),
        const RichAttributionWidget(
          attributions: [TextSourceAttribution('© OpenStreetMap contributors')],
        ),
      ],
    );
  }

  Widget _resultsSheet(Set<String> existingNames) {
    return DraggableScrollableSheet(
      initialChildSize: 0.34,
      minChildSize: 0.12,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppPalette.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppPalette.stroke)),
          ),
          child: _gyms.isEmpty
              ? ListView(
                  controller: scrollController,
                  children: [
                    const _SheetGrip(),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 24, 24, 40),
                      child: Text(
                        '周辺にクライミング施設が見つかりませんでした。\n'
                        '地図を動かして再検索するか、ジム画面から手動で登録できます。',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppPalette.textMid),
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: _gyms.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return Column(
                        children: [
                          const _SheetGrip(),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8, left: 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${_gyms.length}件の施設',
                                style: const TextStyle(
                                  color: AppPalette.textHigh,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    final gym = _gyms[i - 1];
                    return _NearbyTile(
                      gym: gym,
                      added: existingNames.contains(gym.name),
                      selected: identical(gym, _selected),
                      onTap: () => _focus(gym),
                      onAdd: () => _addAsGym(gym),
                    );
                  },
                ),
        );
      },
    );
  }
}

class _SheetGrip extends StatelessWidget {
  const _SheetGrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppPalette.stroke,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _NearbyTile extends StatelessWidget {
  const _NearbyTile({
    required this.gym,
    required this.added,
    required this.selected,
    required this.onTap,
    required this.onAdd,
  });

  final NearbyGym gym;
  final bool added;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      gradientBorder: selected,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppGradients.sunset,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.terrain, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gym.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppPalette.textHigh,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (gym.distanceLabel != null) ...[
                      Pill(
                        label: gym.distanceLabel!,
                        color: AppPalette.sunsetMid,
                        filled: true,
                        icon: Icons.near_me,
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (gym.address != null)
                      Expanded(
                        child: Text(
                          gym.address!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppPalette.textMid,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          added
              ? const Pill(
                  label: '追加済み',
                  color: AppPalette.sent,
                  filled: true,
                  icon: Icons.check,
                )
              : IconButton(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_circle),
                  color: AppPalette.sunsetMid,
                  tooltip: 'ジムに追加',
                ),
        ],
      ),
    );
  }
}

class _GymPin extends StatelessWidget {
  const _GymPin({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.location_on,
      size: active ? 40 : 32,
      color: active ? AppPalette.sunsetEnd : AppPalette.sunsetMid,
      shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
    );
  }
}

class _MyLocationDot extends StatelessWidget {
  const _MyLocationDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4F9DFF),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0x664F9DFF), blurRadius: 8, spreadRadius: 2),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_off_outlined,
              size: 56,
              color: AppPalette.textLow,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppPalette.textMid, fontSize: 14),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }
}
