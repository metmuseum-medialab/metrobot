//RLJ 02/19/16 www.gshed.com
//Connect to UR robot and send squiggles drawn on the screen when click event happens

//Client ur;
String input;
int data[];
String textToSend;

//Array of signatures
ArrayList<Signature> arrSignature = new ArrayList<Signature>();

//App Size
final int APP_WIDTH = 825;
final int APP_HEIGHT = 500;

final boolean MODE_TESTING = true;
final boolean MODE_QUEUE = true;

//Define the Robot drawing space. Currently i'm just using an arbitrary aspect ratio, and use it to define the preview space
PVector vRobotDrawingSpace = new PVector(825,500);
PVector vRobotDrawingOffset = new PVector(-100,110);

final int SIGNATURE_SIZE = 200;
PVector vSignatureDrawingSpace = new PVector(0,APP_HEIGHT-SIGNATURE_SIZE);

PreviewView previewView = new PreviewView(vRobotDrawingSpace);
GoalDrawing goalDrawing = new GoalDrawing(vRobotDrawingSpace);
CanvasStatus canvasStatus = new CanvasStatus();

//=================================NETWORKING DATA===========================================================================
String ipAddress = "10.100.35.125"; //set the ip address of the robot
int port = 30002; //set the port of the robot
//===========================SET POINTS THAT DEFINE THE BASE PLANE OF OUR COORDINATE SYSTEM===================================
//these values should be read from the teachpendant screen and kept in the same units (Millimeters)
PVector origin = new PVector(174.85,269.00,-183.96); //this is the probed origin point of our local coordinate system.
PVector xPt = new PVector(191.05,-358.39,-181.29); //this is a point probed along the x axis of our local coordinate system
PVector yPt = new PVector(574.95,258.02,-194.25); //this is a point probed along the z axis of our local coordinate system
//===============================SET ROBOT VARIABLES=================================================================
URCom ur; //make an instance of our URCom class for talking to this one robot
float radius = 1000; //set our blend radius in mm for movel and movep commands
float speed = 10; //set our speed in mm/s
String openingLines = "def urscript():\nsleep(3)\n"; //in case we want to send more data than just movements, put that text here
String closingLines = "\nend\n"; //closing lines for the end of what we send
//==============================VARIABLES FOR DRAWING============================================================
ArrayList<PVector> sketchPoints = new ArrayList<PVector>();//store our drawing in this arraylist
float minLength = 5; //only register points on the screen if a given distance past the last saved point(keep from building up a million points at the same spot)
boolean firstTouch = false; //have we started drawing?
float zLift = 10;  //distance to lift between drawings

void setup() 
{
  size(825, 500);

  if (MODE_TESTING) {
    ur = new URCom("testing"); 
  } else {
    ur = new URCom("socket"); 
    ur.startSocket(this, ipAddress, port);
  }
  
  Pose basePlane = new Pose(); //make a new "Pose" (Position and orientation) for our base plane
  basePlane.fromPoints(origin,xPt,yPt); //define the base plane based on our probed points
  ur.setWorkObject(basePlane); //set this base plane as our transformation matrix for subsequent movement operations
 
  Pose firstTarget = new Pose(); //make a new pose object to store our desired position and orientation of the tool
  firstTarget.fromTargetAndGuide(new PVector(0,0,0), new PVector(0,0,-1)); //set our pose based on the position we want to be at, and the z axis of our tool

  goalDrawing.loadFromImage("example_goal_image_2.jpg");

}

