part of lighting;

class DirectionalLight implements Light, Struct {
  String name;

  Vector3 color;

  Vector3 direction;

  DirectionalLight(this.color, this.direction);

  Iterable<String> get members => const ['color', 'orientation'];

  bool hasMember(String name) =>
      members.contains(name);

  void forEach(f(String member, dynamic value)) {
    f('color', color);
    f('direction', direction);
  }

  operator [](String member) {
    if (member == 'color') {
      return color;
    } else if (member == 'direction') {
      return direction;
    } else {
      return null;
    }
  }
}
