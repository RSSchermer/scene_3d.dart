import 'package:test/test.dart';
import 'package:scene_3d/observable_value.dart';
import 'package:scene_3d/render_sorting.dart';

class TranslucencyGroupableRenderUnit extends AtomicRenderUnit with TranslucencyGroupable {
  final ObservableValue<bool> isTranslucent;

  TranslucencyGroupableRenderUnit(bool isTranslucent) : isTranslucent = new ObservableValue(isTranslucent);

  void render() {}
}

class OtherRenderUnit extends AtomicRenderUnit {
  void render() {}
}

void main() {
  group('TranslucencyBranchingNode', () {
    makeUnitNode(AtomicRenderUnit renderUnit) =>
        new RenderUnitNode(renderUnit, new ObservableValue(0));

    makeUnitGroupNode() =>
        new RenderUnitGroupNode(new StaticSortCode(0), makeUnitNode);

    group('process', () {
      final renderUnit1 = new TranslucencyGroupableRenderUnit(false);
      final renderUnit2 = new TranslucencyGroupableRenderUnit(false);
      final renderUnit3 = new TranslucencyGroupableRenderUnit(true);
      final renderUnit4 = new TranslucencyGroupableRenderUnit(true);
      final renderUnit5 = new OtherRenderUnit();

      group('a TranslucencyGroupable render unit', () {
        final node = new ProgramBranchingNode(
            new StaticSortCode(0), makeUnitGroupNode);

        node.process(renderUnit1);

        test('results in a new branch', () {
          expect(node.children.length, equals(1));
        });
      });

      group('2 translucent TranslucencyGroupable render units and 2 opaque TranslucencyGroupable render units', () {
        final node = new TranslucencyBranchingNode(
            makeUnitGroupNode(), makeUnitGroupNode());

        node.process(renderUnit1);
        node.process(renderUnit2);
        node.process(renderUnit3);
        node.process(renderUnit4);

        test('results in the opaque branch containing 2 children', () {
          expect(node.opaqueBranch.children.length, equals(2));
        });

        test('results in the translucent branch containing 2 children', () {
          expect(node.translucentBranch.children.length, equals(2));
        });
      });

      group('processing a render unit that is not TranslucencyGroupable', () {
        final node = new TranslucencyBranchingNode(
            makeUnitGroupNode(), makeUnitGroupNode());

        node.process(renderUnit5);

        test('results in the opaque branch containing 1 child', () {
          expect(node.opaqueBranch.children.length, equals(1));
        });

        test('results in the translucent branch containing 0 children', () {
          expect(node.translucentBranch.children.length, equals(0));
        });
      });
    });

    group('sortTree', () {
      final renderUnit1 = new TranslucencyGroupableRenderUnit(false);
      final renderUnit2 = new TranslucencyGroupableRenderUnit(true);

      group('on tree with 1 opaque render unit and 1 translucent render unit', () {
        final node = new TranslucencyBranchingNode(
            makeUnitGroupNode(), makeUnitGroupNode());

        node.process(renderUnit1);
        node.process(renderUnit2);

        group('after the second render unit is set to opaque', () {
          renderUnit2.isTranslucent.value = false;

          node.sortTree();

          test('results in the opaque branch containing 2 children', () {
            expect(node.opaqueBranch.children.length, equals(2));
          });

          test('results in the translucent branch containing 0 children', () {
            expect(node.translucentBranch.children.length, equals(0));
          });
        });
      });
    });

    group('toRenderSortTree', () {
      final renderUnit1 = new TranslucencyGroupableRenderUnit(false);
      final renderUnit2 = new TranslucencyGroupableRenderUnit(true);
      final renderUnit3 = new TranslucencyGroupableRenderUnit(true);
      final renderUnit4 = new OtherRenderUnit();

      final node = new TranslucencyBranchingNode(
          makeUnitGroupNode(), makeUnitGroupNode());

      node.process(renderUnit1);
      node.process(renderUnit2);
      node.process(renderUnit3);
      node.process(renderUnit4);

      final copy = node.toRenderSortTree();

      test('results in a new node with the correct branches', () {
        expect(copy.translucentBranch.children.length, equals(2));
        expect(copy.opaqueBranch.children.length, equals(2));
      });
    });
  });
}