void draw() 
{
  background(255);
  smooth();
  
  //Draw Preview View
  previewView.drawPreview();

  goalDrawing.drawPreview();

  if(firstTouch && validDrawingLocation() ){//if we've started drawing
  
    //*Remove the Y normalization and only add in at end before sending points to robot
    //PVector currentPos = new PVector(mouseX,height-mouseY,0);
    PVector currentPos = new PVector(mouseX,mouseY,0);

    if(PVector.dist(currentPos,sketchPoints.get(sketchPoints.size()-1)) > minLength){
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

  //PImage c = get(int(vSignatureDrawingSpace.x), int(vSignatureDrawingSpace.y), SIGNATURE_SIZE, SIGNATURE_SIZE);
  //image(c,200,200);

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

    /////////// PSEUDOCODE HERE FOR TEMPLATE-MATCHING DRAWING OF SIGNATURE ONTO CANVAS //////

    if (arrSignature.size() > 0) {

        // choose a signature
        Signature thisSignature = arrSignature.get(0); 

        // using webcam, update the status of the canvas
        canvasStatus.update();

        // using canvas status and goaldrawing, generate a 'markorientation' - location, orientation, rotation
        // this is where the templateMatching would happen
        MarkOrientation mk = goalDrawing.getSignatureLocation(canvasStatus, thisSignature); // TODO

        //Add to our view
        previewView.addSignature(thisSignature.generateRobotMark(mk,true));

        // send points to UR for generating a mark
  	if (MODE_TESTING == false) {
            sendPointsToUR(thisSignature.generateRobotMark(mk,false)); // TODO
       	} 
    }
  }

}

boolean validDrawingLocation()
{
   if (mouseX >= vSignatureDrawingSpace.x && mouseX < vSignatureDrawingSpace.x + SIGNATURE_SIZE && mouseY > vSignatureDrawingSpace.y && mouseY < vSignatureDrawingSpace.y + SIGNATURE_SIZE)
   {
     return true;
   }
   return false;
}

void mouseClicked(){
  
  //Add a signature
  if (firstTouch) {
    
   if (MODE_QUEUE)
   {
     arrSignature.add(new Signature(sketchPoints));
   }
   else 
   {
     //If no queue, just send signature right to robot
     sendPointsToUR(sketchPoints);
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

//SEND POINTS TO UR
void sendPointsToUR(ArrayList<PVector> _sketchPoints)
{
  //send the list of target points when the mouse is clicked
  Pose [] poseArray = new Pose[_sketchPoints.size() + 2]; //CREATE A POSE ARRAY TO HOLD ALL OF OUR DRAWING SEQUENCE
  
  ///ADD THE LIFT POINTS TO THE BEGINNING AND END OF THE POSE ARRAY
  PVector aboveFirstPt = new PVector(_sketchPoints.get(0).x,_sketchPoints.get(0).y,_sketchPoints.get(0).z+zLift);
  PVector aboveLastPt = new PVector(_sketchPoints.get(_sketchPoints.size()-1).x,_sketchPoints.get(_sketchPoints.size()-1).y,_sketchPoints.get(_sketchPoints.size()-1).z+zLift);
  Pose aboveFirstPose = new Pose();
  Pose aboveLastPose = new Pose();
  aboveFirstPose.fromTargetAndGuide(aboveFirstPt,new PVector(0,0,-1));
  aboveLastPose.fromTargetAndGuide(aboveLastPt,new PVector(0,0,-1));
  poseArray[0] = aboveFirstPose;
  poseArray[_sketchPoints.size() + 1] = aboveLastPose; //something is off here...the above point isn't getting added...no time to debug...
  
  ///ADD ALL THE ACTUAL SKETCH POINTS TO OUR POSE ARRAY
  for(int i = 0; i< _sketchPoints.size(); i++){ //for each point in our arraylist
    Pose target = new Pose();//creat a new target pose
    
    println("Sketch points sent : " + _sketchPoints.get(i).x + "," + _sketchPoints.get(i).y);
    
    target.fromTargetAndGuide(_sketchPoints.get(i), new PVector(0,0,-1)); //set our pose based on the position we want to be at, and the z axis of our tool
    //ur.moveL(target);
    poseArray[i+1] = target;
  }
  ur.bufferedMoveL(poseArray,openingLines,closingLines); //make our drawing happen!
}
