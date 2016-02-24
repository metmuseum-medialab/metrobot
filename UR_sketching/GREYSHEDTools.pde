//=========================================================================================================================================================
//=========================================================================================================================================================
//7 April, 2014
//This code was written by Ryan Luke Johns (www.ryanlukejohns.com) and is in early developmental stages.  Operate knowing there will be risk and bugs!
//It is intended for use at GREYSHED (www.gshed.com) and for student/research work at the Princeton University School of Architecture. 
//It is currently distributed with this intent only.  Other uses should be with permission and due citation.  For more information, contact info@gshed.com
//=====================================================================================================================================
//=====================================================================================================================================

//=======================================================================================================================================
////////////////////////////////////////////////////POSE CLASS///////////////////////////////////////////////////////////////////////////
//=======================================================================================================================================
//A simple class to store a pose (robTarget, without conf or eax data), composed of a posData (PVector) and orientData (Quaternion)
//Pose is the primary format, which can easily be sent to ABB robots.  Options for returning alternative representations of Pose are included, including
//axis angles and PMatrix

class Pose {
  PVector pos;
  Quaternion orient;

  Pose() { //initialize pose with base XY Plane values
    pos=new PVector(0, 0, 0);
    PVector xAxis = new PVector(1, 0, 0);
    PVector yAxis = new PVector(0, 1, 0);
    PVector zAxis = new PVector(0, 0, 1);
    orient = new Quaternion();
    orient.fromFrame(xAxis, yAxis, zAxis);
  }

  Pose(PVector posePos, Quaternion poseOrient) { //initialize pose with set values
    pos=posePos;
    orient=poseOrient;
  }

  Pose(PMatrix3D m) {
    float [] mArray = new float[16];
    m.get(mArray); //convert the matrix to an array of numbers so that we can use them.
    PVector posElement = new PVector(mArray[3], mArray[7], mArray[11]); //might want to double check these numbers...impatient
    PVector orientX = new PVector(mArray[0], mArray[4], mArray[8]);
    PVector orientY = new PVector(mArray[1], mArray[5], mArray[9]);
    PVector orientZ = new PVector(mArray[2], mArray[6], mArray[10]);
    pos = posElement;
    orient = new Quaternion();
    orient.fromFrame(orientX, orientY, orientZ);
  }

  PVector getPos() {
    return pos;
  }

  Quaternion getOrient() {
    return orient;
  }

  void fromPMatrix3D(PMatrix3D m) {
    float [] mArray = new float[16];
    m.get(mArray); //convert the matrix to an array of numbers so that we can use them.
    PVector posElement = new PVector(mArray[3], mArray[7], mArray[11]); //might want to double check these numbers...impatient
    PVector orientX = new PVector(mArray[0], mArray[4], mArray[8]);
    PVector orientY = new PVector(mArray[1], mArray[5], mArray[9]);
    PVector orientZ = new PVector(mArray[2], mArray[6], mArray[10]);
    pos = posElement;
    orient.fromFrame(orientX, orientY, orientZ);
  }

  PMatrix3D getMatrix() { 
    PVector[] frameVectors = orient.toMatrix();
    PVector x = frameVectors[0];
    PVector y = frameVectors[1];
    PVector z = frameVectors[2];
    //PMatrix3D myPose = new PMatrix3D(x.x, x.y, x.z, 0, y.x, y.y, y.z, 0, z.x, z.y, z.z, 0, pos.x, pos.y, pos.z, 1);
    PMatrix3D myPose = new PMatrix3D(x.x, y.x, z.x, pos.x, x.y, y.y, z.y, pos.y, x.z, y.z, z.z, pos.z, 0, 0, 0, 1);
    //float m00, float m01, float m02, float m03, float m10, float m11, float m12, float m13, float m20, float m21, float m22, float m23, float m30, float m31, float m32, float m33
    //Processing is weird...  http://forum.processing.org/one/topic/understanding-pmatrix3d.html
    //(x.x, x.y, x.z, 0, y.x, y.y, y.z, 0, z.x, z.y, z.z, 0, pos.x, pos.y, pos.z, 1);
    //(x.x,y.x,z.x,pos.x,x.y,y.y,z.y,pos.y,x.z,y.z,z.z,pos.z,0,0,0,1)

    return myPose;
  }

