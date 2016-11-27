import 'package:test/test.dart';
import 'package:scene_3d/observable_value.dart';
import 'package:scene_3d/rendering/realtime/atomic_render_unit.dart';
import 'package:scene_3d/rendering/realtime/sorting.dart';

class RenderUnit extends AtomicRenderUnit {
  void render() {}
}

void main() {
  group('ChildNodes', () {
    group('ascending', () {
      makeUnitNode(AtomicRenderUnit renderUnit) =>
          new RenderUnitNode(renderUnit, new ObservableValue(0));

      final owner = new RenderUnitGroupNode(new StaticSortCode(0), makeUnitNode);
      final node1 = new RenderUnitNode(new RenderUnit(), new ObservableValue(2));
      final node2 = new RenderUnitNode(new RenderUnit(), new ObservableValue(0));
      final node3 = new RenderUnitNode(new RenderUnit(), new ObservableValue(1));
      final node4 = new RenderUnitNode(new RenderUnit(), new ObservableValue(3));

      group('after adding three nodes', () {
        final children = new ChildNodes.ascending(owner);

        children.add(node1);
        children.add(node2);
        children.add(node3);

        test('first returns the correct node', () {
          expect(children.first, equals(node2));
        });

        test('last returns the correct node', () {
          expect(children.last, equals(node1));
        });

        test('isEmpty returns false', () {
          expect(children.isEmpty, isFalse);
        });

        test('isNotEmpty returns true', () {
          expect(children.isNotEmpty, isTrue);
        });

        test('length returns 3', () {
          expect(children.length, equals(3));
        });

        group('contains', () {
          test('returns true for an added node', () {
            expect(children.contains(node1), isTrue);
          });

          test('returns false for a node that was not added', () {
            expect(children.contains(node4), isFalse);
          });
        });

        group('iterator', () {
          final iterator = children.iterator;
          final seen = [];

          while (iterator.moveNext()) {
            seen.add(iterator.current);
          }

          test('has the correct current node for each iteration', () {
            expect(seen, orderedEquals([node2, node3, node1]));
          });
        });

        group('sorting after increasing a node\'s sort code', () {
          setUpAll(() {
            node3.sortCode.value = 3;
            children.sort();
          });

          tearDownAll(() {
            node3.sortCode.value = 1;
            children.sort();
          });

          test('the first node has not changed', () {
            expect(children.first, equals(node2));
          });

          test('the last node has changed correctly', () {
            expect(children.last, equals(node3));
          });

          test('the node order has changed correctly', () {
            expect(children.toList(), orderedEquals([node2, node1, node3]));
          });
        });

        group('sorting after decreasing a node\'s sort code', () {
          setUpAll(() {
            node3.sortCode.value = -1;
            children.sort();
          });

          tearDownAll(() {
            node3.sortCode.value = 1;
            children.sort();
          });

          test('the first node has changed correctly', () {
            expect(children.first, equals(node3));
          });

          test('the last node has not changed', () {
            expect(children.last, equals(node1));
          });

          test('the node order has changed correctly', () {
            expect(children.toList(), orderedEquals([node3, node2, node1]));
          });
        });
      });

      group('remove', () {
        makeUnitNode(AtomicRenderUnit renderUnit) =>
            new RenderUnitNode(renderUnit, new ObservableValue(0));

        final owner = new RenderUnitGroupNode(new StaticSortCode(0), makeUnitNode);
        final node1 = new RenderUnitNode(new RenderUnit(), new ObservableValue(2));
        final node2 = new RenderUnitNode(new RenderUnit(), new ObservableValue(0));
        final node3 = new RenderUnitNode(new RenderUnit(), new ObservableValue(1));
        final node4 = new RenderUnitNode(new RenderUnit(), new ObservableValue(3));

        final children = new ChildNodes.ascending(owner);

        children.add(node1);
        children.add(node2);
        children.add(node3);

        test('returns false with a node that was not added', () {
          expect(children.remove(node4), isFalse);
        });

        group('with the first node', () {
          test('returns true', () {
            expect(children.remove(node2), isTrue);
          });

          test('first returns the correct node', () {
            expect(children.first, equals(node3));
          });

          test('length returns 2', () {
            expect(children.length, equals(2));
          });

          test('contains returns false with the node', () {
            expect(children.contains(node2), isFalse);
          });
        });
      });
    });

    group('descending', () {
      makeUnitNode(AtomicRenderUnit renderUnit) =>
          new RenderUnitNode(renderUnit, new ObservableValue(0));

      final owner = new RenderUnitGroupNode(new StaticSortCode(0), makeUnitNode);
      final node1 = new RenderUnitNode(new RenderUnit(), new ObservableValue(2));
      final node2 = new RenderUnitNode(new RenderUnit(), new ObservableValue(0));
      final node3 = new RenderUnitNode(new RenderUnit(), new ObservableValue(1));
      final node4 = new RenderUnitNode(new RenderUnit(), new ObservableValue(3));

      group('after adding three nodes', () {
        final children = new ChildNodes.descending(owner);

        children.add(node1);
        children.add(node2);
        children.add(node3);

        test('first returns the correct node', () {
          expect(children.first, equals(node1));
        });

        test('last returns the correct node', () {
          expect(children.last, equals(node2));
        });

        test('isEmpty returns false', () {
          expect(children.isEmpty, isFalse);
        });

        test('isNotEmpty returns true', () {
          expect(children.isNotEmpty, isTrue);
        });

        test('length returns 3', () {
          expect(children.length, equals(3));
        });

        group('contains', () {
          test('returns true for an added node', () {
            expect(children.contains(node1), isTrue);
          });

          test('returns false for a node that was not added', () {
            expect(children.contains(node4), isFalse);
          });
        });

        group('iterator', () {
          final iterator = children.iterator;
          final seen = [];

          while (iterator.moveNext()) {
            seen.add(iterator.current);
          }

          test('has the correct current node for each iteration', () {
            expect(seen, orderedEquals([node1, node3, node2]));
          });
        });

        group('sorting after increasing a node\'s sort code', () {
          setUpAll(() {
            node3.sortCode.value = 3;
            children.sort();
          });

          tearDownAll(() {
            node3.sortCode.value = 1;
            children.sort();
          });

          test('the first node has changed correctly', () {
            expect(children.first, equals(node3));
          });

          test('the last node has not changed', () {
            expect(children.last, equals(node2));
          });

          test('the node order has changed correctly', () {
            expect(children.toList(), orderedEquals([node3, node1, node2]));
          });
        });

        group('sorting after decreasing a node\'s sort code', () {
          setUpAll(() {
            node3.sortCode.value = -1;
            children.sort();
          });

          tearDownAll(() {
            node3.sortCode.value = 1;
            children.sort();
          });

          test('the first node has not changed', () {
            expect(children.first, equals(node1));
          });

          test('the last node has changed correctly', () {
            expect(children.last, equals(node3));
          });

          test('the node order has changed correctly', () {
            expect(children.toList(), orderedEquals([node1, node2, node3]));
          });
        });
      });

      group('remove', () {
        makeUnitNode(AtomicRenderUnit renderUnit) =>
            new RenderUnitNode(renderUnit, new ObservableValue(0));

        final owner = new RenderUnitGroupNode(new StaticSortCode(0), makeUnitNode);
        final node1 = new RenderUnitNode(new RenderUnit(), new ObservableValue(2));
        final node2 = new RenderUnitNode(new RenderUnit(), new ObservableValue(0));
        final node3 = new RenderUnitNode(new RenderUnit(), new ObservableValue(1));
        final node4 = new RenderUnitNode(new RenderUnit(), new ObservableValue(3));

        final children = new ChildNodes.descending(owner);

        children.add(node1);
        children.add(node2);
        children.add(node3);

        test('returns false with a node that was not added', () {
          expect(children.remove(node4), isFalse);
        });

        group('with the first node', () {
          test('returns true', () {
            expect(children.remove(node1), isTrue);
          });

          test('first returns the correct node', () {
            expect(children.first, equals(node3));
          });

          test('length returns 2', () {
            expect(children.length, equals(2));
          });

          test('contains returns false with the node', () {
            expect(children.contains(node1), isFalse);
          });
        });
      });
    });

    group('unsorted', () {
      makeUnitNode(AtomicRenderUnit renderUnit) =>
          new RenderUnitNode(renderUnit, new ObservableValue(0));

      final owner = new RenderUnitGroupNode(new StaticSortCode(0), makeUnitNode);
      final node1 = new RenderUnitNode(new RenderUnit(), new ObservableValue(2));
      final node2 = new RenderUnitNode(new RenderUnit(), new ObservableValue(0));
      final node3 = new RenderUnitNode(new RenderUnit(), new ObservableValue(1));
      final node4 = new RenderUnitNode(new RenderUnit(), new ObservableValue(3));

      group('after adding three nodes', () {
        final children = new ChildNodes.unsorted(owner);

        children.add(node1);
        children.add(node2);
        children.add(node3);

        test('first returns the correct node', () {
          expect(children.first, equals(node1));
        });

        test('last returns the correct node', () {
          expect(children.last, equals(node3));
        });

        test('isEmpty returns false', () {
          expect(children.isEmpty, isFalse);
        });

        test('isNotEmpty returns true', () {
          expect(children.isNotEmpty, isTrue);
        });

        test('length returns 3', () {
          expect(children.length, equals(3));
        });

        group('contains', () {
          test('returns true for an added node', () {
            expect(children.contains(node1), isTrue);
          });

          test('returns false for a node that was not added', () {
            expect(children.contains(node4), isFalse);
          });
        });

        group('after changing the second node\'s sort code', () {
          node2.sortCode.value = 5;

          group('after calling sort', () {
            children.sort();

            test('the first node has not changed', () {
              expect(children.first, equals(node1));
            });

            test('the last node has not changed', () {
              expect(children.last, equals(node3));
            });
          });
        });

        group('iterator', () {
          final iterator = children.iterator;
          final seen = [];

          while (iterator.moveNext()) {
            seen.add(iterator.current);
          }

          test('has the correct current node for each iteration', () {
            expect(seen, orderedEquals([node1, node2, node3]));
          });
        });
      });

      group('remove', () {
        makeUnitNode(AtomicRenderUnit renderUnit) =>
            new RenderUnitNode(renderUnit, new ObservableValue(0));

        final owner = new RenderUnitGroupNode(new StaticSortCode(0), makeUnitNode);
        final node1 = new RenderUnitNode(new RenderUnit(), new ObservableValue(2));
        final node2 = new RenderUnitNode(new RenderUnit(), new ObservableValue(0));
        final node3 = new RenderUnitNode(new RenderUnit(), new ObservableValue(1));
        final node4 = new RenderUnitNode(new RenderUnit(), new ObservableValue(3));

        final children = new ChildNodes.unsorted(owner);

        children.add(node1);
        children.add(node2);
        children.add(node3);

        test('returns false with a node that was not added', () {
          expect(children.remove(node4), isFalse);
        });

        group('with a node that was added first', () {
          test('returns true', () {
            expect(children.remove(node1), isTrue);
          });

          test('first returns the correct node', () {
            expect(children.first, equals(node2));
          });

          test('length returns 2', () {
            expect(children.length, equals(2));
          });

          test('contains returns false with the node', () {
            expect(children.contains(node1), isFalse);
          });
        });
      });
    });
  });
}
