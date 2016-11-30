part of lighting;

class DirectionalLight implements Light, Struct {
  String name;

  Vector3 color = new Vector3(1.0, 1.0, 1.0);

  final Transform transform = new Transform();

  Iterable<String> get members => const ['color', 'direction'];

  bool hasMember(String member) =>
      members.contains(member);

  void forEach(f(String member, dynamic value)) {
    f('color', color);
    f('direction', transform.forward);
  }

  operator [](String member) {
    if (member == 'color') {
      return color;
    } else if (member == 'direction') {
      return transform.forward;
    } else {
      return null;
    }
  }
}
