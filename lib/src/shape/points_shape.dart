part of shape;

class PointsShape implements PrimitivesShape<Point> {
  String name;

  final Points primitives;

  final String positionAttributeName;

  final Transform transform = new Transform();

  PointMaterial material;

  factory PointsShape(Points primitives, Material material,
      {String positionAttributeName: 'position'}) {
    final vertexArray = primitives.vertexArray;
    final positionAttribute = vertexArray.attributes[positionAttributeName];

    if (positionAttribute == null || positionAttribute is! Vector4Attribute) {
      throw new ArgumentError('The position attribute "$positionAttributeName" '
          'did not resolve to a Vector4Attribute on the provided '
          '`primitives`.');
    } else {
      return new PointsShape._internal(
          primitives, material, positionAttributeName);
    }
  }

  PointsShape._internal(
      this.primitives, this.material, this.positionAttributeName);
}
