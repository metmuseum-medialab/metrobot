
class PreviewView {

  // this class generates the preview for the drawing, but is a little bit deprecated -
  // currently appears to only draw the borders of the image.
  // TODO: wrap together with the diffDisplayImage and rename it as an 'InterfaceView' class
 
  ArrayList<ArrayList<PVector>> arrDrawings = new ArrayList<ArrayList<PVector>>();  //store our drawing in this arraylist
  
  int drawingBorder = 0;
  
  PVector vPreviewSpace;
  int topX, topY, bottomX, bottomY;
  
  PreviewView(PVector _drawingSpace) {
    vPreviewSpace = new PVector(_drawingSpace.x, _drawingSpace.y);
    topX = drawingBorder; 
    topY = drawingBorder; 
    bottomX = drawingBorder + int(vPreviewSpace.x); 
    bottomY = drawingBorder + int(vPreviewSpace.y);
  }
  
  PVector getRandomPoint()
  {
    return new PVector(drawingBorder+random(vPreviewSpace.x), drawingBorder+random(vPreviewSpace.y) );
  }
  
  void addSignature(Signature sig, MarkOrientation mk) {
    arrDrawings.add(sig.sketchPoints); 
  }
  
  void drawPreview() {

    strokeWeight(3);
    stroke(0);
    rect(drawingBorder,drawingBorder,vPreviewSpace.x + drawingBorder,vPreviewSpace.y + drawingBorder);
    
    strokeWeight(3);
    noFill();
    stroke(200,200,0);
    rect(vSignatureDrawingSpace.x,vSignatureDrawingSpace.y,SIGNATURE_SIZE,SIGNATURE_SIZE);
    
    stroke(0);
    strokeWeight(1);
    noFill();


    //Debug output
    textSize(16);
    fill(255,0,0);
    text("Signature Queue Size: " + arrSignature.size(), 20, 40); 
    text("Signature Used Queue Size: " + arrUsedSignature.size(), 20, 60); 
    text("Place Count: " + signaturesPlacedCount, 20, 80); 
  }
 
}
