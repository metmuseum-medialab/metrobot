
class MarkOrientation {

  // This class stores PVector, scale, rotation

  PVector location;
  float scale;
  float rotation;

  MarkOrientation(PVector _location, float _scale, float _rotation) {
    location = _location;
    scale = _scale;
    rotation = _rotation;
  }

  String toString() {
    return "Location: " + location.toString() + " scale: " + scale + " rotation: " + rotation;
  }

} 

