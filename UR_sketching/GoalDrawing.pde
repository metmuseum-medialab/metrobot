
class GoalDrawing {

  PImage goalImg;

  int goalW, goalH;
  
  GoalDrawing(int w, int h) {
    goalW = w;
    goalH = h;
  }

  void loadFromImage(String filename) { //loads a grayscale image for goal image
    goalImg = loadImage(filename);
    goalImg.resize(goalW, goalH);
  }
  
  void drawPreview() {
    image(goalImg, 0, 0);
    noTint();
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
