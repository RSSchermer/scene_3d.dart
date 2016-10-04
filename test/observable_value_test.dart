import 'package:test/test.dart';
import 'package:scene_3d/observable_value.dart';

void main() {
  group('ObserverableValue', () {
    group('default construct', () {
      group('with initial value', () {
        final value = new ObservableValue('something');

        test('results in a new instance with the correct value', () {
          expect(value.value, equals('something'));
        });
      });
    });

    group('with a subcriber', () {
      group('the value is changed to another value', () {
        final value = new ObservableValue('something');
        final subscriber = new Object();
        final calls = [];

        value.subscribe(subscriber, (newValue, oldValue) {
          calls.add({
            'oldValue': oldValue,
            'newValue': newValue
          });
        });

        value.value = 'something else';

        test('the subscribed handler was called once', () {
          expect(calls.length, equals(1));
        });

        test('the subscribed handler was called with the correct new value', () {
          expect(calls[0]['newValue'], equals('something else'));
        });

        test('the subscribed handler was called with the correct old value', () {
          expect(calls[0]['oldValue'], equals('something'));
        });

        group('the value is changed after unsubscribing', () {
          value.unsubscribe(subscriber);
          value.value = 'another thing';

          test('the subscribed handler is not called anymore', () {
            expect(calls.length, equals(1));
          });
        });
      });

      group('the value is changed to an identical value', () {
        final value = new ObservableValue('something');
        final subscriber = new Object();
        final calls = [];

        value.subscribe(subscriber, (newValue, oldValue) {
          calls.add({
            'oldValue': oldValue,
            'newValue': newValue
          });
        });

        value.value = 'something';

        test('the subscribed handler was not called', () {
          expect(calls.length, equals(0));
        });
      });
    });
  });
}