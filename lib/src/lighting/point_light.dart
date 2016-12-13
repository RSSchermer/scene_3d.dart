part of lighting;

class PointLight implements Light, Struct {
  String name;

  Vector3 color = new Vector3(1.0, 1.0, 1.0);

  final Transform transform = new Transform();

  double constantAttenuation = 1.0;

  double linearAttenuation = 0.0;

  double quadraticAttenuation = 0.0;

  Iterable<String> get members => const [
        'position',
        'color',
        'constantAttenuation',
        'linearAttenuation',
        'quadraticAttenuation'
      ];

  bool hasMember(String member) => members.contains(member);

  void forEach(f(String member, dynamic value)) {
    f('position', transform.position);
    f('color', color);
    f('constantAttenuation', constantAttenuation);
    f('linearAttenuation', linearAttenuation);
    f('quadraticAttenuation', quadraticAttenuation);
  }

  operator [](String member) {
    if (member == 'position') {
      return transform.position;
    } else if (member == 'color') {
      return color;
    } else if (member == 'constantAttenuation') {
      return constantAttenuation;
    } else if (member == 'linearAttenuation') {
      return linearAttenuation;
    } else if (member == 'quadraticAttenuation') {
      return quadraticAttenuation;
    } else {
      return null;
    }
  }
}
