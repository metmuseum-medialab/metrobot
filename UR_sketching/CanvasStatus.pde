
class CanvasStatus {

  // This class stores the current canvas status -- captured by the webcam, or computed internally
  // This class is reponsible for moving the robot arm and updating the canvas, etc.

  PImage canvasImg;
  int canvasW, canvasH;

  CanvasStatus(int w, int h) {
    canvasW = w;
    canvasH = h;

    canvasImg = createImage(canvasW, canvasH, RGB);
    canvasImg.loadPixels(); //load the empty pixel array
    for (int i = 0; i < canvasImg.pixels.length; i++) {
      canvasImg.pixels[i] = color(255); //make every pixel white
    }
    canvasImg.updatePixels(); //update the imge
  }

  void loadState(String filename) { // if image exists, loads a canvasstatus image
    File f = new File(dataPath(filename));
    if (f.exists()) {
      println(filename + " exists!");
      canvasImg = loadImage(filename);
      canvasImg.resize(canvasW, canvasH);
    }
  }

  void saveState(String filename) {
    canvasImg.save(filename);
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

  
    int sigScaledSize = int(sig.signatureSize * mk.scale * 2);

    PImage sigCopy = sig.getPImage().copy();
    sigCopy.resize(int(sigCopy.width * mk.scale), 0);

    PGraphics pg = createGraphics(sigScaledSize, sigScaledSize);
    pg.beginDraw();
    pg.imageMode(CENTER);
    pg.pushMatrix();
    pg.noFill();
    pg.stroke(0);
    pg.strokeWeight(2);
    pg.translate(pg.width / 2, pg.height / 2);
    pg.rotate(mk.rotation);
    pg.image(sigCopy, 0, 0); 
    pg.popMatrix();
    pg.endDraw();
    
    canvasImg.blend(pg, 
    0, 0, sigScaledSize, sigScaledSize,
    int(mk.location.x - (sig.signatureSize * mk.scale)), int(mk.location.y - (sig.signatureSize * mk.scale)), sigScaledSize, sigScaledSize,
    BLEND);
  }

} 


