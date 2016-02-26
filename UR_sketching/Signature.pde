/******************************
*  Signature
*
******************************/
class Signature {

  ArrayList<PVector> sketchPoints = new ArrayList<PVector>();  //store our drawing in this arraylist
  ArrayList<PVector> previewSketchPoints = new ArrayList<PVector>();
  ArrayList<PVector> robotSketchPoints = new ArrayList<PVector>();
  
  float DEFAULT_PREVIEW_SCALE = .3;

  Signature(ArrayList<PVector> _sketchPoints) {

    sketchPoints = (ArrayList<PVector>)_sketchPoints.clone();
  }
  
  //Draw the preview points
  void setSignaturePoints(PVector _v, float _scale, float _rot) {
    
    for (int i=0;i<sketchPoints.size();i++)
    {
      if (MODE_SCALE_OUTPUT == true)
      {
        previewSketchPoints.add(
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
      else 
      {
         previewSketchPoints.add(
         new PVector(
           int(sketchPoints.get(i).x),int(sketchPoints.get(i).y))
         );   
       
         robotSketchPoints.add(
         new PVector(
           int(sketchPoints.get(i).x+vRobotDrawingOffset.x),int(sketchPoints.get(i).y+vRobotDrawingOffset.y))
         ); 
      }
    }
  }

}