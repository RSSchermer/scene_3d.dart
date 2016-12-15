library shape.loading.obj;

import 'dart:async';
import 'dart:typed_data';

import 'package:bagl/geometry.dart';
import 'package:bagl/math.dart';
import 'package:bagl/texture.dart';
import 'package:bagl/vertex_data.dart';
import 'package:objectivist/mtl_reading.dart';
import 'package:objectivist/mtl_statements.dart';
import 'package:objectivist/obj_reading.dart';
import 'package:objectivist/obj_reading/errors.dart';
import 'package:objectivist/obj_statements.dart';
import 'package:path/path.dart' as path;
import 'package:resource/resource.dart';
import 'package:scene_3d/material.dart';
import 'package:scene_3d/shape.dart';

part 'src/obj/_chunked_attribute_data.dart';
part 'src/obj/_chunked_index_data.dart';
part 'src/obj/_statement_visiting_materials_builder.dart';
part 'src/obj/_statement_visiting_shapes_builder.dart';

Future<Iterable<PrimitivesShape>> loadObj(String uri,
    {SurfaceMaterial defaultMaterial}) {
  final resource = new Resource(uri);
  final builder = new _StatementVisitingShapesBuilder(resource.uri);
  final errors = [];

  defaultMaterial ??= new PhongMaterial();

  return statementizeObjResourceStreamed(resource).forEach((results) {
    errors.addAll(results.errors);

    for (var statement in results) {
      statement.acceptVisit(builder);
    }
  }).then((_) {
    final results = builder.build();

    errors.addAll(results.errors);

    return Future.wait(results.mtlBuilderResults).then((mtlBuilderResults) {
      for (var result in mtlBuilderResults) {
        errors.addAll(result.errors);
      }

      final shapes = [];

      results.triangleShapeResults.forEach((result) {
        final usemtlStatement = result.usemtlStatement;

        if (usemtlStatement == null) {
          shapes.add(new TrianglesShape(result.triangles, defaultMaterial));
        } else {
          final materialName = usemtlStatement.materialName;
          var material;

          for (var mtlLibrary in mtlBuilderResults) {
            material = mtlLibrary.materialsByName[materialName];

            if (material != null) {
              break;
            }
          }

          if (material == null) {
            errors.add(new ObjReadingError(
                usemtlStatement.lineNumber,
                'Could not find a material named "$materialName" in any of the '
                'referenced material libraries.'));
          } else {
            shapes.add(new TrianglesShape(result.triangles, material));
          }
        }
      });

      return shapes;
    });
  });
}
