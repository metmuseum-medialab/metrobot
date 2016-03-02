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
 
    for (int i=0;i<sketchPoints.size();i++)
    {
      
       PVector _p;
      
       if (bPreview == true)
       {
         _p = new PVector(
             mk.loc.x+int(sketchPoints.get(i).x*DEFAULT_PREVIEW_SCALE*mk.scale),
             mk.loc.y+int(sketchPoints.get(i).y*DEFAULT_PREVIEW_SCALE*mk.scale)
           );
           
       } else {
       
         _p = new PVector(
           mk.loc.x + int(sketchPoints.get(i).x*mk.scale) + vRobotDrawingOffset.x,
           mk.loc.y + int(sketchPoints.get(i).y*mk.scale) + vRobotDrawingOffset.y
          );
       }
       
       _p.rotate((mk.rotation/360)*TWO_PI);
         
       robotSketchPoints.add(_p);  
    }
    
    return robotSketchPoints;
  }
}