import oscP5.*;

//*******************************************//
// SETTINGS
//*******************************************//

//App Size
final static int APP_WIDTH = 500;
final static int APP_HEIGHT = 500;

final boolean MODE_TESTING = true;
final boolean MODE_QUEUE = true;
final boolean OSC_LISTEN = false;
final boolean LOAD_STATE = false;
final boolean SAVE_STATE = false;

final String ROBOT_IP = "10.100.35.125"; //set the ip address of the robot
final int ROBOT_COMMAND_PORT = 30002; //set the port of the robot
final int ROBOT_FEEDBACK_PORT = 30003; //set the port of the robot

final static int SIGNATURE_SIZE = 50;

// SET POINTS THAT DEFINE THE BASE PLANE OF OUR COORDINATE SYSTEM
//these values should be read from the teachpendant screen and kept in the same units (Millimeters)
/*final PVector origin = new PVector(174.85,269.00,-183.96); //this is the probed origin point of our local coordinate system.
final PVector xPt = new PVector(191.05,-358.39,-181.29); //this is a point probed along the x axis of our local coordinate system
final PVector yPt = new PVector(574.95,258.02,-181.25); //this is a point probed along the z axis of our local coordinate system*/

final PVector origin = new PVector(174.85,269.00,-183.96); //this is the probed origin point of our local coordinate system.
final PVector xPt = new PVector(191.05,-358.39,-181.29); //this is a point probed along the x axis of our local coordinate system
final PVector yPt = new PVector(828.66,-234.23,-181.25); //this is a point probed along the z axis of our local coordinate system

final float lineMinLength = 5; //only register points on the screen if a given distance past the last saved point(keep from building up a million points at the same spot)

final String GOAL_IMAGE = "calibration1.jpg"; 
final String STATE_FILE = "160301_calibration1.jpg";

//*******************************************//
// Variables
//*******************************************//

//Client ur;
String input;
int data[];
String textToSend;


//START AUTO PLACE
boolean autoPlace = false;
boolean bShowImage = true;
int signaturesPlacedCount = 0;


//Define the Robot drawing space. Currently i'm just using an arbitrary aspect ratio, and use it to define the preview space
PVector vRobotDrawingSpace = new PVector(500, 500);
PVector vRobotDrawingOffset = new PVector(-100,110);
PVector vSignatureDrawingSpace = new PVector(0, vRobotDrawingSpace.y - SIGNATURE_SIZE);

//Array of signatures
ArrayList<Signature> arrSignature = new ArrayList<Signature>();
ArrayList<Signature> arrUsedSignature = new ArrayList<Signature>();

ArrayList<PVector> sketchPoints = new ArrayList<PVector>();//store our drawing in this arraylist

PreviewView previewView;
GoalDrawing goalDrawing;
CanvasStatus canvasStatus;
TemplateMatcher templateMatcher;

URCom ur; //make an instance of our URCom class for talking to this one robot

boolean firstTouch = false; //have we started drawing?

boolean PLACING_SIGNATURE = false;


OscP5 oscP5;

//*******************************************///
// CODE MAIN
//*******************************************//


void setup() 
{
  size(1100, 500);

  /* start oscP5, listening for incoming messages at port 12000 */
  if (OSC_LISTEN) {
    oscP5 = new OscP5(this,12345);
  }
  
  if (MODE_TESTING) {
    ur = new URCom("testing"); 
  } else {
    ur = new URCom("socket"); 
    ur.startCommandSocket(this, ROBOT_IP, ROBOT_COMMAND_PORT);
    ur.startFeedbackSocket(this, ROBOT_IP, ROBOT_FEEDBACK_PORT);
  }

  previewView = new PreviewView(vRobotDrawingSpace);
  goalDrawing = new GoalDrawing(int(vRobotDrawingSpace.x), int(vRobotDrawingSpace.y)); //APP_WIDTH, APP_HEIGHT);
  canvasStatus = new CanvasStatus(APP_WIDTH, APP_HEIGHT);
  templateMatcher = new TemplateMatcher();

  Pose basePlane = new Pose(); //make a new "Pose" (Position and orientation) for our base plane
  basePlane.fromPoints(origin,xPt,yPt); //define the base plane based on our probed points
  ur.setWorkObject(basePlane); //set this base plane as our transformation matrix for subsequent movement operations
 
  Pose firstTarget = new Pose(); //make a new pose object to store our desired position and orientation of the tool
  firstTarget.fromTargetAndGuide(new PVector(0,0,0), new PVector(0,0,-1)); //set our pose based on the position we want to be at, and the z axis of our tool

  // set a goal Drawing
  if(LOAD_STATE) {
    goalDrawing.loadFromImage(GOAL_IMAGE);
  }

  // load a save state 
  if(SAVE_STATE) {
    canvasStatus.loadState(STATE_FILE);
  }
  
}

PImage diffDisplayImg;

