import 'package:test/test.dart';
import 'package:scene_3d/observable_value.dart';
import 'package:scene_3d/rendering/realtime/atomic_render_unit.dart';
import 'package:scene_3d/rendering/realtime/sorting.dart';

class Program {}

class ProgramGroupableRenderUnit extends AtomicRenderUnit {
  ObservableValue<Program> program;

  ObservableValue<bool> isTranslucent;

  ProgramGroupableRenderUnit(Program program)
      : program = new ObservableValue(program);

  void render() {}
}

void main() {
  group('GroupingNode', () {
    var i = 0;

    makeUnitNode(ProgramGroupableRenderUnit renderUnit) =>
        new RenderUnitNode(renderUnit, new ObservableValue(0));

    makeUnitGroupNode(Program program) =>
        new RenderUnitGroupNode<ProgramGroupableRenderUnit>(
            new StaticSortCode(i++), makeUnitNode);

    group('process', () {
      final program1 = new Program();
      final program2 = new Program();

      final renderUnit1 = new ProgramGroupableRenderUnit(program1);
      final renderUnit2 = new ProgramGroupableRenderUnit(program2);
      final renderUnit3 = new ProgramGroupableRenderUnit(program1);
      final renderUnit4 = new ProgramGroupableRenderUnit(null);
      final renderUnit5 = new ProgramGroupableRenderUnit(null);

      group('a render unit', () {
        final node = new GroupingNode<ProgramGroupableRenderUnit, Program>(
            (u) => u.program,
            makeUnitGroupNode,
            new StaticSortCode(0));

        node.process(renderUnit1);

        test('results in a new branch', () {
          expect(node.branches.length, equals(1));
        });
      });

      group('2 render units with a different program', () {
        final node = new GroupingNode<ProgramGroupableRenderUnit, Program>(
            (u) => u.program,
            makeUnitGroupNode,
            new StaticSortCode(0));

        node.process(renderUnit1);
        node.process(renderUnit2);

        test('results in 2 branches', () {
          expect(node.branches.length, equals(2));
        });
      });

      group('2 render units the same program', () {
        final node = new GroupingNode<ProgramGroupableRenderUnit, Program>(
            (u) => u.program,
            makeUnitGroupNode,
            new StaticSortCode(0));

        node.process(renderUnit1);
        node.process(renderUnit3);

        test('results in 1 branch with 2 children', () {
          expect(node.branches.length, equals(1));
          expect((node.branches.first as BranchingNode).branches.length, equals(2));
        });
      });

      group('processing a render unit with a program and a render unit with a null program', () {
        final node = new GroupingNode<ProgramGroupableRenderUnit, Program>(
            (u) => u.program,
            makeUnitGroupNode,
            new StaticSortCode(0));

        node.process(renderUnit1);
        node.process(renderUnit4);

        test('results in 2 branches', () {
          expect(node.branches.length, equals(2));
        });
      });

      group('processing a render unit with a program and 2 render units with a null program', () {
        final node = new GroupingNode<ProgramGroupableRenderUnit, Program>(
            (u) => u.program,
            makeUnitGroupNode,
            new StaticSortCode(0));

        node.process(renderUnit1);
        node.process(renderUnit4);
        node.process(renderUnit5);

        test('results in 2 branches of which the last has 2 children', () {
          expect(node.branches.length, equals(2));
          expect((node.branches.last as BranchingNode).branches.length, equals(2));
        });
      });

      group('with a default value', () {
        group('processing a render unit with the default program and a render unit with a null program', () {
          final node = new GroupingNode<ProgramGroupableRenderUnit, Program>(
              (u) => u.program,
              makeUnitGroupNode,
              new StaticSortCode(0),
              defaultValue: program1);

          node.process(renderUnit1);
          node.process(renderUnit4);

          test('results in 1 branch', () {
            expect(node.branches.length, equals(1));
          });
        });
      });
    });

    group('sort', () {
      final program1 = new Program();
      final program2 = new Program();

      final renderUnit1 = new ProgramGroupableRenderUnit(program1);
      final renderUnit2 = new ProgramGroupableRenderUnit(program2);
      final renderUnit3 = new ProgramGroupableRenderUnit(program1);

      group('on tree with 2 render units with different programs', () {
        final node = new GroupingNode<ProgramGroupableRenderUnit, Program>(
            (u) => u.program,
            makeUnitGroupNode,
            new StaticSortCode(0));

        node.process(renderUnit1);
        node.process(renderUnit2);

        group('after the second render unit\'s program is changed to be equal to the first render unit\'s program', () {
          renderUnit2.program.value = program1;

          node.sort();

          test('results in 1 branch with 2 children', () {
            expect(node.branches.length, equals(1));
            expect((node.branches.first as BranchingNode).branches.length, equals(2));
          });
        });
      });

      group('on tree with 2 render units with the same program', () {
        final node = new GroupingNode<ProgramGroupableRenderUnit, Program>(
            (u) => u.program,
            makeUnitGroupNode,
            new StaticSortCode(0));

        node.process(renderUnit1);
        node.process(renderUnit3);

        group('after the second render unit\'s program is changed to be different from the first render unit\'s program', () {
          renderUnit3.program.value = program2;

          node.sort();

          test('results in 2 branches', () {
            expect(node.branches.length, equals(2));
          });
        });
      });
    });

    group('toRenderSortTree', () {
      final program1 = new Program();
      final program2 = new Program();

      final renderUnit1 = new ProgramGroupableRenderUnit(program1);
      final renderUnit2 = new ProgramGroupableRenderUnit(program2);
      final renderUnit3 = new ProgramGroupableRenderUnit(program1);
      final renderUnit4 = new ProgramGroupableRenderUnit(null);
      final renderUnit5 = new ProgramGroupableRenderUnit(null);

      final node = new GroupingNode<ProgramGroupableRenderUnit, Program>(
          (u) => u.program,
          makeUnitGroupNode,
          new StaticSortCode(0),
          sortOrder: SortOrder.ascending);

      node.process(renderUnit1);
      node.process(renderUnit2);
      node.process(renderUnit3);
      node.process(renderUnit4);
      node.process(renderUnit5);

      final copy = node.toRenderTree();

      test('results in 3 branches', () {
        expect(copy.branches.length, equals(3));
      });

      test('results in the first branch holding the correct render units', () {
        expect(copy.branches.elementAt(0).branches.map((b) => b.renderUnit),
            equals([renderUnit1, renderUnit3]));
      });

      test('results in the second branch holding the correct render units', () {
        expect(copy.branches.elementAt(1).branches.map((b) => b.renderUnit),
            equals([renderUnit2]));
      });

      test('results in the third branch holding the correct render units', () {
        expect(copy.branches.elementAt(2).branches.map((b) => b.renderUnit),
            equals([renderUnit4, renderUnit5]));
      });
    });
  });
}
