part of lighting;

class SpotLight implements Light, Struct {
  String name;

  Vector3 color = new Vector3(1.0, 1.0, 1.0);

  final Transform transform = new Transform();

  double constantAttenuation = 1.0;

  double linearAttenuation = 0.0;

  double quadraticAttenuation = 0.0;

  num _falloffAngle = PI;

  double _falloffAngleCosine;

  double falloffExponent = 0.0;

  num get falloffAngle => _falloffAngle;

  void set falloffAngle(num value) {
    _falloffAngle = value;
    _falloffAngleCosine = null;
  }

  num get falloffAngleCosine {
    _falloffAngleCosine ??= cos(falloffAngle);

    return _falloffAngleCosine;
  }

  Iterable<String> get members => const [
        'position',
        'color',
        'direction',
        'constantAttenuation',
        'linearAttenuation',
        'quadraticAttenuation',
        'falloffExponent',
        'falloffAngleCosine'
      ];

  bool hasMember(String member) => members.contains(member);

  void forEach(f(String member, dynamic value)) {
    f('position', transform.position);
    f('color', color);
    f('direction', transform.forward);
    f('constantAttenuation', constantAttenuation);
    f('linearAttenuation', linearAttenuation);
    f('quadraticAttenuation', quadraticAttenuation);
    f('falloffExponent', falloffExponent);
    f('falloffAngleCosine', falloffAngleCosine);
  }

  operator [](String member) {
    if (member == 'position') {
      return transform.position;
    } else if (member == 'color') {
      return color;
    } else if (member == 'direction') {
      return transform.forward;
    } else if (member == 'constantAttenuation') {
      return constantAttenuation;
    } else if (member == 'linearAttenuation') {
      return linearAttenuation;
    } else if (member == 'quadraticAttenuation') {
      return quadraticAttenuation;
    } else if (member == 'falloffExponent') {
      return falloffExponent;
    } else if (member == 'falloffAngleCosine') {
      return falloffAngleCosine;
    } else {
      return null;
    }
  }
}
