//********** UR SKETCHING MAIN APP **********//

import oscP5.*;

//*******************************************//
// SETTINGS
//*******************************************//

//App Size
final static int APP_WIDTH = 500;
final static int APP_HEIGHT = 500;

final boolean MODE_TESTING = true;
final boolean MODE_QUEUE = true;
final boolean OSC_LISTEN = true;
final boolean LOAD_STATE = false;
final boolean SAVE_STATE = false;

final String ROBOT_IP = "10.100.35.125"; //set the ip address of the robot
final int ROBOT_COMMAND_PORT = 30002; //set the port of the robot
final int ROBOT_FEEDBACK_PORT = 30003; //set the port of the robot

final static int SIGNATURE_SIZE = 50;

//final static float signatureScale = 1;


// SET POINTS THAT DEFINE THE BASE PLANE OF OUR COORDINATE SYSTEM
//these values should be read from the teachpendant screen and kept in the same units (Millimeters)
/*final PVector origin = new PVector(174.85,269.00,-183.96); //this is the probed origin point of our local coordinate system.
 final PVector xPt = new PVector(191.05,-358.39,-181.29); //this is a point probed along the x axis of our local coordinate system
 final PVector yPt = new PVector(574.95,258.02,-181.25); //this is a point probed along the z axis of our local coordinate system*/

final PVector origin = new PVector(174.85, 269.00, -183.96); //this is the probed origin point of our local coordinate system.
final PVector xPt = new PVector(191.05, -358.39, -181.29); //this is a point probed along the x axis of our local coordinate system
final PVector yPt = new PVector(828.66, -234.23, -181.25); //this is a point probed along the z axis of our local coordinate system

final float lineMinLength = 5; //only register points on the screen if a given distance past the last saved point(keep from building up a million points at the same spot)

final String GOAL_IMAGE = "br1.jpg"; 
final String STATE_FILE = "br1_State1.jpg";

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
PVector vRobotDrawingOffset = new PVector(-100, 110);
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

boolean sigFirstTouch = false; //have we started drawing?
int sigPenPosition = 1;

boolean PLACING_SIGNATURE = false;


int stays_on_place=0;
int same_speed_counter=0;
float prev_speed=0;

OscP5 oscP5;

//*******************************************///
// CODE MAIN
//*******************************************//