  void fromPoints(PVector origin, PVector xPt, PVector yPt) {
    //defines a Pose from probed points.  Origin, a point along the x axis, and a point along the y axis.  This code is X axis dominant,
    //meaning that the x axis will be exactly as defined, and the Y axis will be as close as possible to the probed point while maintaining a true plane definition
    PVector xAxis = PVector.sub(xPt, origin).normalize(); //our x axis is defined by the line between 
    PVector tempYAxis = PVector.sub(yPt, origin).normalize();
    PVector zAxis = xAxis.cross(tempYAxis);
    PVector yAxis = zAxis.cross(xAxis);
    pos = origin;
    orient.fromFrame(xAxis, yAxis, zAxis);
  }

  void fromTargetAndGuide(PVector target, PVector zDir) {
    //define a pose based on a taget point and a vector defining the z axis of the tool, and an optional guide x axis vector to use for rotational alignment
    PVector xGuide = new PVector(1, 0, 0);//we want our x guide to point along the x axis
    pos = target;
    zDir.normalize();
    PVector yDir = zDir.cross(xGuide);
    PVector xDir = yDir.cross(zDir);
    orient.fromFrame(xDir, yDir, zDir);
  }
  void fromTargetAndGuide(PVector target, PVector zDir, PVector xGuide) {
    //define a pose based on a taget point and a vector defining the z axis of the tool, and an optional guide x axis vector to use for rotational alignment
    pos = target;
    zDir.normalize();
    PVector yDir = zDir.cross(xGuide);
    PVector xDir = yDir.cross(zDir);
    orient.fromFrame(xDir, yDir, zDir);
  }
  
}

//=======================================================================================================================================
////////////////////////////////////////////////////QUATERNION CLASS///////////////////////////////////////////////////////////////////////////
//=======================================================================================================================================

class Quaternion {
  float qW, qX, qY, qZ; //the values of our quaternion

  Quaternion() { //if no values are set at initialization, use the wold xy plane as the default
    qW=1.00000;
    qX=0.00000;
    qY=0.00000;
    qZ=0.00000;
  } 

  Quaternion(float qWIn, float qXIn, float qYIn, float qZIn) { //initialize quaternion with set values
    qW=qWIn;
    qX=qXIn;
    qY=qYIn;
    qZ=qZIn;
  } 

  void set(float qWIn, float qXIn, float qYIn, float qZIn) { //define the values of our quaternion
    qW=qWIn;
    qX=qXIn;
    qY=qYIn;
    qZ=qZIn;
  }

  void fromFrame(PVector xV, PVector yV, PVector zV) {//create a new quaternion given the x,y,z vectors of a target frame
    //unitize these frame vectors
    xV.normalize(); //x axis
    yV.normalize(); //y axis
    zV.normalize(); //z axis

    //using these frame vectors, calculate the quaternion.  Calclation based on information from euclideanspace:
    //http://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToQuaternion/
    float trace, s, w, x, y, z;
    trace = xV.x + yV.y + zV.z;
    if (trace > 0.0) {
      s = 0.5 / sqrt(trace + 1.0);
      w = 0.25 / s;
      x = ( yV.z - zV.y) * s;
      y = ( zV.x - xV.z) * s;
      z = ( xV.y - yV.x) * s;
    } else {
      if (xV.x > yV.y && xV.x > zV.z) {
        s = 2.0 * sqrt(1.0 + xV.x - yV.y - zV.z);
        w = (yV.z - zV.y ) / s;
        x = 0.25 * s;
        y = (yV.x + xV.y ) / s;
        z = (zV.x + xV.z ) / s;
      } else if (yV.y > zV.z) {
        s = 2.0 * sqrt(1.0 + yV.y - xV.x - zV.z);
        w = (zV.x - xV.z) / s;
        x = (yV.x + xV.y) / s;
        y = 0.25 * s;
        z = (zV.y + yV.z ) / s;
      } else {
        s = 2.0 * sqrt(1.0 + zV.z - xV.x - yV.y);
        w = (xV.y - yV.x) / s;
        x = (zV.x + xV.z ) / s;
        y = (zV.y + yV.z ) / s;
        z = 0.25 * s;
      }
    }

    //normalize the found quaternion
    float qLength;
    qLength = 1.0 / sqrt(w * w + x * x + y * y + z * z);
    w *= qLength;
    x *= qLength;
    y *= qLength;
    z *= qLength;
    //set the components of our quaternion
    qW=w;
    qX=x;
    qY=y;
    qZ=z;
  }

