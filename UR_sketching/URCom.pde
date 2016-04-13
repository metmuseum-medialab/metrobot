
//==================================================================================
//==================================================================================
//UR COM Class Based on ABB Com Class (07 April 2014) by Ryan Luke Johns
//Eventually, these two will be merged into one that allows communication with 
//both varieties of robot...but for now we'll keep things separate.
//Developed for use at the MET Medialab and Columbia GSAPP and should cite the author(s) when used
import processing.net.*;  //import processing library for TCP/IP communication

class URCom {

  Client robMessageClient, robFeedbackClient; //the robot client we'll be talking to
  boolean testingMode = false; //setup two modes so the code can easily run if not connected
  boolean socketMode = false;
  PMatrix3D xForm = new PMatrix3D(); //create the identity matrix.  If we set a workobject, this will be used to transform coordinate systems
  float v = 50; //the speed of our tool in mm/s
  float zone = 1; //the blend radius of our tool in mm
  float scaledV = .1; //the speed of our tool in m/s
  float scaledZone = .0011; //the blend radius of our tool in m
  Pose [] moveLBuffer; //an array of movements that we store to send a chunk all at once

  float zLift = 100;  //distance to lift between drawings
  float zLiftOut = 100;

  String openingLines = "def urscript():\nsleep(3)\n"; //in case we want to send more data than just movements, put that text here
  String closingLines = "\nend\n"; //closing lines for the end of what we send
  
  byte[] byteArrayPrev = new byte[812];
  int    byteArrayPrevLength = 0;
  
  RobotFeedback robotFeedback = new RobotFeedback();

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

  void startCommandSocket(PApplet theSketch, String theIPAddress, int thePort) { //initialize our serial communication
    if(robMessageClient == null) {
       robMessageClient = new Client(theSketch, theIPAddress, thePort); //setup a new client
    }
    if(robMessageClient.active() == false) {
      robMessageClient.stop();
      robMessageClient = new Client(theSketch, theIPAddress, thePort); //setup a new client
    }
  }
  
  void startFeedbackSocket(PApplet theSketch, String theIPAddress, int thePort) { //initialize our serial communication
    if(robFeedbackClient == null) {
       robFeedbackClient = new Client(theSketch, theIPAddress, thePort); //setup a new client
    }
    if(robFeedbackClient.active() == false) {
      robFeedbackClient.stop();
      robFeedbackClient = new Client(theSketch, theIPAddress, thePort); //setup a new client
    }
  }
 
  float getRobotTotalSpeed() {
    double[] rs = getRobotSpeed();
    return abs((float)rs[0]) + abs((float)rs[1]) + abs((float)rs[2]);
  }
  
