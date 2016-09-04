part of lighting;

class SpotLight implements Light, Struct {
  String name;

  Vector3 position;

  Vector3 color;

  Vector3 direction;

  double constantAttenuation;

  double linearAttenuation;

  double quadraticAttenuation;

  num falloffAngle;

  double falloffExponent;

  SpotLight(this.position, this.color, this.direction,
      {this.constantAttenuation: 1.0,
      this.linearAttenuation: 0.0,
      this.quadraticAttenuation: 0.0,
      this.falloffAngle: PI,
      this.falloffExponent: 0.0});

  Iterable<String> get members => const [
    'position',
    'color',
    'direction'
    'constantAttenuation',
    'linearAttenuation',
    'quadraticAttenuation',
    'falloffAngle',
    'falloffExponent'
  ];

  bool hasMember(String name) => members.contains(name);

  void forEach(f(String member, dynamic value)) {
    f('position', position);
    f('color', color);
    f('direction', direction);
    f('constantAttenuation', constantAttenuation);
    f('linearAttenuation', linearAttenuation);
    f('quadraticAttenuation', quadraticAttenuation);
    f('falloffAngle', falloffAngle);
    f('falloffExponent', falloffExponent);
  }

  operator [](String member) {
    if (member == 'position') {
      return position;
    } else if (member == 'color') {
      return color;
    } else if (member == 'direction') {
      return direction;
    } else if (member == 'constantAttenuation') {
      return constantAttenuation;
    } else if (member == 'linearAttenuation') {
      return linearAttenuation;
    } else if (member == 'quadraticAttenuation') {
      return quadraticAttenuation;
    } else if (member == 'falloffAngle') {
      return falloffAngle;
    } else if (member == 'falloffExponent') {
      return falloffExponent;
    } else {
      return null;
    }
  }
}
