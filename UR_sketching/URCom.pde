//==================================================================================
//==================================================================================
//UR COM Class Based on ABB Com Class (07 April 2014) by Ryan Luke Johns
//Eventually, these two will be merged into one that allows communication with 
//both varieties of robot...but for now we'll keep things separate.
//Developed for use at the MET Medialab and Columbia GSAPP and should cite the author(s) when used
import processing.net.*;  //import processing library for TCP/IP communication

class URCom {

  Client robClient; //the robot client we'll be talking to
  boolean testingMode = false; //setup two modes so the code can easily run if not connected
  boolean socketMode = false;
  PMatrix3D xForm = new PMatrix3D(); //create the identity matrix.  If we set a workobject, this will be used to transform coordinate systems
  float v = 50; //the speed of our tool in mm/s
  float zone = 1; //the blend radius of our tool in mm
  float scaledV = .1; //the speed of our tool in m/s
  float scaledZone = .0001; //the blend radius of our tool in m
  Pose [] moveLBuffer; //an array of movements that we store to send a chunk all at once

  URCom(String comType) { //construct in either testing or serial mode
    if (comType == "testing") {
      testingMode = true;
      socketMode = false;
    } else if (comType == "socket") {
      testingMode = false;
      socketMode = true;
    }
  }

  void setMode(String comType) { //switch modes after initial setup
    if (comType == "testing") {
      testingMode = true;
      socketMode = false;
    } else if (comType == "socket") {
      testingMode = false;
      socketMode = true;
    }
  }

  void startSocket(PApplet theSketch, String theIPAddress, int thePort) { //initialize our serial communication
    robClient = new Client(theSketch, theIPAddress, thePort); //setup a new client
  }

  void setWorkObject(Pose wObjDat) {
    //The workobject is a local coordinate frame you can define on the robot, then subsequent cartesian moves will be in this coordinate frame. 
    //in this class, we don't actually send this to the robot, but just use it for transformations before we send things to the robot...
    xForm = wObjDat.getMatrix(); //get the transformation matrix of our pose
   
   float[] matArray = new float[16];
   xForm.get(matArray);
   println(matArray);
}

  void setSpeed(float velTcp) { //set speed with only one parameter, a blend radius
    v = velTcp;
    scaledV = v/1000.0;
    if (testingMode) {
      print("Set Speed To: " + v + " mm/s");
    }
  }

  void setZone(float pZoneTcp) {  //set zone with one paramater, blend radius
    zone = pZoneTcp;
    scaledZone = pZoneTcp/1000.0;
    if (testingMode) {
      print("Test SetZone Command: " + zone);
    }
  }

  void moveL(Pose fPose){
    //movel(p[.535,.13,-.395,-1.20,2.90,0.00],v=0.30)\n a sample movel
    //movel(p[0.4666,0.3362,0.2317,1.20,-2.90,0.00],v=0.30,r=0.04212)\n another sample movel
    String msg = " movel(" + formatPose(fPose) + ",v=" + String.format("%.3f,", scaledV) + "r=" + String.format("%.5f", scaledZone) +", a=.001)\n";
    if (socketMode) {
      robClient.write(msg);
    } else if (testingMode) {
      print("Test MoveL Command: " + msg);
    }
  }
  
    void setTool(Pose toolDat) {
    //Sets the tool centerpoint (TCP) of the robot. 
    //Offsets are from tool0, which is defined at the intersection of the tool flange center axis and the flange face.
    //Recognize that we are not setting mass data here.  For precise movements, this really should be done.  To be edited later, I assume...
    //set_tcp(p[0.0000,0.0000,0.0575,0.0000,0.0000,0.0000]) //example line
    String msg = "set_tcp(" + formatPose(toolDat) + ")\n";
    if (socketMode) {
      robClient.write(msg);
    } else if (testingMode) {
      print("Test SetTool Command: " + msg);
    }
  }
  
  void sendString(String msg){
    if (socketMode) {
      robClient.write(msg);
    } else if (testingMode) {
      print("IN TESTING MODE, FOLLOWING MESSAGE NOT SENT: " + msg);
    }
  }
  
  void bufferedMoveL(Pose [] pA, String opening, String closing){
    sendString(opening);
    for(int i = 0; i<pA.length-1;i++){
      //println(i);
      //println(pA[i].pos);
      moveL(pA[i]);
    }
    
    sendString(closing);
    
    
  }//send a pose array

  String formatPose(Pose framePose) {
    //first we need to move our pose to the coordinate system of our base
    PMatrix3D frameMatrix = framePose.getMatrix(); //get the matrix of this pose
    PMatrix3D newMatrix = new PMatrix3D();
    newMatrix.set(xForm);
    newMatrix.apply(frameMatrix);
    //newMatrix = frameMatrix.apply(xForm); //apply our transformation matrix to this pose
    framePose.fromPMatrix3D(newMatrix); //reset our framePose to this transformed value
    String msg  = "";
    msg += "p[";
    //add the position data to the string
    msg += String.format("%.6f,", framePose.pos.x/1000.0);
    msg += String.format("%.6f,", framePose.pos.y/1000.0);
    msg += String.format("%.6f,", framePose.pos.z/1000.0);
    //add the orientation data to the string
    //but first we have to transform it to axis angle notation
    PVector aaNotation = framePose.orient.toAxisAngle();
    msg += String.format("%.6f,", aaNotation.x);
    msg += String.format("%.6f,", aaNotation.y);
    msg += String.format("%.6f", aaNotation.z);
    msg += "]" ;
    return msg;
  }
  
}//end URCom Class