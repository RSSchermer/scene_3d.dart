part of shape.loading.obj;

class _StatementVisitingMtlBuilder implements MtlStatementVisitor {
  final Uri sourceUri;

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

  _StatementVisitingMtlBuilder(this.sourceUri);

  void visitBumpStatement(BumpStatement statement) {
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
      _diffuseColor =
          new Vector3(color.r, color.g ?? color.r, color.b ?? color.r);
    }
  }

  void visitKsStatement(KsStatement statement) {
    final color = statement.reflectionColor;

    if (color is RGB) {
      _specularColor =
          new Vector3(color.r, color.g ?? color.r, color.b ?? color.r);
    }
  }

  void visitMapAatStatement(MapAatStatement statement) {}

  void visitMapDStatement(MapDStatement statement) {
    _opacityMap =
        new Texture2D.fromImageURL(_filenameToUri(statement.filename));
  }

  void visitMapKaStatement(MapKaStatement statement) {}

  void visitMapKdStatement(MapKdStatement statement) {
    _diffuseMap =
        new Texture2D.fromImageURL(_filenameToUri(statement.filename));
  }

  void visitMapKsStatement(MapKsStatement statement) {
    _specularMap =
        new Texture2D.fromImageURL(_filenameToUri(statement.filename));
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
        ..name = _name
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
      return path.join(path.dirname(sourceUri.path), filename);
    }
  }
}

class _MtlBuilderResult {
  final Map<String, SurfaceMaterial> materialsByName;

  final List<ObjReadingError> errors;

  _MtlBuilderResult(this.materialsByName, this.errors);
}
