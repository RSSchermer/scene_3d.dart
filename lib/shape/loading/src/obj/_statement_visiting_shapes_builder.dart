part of shape.loading.obj;

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
      {this.vertexDataChunkSize: 1000, this.indexDataChunkSize: 3000}) {
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
      final uri =
          path.isAbsolute(filename) ? filename : path.join(dirname, filename);
      final resource = new Resource(uri);
      final builder = new _StatementVisitingMtlBuilder(resource.uri);

      final mtlLibrary =
          statementizeMtlResourceStreamed(resource).forEach((results) {
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
      _trianglesRanges
          .add(new _ShapeRange(offset, count, _activeUsemtlStatement));
    }
  }
}

class _ObjBuilderResult {
  final List<_TrianglesShapeResult> triangleShapeResults;

  final List<Future<_MtlBuilderResult>> mtlBuilderResults;

  final List<ObjReadingError> errors;

  _ObjBuilderResult(
      this.triangleShapeResults, this.mtlBuilderResults, this.errors);
}

class _TrianglesShapeResult {
  final Triangles triangles;

  final UsemtlStatement usemtlStatement;

  _TrianglesShapeResult(this.triangles, this.usemtlStatement);
}

class _ShapeRange {
  final int offset;

  final int count;

  final UsemtlStatement usemtlStatement;

  _ShapeRange(this.offset, this.count, this.usemtlStatement);
}
