PImage goalImg, sigImg, canvasImg;
int signatureWidth = 60;
int signatureHeight = 30;
PVector signatureLocation = new PVector(0, 0); //store the location of our matching coordinate
float scaleForCalculations = .5;  //our image processing is really slow, so we have the option to speed it up by scaling the image down, sampling, and then scaling back up...
//set to one for no scaling...only really necessary if goal image is much greater than 500 px square...
//this also wants to be a number that is evenly divisible into the signature size and the goalimage/cameraimage size...


void setup() {
  size(800, 800); //this should match the size of the goal image, which should also match the size of the robot coordinate space in mm...
  goalImg=loadImage("pollock_800.jpg"); //our goal image
  sigImg = createImage(signatureWidth, signatureHeight, RGB);

  //===========================CREATE CANVAS (EQUIVALENT TO WEBCAM IMAGE)====================================
  //the canvas here is where we draw the signatures to a virtual image because we don't yet have a webcam and a robot connected...
  //we are simulating the webcam image by updating this PImge
  //all this stuff gets deleted if we have a webcam...canvas image becomes the webcam image
  canvasImg = createImage(goalImg.width, goalImg.height, RGB); //create blank image, to be filled in with the webcam image later
  canvasImg.loadPixels(); //load the empty pixel array
  for (int i = 0; i < canvasImg.pixels.length; i++) {
    canvasImg.pixels[i] = color(255); //make every pixel white
  }
  canvasImg.updatePixels(); //update the imge
  //===========================END CREATE CANVAS==============================================================
}//END SETUP


void draw() {
  background(255);
  //tint(0, 153, 204, 126); //make the image a little blue so we can tell between the two
  if (frameCount%30 != 0) {
  image(goalImg, 0, 0); //draw the goal image
  }
  //image(differenceImg,0,0);
  noTint();
  tint(240, 240, 240, 200);
  image(canvasImg, 0, 0);
  noTint();

  ////////get the location of our signature//////////////
  sigImg = getSampleSig(signatureWidth, signatureHeight);
  signatureLocation = getSignatureLocation(canvasImg, goalImg, sigImg, scaleForCalculations);
  image(sigImg, int(signatureLocation.x), int(signatureLocation.y));//position the image at the matching coordinate
  ////////end get the location of our signature//////////


  ////////this is where we would send the signature//////////////
  //send signature with corner location "signatureLocation"
  ////////end this is where we would send the signature//////////////

  println(signatureLocation.x + " : " + signatureLocation.y);

  //===============UPDATE CANVAS IMAGE (DELETE IF USING WEBCAM)==================================================
  //update our canvas image to contain this little drawing (all of this doesn't have to happen if we're using a webcam)
  //
  PGraphics canvasGraphics = createGraphics(goalImg.width, goalImg.height);
  canvasGraphics.beginDraw();
  canvasGraphics.image(canvasImg, 0, 0);
  canvasGraphics.endDraw();

  canvasImg.blend(sigImg, 
    0, 0, signatureWidth, signatureHeight, 
    int(signatureLocation.x), int(signatureLocation.y), signatureWidth, signatureHeight,
    BLEND);

  if (frameCount%30 == 0) {
    saveFrame("BR3-#####.jpg");
  }
  //==============END UPDATE CANVAS (DELETE IF USING WEBCAM)====================================================
} //END DRAW





