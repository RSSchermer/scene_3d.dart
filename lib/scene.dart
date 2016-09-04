
library scene;

import 'package:bagl/math.dart';

import 'observable_set.dart';

class Scene {
  final ObservableSet<Object> objects = new ObservableSet();

  Vector3 clearColor;

  Vector3 ambientColor = new Vector3(0.0, 0.0, 0.0);
}
