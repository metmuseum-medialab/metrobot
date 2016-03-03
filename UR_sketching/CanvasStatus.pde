
class CanvasStatus {

  // This class stores the current canvas status -- captured by the webcam, or computed internally
  // This class is reponsible for moving the robot arm and updating the canvas, etc.

  PImage canvasImg;

  CanvasStatus(int w, int h) {
    canvasImg = createImage(w, h, RGB);
    canvasImg.loadPixels(); //load the empty pixel array
    for (int i = 0; i < canvasImg.pixels.length; i++) {
      canvasImg.pixels[i] = color(255); //make every pixel white
    }
    canvasImg.updatePixels(); //update the imge
  }

  void draw() {
    tint(240, 240, 240, 200);
    image(canvasImg, 0, 0);
    noTint();
  }

  void update() {
    // TODO: check when last updated, if we need updating, move camera and take a picture, then process
  }

  void addSignature(Signature sig, MarkOrientation mk) {

  // TODO: implement scaling

    PGraphics pg = createGraphics(sig.signatureSize * 2, sig.signatureSize * 2); 
    pg.beginDraw();
    pg.imageMode(CENTER);
    pg.pushMatrix();
    pg.noFill();
    pg.stroke(0);
    pg.strokeWeight(2);
    pg.translate(pg.width / 2, pg.height / 2);
    pg.rotate(mk.rotation);
    pg.image(sig.getPImage(), 0, 0); 
    pg.popMatrix();
    pg.endDraw();
    
    canvasImg.blend(pg, 
    0, 0, sig.signatureSize * 2, sig.signatureSize * 2,
    int(mk.location.x) - sig.signatureSize, int(mk.location.y) - sig.signatureSize, sig.signatureSize * 2, sig.signatureSize * 2,
    DARKEST);
  }

} 


