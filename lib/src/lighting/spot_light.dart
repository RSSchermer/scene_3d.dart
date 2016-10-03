part of lighting;

class SpotLight implements Light, Struct {
  String name;

  Vector3 position = new Vector3(0.0, 0.0, 0.0);

  Vector3 color = new Vector3(1.0, 1.0, 1.0);

  Vector3 direction = new Vector3(1.0, 0.0, 0.0);

  double constantAttenuation = 1.0;

  double linearAttenuation = 0.0;

  double quadraticAttenuation = 0.0;

  num falloffAngle = PI;

  double falloffExponent = 0.0;

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

  bool hasMember(String member) => members.contains(member);

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
