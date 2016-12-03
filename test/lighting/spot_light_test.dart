import 'package:test/test.dart';
import 'package:bagl/math.dart';
import 'package:scene_3d/lighting.dart';

void main() {
  group('SpotLight', () {
    final light = new SpotLight();

    group('members', () {
      test('returns the correct values', () {
        expect(light.members, unorderedEquals([
          'position',
          'color',
          'direction',
          'constantAttenuation',
          'linearAttenuation',
          'quadraticAttenuation',
          'falloffAngleCosine',
          'falloffExponent'
        ]));
      });
    });

    group('hasMember', () {
      test('returns false for a non-existing member', () {
        expect(light.hasMember('nonexisting'), isFalse);
      });

      test('returns true for "color"', () {
        expect(light.hasMember('color'), isTrue);
      });

      test('returns true for "position"', () {
        expect(light.hasMember('position'), isTrue);
      });

      test('returns true for "direction"', () {
        expect(light.hasMember('position'), isTrue);
      });

      test('returns true for "constantAttenuation"', () {
        expect(light.hasMember('constantAttenuation'), isTrue);
      });

      test('returns true for "linearAttenuation"', () {
        expect(light.hasMember('linearAttenuation'), isTrue);
      });

      test('returns true for "quadraticAttenuation"', () {
        expect(light.hasMember('quadraticAttenuation'), isTrue);
      });

      test('returns true for "falloffAngleCosine"', () {
        expect(light.hasMember('falloffAngleCosine'), isTrue);
      });

      test('returns true for "falloffExponent"', () {
        expect(light.hasMember('falloffExponent'), isTrue);
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
          {'member': 'position', 'value': new Vector3(0.0, 0.0, 0.0)},
          {'member': 'direction', 'value': new Vector3(0.0, 0.0, 1.0)},
          {'member': 'constantAttenuation', 'value': 1.0},
          {'member': 'linearAttenuation', 'value': 0.0},
          {'member': 'quadraticAttenuation', 'value': 0.0},
          {'member': 'falloffAngleCosine', 'value': -1.0},
          {'member': 'falloffExponent', 'value': 0.0}
        ]));
      });
    });

    group('[] operator', () {
      test('with "color" returns the correct value', () {
        expect(light['color'], equals(new Vector3(1.0, 1.0, 1.0)));
      });

      test('with "position" returns the correct value', () {
        expect(light['position'], equals(new Vector3(0.0, 0.0, 0.0)));
      });

      test('with "direction" returns the correct value', () {
        expect(light['direction'], equals(new Vector3(0.0, 0.0, 1.0)));
      });

      test('with "constantAttenuation" returns the correct value', () {
        expect(light['constantAttenuation'], equals(1.0));
      });

      test('with "linearAttenuation" returns the correct value', () {
        expect(light['linearAttenuation'], equals(0.0));
      });

      test('with "quadraticAttenuation" returns the correct value', () {
        expect(light['quadraticAttenuation'], equals(0.0));
      });

      test('with "falloffAngle" returns the correct value', () {
        expect(light['falloffAngleCosine'], equals(-1.0));
      });

      test('with "falloffExponent" returns the correct value', () {
        expect(light['falloffExponent'], equals(0.0));
      });

      test('with a nonexisting member name returns null', () {
        expect(light['nonexisting'], isNull);
      });
    });
  });
}
