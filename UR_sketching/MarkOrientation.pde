class MarkOrientation {

  // This class stores PVector, scale, rotation, 
  // and is combined with a Signature 
  // in order to describe a mark placed somewhere on the canvas (in Processing coordinates)

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