void draw() {
  smooth();
  background(255);
  
  if (bShowImage)
  {
    goalDrawing.drawPreview();
  }
  
  canvasStatus.draw();  

   //Draw Preview View
  previewView.drawPreview();

  if (diffDisplayImg != null ) { 
    image(diffDisplayImg, 600, 0);
  }

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

  

  /*
  if (MODE_TESTING == false)
  {



  }*/
  

  if (autoPlace == true)
  {
    if (PLACING_SIGNATURE == false) {

  
      if(MODE_TESTING == false) {
        println("mode = false");
        
        ur.startCommandSocket(this, ROBOT_IP, ROBOT_COMMAND_PORT);
        ur.startFeedbackSocket(this, ROBOT_IP, ROBOT_FEEDBACK_PORT);
        
        if( ur.getRobotTotalSpeed() < 0.001 ) {

          println("penspeed is < 0.001");
          
          //draw next
          placeSignature();
          delay(4000);
          println("Speed ==== " + ur.getRobotTotalSpeed());
        }
      } else {
        placeSignature();
      }
    }
  }


  if (frameCount % 100 == 0) {
    canvasStatus.saveState(dataPath(STATE_FILE));
  }

}

void keyPressed() {
   
  // 'p' draw next value in queue
  //
  // 'a' draw next value and remove
  //

  if (key == 'p') { // place a signature
    placeSignature();
  }

  if (key == 'a') {
    autoPlace = !autoPlace;
  }
  
  //Hide image
  if (key == 'i') {
    bShowImage = !bShowImage;
  }
    
  if (key == 'b') {
    drawBounds();
  }
    
}


Signature getNextSignature()
{
  Signature _sig;
  
  //If Still queue of unused
  if (arrSignature.size() > 0) {
    
    _sig = arrSignature.get(0);
    
    arrSignature.remove(0);
    arrUsedSignature.add(_sig);
  } else {
    
    _sig = arrUsedSignature.get(int(random(0,arrUsedSignature.size())));
  }
  
  return _sig;
  
}

void placeSignature() {
    ////// THIS IS WHERE THE MAGIC IS RIGHT NOW ////

  if (arrSignature.size() > 0 || arrUsedSignature.size() > 0) {
    PLACING_SIGNATURE = true;

    println( ">>>> WE ARE placing SIG #" + signaturesPlacedCount);

    // choose a signature
    Signature thisSignature = getNextSignature(); //arrSignature.get(arrSignature.size() - 1);


    // using webcam, update the status of the canvas
    canvasStatus.update();

    // using the templateMatcher, a signature, canvas status and goaldrawing, 
    // generate a 'markorientation' - location, orientation, rotation
    MarkOrientation mk = templateMatcher.placeSignature(goalDrawing, canvasStatus, thisSignature);
    println(mk);

    // add signature to canvas
    canvasStatus.addSignature(thisSignature, mk);

    // this temporarily shows the difference image on the canvas
    diffDisplayImg = templateMatcher.getDifferenceImage(goalDrawing.goalImg, canvasStatus.canvasImg);
    diffDisplayImg.resize(int(diffDisplayImg.width * 1.0), 0);

    ur.sendPoints(toRobotCoordinates(thisSignature.generateRobotMark(mk))); 
    
    PLACING_SIGNATURE = false;
    signaturesPlacedCount++;
  }
}


ArrayList<PVector> toRobotCoordinates(ArrayList<PVector> pts) {

  ArrayList<PVector> robotPts = new ArrayList<PVector>();

  for (int i = 0;i < pts.size(); i++) {

    PVector p = pts.get(i).copy();

    //Get rid of out of bounds values
    if (p.x < 0) {p.x = 0;}
    if (p.x > vRobotDrawingSpace.x) {p.x = vRobotDrawingSpace.x;}
    if (p.y < 0) {p.y = 0;}
    if (p.y > vRobotDrawingSpace.y) {p.y = vRobotDrawingSpace.y;}

    //Add the Y Normalization back in before we send to robot
    //This needs to be moved to the last thing that is done
    p.y = vRobotDrawingSpace.y - p.y;

    p.x += vRobotDrawingOffset.x;
    p.y += vRobotDrawingOffset.y;

    robotPts.add(p);  
  }
  return robotPts;

}

void drawBounds() {
  ArrayList<PVector> boundPoints = new ArrayList<PVector>();  //store our drawing in this arraylist

  boundPoints.add(new PVector(0, 0));
  boundPoints.add(new PVector(APP_WIDTH, 0));
  boundPoints.add(new PVector(APP_WIDTH, APP_HEIGHT));
  boundPoints.add(new PVector(0, APP_HEIGHT));
  boundPoints.add(new PVector(0, 0));

  println(boundPoints);
  ur.sendPoints(toRobotCoordinates(boundPoints));
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

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {

  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  theOscMessage.print();
  //println(" typetag: "+theOscMessage.typetag());
}
