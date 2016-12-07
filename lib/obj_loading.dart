library obj_file_parser;

import 'dart:async';
import 'dart:typed_data';

import 'package:bagl/geometry.dart';
import 'package:bagl/vertex_data.dart';
import 'package:objectivist/obj_reading.dart';
import 'package:objectivist/obj_reading/errors.dart';
import 'package:objectivist/obj_statements.dart';
import 'package:resource/resource.dart';

import 'material.dart';
import 'shape.dart';

Future<Iterable<PrimitivesShape>> loadObjResource(Resource resource) {
  final builder = new _StatementVisitingShapesBuilder();

  return statementizeObjResourceStreamed(resource).forEach((results) {
    for (var error in results.errors) {
      print('Error when reading ${resource.uri} (line ${error.lineNumber}): ${error.description}');
    }

    for (var statement in results) {
      statement.acceptVisit(builder);
    }
  }).then((_) => builder.build());
}

class _StatementVisitingShapesBuilder implements ObjStatementVisitor {
  final int vertexDataChunkSize;

  final int indexDataChunkSize;

  PhongMaterial _defaultTrianglesMaterial;

  _ChunkedAttributeData _positionData;

  _ChunkedAttributeData _normalData;

  _ChunkedAttributeData _texCoordData;

  List<PrimitivesShape> _finishedShapes = [];

  _ChunkedAttributeData _currentTrianglesAttributeData;

  _ChunkedIndexData _currentTrianglesIndexData;

  final List<ObjReadingError> _errors = [];

  _StatementVisitingShapesBuilder({this.vertexDataChunkSize: 1000, this.indexDataChunkSize: 3000, PhongMaterial defaultTrianglesMaterial}) {
    _defaultTrianglesMaterial = defaultTrianglesMaterial ?? new PhongMaterial();
    _positionData = new _ChunkedAttributeData(4, vertexDataChunkSize);
    _normalData = new _ChunkedAttributeData(3, vertexDataChunkSize);
    _texCoordData = new _ChunkedAttributeData(3, vertexDataChunkSize);
  }

  void visitVStatement(VStatement statement) {
    _positionData.addRow([statement.x ?? 0.0, statement.y ?? 0.0, statement.z ?? 0.0, statement.w ?? 1.0]);
  }

  void visitVtStatement(VtStatement statement) {
    _texCoordData.addRow([statement.u ?? 0.0, statement.v ?? 0.0, statement.w ?? 0.0]);
  }

