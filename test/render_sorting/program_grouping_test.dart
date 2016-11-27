import 'package:test/test.dart';
import 'package:bagl/rendering.dart';
import 'package:scene_3d/observable_value.dart';
import 'package:scene_3d/render_sorting.dart';

class ProgramGroupableRenderUnit extends AtomicRenderUnit with ProgramGroupable {
  final ObservableValue<Program> program;

  ProgramGroupableRenderUnit(Program program) : program = new ObservableValue(program);

  void render() {}
}

class OtherRenderUnit extends AtomicRenderUnit {
  void render() {}
}

void main() {
  group('ProgramBranchingNode', () {
    makeUnitNode(AtomicRenderUnit renderUnit) =>
        new RenderUnitNode(renderUnit, new ObservableValue(0));

    makeUnitGroupNode() =>
        new RenderUnitGroupNode(new StaticSortCode(0), makeUnitNode);

    group('process', () {
      final program1 = new Program('vertex1', 'fragment1');
      final program2 = new Program('vertex2', 'fragment2');

      final renderUnit1 = new ProgramGroupableRenderUnit(program1);
      final renderUnit2 = new ProgramGroupableRenderUnit(program2);
      final renderUnit3 = new ProgramGroupableRenderUnit(program1);
      final renderUnit4 = new OtherRenderUnit();
      final renderUnit5 = new OtherRenderUnit();

      group('a ProgramGroupable render unit', () {
        final node = new ProgramBranchingNode(
            new StaticSortCode(0), makeUnitGroupNode);

        node.process(renderUnit1);

        test('results in a new branch', () {
          expect(node.children.length, equals(1));
        });
      });

      group('2 ProgramGroupable render units with a different program', () {
        final node = new ProgramBranchingNode(
            new StaticSortCode(0), makeUnitGroupNode);

        node.process(renderUnit1);
        node.process(renderUnit2);

        test('results in 2 branches', () {
          expect(node.children.length, equals(2));
        });
      });

      group('2 ProgramGroupable render units the same program', () {
        final node = new ProgramBranchingNode(
            new StaticSortCode(0), makeUnitGroupNode);

        node.process(renderUnit1);
        node.process(renderUnit3);

        test('results in 1 branch with 2 children', () {
          expect(node.children.length, equals(1));
          expect((node.children.first as BranchingNode).children.length, equals(2));
        });
      });

      group('processing a ProgramGroupable render unit and a render unit that is not ProgramGroupable', () {
        final node = new ProgramBranchingNode(
            new StaticSortCode(0), makeUnitGroupNode);

        node.process(renderUnit1);
        node.process(renderUnit4);

        test('results in 2 branches', () {
          expect(node.children.length, equals(2));
        });
      });

      group('processing a ProgramGroupable render unit and 2 render units that are not ProgramGroupable', () {
        final node = new ProgramBranchingNode(
            new StaticSortCode(0), makeUnitGroupNode);

        node.process(renderUnit1);
        node.process(renderUnit4);
        node.process(renderUnit5);

        test('results in 2 branches of which the last has 2 children', () {
          expect(node.children.length, equals(2));
          expect((node.children.last as BranchingNode).children.length, equals(2));
        });
      });
    });

    group('sortTree', () {
      final program1 = new Program('vertex1', 'fragment1');
      final program2 = new Program('vertex2', 'fragment2');

      final renderUnit1 = new ProgramGroupableRenderUnit(program1);
      final renderUnit2 = new ProgramGroupableRenderUnit(program2);
      final renderUnit3 = new ProgramGroupableRenderUnit(program1);

      group('on tree with 2 ProgramGroupable render units with different programs', () {
        final node = new ProgramBranchingNode(
            new StaticSortCode(0), makeUnitGroupNode);

        node.process(renderUnit1);
        node.process(renderUnit2);

        group('after the second render unit\'s program is changed to be equal to the first render unit\'s program', () {
          renderUnit2.program.value = program1;

          node.sort();

          test('results in 1 branch with 2 children', () {
            expect(node.children.length, equals(1));
            expect((node.children.first as BranchingNode).children.length, equals(2));
          });
        });
      });

      group('on tree with 2 ProgramGroupable render units with the same program', () {
        final node = new ProgramBranchingNode(
            new StaticSortCode(0), makeUnitGroupNode);

        node.process(renderUnit1);
        node.process(renderUnit3);

        group('after the second render unit\'s program is changed to be different from the first render unit\'s program', () {
          renderUnit3.program.value = program2;

          node.sort();

          test('results in 2 branches', () {
            expect(node.children.length, equals(2));
          });
        });
      });
    });

    group('toRenderSortTree', () {
      final program1 = new Program('vertex1', 'fragment1');
      final program2 = new Program('vertex2', 'fragment2');

      final renderUnit1 = new ProgramGroupableRenderUnit(program1);
      final renderUnit2 = new ProgramGroupableRenderUnit(program2);
      final renderUnit3 = new ProgramGroupableRenderUnit(program1);
      final renderUnit4 = new OtherRenderUnit();
      final renderUnit5 = new OtherRenderUnit();

      final node = new ProgramBranchingNode(
          new StaticSortCode(0), makeUnitGroupNode);

      node.process(renderUnit1);
      node.process(renderUnit2);
      node.process(renderUnit3);
      node.process(renderUnit4);
      node.process(renderUnit5);

      final copy = node.toRenderTree();

      test('results in a new node with the correct branches', () {
        expect(copy.children.length, equals(3));
        expect((copy.children.elementAt(0) as BranchingNode).children.length, equals(2));
        expect((copy.children.elementAt(1) as BranchingNode).children.length, equals(1));
        expect((copy.children.elementAt(2) as BranchingNode).children.length, equals(2));
      });
    });
  });
}
