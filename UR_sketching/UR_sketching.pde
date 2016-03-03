//*******************************************//
// SETTINGS
//*******************************************//

//App Size
final static int APP_WIDTH = 1000;
final static int APP_HEIGHT = 1000;

final boolean MODE_TESTING = true;
final boolean MODE_QUEUE = true;

final String ROBOT_IP = "10.100.35.125"; //set the ip address of the robot
final int ROBOT_PORT = 30002; //set the port of the robot

final static int SIGNATURE_SIZE = 200;

// SET POINTS THAT DEFINE THE BASE PLANE OF OUR COORDINATE SYSTEM
//these values should be read from the teachpendant screen and kept in the same units (Millimeters)
final PVector origin = new PVector(174.85,269.00,-183.96); //this is the probed origin point of our local coordinate system.
final PVector xPt = new PVector(191.05,-358.39,-181.29); //this is a point probed along the x axis of our local coordinate system
final PVector yPt = new PVector(574.95,258.02,-194.25); //this is a point probed along the z axis of our local coordinate system

final float lineMinLength = 5; //only register points on the screen if a given distance past the last saved point(keep from building up a million points at the same spot)

//*******************************************//
// Variables
//*******************************************//

//Client ur;
String input;
int data[];
String textToSend;


//Define the Robot drawing space. Currently i'm just using an arbitrary aspect ratio, and use it to define the preview space
PVector vRobotDrawingSpace = new PVector(825, 500);
PVector vRobotDrawingOffset = new PVector(-100,110);
PVector vSignatureDrawingSpace = new PVector(0, vRobotDrawingSpace.y - SIGNATURE_SIZE);

//Array of signatures
ArrayList<Signature> arrSignature = new ArrayList<Signature>();

ArrayList<PVector> sketchPoints = new ArrayList<PVector>();//store our drawing in this arraylist

PreviewView previewView;
GoalDrawing goalDrawing;
CanvasStatus canvasStatus;
TemplateMatcher templateMatcher;

URCom ur; //make an instance of our URCom class for talking to this one robot

boolean firstTouch = false; //have we started drawing?

boolean PLACING_SIGNATURE = false;

//*******************************************///
// CODE MAIN
//*******************************************//


void setup() 
{
  size(1000, 1000);

  if (MODE_TESTING) {
    ur = new URCom("testing"); 
  } else {
    ur = new URCom("socket"); 
    ur.startSocket(this, ROBOT_IP, ROBOT_PORT);
  }

  previewView = new PreviewView(vRobotDrawingSpace);
  goalDrawing = new GoalDrawing(vRobotDrawingSpace);
  canvasStatus = new CanvasStatus(APP_WIDTH, APP_HEIGHT);
  templateMatcher = new TemplateMatcher();


  Pose basePlane = new Pose(); //make a new "Pose" (Position and orientation) for our base plane
  basePlane.fromPoints(origin,xPt,yPt); //define the base plane based on our probed points
  ur.setWorkObject(basePlane); //set this base plane as our transformation matrix for subsequent movement operations
 
  Pose firstTarget = new Pose(); //make a new pose object to store our desired position and orientation of the tool
  firstTarget.fromTargetAndGuide(new PVector(0,0,0), new PVector(0,0,-1)); //set our pose based on the position we want to be at, and the z axis of our tool

  goalDrawing.loadFromImage("pollock_800.jpg");

}

void draw() {
  smooth();
  background(255);
  
  goalDrawing.drawPreview();

  canvasStatus.draw();  

   //Draw Preview View
  previewView.drawPreview();

  

  if(firstTouch && validDrawingLocation() ) {//if we've started drawing
  
    //*Remove the Y normalization and only add in at end before sending points to robot
    //PVector currentPos = new PVector(mouseX,height-mouseY,0);
    PVector currentPos = new PVector(mouseX,mouseY,0);

    if(PVector.dist(currentPos,sketchPoints.get(sketchPoints.size()-1)) > lineMinLength){
      sketchPoints.add(currentPos);
    }
  }

  //DRAW THE SIGNATURE
  strokeWeight(1);
  stroke(0);
  noFill();
  beginShape();
  for(PVector p: sketchPoints) {
    
    //*Remove the Y normalization and only add in at end before sending points to robot
    vertex(p.x, p.y);
  }
  endShape();

//  if (PLACING_SIGNATURE == false) {
//    placeSignature();
//  }
}

void keyPressed() {
   
  // 'a' draw next value in queue
  //
  // 'q' draw next value and remove
  //
  if (key == 'q' || key == 'a') {
    
    //Pop out of Queue and Draw Preview
    if (arrSignature.size() > 0) {
        
        //Find random point and scale in preview area
        PVector _v = new PVector(0, 0); // previewView.getRandomPoint();
        float _s = 1; //.5 + random(1);

        println(_v);
        
        //We first call a funciton to conform the signature points in robot and preview space for the 
        // given parameters: location, scale, rotation
        //arrSignature.get(0).setSignaturePoints(_v, _s, 0);
        
        //Now we can send these points to the robot
        //sendPointsToUR(arrSignature.get(0).robotSketchPoints);
        
        //Now we can add these points to the preview
        //previewView.addSignature(arrSignature.get(0).previewSketchPoints);
        
        if (key == 'q') { 
          arrSignature.remove(0);
        }
 
        println(arrSignature.size());
    }
  }
  if (key == 'p') { // place a signature

    placeSignature();

  }

}


void placeSignature() {
    ////// THIS IS WHERE THE MAGIC IS RIGHT NOW ////

  if (arrSignature.size() > 0) {
    PLACING_SIGNATURE = true;

    println( "placing SIG!");

    // choose a signature
    Signature thisSignature = arrSignature.get(arrSignature.size() - 1);
    //Signature thisSignature = arrSignature.get(int(random(0, arrSignature.size())));


    // using webcam, update the status of the canvas
    canvasStatus.update();

    // using the templateMatcher, a signature, canvas status and goaldrawing, 
    // generate a 'markorientation' - location, orientation, rotation
    MarkOrientation mk = templateMatcher.placeSignature(goalDrawing, canvasStatus, thisSignature);
    println(mk);

    //Add to our view
    previewView.addSignature(thisSignature, mk);

    //Add to our canvas
    canvasStatus.addSignature(thisSignature, mk);

    // send points to UR for generating a mark
  //  ur.sendPoints(thisSignature.generateRobotMark(mk,false)); 
  //  arrSignature.remove(0);
  //
    PLACING_SIGNATURE = false;
  }
}

boolean validDrawingLocation() {
   if (mouseX >= vSignatureDrawingSpace.x && mouseX < vSignatureDrawingSpace.x + SIGNATURE_SIZE && mouseY > vSignatureDrawingSpace.y && mouseY < vSignatureDrawingSpace.y + SIGNATURE_SIZE)
   {
     return true;
   }
   return false;
}

void mouseClicked() {
  
  //Add a signature
  if (firstTouch) {
    
    if (MODE_QUEUE) {
      arrSignature.add(new Signature(SIGNATURE_SIZE, sketchPoints));
    } else {
      //If no queue, just send signature right to robot
      
      //ur.sendPoints(sketchPoints);
    }

   sketchPoints.clear();
   //reset to a new drawing
   firstTouch = false;
  } else if (validDrawingLocation()) {
    
   firstTouch = true;
   
   //*Remove the Y normalization and only add in at end before sending points to robot
   PVector pos = new PVector(mouseX,mouseY,0);
   sketchPoints.add(pos);
  }

}
