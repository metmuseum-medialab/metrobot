class Signature {

  // This class stores an array of vector points for a Signature
  // and is combined with a MarkOrientation 
  // in order to describe a mark placed somewhere on the canvas (in Processing coordinates)

  ArrayList<PVector> sketchPoints = new ArrayList<PVector>();  //store our drawing in this arraylist
  //ArrayList<PVector> previewSketchPoints = new ArrayList<PVector>();
  //ArrayList<PVector> robotSketchPoints = new ArrayList<PVector>();
  
  float DEFAULT_PREVIEW_SCALE = 1.0;
  float SIGNATURE_PREVIEW_SCALE = .5;
  float density = 0;

  int signatureSize;
  
  Signature(int _signatureSize, ArrayList<PVector> _sketchPoints) {

  signatureSize = _signatureSize;

    //Normalize location
    for (int i=0; i<_sketchPoints.size(); i++)
    {
       sketchPoints.add(new PVector( SIGNATURE_PREVIEW_SCALE*(_sketchPoints.get(i).x - vSignatureDrawingSpace.x), SIGNATURE_PREVIEW_SCALE*(_sketchPoints.get(i).y - vSignatureDrawingSpace.y), _sketchPoints.get(i).z));
       //sketchPoints.add(new PVector(_sketchPoints.get(i).x - vSignatureDrawingSpace.x , _sketchPoints.get(i).y - vSignatureDrawingSpace.y));
    }
    //sketchPoints = (ArrayList<PVector>)_sketchPoints.clone();
    
    //Get pixel density
    PImage c = get(int(vSignatureDrawingSpace.x), int(vSignatureDrawingSpace.y), signatureSize, signatureSize);
    
    float _count = 0;
    
    for (int i=0; i<c.pixels.length; i++)
    {
      if (c.pixels[i] == color(0)) {
        _count++;
      }
      
    }
    
    density = 100* _count / (signatureSize*signatureSize);
    
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
  ArrayList<PVector> generateRobotMark(MarkOrientation mk) {

    ArrayList<PVector> robotSketchPoints = new ArrayList<PVector>();
 
    PVector _center = new PVector(mk.scale*signatureSize*.5, mk.scale*signatureSize*.5);
 
    for (int i=0;i<sketchPoints.size();i++)
    {
      
       PVector _p;
 
       _p = new PVector(
           int(sketchPoints.get(i).x*mk.scale),
           int(sketchPoints.get(i).y*mk.scale),
           int(sketchPoints.get(i).z)
       );
       
       
       _p.x -= _center.x;
       _p.y -= _center.y;
       
       _p.rotate((mk.rotation/360)*TWO_PI);
       
       _p.x += mk.location.x;
       _p.y += mk.location.y;
       
       
       
       robotSketchPoints.add(_p);  
    }
    
    return robotSketchPoints;
  }

  PImage getPImage() {
    int sWidth = signatureSize;
    int sHeight = signatureSize;
    PGraphics pg = createGraphics(sWidth, sHeight);
    pg.beginDraw();
    pg.noFill();
    pg.stroke(0);
    pg.strokeWeight(2);
    int vertexCount = int(random(2, 14));

    pg.beginShape();
    for(PVector p: sketchPoints) {
      
      //If pen is up, end/start shape
      if (p.z == -1) {
        pg.endShape();
        pg.beginShape();
      }
    
      pg.vertex(int(p.x), int(p.y));
    }
    pg.endShape();
    pg.endDraw();

    return pg.get();
  }
 
}