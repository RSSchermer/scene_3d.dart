import 'package:test/test.dart';
import 'package:bagl/rendering.dart';
import 'package:scene_3d/observable_value.dart';
import 'package:scene_3d/render_sorting.dart';

class RenderUnit extends AtomicRenderUnit with TranslucencyGroupable, ProgramGroupable, SquaredDistanceSortable {
  final int id;

  final ObservableValue<bool> isTranslucent;

  final ObservableValue<Program> program;

  final ObservableValue<double> squaredDistance;

  RenderUnit(this.id, bool isTranslucent, Program program, double squaredDistance)
      : isTranslucent = new ObservableValue(isTranslucent),
        program = new ObservableValue(program),
        squaredDistance = new ObservableValue(squaredDistance);

  void render() {}
}

void main() {
  group('SortedRenderBin', () {
    makeOpaqueUnitNode(AtomicRenderUnit renderUnit) =>
        new RenderUnitNode(renderUnit, new ObservableValue(0));

    makeOpaqueUnitGroupNode() =>
        new RenderUnitGroupNode(new StaticSortCode(0), makeOpaqueUnitNode);

    final opaqueBranch = new ProgramBranchingNode(
        new StaticSortCode(0), makeOpaqueUnitGroupNode);

    makeTranslucentUnitNode(AtomicRenderUnit renderUnit) {
      if (renderUnit is SquaredDistanceSortable) {
        return new RenderUnitNode(renderUnit, renderUnit.squaredDistance);
      } else {
        return new RenderUnitNode(renderUnit, new ObservableValue(0));
      }
    }

    final translucentBranch = new RenderUnitGroupNode(
        new StaticSortCode(0), makeTranslucentUnitNode,
        sortOrder: SortOrder.descending);

    final root = new TranslucencyBranchingNode(opaqueBranch, translucentBranch);
    final units = new RenderSortTreeUnits(root);

    final program1 = new Program('vertex1', 'fragment1');
    final program2 = new Program('vertex2', 'fragment2');

    final unit1 = new RenderUnit(1, true, program1, 4.0);
    final unit2 = new RenderUnit(2, false, program1, 2.0);
    final unit3 = new RenderUnit(3, false, program2, 3.0);
    final unit4 = new RenderUnit(4, true, program2, 1.0);
    final unit5 = new RenderUnit(5, false, program1, 4.0);

    group('after adding 5 units', () {
      units.addAll([unit1, unit2, unit3, unit4, unit5]);

      test('length returns 5', () {
        expect(units.length, equals(5));
      });

      test('iterator returns an iterator that returns the correct current value on each iteration', () {
        print(units.map((u) => u != null ? u.id : 0).toList());
        print(translucentBranch.children.toList());
        print(translucentBranch.children.first.previousSibling);
        print(translucentBranch.children.last.nextSibling);

        final iterator = units.iterator;
        final seen = [];

        while (iterator.moveNext()) {
          seen.add(iterator.current);
        }

        expect(seen, orderedEquals([unit2, unit5, unit3, unit1, unit4]));
      });

//      group('after changing an observable value used as for grouping', () {
//        setUp(() {
//          unit1.isTranslucent.value = false;
//        });
//
//        tearDown(() {
//          unit1.isTranslucent.value = true;
//        });
//
//        test('the iteration order is updated correctly', () {
//          print(units.toList().map((u) => u != null ? u.id : 0));
//
//          final iterator = units.iterator;
//          final seen = [];
//
//          while (iterator.moveNext()) {
//            seen.add(iterator.current);
//          }
//
//          expect(seen, orderedEquals([unit2, unit5, unit1, unit3, unit4]));
//        });
//      });
//
//      group('after changing an observable value used for sorting', () {
//        setUp(() {
//          unit4.squaredDistance.value = 5.0;
//        });
//
//        tearDown(() {
//          unit4.squaredDistance.value = 1.0;
//        });
//
//        test('the iteration order is updated correctly', () {
//          final iterator = units.iterator;
//          final seen = [];
//
//          while (iterator.moveNext()) {
//            seen.add(iterator.current);
//          }
//
//          expect(seen, orderedEquals([unit2, unit5, unit3, unit4, unit1]));
//        });
//      });
//
//      group('after removing a render unit', () {
//        setUp(() {
//          units.remove(unit3);
//        });
//
//        tearDown(() {
//          units.add(unit3);
//        });
//
//        test('length returns 4', () {
//          expect(units.length, equals(4));
//        });
//
//        test('iterator returns an iterator that returns the correct current value on each iteration', () {
//          final iterator = units.iterator;
//          final seen = [];
//
//          while (iterator.moveNext()) {
//            seen.add(iterator.current);
//          }
//
//          expect(seen, orderedEquals([unit2, unit5, unit1, unit4]));
//        });
//      });
    });
  });
}