  double[] getRobotSpeed() {
    
      int availableBytes = robFeedbackClient.available();
      
      if ( availableBytes > 0)
      {
       // println(robFeedbackClient.readString());
        byte byteArray[] = robFeedbackClient.readBytes();
        
        int newLength = byteArray.length + byteArrayPrevLength;
        
        byte[] buffer = new byte[newLength];
        System.arraycopy(byteArrayPrev, 0, buffer, 0, byteArrayPrevLength);
        System.arraycopy(byteArray    , 0, buffer, byteArrayPrevLength, byteArray.length);

        int len = buffer.length;
        int srcPos = 0;
        int iLoop = 0;
        while ( len - srcPos >= 812 )
        {
          System.arraycopy(buffer,srcPos,robotFeedback.byteBuffer,0,812);
          srcPos += 812;
          robotFeedback.computeData();
          
        }
        if ( srcPos < len )
        {
          byteArrayPrevLength = len-srcPos;
          System.arraycopy(buffer,srcPos,byteArrayPrev,0,len-srcPos);
        }else{
          byteArrayPrevLength = 0;
        }
      }      
      
      return robotFeedback.tcp_speed;
      /*displayDoubleArray("tool_vector", robotFeedback.tool_vector, 10, 70);
      displayDoubleArray("q_actual", robotFeedback.q_actual, 100, 70);
      displayDoubleArray("tcp_speed", robotFeedback.tcp_speed, 190, 70);
      displayDouble("robot_mode", robotFeedback.robot_mode, 280, 70);*/
    
  } 

void displayDoubleArray(String title, double[] doubleArray, int left, int top){
  int lineHeight = 17;
  text(title, left, top);
  
  for(int i=0; i<doubleArray.length; i++){
    text((float)doubleArray[i], left, top + (1 + i) * lineHeight);
  }
}

void displayDouble(String title, double doubleVal, int left, int top){
  int lineHeight = 17;
  text(title, left, top);
  text((float)doubleVal, left, top + lineHeight);
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

  void getJointPositions() {
  
    String _msg = " get_actual_joint_positions()\n";

    sendString(openingLines);
    
    println(_msg);
    
    sendString(_msg);
    sendString(closingLines);
 
  }
  
  void moveL(Pose fPose){
        
    //movel(p[.535,.13,-.395,-1.20,2.90,0.00],v=0.30)\n a sample movel
    //movel(p[0.4666,0.3362,0.2317,1.20,-2.90,0.00],v=0.30,r=0.04212)\n another sample movel
    String msg = " movel(" + formatPose(fPose) + ",v=" + String.format("%.3f,", scaledV) + "r=" + String.format("%.5f", scaledZone) +", a=.001)\n";
    if (socketMode) {
      robMessageClient.write(msg);
      print("MoveL Command: " + msg + "*");
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
      robMessageClient.write(msg);
    } else if (testingMode) {
      print("Test SetTool Command: " + msg);
    }
  }
  
  void sendString(String msg){
    if (socketMode) {
      robMessageClient.write(msg);
    } else if (testingMode) {
      print("IN TESTING MODE, FOLLOWING MESSAGE NOT SENT: " + msg);
    }
  }
  
  void bufferedMoveL(Pose [] pA, String opening, String closing){
    sendString(opening);

    if (testingMode) {
//      for(Pose thisPose: pA) {
//        println("TESTING: Sketch points sent : " + thisPose.pos);
//      }
    } else {
      for(Pose thisPose: pA) {
        moveL(thisPose);
      } 
    }
    
    //sendString("socket_send_string(\"done\")");
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


 //SEND POINTS TO UR
  void sendPoints(ArrayList<PVector> _sketchPoints)
  {
    //=========================MAKE COPY OF ARRAY WITH LIFT POINTS===============================
    ArrayList<PVector> sendWithLift = new ArrayList<PVector>();
    for(int i=0; i<_sketchPoints.size(); i++){
      if(i == 0){
        PVector startPt = new PVector(_sketchPoints.get(i).x,_sketchPoints.get(i).y,zLift);
        sendWithLift.add(startPt);
      }
      else if(_sketchPoints.get(i).z < 1.1 && _sketchPoints.get(i).z > .9){
        PVector curvePt = new PVector(_sketchPoints.get(i).x,_sketchPoints.get(i).y,0);
        sendWithLift.add(curvePt);
      }
      if(_sketchPoints.get(i).z > -1.1 && _sketchPoints.get(i).z < -.9){
        sendWithLift.add(new PVector(_sketchPoints.get(i).x,_sketchPoints.get(i).y,zLift));
        if(i < _sketchPoints.size()-2){
          sendWithLift.add(new PVector(_sketchPoints.get(i+1).x,_sketchPoints.get(i+1).y,zLift));
        }
      }
      if(i ==_sketchPoints.size()-1){
        sendWithLift.add(new PVector(_sketchPoints.get(i).x,_sketchPoints.get(i).y,zLift));
      
      }
    }
    ///============================END MAKE COPY OF ARRAY WITH LIFT POINTS
    //send the list of target points when the mouse is clicked
    Pose [] poseArray = new Pose[sendWithLift.size()]; //CREATE A POSE ARRAY TO HOLD ALL OF OUR DRAWING SEQUENCE

    ///ADD ALL THE ACTUAL SKETCH POINTS TO OUR POSE ARRAY
    println("================printingz===============");
    for(int i = 0; i< sendWithLift.size(); i++){ //for each point in our arraylist
      Pose target = new Pose();//creat a new target pose
      //println(sendWithLift.get(i).z);
      
      target.fromTargetAndGuide(sendWithLift.get(i), new PVector(0,0,-1)); //set our pose based on the position we want to be at, and the z axis of our tool
      poseArray[i] = target;
    }
    bufferedMoveL(poseArray,openingLines,closingLines); //make our drawing happen!
  }
}//end URCom Class