  void visitVnStatement(VnStatement statement) {
    _normalData.addRow([statement.i ?? 0.0, statement.j ?? 0.0, statement.k ?? 0.0]);
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
    final numTriplesLength = numTriples.length;

    if (numTriplesLength >= 3) {
      _currentTrianglesAttributeData ??= new _ChunkedAttributeData(9, vertexDataChunkSize);
      _currentTrianglesIndexData ??= new _ChunkedIndexData(indexDataChunkSize);

      final startIndex = _currentTrianglesAttributeData.rowCount;
      var usesFaceNormal = false;

      for (var numTriple in numTriples) {
        final row = new Float32List(9);

        final vNum = numTriple.vNum;
        final vnNum = numTriple.vnNum;
        final vtNum = numTriple.vtNum;

        final positionIndex = vNum < 0 ? _positionData.rowCount + vNum : vNum - 1;
        final position = _positionData.rowAt(positionIndex);

        if (position != null) {
          row[0] = position[0];
          row[1] = position[1];
          row[2] = position[2];
          row[3] = position[3];
        } else {
          _errors.add(new ObjReadingError(statement.lineNumber, 'Invalid `v` reference: $vNum.'));
        }

        if (vnNum != null) {
          final normalIndex = vnNum < 0 ? _normalData.rowCount + vnNum : vnNum - 1;
          final normal = _normalData.rowAt(normalIndex);

          if (normal != null) {
            row[4] = normal[0];
            row[5] = normal[1];
            row[6] = normal[2];
          } else {
            _errors.add(new ObjReadingError(statement.lineNumber, 'Invalid `vn` reference: $vnNum.'));
          }
        } else {
          usesFaceNormal = true;
        }

        if (vtNum != null) {
          final texCoordIndex = vtNum < 0 ? _texCoordData.rowCount + vtNum : vtNum - 1;
          final texCoord = _texCoordData.rowAt(texCoordIndex);

          if (texCoord != null) {
            row[7] = texCoord[0];
            row[8] = texCoord[1];
          } else {
            _errors.add(new ObjReadingError(statement.lineNumber, 'Invalid `vt` reference: $vtNum.'));
          }
        }

        _currentTrianglesAttributeData.addRow(row);
      }

      for (var i = 2; i < numTriplesLength; i++) {
        _currentTrianglesIndexData.add(startIndex);
        _currentTrianglesIndexData.add(startIndex + i - 1);
        _currentTrianglesIndexData.add(startIndex + i);
      }

      if (usesFaceNormal) {
        var normalI = 0.0;
        var normalJ = 0.0;
        var normalK = 0.0;

        for (var i = 0; i < numTriplesLength; i++) {
          final current = _currentTrianglesAttributeData.rowAt(startIndex + i);
          final next = _currentTrianglesAttributeData.rowAt(startIndex + (i + 1) % numTriplesLength);
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

        for (var i = 0; i < numTriplesLength; i++) {
          final row = _currentTrianglesAttributeData.rowAt(startIndex + i);

          row[4] = normalI;
          row[5] = normalJ;
          row[6] = normalK;
        }
      }
    } else {
      _errors.add(new ObjReadingError(statement.lineNumber, 'An `f` statement must define at least 3 vertices.'));
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

  void visitSStatement(SStatement statement) {}

  void visitMgStatement(MgStatement statement) {}

  void visitOStatement(OStatement statement) {}

  void visitBevelStatement(BevelStatement statement) {}

  void visitCInterpStatement(CInterpStatement statement) {}

  void visitDInterpStatement(DInterpStatement statement) {}

  void visitLodStatement(LodStatement statement) {}

  void visitMaplibStatement(MaplibStatement statement) {}

  void visitUsemapStatement(UsemapStatement statement) {}

  void visitUsemtlStatement(UsemtlStatement statement) {}

  void visitMtllibStatement(MtllibStatement statement) {}

  void visitShadowObjStatement(ShadowObjStatement statement) {}

  void visitTraceObjStatement(TraceObjStatement statement) {}

  void visitCtechStatement(CtechStatement statement) {}

  void visitStechStatement(StechStatement statement) {}

  Iterable<PrimitivesShape> build() {
    _finishCurrentTrianglesShape();

    return _finishedShapes;
  }

  void _finishCurrentTrianglesShape() {
    if (_currentTrianglesAttributeData != null) {
      final attributeData = _currentTrianglesAttributeData.asAttributeDataTable();
      final vertexArray = new VertexArray.fromAttributes(<String, VertexAttribute>{
        'position': new Vector4Attribute(attributeData),
        'normal': new Vector3Attribute(attributeData, offset: 4),
        'texCoord': new Vector2Attribute(attributeData, offset: 7)
      });
      final primitives = new Triangles(vertexArray);

      _finishedShapes.add(new PhongTrianglesShape(primitives, _defaultTrianglesMaterial));
    }
  }
}

class _ChunkedAttributeData {
  final int rowLength;

  final int chunkLength;

  final List<AttributeDataTable> _filledChunks = [];

  AttributeDataTable _activeChunk;

  int _activeChunkFillCount = 0;

  _ChunkedAttributeData(this.rowLength, this.chunkLength);

  int get rowCount => _filledChunks.length * chunkLength + _activeChunkFillCount;

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

  int get indexCount => _filledChunks.length * chunkLength + _activeChunkFillCount;

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
