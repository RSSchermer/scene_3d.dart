library obj_file_parser;

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

import 'material.dart';
import 'shape.dart';

Future<Iterable<PrimitivesShape>> loadObj(String uri,
    {PhongMaterial defaultTrianglesMaterial}) {
  final resource = new Resource(uri);
  final builder = new _StatementVisitingShapesBuilder(resource.uri);
  final errors = [];

  defaultTrianglesMaterial ??= new PhongMaterial();

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
          shapes.add(new TrianglesShape(result.triangles, defaultTrianglesMaterial));
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
            errors.add(new ObjReadingError(usemtlStatement.lineNumber,
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

class _StatementVisitingShapesBuilder implements ObjStatementVisitor {
  final Uri uri;

  final int vertexDataChunkSize;

  final int indexDataChunkSize;

  int _activeSmoothingGroup = 0;

  UsemtlStatement _activeUsemtlStatement;

  List<Future<_MtlBuilderResult>> _mtlLibraries = [];

  _ChunkedAttributeData _positionData;

  _ChunkedAttributeData _normalData;

  _ChunkedAttributeData _texCoordData;

  _ChunkedAttributeData _trianglesAttributeData;

  _ChunkedIndexData _trianglesIndexData;

  Map<VertexNumTriple, int> _numTripleVertexIndexMap = {};

  List<_ShapeRange> _trianglesRanges = [];

  final List<ObjReadingError> _errors = [];

  _StatementVisitingShapesBuilder(this.uri,
      {this.vertexDataChunkSize: 1000,
      this.indexDataChunkSize: 3000}) {
    _positionData = new _ChunkedAttributeData(4, vertexDataChunkSize);
    _normalData = new _ChunkedAttributeData(3, vertexDataChunkSize);
    _texCoordData = new _ChunkedAttributeData(3, vertexDataChunkSize);
    _trianglesAttributeData = new _ChunkedAttributeData(9, vertexDataChunkSize);
    _trianglesIndexData = new _ChunkedIndexData(indexDataChunkSize);
  }

  void visitVStatement(VStatement statement) {
    _positionData.addRow([
      statement.x ?? 0.0,
      statement.y ?? 0.0,
      statement.z ?? 0.0,
      statement.w ?? 1.0
    ]);
  }

  void visitVtStatement(VtStatement statement) {
    _texCoordData
        .addRow([statement.u ?? 0.0, statement.v ?? 0.0, statement.w ?? 0.0]);
  }

  void visitVnStatement(VnStatement statement) {
    _normalData
        .addRow([statement.i ?? 0.0, statement.j ?? 0.0, statement.k ?? 0.0]);
  }

  void visitVpStatement(VpStatement statement) {}

  void visitCstypeStatement(CstypeStatement statement) {}

  void visitDegStatement(DegStatement statement) {}

  void visitBmatStatement(BmatStatement statement) {}

  void visitStepStatement(StepStatement statement) {}

  void visitPStatement(PStatement statement) {}

  void visitLStatement(LStatement statement) {}

  void visitFStatement(FStatement statement) {
    final numTriples = statement.vertexNumTriples.toList();

    if (numTriples.length >= 3) {
      final vertexRowIndices = [];
      var requiresFaceNormal = false;

      for (var numTriple in numTriples) {
        final vNum = numTriple.vNum;
        final vnNum = numTriple.vnNum;
        final vtNum = numTriple.vtNum;

        if (vnNum == null) {
          requiresFaceNormal = true;
        }

        var seenIndex = null;

        if (requiresFaceNormal && _activeSmoothingGroup != 0) {
          final key = new VertexNumTriple(vNum, vtNum, _activeSmoothingGroup);

          seenIndex = _numTripleVertexIndexMap[key];
        } else if (!requiresFaceNormal) {
          seenIndex = _numTripleVertexIndexMap[numTriple];
        }

        if (seenIndex != null) {
          vertexRowIndices.add(seenIndex);
        } else {
          final row = new Float32List(9);

          final positionIndex =
              vNum < 0 ? _positionData.rowCount + vNum : vNum - 1;
          final position = _positionData.rowAt(positionIndex);

          if (position != null) {
            row[0] = position[0];
            row[1] = position[1];
            row[2] = position[2];
            row[3] = position[3];
          } else {
            _errors.add(new ObjReadingError(
                statement.lineNumber, 'Invalid `v` reference: $vNum.'));
          }

          if (vnNum != null) {
            final normalIndex =
                vnNum < 0 ? _normalData.rowCount + vnNum : vnNum - 1;
            final normal = _normalData.rowAt(normalIndex);

            if (normal != null) {
              row[4] = normal[0];
              row[5] = normal[1];
              row[6] = normal[2];
            } else {
              _errors.add(new ObjReadingError(
                  statement.lineNumber, 'Invalid `vn` reference: $vnNum.'));
            }
          }

          if (vtNum != null) {
            final texCoordIndex =
                vtNum < 0 ? _texCoordData.rowCount + vtNum : vtNum - 1;
            final texCoord = _texCoordData.rowAt(texCoordIndex);

            if (texCoord != null) {
              row[7] = texCoord[0];
              row[8] = 1.0 - texCoord[1];
            } else {
              _errors.add(new ObjReadingError(
                  statement.lineNumber, 'Invalid `vt` reference: $vtNum.'));
            }
          }

          _trianglesAttributeData.addRow(row);

          final index = _trianglesAttributeData.rowCount - 1;

          if (requiresFaceNormal && _activeSmoothingGroup != 0) {
            final key = new VertexNumTriple(vNum, vtNum, _activeSmoothingGroup);

            _numTripleVertexIndexMap[key] = index;
          } else {
            _numTripleVertexIndexMap[numTriple] = index;
          }

          vertexRowIndices.add(index);
        }
      }

      final vertexCount = vertexRowIndices.length;

      for (var i = 2; i < vertexCount; i++) {
        _trianglesIndexData.add(vertexRowIndices[0]);
        _trianglesIndexData.add(vertexRowIndices[i - 1]);
        _trianglesIndexData.add(vertexRowIndices[i]);
      }

      if (requiresFaceNormal) {
        var normalI = 0.0;
        var normalJ = 0.0;
        var normalK = 0.0;

        for (var i = 0; i < vertexCount; i++) {
          final current = _trianglesAttributeData.rowAt(vertexRowIndices[i]);
          final next = _trianglesAttributeData
              .rowAt(vertexRowIndices[(i + 1) % vertexCount]);
          final currentX = current[0];
          final currentY = current[1];
          final currentZ = current[2];
          final nextX = next[0];
          final nextY = next[1];
          final nextZ = next[2];

          normalI += (currentY - nextY) * (currentZ + nextZ);
          normalJ += (currentZ - nextZ) * (currentX + nextX);
          normalK += (currentX - nextX) * (currentY + nextY);
        }

        for (var index in vertexRowIndices) {
          final row = _trianglesAttributeData.rowAt(index);

          row[4] += normalI;
          row[5] += normalJ;
          row[6] += normalK;
        }
      }
    } else {
      _errors.add(new ObjReadingError(statement.lineNumber,
          'An `f` statement must define at least 3 vertices.'));
    }
  }

  void visitCurvStatement(CurvStatement statement) {}

  void visitCurv2Statement(Curv2Statement statement) {}

  void visitSurfStatement(SurfStatement statement) {}

  void visitParmStatement(ParmStatement statement) {}

  void visitTrimStatement(TrimStatement statement) {}

  void visitHoleStatement(HoleStatement statement) {}

  void visitScrvStatement(ScrvStatement statement) {}

  void visitSpStatement(SpStatement statement) {}

  void visitEndStatement(EndStatement statement) {}

  void visitConStatement(ConStatement statement) {}

  void visitGStatement(GStatement statement) {}

  void visitSStatement(SStatement statement) {
    _activeSmoothingGroup = statement.isOn ? statement.smoothingGroup : 0;
  }

  void visitMgStatement(MgStatement statement) {}

  void visitOStatement(OStatement statement) {}

  void visitBevelStatement(BevelStatement statement) {}

  void visitCInterpStatement(CInterpStatement statement) {}

  void visitDInterpStatement(DInterpStatement statement) {}

  void visitLodStatement(LodStatement statement) {}

  void visitMaplibStatement(MaplibStatement statement) {}

  void visitUsemapStatement(UsemapStatement statement) {}

  void visitUsemtlStatement(UsemtlStatement statement) {
    _finishTrianglesRange();

    _activeUsemtlStatement = statement;
  }

  void visitMtllibStatement(MtllibStatement statement) {
    final dirname = path.dirname(uri.path);

    for (var filename in statement.filenames) {
      final uri = path.isAbsolute(filename) ? filename : path.join(dirname, filename);
      final resource = new Resource(uri);
      final builder = new _StatementVisitingMtlBuilder(resource.uri);

      final mtlLibrary = statementizeMtlResourceStreamed(resource).forEach((results) {
        // TODO: make reading errors implement common interface in objectivist
        // _errors.addAll(results.errors);

        for (var statement in results) {
          statement.acceptVisit(builder);
        }
      }).then((_) => builder.build());

      _mtlLibraries.add(mtlLibrary);
    }
  }

  void visitShadowObjStatement(ShadowObjStatement statement) {}

  void visitTraceObjStatement(TraceObjStatement statement) {}

  void visitCtechStatement(CtechStatement statement) {}

  void visitStechStatement(StechStatement statement) {}

  _ObjBuilderResult build() {
    final attributeData = _trianglesAttributeData.asAttributeDataTable();
    final indexList = _trianglesIndexData.asIndexList();
    final vertexArray =
        new VertexArray.fromAttributes(<String, VertexAttribute>{
      'position': new Vector4Attribute(attributeData),
      'normal': new Vector3Attribute(attributeData, offset: 4),
      'texCoord': new Vector2Attribute(attributeData, offset: 7)
    });

    for (var vertex in vertexArray) {
      vertex['normal'] = vertex['normal'].unitVector;
    }

    _finishTrianglesRange();

    final shapes = <_TrianglesShapeResult>[];

    for (var range in _trianglesRanges) {
      final triangles = new Triangles(vertexArray,
          indexList: indexList, offset: range.offset, count: range.count);

      shapes.add(new _TrianglesShapeResult(triangles, range.usemtlStatement));
    }

    return new _ObjBuilderResult(shapes, _mtlLibraries, _errors);
  }

  void _finishTrianglesRange() {
    final offset = _trianglesRanges.isNotEmpty
        ? _trianglesRanges.last.offset + _trianglesRanges.last.count
        : 0;
    final count = _trianglesIndexData.indexCount - offset;

    if (count > 0) {
      _trianglesRanges.add(
          new _ShapeRange(offset, count, _activeUsemtlStatement));
    }
  }
}

class _StatementVisitingMtlBuilder implements MtlStatementVisitor {
  final Uri uri;

  Map<String, PhongMaterial> _materialsByName = {};

  String _name;

  double _opacity;

  double _shininess;

  Vector3 _diffuseColor;

  Vector3 _specularColor;

  Texture2D _diffuseMap;

  Texture2D _specularMap;

  Texture2D _normalMap;

  Texture2D _opacityMap;

  _StatementVisitingMtlBuilder(this.uri);

  void visitBumpStatement(BumpStatement statement) {
    print('test');
    _normalMap = new Texture2D.fromImageURL(_filenameToUri(statement.filename));
  }

  void visitDStatement(DStatement statement) {
    _opacity = statement.factor;
  }

  void visitDecalStatement(DecalStatement statement) {}

  void visitDispStatement(DispStatement statement) {}

  void visitIllumStatement(IllumStatement statement) {}

  void visitKaStatement(KaStatement statement) {}

  void visitKdStatement(KdStatement statement) {
    final color = statement.reflectionColor;

    if (color is RGB) {
      _diffuseColor = new Vector3(color.r, color.g ?? color.r, color.b ?? color.r);
    }
  }

  void visitKsStatement(KsStatement statement) {
    final color = statement.reflectionColor;

    if (color is RGB) {
      _specularColor = new Vector3(color.r, color.g ?? color.r, color.b ?? color.r);
    }
  }

  void visitMapAatStatement(MapAatStatement statement) {}

  void visitMapDStatement(MapDStatement statement) {
    _opacityMap = new Texture2D.fromImageURL(_filenameToUri(statement.filename));
  }

  void visitMapKaStatement(MapKaStatement statement) {}

  void visitMapKdStatement(MapKdStatement statement) {
    _diffuseMap = new Texture2D.fromImageURL(_filenameToUri(statement.filename));
  }

  void visitMapKsStatement(MapKsStatement statement) {
    _specularMap = new Texture2D.fromImageURL(_filenameToUri(statement.filename));
  }

  void visitMapNsStatement(MapNsStatement statement) {}

  void visitNewmtlStatement(NewmtlStatement statement) {
    _finishMaterial();
    _reset();

    _name = statement.materialName;
  }

  void visitNiStatement(NiStatement statement) {}

  void visitNsStatement(NsStatement statement) {
    _shininess = statement.exponent;
  }

  void visitReflStatement(ReflStatement statement) {}

  void visitSharpnessStatement(SharpnessStatement statement) {}

  void visitTfStatement(TfStatement statement) {}

  _MtlBuilderResult build() {
    _finishMaterial();

    return new _MtlBuilderResult(_materialsByName, []);
  }

  void _finishMaterial() {
    if (_name != null) {
      _materialsByName[_name] = new PhongMaterial()
          ..diffuseColor = _diffuseColor ?? new Vector3.constant(1.0)
          ..diffuseMap = _diffuseMap
          ..specularColor = _specularColor ?? new Vector3.constant(1.0)
          ..specularMap = _specularMap
          ..shininess = _shininess != null ? _shininess.toDouble() : 30.0
          ..opacity = _opacity ?? 1.0
          ..opacityMap = _opacityMap
          ..normalMap = _normalMap;
    }
  }

  void _reset() {
    _name = null;
    _diffuseColor = null;
    _diffuseMap = null;
    _specularColor = null;
    _specularMap = null;
    _shininess = null;
    _opacity = null;
    _opacityMap = null;
    _normalMap = null;
  }

  String _filenameToUri(String filename) {
    if (path.isAbsolute(filename)) {
      return filename;
    } else {
      return path.join(path.dirname(uri.path), filename);
    }
  }
}

class _ObjBuilderResult {
  final List<_TrianglesShapeResult> triangleShapeResults;

  final List<Future<_MtlBuilderResult>> mtlBuilderResults;

  final List<ObjReadingError> errors;

  _ObjBuilderResult(this.triangleShapeResults, this.mtlBuilderResults, this.errors);
}

class _TrianglesShapeResult {
  final Triangles triangles;

  final UsemtlStatement usemtlStatement;

  _TrianglesShapeResult(this.triangles, this.usemtlStatement);
}

class _MtlBuilderResult {
  final Map<String, SurfaceMaterial> materialsByName;

  final List<ObjReadingError> errors;

  _MtlBuilderResult(this.materialsByName, this.errors);
}

class _ChunkedAttributeData {
  final int rowLength;

  final int chunkLength;

  final List<AttributeDataTable> _filledChunks = [];

  AttributeDataTable _activeChunk;

  int _activeChunkFillCount = 0;

  _ChunkedAttributeData(this.rowLength, this.chunkLength);

  int get rowCount =>
      _filledChunks.length * chunkLength + _activeChunkFillCount;

  void addRow(List<double> values) {
    _activeChunk ??= new AttributeDataTable(rowLength, chunkLength);

    if (_activeChunkFillCount == chunkLength) {
      _filledChunks.add(_activeChunk);
      _activeChunk = new AttributeDataTable(rowLength, chunkLength);
      _activeChunkFillCount = 0;
    }

    final currentRow = _activeChunk[_activeChunkFillCount];

    for (var i = 0; i < rowLength && i < values.length; i++) {
      currentRow[i] = values[i];
    }

    _activeChunkFillCount++;
  }

  AttributeDataRowView rowAt(int index) {
    final chunkIndex = index ~/ chunkLength;
    final rowIndex = index.remainder(chunkLength);

    var chunk;

    if (chunkIndex < _filledChunks.length) {
      chunk = _filledChunks[chunkIndex];
    } else if (chunkIndex == _filledChunks.length) {
      chunk = _activeChunk;
    }

    if (chunk != null) {
      return chunk[rowIndex];
    } else {
      return null;
    }
  }

  AttributeDataTable asAttributeDataTable() {
    final storage = new Float32List(rowCount * rowLength);
    final chunkSize = chunkLength * rowLength;

    for (var i = 0; i < _filledChunks.length; i++) {
      final data = new Float32List.view(_filledChunks[i].buffer);
      final start = i * chunkSize;

      storage.setRange(start, start + chunkSize, data);
    }

    if (_activeChunk != null) {
      final data = new Float32List.view(_activeChunk.buffer);
      final start = _filledChunks.length * chunkSize;

      storage.setRange(start, start + _activeChunkFillCount * rowLength, data);
    }

    return new AttributeDataTable.view(rowLength, storage.buffer);
  }
}

class _ChunkedIndexData {
  final int chunkLength;

  final List<Uint16List> _filledChunks = [];

  Uint16List _activeChunk;

  int _activeChunkFillCount = 0;

  _ChunkedIndexData(this.chunkLength);

  int get indexCount =>
      _filledChunks.length * chunkLength + _activeChunkFillCount;

  void add(int index) {
    _activeChunk ??= new Uint16List(chunkLength);

    if (_activeChunkFillCount == chunkLength) {
      _filledChunks.add(_activeChunk);
      _activeChunk = new Uint16List(chunkLength);
      _activeChunkFillCount = 0;
    }

    _activeChunk[_activeChunkFillCount] = index;
    _activeChunkFillCount++;
  }

  IndexList asIndexList() {
    final indexList = new IndexList(indexCount);

    for (var i = 0; i < _filledChunks.length; i++) {
      final start = i * chunkLength;

      indexList.setRange(start, start + chunkLength, _filledChunks[i]);
    }

    if (_activeChunk != null) {
      final start = _filledChunks.length * chunkLength;

      indexList.setRange(start, start + _activeChunkFillCount, _activeChunk);
    }

    return indexList;
  }
}

class _ShapeRange {
  final int offset;

  final int count;

  final UsemtlStatement usemtlStatement;

  _ShapeRange(this.offset, this.count, this.usemtlStatement);
}
