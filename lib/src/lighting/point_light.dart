part of lighting;

class PointLight implements Light, Struct {
  String name;

  Vector3 position;

  Vector3 color;

  double constantAttenuation;

  double linearAttenuation;

  double quadraticAttenuation;

  PointLight(this.position, this.color,
      {this.constantAttenuation: 1.0,
      this.linearAttenuation: 0.0,
      this.quadraticAttenuation: 0.0});

  Iterable<String> get members => const [
        'position',
        'color',
        'constantAttenuation',
        'linearAttenuation',
        'quadraticAttenuation'
      ];

  bool hasMember(String name) =>
      members.contains(name);

  void forEach(f(String member, dynamic value)) {
    f('position', position);
    f('color', color);
    f('constantAttenuation', constantAttenuation);
    f('linearAttenuation', linearAttenuation);
    f('quadraticAttenuation', quadraticAttenuation);
  }

  operator [](String member) {
    if (member == 'position') {
      return position;
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