  String toOrientString() { //given a quaternion, return a string in square brackets that has been truncated to 6 decimal places
    String orientString = String.format("[%.6f,%.6f,%.6f,%.6f]", qW, qX, qY, qZ);
    return orientString;
  }

  void normalizeQuaternion() {
    //normalizing function
    float qLength = 1.0 / sqrt(qW * qW + qX * qX + qY * qY + qZ * qZ);
    qW *= qLength;
    qX *= qLength;
    qY *= qLength;
    qZ *= qLength;
  }

  PVector[] toMatrix() { //given a quaternion, return a frame/transformation matrix (as an array of three PVectors, X,Y,Z)
    //info from: http://www.euclideanspace.com/maths/geometry/rotations/conversions/quaternionToMatrix/index.htm

    PVector xVector = new PVector();
    PVector yVector = new PVector();
    PVector zVector = new PVector();

    xVector.x = 1 - 2 * qY * qY - 2 * qZ * qZ;
    xVector.y = 2 * qX * qY + 2 * qZ * qW;
    xVector.z = 2 * qX * qZ - 2 * qY * qW;

    yVector.x = 2 * qX * qY - 2 * qZ * qW;
    yVector.y = 1 - 2 * qX * qX - 2 * qZ * qZ;
    yVector.z = 2 * qY * qZ + 2 * qX * qW;

    zVector.x = 2 * qX * qZ + 2 * qY * qW;
    zVector.y = 2 * qY * qZ - 2 * qX * qW;
    zVector.z = 1 - 2 * qX * qX - 2 * qY * qY;


    PVector[] xFormMatrix = new PVector[3];
    xFormMatrix[0] = xVector;
    xFormMatrix[1] = yVector;
    xFormMatrix[2] = zVector;
    return xFormMatrix;
  }

  PVector toAxisAngle() {
    //convert a quaternion to axis angle notation.  based on code from: http://www.euclideanspace.com/maths/geometry/rotations/conversions/quaternionToAngle/
    float aaX = 0;
    float aaY = 0;
    float aaZ = 0; //our axis angles to set
    PVector aa; //the pVector to send
    if (qW > 1) normalizeQuaternion(); // if w>1 acos and sqrt will produce errors, this cant happen if quaternion is normalised
    float angle = 2*acos(qW);
    float s = sqrt(1-qW*qW); // assuming quaternion normalised then w is less than 1, so term always positive.
    if (s < 0.001) { // test to avoid divide by zero, s is always positive due to sqrt
      // if s close to zero then direction of axis not important
      aaX = qX; // if it is important that axis is normalised then replace with x=1; y=z=0;
      aaY = qY;
      aaZ = qZ;
    } else {
      aaX = qX / s; // normalise axis
      aaY = qY / s;
      aaZ = qZ / s;
    }
    aa = new PVector(aaX, aaY, aaZ);
    aa.setMag(angle);
    return(aa);
  }

  void fromAxisAngle(PVector aa) {
    //make a new quaternion from axis angle notation
    //based on code from:  http://www.euclideanspace.com/maths/geometry/rotations/conversions/angleToQuaternion/index.htm
    //our angle is the length of our vector
    float angle = aa.mag();
    aa.normalize();
    //assumes axis is already normalized
    float s = sin(angle/2);
    qX = aa.x * s;
    qY = aa.y * s;
    qZ = aa.z * s;
    qW = cos(angle/2);
  }
}

//=======================================================================================================================================
////////////////////////////////////////////////////TRANSFORMS///////////////////////////////////////////////////////////////////////////
//=======================================================================================================================================

