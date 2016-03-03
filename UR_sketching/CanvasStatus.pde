
class CanvasStatus {

  // This class stores the current canvas status -- captured by the webcam, or computed internally
  // This class is reponsible for moving the robot arm and updating the canvas, etc.

  PImage canvasImg;

  CanvasStatus(int w, int h) {
    canvasImg = createImage(w, h, RGB);
    canvasImg.loadPixels(); //load the empty pixel array
    for(color p: canvasImg.pixels) {
      p = color(255); // make canvas white
    }
    canvasImg.updatePixels(); //update the imge
  }

  void update() {
    // TODO: check when last updated, if we need updating, move camera and take a picture, then process
  }

  void addSignature(Signature sig, MarkOrientation mk) {
    // TODO: add signature to canvas
  }

} 


