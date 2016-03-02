
class CanvasStatus {

  // This class stores the current canvas status -- captured by the webcam, or computed internally
  // This class is reponsible for moving the robot arm and updating the canvas, etc.

  PImage canvas;

  CanvasStatus(int w, int h) {
    canvas = new PImage(w, h, ALPHA);
  }

  void update() {
    // TODO: check when last updated, if we need updating, move camera and take a picture, then process
  }

} 