PVector transformPoint(PVector p1, Pose startPose) { 

  //given a point in the coordinate system of a plane, and the Pose of that plane in the world/wobj coordinate system,
  //return the location of that point in the world/wobj coordinate system
  //this function is especially useful if the kinect is mounted to the robot and the tooldata of the robot has been calibrated at the 
  //kinect's origin.  Basically, it tranforms a point in kinect coordinate space to robot coordinate space
  //ensure that your incoming points are right hand rule, i.e. not mirrored across the x axis...
  //information and code on rotations with quaternions can be found here:
  //http://www.euclideanspace.com/maths/algebra/realNormedAlgebra/quaternions/transforms/
  //RYAN LUKE JOHNS // 7 APRIL 2014 // WWW.GSHED.COM

  PVector startPosition = startPose.getPos();
  Quaternion startOrientation = startPose.getOrient();
  PVector p2 = new PVector();  //our tansformed point
  float w = startOrientation.qW; // real part of quaternion
  float x = startOrientation.qX; // imaginary i part of quaternion
  float y = startOrientation.qY; // imaginary j part of quaternion
  float z = startOrientation.qZ; // imaginary k part of quaternion

  //rotate our point

  p2.x = w*w*p1.x + 2*y*w*p1.z - 2*z*w*p1.y + x*x*p1.x + 2*y*x*p1.y + 2*z*x*p1.z - z*z*p1.x - y*y*p1.x;
  p2.y = 2*x*y*p1.x + y*y*p1.y + 2*z*y*p1.z + 2*w*z*p1.x - z*z*p1.y + w*w*p1.y - 2*x*w*p1.z - x*x*p1.y;
  p2.z = 2*x*z*p1.x + 2*y*z*p1.y + z*z*p1.z - 2*w*y*p1.x - y*y*p1.z + 2*w*x*p1.y - x*x*p1.z + w*w*p1.z;

  //translate our point

  p2.x = p2.x + startPosition.x;
  p2.y = p2.y + startPosition.y;
  p2.z = p2.z + startPosition.z;


  return p2;
}

Pose convertWObjCoordToToolCoord(Pose planeToConvert, Pose lastToolData, Pose lastTarget) {
  //given a plane in the world or workobject coordinates, and the current tooldata, and the target that tool was at,
  //return that same plane in the coordinate system of the wrist
  //RYAN LUKE JOHNS // 7 APRIL 2014 // WWW.GSHED.COM
  PVector worldOriginPos = new PVector(0, 0, 0); //define our world/workobject origin
  Quaternion worldOriginQuat = new Quaternion(1, 0, 0, 0); //define our world/workobject origin
  Pose worldOriginPose = new Pose(worldOriginPos, worldOriginQuat); //define our world/workobject origin
  //println(lastToolData.getPos());
  PMatrix3D lastToolMatrix = lastToolData.getMatrix(); //this is the matrix to decide how to get from the base wrist plane to our tooltip plane
  PMatrix3D backToTool0Matrix = new PMatrix3D(); //this is a new empty matrix to describe how to get from our tooltip back to the tool0 plane
  backToTool0Matrix.set(lastToolMatrix);
  backToTool0Matrix.invert(); //this is the matrix to describe how to get from our current tooldata to the tool0 plane

  PMatrix3D lastTargetMatrix = lastTarget.getMatrix(); //the matrix of our target position

  PMatrix3D tool0LocationMatrix = lastTargetMatrix;
  tool0LocationMatrix.apply(backToTool0Matrix); //figure out where our tool0 is in WObj Coords
  //at this point, tool0LocationMatrix describes the transformation that moves the world (WObj) xy plane to the plane of our tool
  Pose tool0LocationPose = new Pose(tool0LocationMatrix); //this is the location of our tool0 in wObj Coords
  PVector tool0Location = tool0LocationPose.getPos();
  Quaternion tool0Orientation = tool0LocationPose.getOrient();
  //println(tool0Location);
  //println(tool0Orientation.qW, tool0Orientation.qX, tool0Orientation.qY, tool0Orientation.qZ);

  //OK, now we know where our tool0 (wrist coordinate plane) is with respect to our workobject coordinate system
  //now, we need to know where a our next target point is with respect to our tool0 plane (to define our next toolData)
  /////////////////////////was called nextTarget
  PMatrix3D nextTooltipMatrix = tool0LocationPose.getMatrix();//this describes how to move from the coordinate system of our tool back to the WObj coordinate system
  nextTooltipMatrix.invert();
  PMatrix3D nextTargetMatrix = planeToConvert.getMatrix();
  nextTooltipMatrix.apply(nextTargetMatrix);
  Pose nextTargetToolData = new Pose(nextTooltipMatrix);
  //PVector nextTargetToolPos = nextTargetToolData.getPos();
  // println("nextTargetToolPos:  " + nextTargetToolPos);
  return nextTargetToolData;
}