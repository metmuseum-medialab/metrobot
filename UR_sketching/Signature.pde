/******************************
*  Signature
*
******************************/
class Signature {

  ArrayList<PVector> sketchPoints = new ArrayList<PVector>();  //store our drawing in this arraylist
  //ArrayList<PVector> previewSketchPoints = new ArrayList<PVector>();
  //ArrayList<PVector> robotSketchPoints = new ArrayList<PVector>();
  
  float DEFAULT_PREVIEW_SCALE = 1.0;
  float density = 0;
  
  Signature(ArrayList<PVector> _sketchPoints) {

    //Normalize location
    for (int i=0; i<_sketchPoints.size(); i++)
    {
       sketchPoints.add(new PVector(_sketchPoints.get(i).x - vSignatureDrawingSpace.x, _sketchPoints.get(i).y - vSignatureDrawingSpace.y));
       //sketchPoints.add(new PVector(_sketchPoints.get(i).x - vSignatureDrawingSpace.x , _sketchPoints.get(i).y - vSignatureDrawingSpace.y));
    }
    //sketchPoints = (ArrayList<PVector>)_sketchPoints.clone();
    
    //Get pixel density
    PImage c = get(int(vSignatureDrawingSpace.x), int(vSignatureDrawingSpace.y), SIGNATURE_SIZE, SIGNATURE_SIZE);
    
    float _count = 0;
    
    for (int i=0; i<c.pixels.length; i++)
    {
      if (c.pixels[i] == color(0)) {
        _count++;
      }
      
    }
    
    density = 100* _count / (SIGNATURE_SIZE*SIGNATURE_SIZE);
    
    println("DENSITY : " + density);
    
  }
  
  //Draw the preview points
/*
  void setSignaturePoints(PVector _v, float _scale, float _rot) {
    
    for (int i=0;i<sketchPoints.size();i++)
    {
         robotSketchPoints.add(
         new PVector(
           _v.x+int(sketchPoints.get(i).x*DEFAULT_PREVIEW_SCALE*_scale),
           _v.y+int(sketchPoints.get(i).y*DEFAULT_PREVIEW_SCALE*_scale)
         )
         );   
       
         robotSketchPoints.add(
         new PVector(
           _v.x + int(sketchPoints.get(i).x*_scale) + vRobotDrawingOffset.x,
           _v.y + int(sketchPoints.get(i).y*_scale) + vRobotDrawingOffset.y
         )); 
    }
  }
*/
  ArrayList<PVector> generateRobotMark(MarkOrientation mk, boolean bPreview) {

    ArrayList<PVector> robotSketchPoints = new ArrayList<PVector>();
 
    PVector _center = new PVector(mk.scale*SIGNATURE_SIZE*.5, mk.scale*SIGNATURE_SIZE*.5);
 
    for (int i=0;i<sketchPoints.size();i++)
    {
      
       PVector _p;
 
       _p = new PVector(
           int(sketchPoints.get(i).x*mk.scale),
           int(sketchPoints.get(i).y*mk.scale)
       );
       
       
       _p.x -= _center.x;
       _p.y -= _center.y;
       
       _p.rotate((mk.rotation/360)*TWO_PI);
       
       _p.x += mk.loc.x;
       _p.y += mk.loc.y;
       
       if (bPreview == false) {
         
         //Add the Y Normalization back in before we send to robot
         //This needs to be moved to the last thing that is done
         _p.y = vRobotDrawingSpace.y - _p.y;
         
         _p.x += vRobotDrawingOffset.x;
         _p.y += vRobotDrawingOffset.y;
       }
       
       //println("[" + _p.x + "," + _p.y + "],");
       robotSketchPoints.add(_p);  
    }
    
    return robotSketchPoints;
  }

    void test() {
      println("yehofjdsklf;as");
    }
  PImage generateRandomSignature() {
    int sWidth = SIGNATURE_SIZE;
    int sHeight = SIGNATURE_SIZE;
    //a simple function for drawing an ugly bunch of lines, returns a pimage
    PGraphics pg = createGraphics(sWidth, sHeight);
    pg.beginDraw();
    //pg.background(255);
    pg.noFill();
    pg.stroke(0);
    pg.strokeWeight(2);
    int vertexCount = int(random(2, 14));
    pg.beginShape();
    if (random(1)<.6) {
      for (int i = 0; i< vertexCount - 1; i++) {
        pg.vertex(random(sWidth), random(sHeight));
      }
    } else {
      for (int i = 0; i< vertexCount - 1; i++) {
        int vx = int(random(sWidth));
        int vy = int(random(sHeight));
        if (i == 0 || i == vertexCount-1) {
          pg.curveVertex(vx, vy);
        }
        pg.curveVertex(vx, vy);
      }
    }
    pg.endShape();
    pg.endDraw();
    return pg.get();
  }
 
}