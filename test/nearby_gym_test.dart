import 'package:climb_log/data/nearby_gym_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('NearbyGym.distanceLabel', () {
    NearbyGym at(double? meters) => NearbyGym(
          name: 'テストジム',
          location: const LatLng(35.0, 139.0),
          distanceMeters: meters,
        );

    test('1km未満はメートル表示', () {
      expect(at(0).distanceLabel, '0m');
      expect(at(349.6).distanceLabel, '350m');
      expect(at(999).distanceLabel, '999m');
    });

    test('1km以上はキロメートル表示（小数1桁）', () {
      expect(at(1000).distanceLabel, '1.0km');
      expect(at(1234).distanceLabel, '1.2km');
      expect(at(15800).distanceLabel, '15.8km');
    });

    test('距離不明はnull', () {
      expect(at(null).distanceLabel, isNull);
    });
  });
}
