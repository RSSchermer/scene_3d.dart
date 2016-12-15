part of shape;

class LinesShape implements PrimitivesShape<Line> {
  String name;

  final Lines primitives;

  final String positionAttributeName;

  final Transform transform = new Transform();

  LineMaterial material;

  factory LinesShape(Lines primitives, Material material,
      {String positionAttributeName: 'position'}) {
    final vertexArray = primitives.vertexArray;
    final positionAttribute = vertexArray.attributes[positionAttributeName];

    if (positionAttribute == null || positionAttribute is! Vector4Attribute) {
      throw new ArgumentError('The position attribute "$positionAttributeName" '
          'did not resolve to a Vector4Attribute on the provided '
          '`primitives`.');
    } else {
      return new LinesShape._internal(
          primitives, material, positionAttributeName);
    }
  }

  LinesShape._internal(
      this.primitives, this.material, this.positionAttributeName);
}
