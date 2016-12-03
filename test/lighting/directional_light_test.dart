import 'package:test/test.dart';
import 'package:bagl/math.dart';
import 'package:scene_3d/lighting.dart';

void main() {
  group('DirectionalLight', () {
    final light = new DirectionalLight();

    group('members', () {
      test('returns the correct values', () {
        expect(light.members, unorderedEquals(['color', 'direction']));
      });
    });

    group('hasMember', () {
      test('returns false for a non-existing member', () {
        expect(light.hasMember('nonexisting'), isFalse);
      });

      test('returns true for "color"', () {
        expect(light.hasMember('color'), isTrue);
      });

      test('returns true for "direction"', () {
        expect(light.hasMember('direction'), isTrue);
      });
    });

    group('forEach', () {
      final calls = [];

      light.forEach((member, value) {
        calls.add({
          'member': member,
          'value':value
        });
      });

      test('calls the callback the correct number of times with the correct values', () {
        expect(calls, unorderedEquals([
          {'member': 'color', 'value': new Vector3(1.0, 1.0, 1.0)},
          {'member': 'direction', 'value': new Vector3(0.0, 0.0, 1.0)}
        ]));
      });
    });

    group('[] operator', () {
      test('with "color" returns the correct value', () {
        expect(light['color'], equals(new Vector3(1.0, 1.0, 1.0)));
      });

      test('with "direction" returns the correct value', () {
        expect(light['direction'], equals(new Vector3(0.0, 0.0, 1.0)));
      });

      test('with a nonexisting member name returns null', () {
        expect(light['nonexisting'], isNull);
      });
    });
  });
}
