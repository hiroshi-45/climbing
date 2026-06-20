import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// 周辺検索でヒットしたボルダリング/クライミング施設。
///
/// OpenStreetMap (Overpass API) から取得した外部データ。アプリ内のジム
/// （[Gym]）とは別物で、ユーザーが「ジムに追加」して初めてDBへ保存される。
class NearbyGym {
  const NearbyGym({
    required this.name,
    required this.location,
    this.address,
    this.distanceMeters,
  });

  final String name;
  final LatLng location;

  /// 住所（取得できた場合のみ）。
  final String? address;

  /// 現在地からの距離（メートル）。現在地が不明なら null。
  final double? distanceMeters;

  /// "1.2km" / "350m" のような表示用文字列。
  String? get distanceLabel {
    final d = distanceMeters;
    if (d == null) return null;
    if (d >= 1000) return '${(d / 1000).toStringAsFixed(1)}km';
    return '${d.round()}m';
  }
}

/// 位置情報の取得に失敗したことを表す（UIで分かりやすく案内するため）。
class LocationException implements Exception {
  const LocationException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// 周辺のボルダリング施設を OpenStreetMap から検索するサービス。
///
/// APIキー不要・無料の Overpass API を利用する。Google Places のような従量
/// 課金や鍵管理を避けつつ、`sport=climbing` 系タグの施設を取得する。
class NearbyGymService {
  NearbyGymService._();

  static const _endpoint = 'https://overpass-api.de/api/interpreter';

  /// 現在地を取得する。サービス無効・権限拒否時は [LocationException] を投げる。
  static Future<Position> currentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException(
        '位置情報サービスがオフです。端末の設定からオンにしてください。',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException('位置情報の利用が許可されませんでした。');
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        '位置情報が拒否されています。設定アプリから許可してください。',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  /// [center] を中心に [radiusMeters] 以内のクライミング施設を距離順で返す。
  static Future<List<NearbyGym>> search({
    required LatLng center,
    int radiusMeters = 10000,
  }) async {
    final r = radiusMeters;
    final lat = center.latitude;
    final lng = center.longitude;
    // クライミング系の主要タグを網羅して取得（node/way/relation）。
    final query =
        '[out:json][timeout:25];'
        '('
        'nwr["sport"="climbing"](around:$r,$lat,$lng);'
        'nwr["leisure"="climbing"](around:$r,$lat,$lng);'
        'nwr["climbing"](around:$r,$lat,$lng);'
        ');'
        'out center tags;';

    final res = await http.post(
      Uri.parse(_endpoint),
      headers: const {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'data': query},
    );
    if (res.statusCode != 200) {
      throw Exception('施設の取得に失敗しました (HTTP ${res.statusCode})');
    }

    final decoded = jsonDecode(utf8.decode(res.bodyBytes)) as Map;
    final elements = (decoded['elements'] as List?) ?? const [];

    final results = <NearbyGym>[];
    for (final e in elements) {
      final el = e as Map;
      final tags = (el['tags'] as Map?) ?? const {};
      final name = (tags['name'] as String?)?.trim();
      if (name == null || name.isEmpty) continue; // 名称不明は除外

      final coord = _coordOf(el);
      if (coord == null) continue;

      final distance = Geolocator.distanceBetween(
        center.latitude,
        center.longitude,
        coord.latitude,
        coord.longitude,
      );
      results.add(
        NearbyGym(
          name: name,
          location: coord,
          address: _addressOf(tags),
          distanceMeters: distance,
        ),
      );
    }

    // 同一施設が node/way 二重でヒットすることがあるため名前+座標で重複排除。
    final seen = <String>{};
    final deduped = <NearbyGym>[];
    for (final g in results) {
      final key =
          '${g.name}@${g.location.latitude.toStringAsFixed(4)},'
          '${g.location.longitude.toStringAsFixed(4)}';
      if (seen.add(key)) deduped.add(g);
    }

    deduped.sort(
      (a, b) =>
          (a.distanceMeters ?? double.infinity).compareTo(
            b.distanceMeters ?? double.infinity,
          ),
    );
    return deduped;
  }

  /// node は lat/lon、way/relation は center.lat/lon を持つ。
  static LatLng? _coordOf(Map el) {
    final lat = el['lat'] as num?;
    final lon = el['lon'] as num?;
    if (lat != null && lon != null) {
      return LatLng(lat.toDouble(), lon.toDouble());
    }
    final center = el['center'] as Map?;
    final clat = center?['lat'] as num?;
    final clon = center?['lon'] as num?;
    if (clat != null && clon != null) {
      return LatLng(clat.toDouble(), clon.toDouble());
    }
    return null;
  }

  /// addr:* タグから人が読める住所を組み立てる。
  static String? _addressOf(Map tags) {
    final full = tags['addr:full'] as String?;
    if (full != null && full.trim().isNotEmpty) return full.trim();

    final parts = [
      tags['addr:province'],
      tags['addr:city'],
      tags['addr:suburb'],
      tags['addr:neighbourhood'],
      tags['addr:block_number'],
      tags['addr:housenumber'],
    ].whereType<String>().where((s) => s.trim().isNotEmpty).toList();
    if (parts.isEmpty) return null;
    return parts.join(' ');
  }
}