//====================FUNCTION FOR GETTING SIGNATURE LOCATION======================
//====================FUNCTION FOR GETTING SIGNATURE LOCATION======================
//====================FUNCTION FOR GETTING SIGNATURE LOCATION======================
PVector getSignatureLocation(PImage cameraPI, PImage goalPI, PImage signaturePI, float scale) {
  PImage goalImage = goalPI.copy();
  PImage cameraImage = cameraPI.copy();
  PImage signatureImage = signaturePI.copy();


  goalImage.resize(int(goalImage.width*scale), 0);
  cameraImage.resize(int(cameraImage.width*scale), 0);
  signatureImage.resize(int(signatureImage.width*scale), 0);


  PImage differenceImg = createImage(goalImg.width, goalImg.height, RGB); //create blank difference image
  differenceImg = getDifferenceImage(goalImage, cameraImage);//GET THE MACRO DIFFERENCE BETWEEN OUR CANVAS AND OUR GOAL IMAGE
  differenceImg.loadPixels();
  cameraImage.loadPixels();
  signatureImage.loadPixels();
  int sWidth = signatureImage.width;
  int sHeight = signatureImage.height;
  int loopWidth = goalImage.width - sWidth - 1; //how many steps in our image matching loop
  int loopHeight = goalImage.height - sHeight - 1;//how many steps in our image matching loop
  int recordSum = 2147483640; //store our best sum
  int matchingCoordX = 0; //the location of our best match (i.e. signature location)
  int matchingCoordY = 0;
  int index; //where are we in pixel coordinates when looking through the image
  for (int i = 0; i<loopHeight; i++) { //for EVERY signature sized square in the difference image, compare the signature to this image to see how well we match
    for (int j = 0; j<loopWidth; j++) {
      int movementSum = 0; // Amount of movement in the section
      int goalPixelAverage = 0;
      int cameraPixelAverage = 0;
      boolean darkerThanGoal = false; //is our actual drawing darker than the goal image?  In this case, skip this calculation...
      goalPixelAverage = getAverageColor(goalImage, j, i, sWidth, sHeight);
      cameraPixelAverage = getAverageColor(cameraImage, j, i, sWidth, sHeight);
      if(goalPixelAverage >= cameraPixelAverage){
        //if the goal image is lighter than our camera image
        movementSum = 2147483640; //set our movement sum as huge...
        darkerThanGoal = true; //set our darker than goal as true
      }
      //goalPixelAverage = goalImage.get(
      if(!darkerThanGoal){
      for (int k = 0; k<sHeight-1; k++) {
        for (int l = 0; l<sWidth-1; l++) {
          //for each pixel in the image, get the difference and add it to the total movement value for this square
          int globalX = j+l;
          int globalY = i+k;
          index = globalX + globalY*goalImage.width;
          color existingColor = differenceImg.pixels[index];
          color signatureColor = signatureImage.pixels[l + k*sWidth];
          //WE ASSUME THE IMAGE IS ALREADY IN BLACK AND WHITE, THUS R,G,B ARE THE SAME
          int currR = (existingColor >> 16) & 0xFF;//get red of color
          int prevR = (signatureColor >> 16) & 0xFF; //get red of color
          int diffR = abs(currR - prevR);
          //int diffR = abs(currR*currR - prevR);
          movementSum +=diffR;
        }//end sampleLoop l
      }//end sampleLoop k
      }//end if not darker than goal

      

      if (movementSum < recordSum) {
        recordSum = movementSum;
        matchingCoordX = j;
        matchingCoordY = i;
      }
    }
  }
  float rescaleMultiplier = 1.0/scale; //rescale our location if we've scaled the image down for performance
  PVector sigLocation = new PVector(matchingCoordX*rescaleMultiplier, matchingCoordY*rescaleMultiplier); //return the location of the signature
  return sigLocation;
}
//====================FUNCTION FOR GENERATING RANDOM "SIGNATURES"======================
//====================FUNCTION FOR GENERATING RANDOM "SIGNATURES"======================
//====================FUNCTION FOR GENERATING RANDOM "SIGNATURES"======================
PImage getSampleSig(int sWidth, int sHeight) {
  //a simple function for drawing an ugly bunch of lines, returns a PImage
  PGraphics pg = createGraphics(sWidth, sHeight);
  pg.beginDraw();
  //pg.background(255);
  pg.noFill();
  pg.stroke(0);
  pg.strokeWeight(2);
  int vertexCount = int(random(2, 14));
  pg.beginShape();
  if (random(1)<.6) {
    for (int i = 0; i< vertexCount - 1; i++) {
      pg.vertex(random(sWidth), random(sHeight));
    }
  } else {
    for (int i = 0; i< vertexCount - 1; i++) {
      int vx = int(random(sWidth));
      int vy = int(random(sHeight));
      if (i == 0 || i == vertexCount-1) {
        pg.curveVertex(vx, vy);
      }
      pg.curveVertex(vx, vy);
    }
  }
  pg.endShape();
  pg.endDraw();
  return pg.get();
}
//====================FUNCTION FOR RETURNING DIFFERENCE IMAGE BETWEEN TWO IMAGES======================
//====================FUNCTION FOR RETURNING DIFFERENCE IMAGE BETWEEN TWO IMAGES======================
//====================FUNCTION FOR RETURNING DIFFERENCE IMAGE BETWEEN TWO IMAGES======================
PImage getDifferenceImage(PImage image1, PImage image2) {
  //returns the difference image from two images that are the same size, and black and white
  //in this case, image2 is our "canvas image"
  PImage theDifferenceImage = createImage(image1.width, image1.height, RGB);
  image1.loadPixels();
  image2.loadPixels();
  int pixelCount = image1.width * image1.height;
  for (int i = 0; i < pixelCount; i++) { // For each pixel in the video frame...
    color img1Color = image1.pixels[i];
    color img2Color = image2.pixels[i];
    // Extract the red
    int img1R = (img1Color >> 16) & 0xFF; // Like red(), but faster
    // Extract red
    int img2R = (img2Color >> 16) & 0xFF;
    // Compute the difference of the red
    int diffR = 0;
    //if the canvas image is darker than it should be, we want to make it pure white to avoid having more stuff drawn on it...
    if ((img1R - img2R)<0) { //canvas is brighter than the goal image, we want drawing to happen here
      diffR = 255 - abs(img1R - img2R);//this function is relly iportnt to tweak...
      //diffR  = img1R; //this would just return the actual color, not prioritizing areas that are MORE light than the canvas
    } else if ((img1R-img2R)>=0) {  //canvas is darker than or equal to the goal image, we don't want drawing here, so make it white
      diffR = 255;
    }
    // Add these differences to the running tally
    // Render the difference image to the screen
    theDifferenceImage.pixels[i] = color(diffR, diffR, diffR);
    // The following line is much faster, but more confusing to read
    //pixels[i] = 0xff000000 | (diffR << 16) | (diffG << 8) | diffB;
    // Save the current color into the 'previous' buffer
  }
  theDifferenceImage.updatePixels();
  return theDifferenceImage;
}

//====================FUNCTION FOR GETTING THE COLOR (greyscale) OF A SUBSAMPLE OF A greyscale IMAGE======================
int getAverageColor(PImage theImg, int xPos, int yPos, int xWidth, int yHeight) {
  int redValue = 0;
  int pixelCount = xWidth*yHeight;
  PImage theImgSection = theImg.get(xPos, yPos, xWidth, yHeight);
  for (int i = 0; i<yHeight - 1; i++) {
    for (int j = 0; j<xWidth - 1; j++) {
      int theRed = theImg.pixels[j + i*xWidth];
      redValue+=theRed;
    }
  }
  int theAverage = int(redValue/pixelCount);
  
  return theAverage;
}