void setup() 
{
  size(1100, 500);

  /* start oscP5, listening for incoming messages at port 12000 */

  if (OSC_LISTEN) {
    OscProperties myProperties = new OscProperties();
    myProperties.setDatagramSize(30000); 
    myProperties.setListeningPort(12345);
    oscP5 = new OscP5(this, myProperties);
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
  basePlane.fromPoints(origin, xPt, yPt); //define the base plane based on our probed points
  ur.setWorkObject(basePlane); //set this base plane as our transformation matrix for subsequent movement operations

  Pose firstTarget = new Pose(); //make a new pose object to store our desired position and orientation of the tool
  firstTarget.fromTargetAndGuide(new PVector(0, 0, 0), new PVector(0, 0, -1)); //set our pose based on the position we want to be at, and the z axis of our tool

  // set a goal Drawing
  goalDrawing.loadFromImage(GOAL_IMAGE);

  // load a save state 
  if (LOAD_STATE) {
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

  if (sigFirstTouch && validDrawingLocation() && sigPenPosition >= 0) {  //if we've started drawing

    //*Remove the Y normalization and only add in at end before sending points to robot
    //PVector currentPos = new PVector(mouseX,height-mouseY,0);
    PVector currentPos = new PVector(mouseX, mouseY, sigPenPosition);

    if (PVector.dist(currentPos, sketchPoints.get(sketchPoints.size()-1)) > lineMinLength) {
      sketchPoints.add(currentPos);
    }
  }

  //DRAW THE SIGNATURE
  strokeWeight(1);
  stroke(0);
  noFill();
  beginShape();
  for (PVector p : sketchPoints) {

    //*Remove the Y normalization and only add in at end before sending points to robot

    //If pen is up, end/start shape
    if (p.z == -1) {
      endShape();
      beginShape();
    }
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


      if (MODE_TESTING == false) {
        println("mode = false");

        ur.startCommandSocket(this, ROBOT_IP, ROBOT_COMMAND_PORT);
        ur.startFeedbackSocket(this, ROBOT_IP, ROBOT_FEEDBACK_PORT);

        if ( ur.getRobotTotalSpeed() < 0.01 ) {

          println("penspeed is < 0.001");

          // check if stucked
          if (stays_on_place<10) {
            stays_on_place++;
            delay(100);
          } else {


            placeSignature();
            delay(2000);
            stays_on_place=0;
            same_speed_counter=0;
          }


          println("Speed ==== " + ur.getRobotTotalSpeed());
        } else {
          // check if  speed stucked and always the same
          if (ur.getRobotTotalSpeed() == prev_speed) {
            same_speed_counter++;
          }
          prev_speed=ur.getRobotTotalSpeed();
          
          if (same_speed_counter>10) {
            placeSignature();
            delay(2000);
            stays_on_place=0;
            same_speed_counter=0;
          }
          delay(100);
          println("Speed ==== " + ur.getRobotTotalSpeed());
        }
      } else {
        placeSignature();
      }
    }
  }


  if (SAVE_STATE) {
    if (frameCount % 100 == 0) {
      canvasStatus.saveState(dataPath(STATE_FILE));
    }
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
    PLACING_SIGNATURE = false;
  }

  //Hide image
  if (key == 'i') {
    bShowImage = !bShowImage;
  }

  if (key == 'b') {
    drawBounds();
  }

  if (key == 's') {

    //Add a signature
    if (sigFirstTouch) {

      if (MODE_QUEUE) {
        arrSignature.add(new Signature(SIGNATURE_SIZE, sketchPoints));
      }

      sketchPoints.clear();

      //reset to a new drawing
      sigFirstTouch = false;
    }
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

    _sig = arrUsedSignature.get(int(random(0, arrUsedSignature.size())));
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

  for (int i = 0; i < pts.size(); i++) {

    PVector p = pts.get(i).copy();

    //Get rid of out of bounds values
    if (p.x < 0) {
      p.x = 0;
    }
    if (p.x > vRobotDrawingSpace.x) {
      p.x = vRobotDrawingSpace.x;
    }
    if (p.y < 0) {
      p.y = 0;
    }
    if (p.y > vRobotDrawingSpace.y) {
      p.y = vRobotDrawingSpace.y;
    }

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
  if (sigFirstTouch) {

    //Switch pen position
    sigPenPosition *= -1;

    //If we are putting the pen down again, the first point has a pen up value
    if (sigPenPosition == 1) {

      PVector _currentPos = new PVector(mouseX, mouseY, -1);
      sketchPoints.add(_currentPos);
    }
  } else if (validDrawingLocation()) {

    sigFirstTouch = true;
    sigPenPosition = 1;

    //*Remove the Y normalization and only add in at end before sending points to robot
    PVector pos = new PVector(mouseX, mouseY, 0);
    sketchPoints.add(pos);
  }
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage _osc) {

  ArrayList<PVector> oscSketchPoints = new ArrayList<PVector>();//store our drawing in this arraylist

  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");

  _osc.print();

  //println( _osc.arguments );

  println(_osc.addrPattern());

  println(" typetag: "+_osc.typetag());

  String _type = _osc.typetag();

  int _z = -1;

  for (int i=0; i<_type.length(); i++)
  {
     if ( i>0 && _type.charAt(i) == 's')
     {
        String _msg = _osc.get(i).toString();
        String[] _arrPoints = split(_msg,",");
        
        println("out>" + _msg);
        if (_msg == "new_line") {
          _z = -1;
        } else if (_arrPoints.length>1) {
        
        for (int j=0; j<_arrPoints.length; j=j+3)
        {
          if (float(_arrPoints[0]) > 0 && float(_arrPoints[1]) > 0)
          {
            if (float(_arrPoints[0]) > 1) { _arrPoints[j]="1";}
            if (float(_arrPoints[1]) > 1) { _arrPoints[j]="1";}
            
           //oscSketchPoints.add(new PVector( (float(_arrPoints[j])*SIGNATURE_SIZE+vSignatureDrawingSpace.x), (float(_arrPoints[j+1])*SIGNATURE_SIZE + vSignatureDrawingSpace.y) ));  
           println("Add : " + _arrPoints[0] + "," + _arrPoints[01] + "," + _z + " " +(float(_arrPoints[0])*SIGNATURE_SIZE+SIGNATURE_SIZE + vSignatureDrawingSpace.x) + "," + (float(_arrPoints[1])*SIGNATURE_SIZE + vSignatureDrawingSpace.y));
          
           /*  
           if (float(_arrPoints[j]) < 0) { _arrPoints[j]="0";}
           if (float(_arrPoints[j]) > 1) { _arrPoints[j]="1";}
           
           if (float(_arrPoints[j+1]) < 0) { _arrPoints[j]="0";}
           if (float(_arrPoints[j+1]) > 1) { _arrPoints[j]="1";}
           
           //oscSketchPoints.add(new PVector( (float(_arrPoints[j])*SIGNATURE_SIZE+vSignatureDrawingSpace.x), (float(_arrPoints[j+1])*SIGNATURE_SIZE + vSignatureDrawingSpace.y) )); 
           
           println("Add : " + _arrPoints[j] + "," + _arrPoints[j+1] + "," + _z + " " +(float(_arrPoints[j])*SIGNATURE_SIZE+SIGNATURE_SIZE + vSignatureDrawingSpace.x) + "," + (float(_arrPoints[j+1])*SIGNATURE_SIZE + vSignatureDrawingSpace.y));
          */
          }
        }
            _z = 1;
        }
      
     }
  }

  //Add the signature
  arrSignature.add(new Signature(SIGNATURE_SIZE, oscSketchPoints));
}
