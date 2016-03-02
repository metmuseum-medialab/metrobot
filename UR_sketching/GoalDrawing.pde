
class GoalDrawing {

  PImage goalImg;

  int drawingBorder = 0;
  PVector vPreviewSpace;
  int topX, topY, bottomX, bottomY;
  
  GoalDrawing(PVector _drawingSpace) {
 
    vPreviewSpace = new PVector(_drawingSpace.x, _drawingSpace.y);
 
    topX = drawingBorder; 
    topY = drawingBorder; 
    bottomX = drawingBorder + int(vPreviewSpace.x); 
    bottomY = drawingBorder + int(vPreviewSpace.y);
  }

  void loadGoal(String filename) { //loads a grayscale image for goal image
    goalImg = loadImage(filename);
  }
  
  void drawPreview() {
    image(goalImg, 0, 0);
  }

  MarkOrientation getSignatureLocation(CanvasStatus canv, Signature sig) {
    // TODO
    
    //
    return new MarkOrientation(new PVector(APP_WIDTH/2, APP_HEIGHT/2), (random(1)+.5), random(360));
    //return new MarkOrientation(new PVector(0,0), 1.0, 0.0);
  }

  void pointsToDraw() {
    println("hey");
    goalImg.loadPixels();
    for (int y = 0; y < goalImg.height; y++) {
      for (int x = 0; x < goalImg.width; x++) {
        int loc = x + (y * goalImg.width);
        //println(brightness(goalImg.pixels[loc]));
        if(brightness(goalImg.pixels[loc]) < 200) { print("#"); }
        else { print(" "); }
      }
      println("");
    }
    goalImg.updatePixels();
  }
 
}