// this class is used to implement the matching algorithm.

class TemplateMatcher {

  void TemplateMatcher() { } // constructor is useless - this is kind of a static class but not static so we can use random()
    

  MarkOrientation placeSignature(GoalDrawing goalDrawing, CanvasStatus canvasStatus, Signature thisSignature) {
    println("HEYYYY!");
    
    return new MarkOrientation(new PVector(random(vRobotDrawingSpace.x), random(vRobotDrawingSpace.y)), (random(1)+.5), random(360));
    //return new MarkOrientation(new PVector(vRobotDrawingSpace.x/2, vRobotDrawingSpace.y/2), 1, 0);
  }

}