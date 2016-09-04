import 'package:test/test.dart';
import 'package:scene_3d/observable_set.dart';

void main() {
  group('ObserverableSet', () {
    group('instance', () {
      group('add', () {
        group('with a value not yet contained in the set', () {
          final set = new ObservableSet<int>();

          test('calls a change listener once with the correct change record', () {
            set.changes.listen(expectAsync((changeRecord) {
              expect(changeRecord.additions, unorderedEquals([1]));
              expect(changeRecord.removals, unorderedEquals([]));
            }, count: 1));

            set.add(1);
          });
        });

        group('with a value already contained in the set', () {
          final set = new ObservableSet<int>.from([1]);

          test('does not call the change listener', () {
            set.changes.listen(expectAsync((changeRecord) { }, count: 0));

            set.add(1);
          });
        });
      });

      group('addAll', () {
        group('with values that are not all contained in the set', () {
          final set = new ObservableSet<int>.from([1]);

          test('calls a change listener once with the correct change record', () {
            set.changes.listen(expectAsync((changeRecord) {
              expect(changeRecord.additions, unorderedEquals([2, 3]));
              expect(changeRecord.removals, unorderedEquals([]));
            }, count: 1));

            set.addAll([1, 2, 3]);
          });
        });

        group('with values that are all contained in the set', () {
          final set = new ObservableSet<int>.from([1, 2, 3]);

          test('does not call the change listener', () {
            set.changes.listen(expectAsync((changeRecord) { }, count: 0));

            set.addAll([1, 2, 3]);
          });
        });
      });

      group('clear', () {
        group('on a set that is not empty', () {
          final set = new ObservableSet<int>.from([1, 2, 3]);

          test('calls a change listener once with the correct change record', () {
            set.changes.listen(expectAsync((changeRecord) {
              expect(changeRecord.additions, unorderedEquals([]));
              expect(changeRecord.removals, unorderedEquals([1, 2, 3]));
            }, count: 1));

            set.clear();
          });
        });

        group('on an empty set', () {
          final set = new ObservableSet<int>();

          test('does not call the change listener', () {
            set.changes.listen(expectAsync((changeRecord) { }, count: 0));

            set.clear();
          });
        });
      });

      group('remove', () {
        group('with a value contained in the set', () {
          final set = new ObservableSet<int>.from([1, 2, 3]);

          test('calls a change listener once with the correct change record', () {
            set.changes.listen(expectAsync((changeRecord) {
              expect(changeRecord.additions, unorderedEquals([]));
              expect(changeRecord.removals, unorderedEquals([2]));
            }, count: 1));

            set.remove(2);
          });
        });

        group('with a value not contained in the set', () {
          final set = new ObservableSet<int>.from([1, 2, 3]);

          test('does not call the change listener', () {
            set.changes.listen(expectAsync((changeRecord) { }, count: 0));

            set.remove(4);
          });
        });
      });

      group('removeAll', () {
        group('with values that intersect the set', () {
          final set = new ObservableSet<int>.from([1, 2, 3]);

          test('calls a change listener once with the correct change record', () {
            set.changes.listen(expectAsync((changeRecord) {
              expect(changeRecord.additions, unorderedEquals([]));
              expect(changeRecord.removals, unorderedEquals([2, 3]));
            }, count: 1));

            set.removeAll([2, 3, 4]);
          });
        });

        group('with values that do not intersect the set', () {
          final set = new ObservableSet<int>.from([1, 2, 3]);

          test('does not call the change listener', () {
            set.changes.listen(expectAsync((changeRecord) { }, count: 0));

            set.removeAll([4, 5]);
          });
        });
      });

      group('removeWhere', () {
        group('with a function that evaluates to true for a subset of the values in the set', () {
          final set = new ObservableSet<int>.from([1, 2, 3]);

          test('calls a change listener once with the correct change record', () {
            set.changes.listen(expectAsync((changeRecord) {
              expect(changeRecord.additions, unorderedEquals([]));
              expect(changeRecord.removals, unorderedEquals([2, 3]));
            }, count: 1));

            set.removeWhere((o) => [2, 3].contains(o));
          });
        });

        group('with a function that evaluates to false for all values', () {
          final set = new ObservableSet<int>.from([1, 2, 3]);

          test('does not call the change listener', () {
            set.changes.listen(expectAsync((changeRecord) { }, count: 0));

            set.removeWhere((o) => false);
          });
        });
      });

      group('retainAll', () {
        group('with a collection that does not contain the set', () {
          final set = new ObservableSet<int>.from([1, 2, 3]);

          test('calls a change listener once with the correct change record', () {
            set.changes.listen(expectAsync((changeRecord) {
              expect(changeRecord.additions, unorderedEquals([]));
              expect(changeRecord.removals, unorderedEquals([1]));
            }, count: 1));

            set.retainAll([2, 3, 4]);
          });
        });

        group('with a collection that contains the set', () {
          final set = new ObservableSet<int>.from([1, 2, 3]);

          test('does not call the change listener', () {
            set.changes.listen(expectAsync((changeRecord) { }, count: 0));

            set.retainAll([1, 2, 3, 4]);
          });
        });
      });

      group('retainWhere', () {
        group('with a function that evaluates to false for a subset of the values in the set', () {
          final set = new ObservableSet<int>.from([1, 2, 3]);

          test('calls a change listener once with the correct change record', () {
            set.changes.listen(expectAsync((changeRecord) {
              expect(changeRecord.additions, unorderedEquals([]));
              expect(changeRecord.removals, unorderedEquals([2, 3]));
            }, count: 1));

            set.retainWhere((o) => ![2, 3].contains(o));
          });
        });

        group('with a function that evaluates to true for all values', () {
          final set = new ObservableSet<int>.from([1, 2, 3]);

          test('does not call the change listener', () {
            set.changes.listen(expectAsync((changeRecord) { }, count: 0));

            set.retainWhere((o) => true);
          });
        });
      });
    });
  });
}
