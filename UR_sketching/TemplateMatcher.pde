// this class is used to implement the matching algorithm.

class TemplateMatcher {

  void TemplateMatcher() { } // constructor is useless - this is kind of a static class but not static so we can use random()
    

  MarkOrientation placeSignature(GoalDrawing goalDrawing, CanvasStatus canvasStatus, Signature thisSignature) {
    println("HEYYYY!");
    return new MarkOrientation(new PVector(APP_WIDTH/2, APP_HEIGHT/2), (random(1)+.5), random(360));
  }

}

