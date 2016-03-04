// this class is used to implement the matching algorithm.

class TemplateMatcher {

  void TemplateMatcher() { } // constructor is useless - this is kind of a static class but not static so we can use random()
    

  MarkOrientation placeSignature(GoalDrawing goalDrawing, CanvasStatus canvasStatus, Signature thisSignature) {

    //return new MarkOrientation(new PVector(int(random(APP_WIDTH)), int(random(APP_HEIGHT))), (random(1)+.5), random(360));
    
    PImage goalImage = goalDrawing.goalImg.copy();
    PImage canvasImage = canvasStatus.canvasImg.copy();
    PImage signatureImage = thisSignature.getPImage().copy();

    // resize images for speedup
    float scaleForCalc = .5;  
    goalImage.resize(int(goalImage.width * scaleForCalc), 0);
    canvasImage.resize(int(canvasImage.width * scaleForCalc), 0);

    float signatureScale = random(0.4, 1.2);
    //float signatureRotation = radians(random(0, 360));
    float signatureRotation = 0; 

    // resize signature..
    //signatureImage.resize(int(signatureImage.width * scaleForCalc * signatureScale), 0);

    /*
    // rotate signature 
    // because we rotate the signature, the scale actually has to change, otherwise we risk cutting off the edges
    int sigScaledSize = int(thisSignature.signatureSize * scaleForCalc * signatureScale * 2);
    PGraphics pg = createGraphics(sigScaledSize, sigScaledSize);
    pg.beginDraw();
    pg.imageMode(CENTER);
    pg.pushMatrix();
    pg.noFill();
    pg.stroke(0);
    pg.strokeWeight(2);
    pg.translate(pg.width / 2, pg.height / 2);
    pg.rotate(signatureRotation);
    pg.image(signatureImage, 0, 0); 
    pg.popMatrix();
    pg.endDraw();
    signatureImage = pg.get().copy(); 


    */
    //println("nowsig = " + signatureImage.width);

    println("original signature size = " + thisSignature.getPImage().width + ", NEW oriented signature size = " + signatureImage.width);

    // generate difference image
    PImage differenceImage = createImage(goalImage.width, goalImage.height, RGB); //create blank difference image
    differenceImage = getDifferenceImage(goalImage, canvasImage);

    differenceImage.loadPixels();
    canvasImage.loadPixels();
    signatureImage.loadPixels();

    int sWidth = signatureImage.width;
    int sHeight = signatureImage.height;
    int loopWidth = goalImage.width - sWidth - 1; //how many steps in our image matching loop
    int loopHeight = goalImage.height - sHeight - 1;//how many steps in our image matching loop

    int recordSum = 2147483640; //store our best sum
    int matchingCoordX = 0; //the location of our best match (i.e. signature location)
    int matchingCoordY = 0;
    int index; //where are we in pixel coordinates when looking through the image

    //for EVERY signature sized square in the difference image, compare the signature to this image to see how well we match
    for (int i = 0; i < loopHeight; i++) { 
      for (int j = 0; j < loopWidth; j++) {

        int movementSum = 0; // Amount of movement in the section
        int goalPixelAverage = 0;
        int canvasPixelAverage = 0;
        boolean darkerThanGoal = false; //is our actual drawing darker than the goal image?  In this case, skip this calculation...
        goalPixelAverage = getAverageColor(goalImage, j, i, sWidth, sHeight);
        canvasPixelAverage = getAverageColor(canvasImage, j, i, sWidth, sHeight);
        if(goalPixelAverage >= canvasPixelAverage){
          //if the goal image is lighter than our canvas image
          movementSum = 2147483640; //set our movement sum as huge...
          darkerThanGoal = true; //set our darker than goal as true
        }
        //goalPixelAverage = goalImage.get(
        if(!darkerThanGoal){
 //         println("not darker than goal!!");
          for (int k = 0; k<sHeight-1; k++) {
            for (int l = 0; l<sWidth-1; l++) {
              //for each pixel in the image, get the difference and add it to the total movement value for this square
              int globalX = j+l;
              int globalY = i+k;
              index = globalX + globalY*goalImage.width;
              color existingColor = differenceImage.pixels[index];
              color signatureColor = signatureImage.pixels[l + k*sWidth];
              //WE ASSUME THE IMAGE IS ALREADY IN BLACK AND WHITE, THUS R,G,B ARE THE SAME
              int currR = (existingColor >> 16) & 0xFF;//get red of color
              int prevR = (signatureColor >> 16) & 0xFF; //get red of color
              int diffR = abs(currR - prevR);
              //int diffR = abs(currR*currR - prevR);
              movementSum +=diffR;
            }//end sampleLoop l
          }//end sampleLoop k
        }

        if (movementSum < recordSum) {
          recordSum = movementSum;
          matchingCoordX = j;
          matchingCoordY = i;
        }
      }
    }

    MarkOrientation newMark = new MarkOrientation(
        new PVector(matchingCoordX / scaleForCalc, matchingCoordY / scaleForCalc),
        signatureScale,
        signatureRotation); //return the location of the signature
    return newMark;

  }


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

  int getAverageColor(PImage theImg, int xPos, int yPos, int xWidth, int yHeight) {
    int pixelCount = xWidth * yHeight;
    PImage theImgSection = theImg.get(xPos, yPos, xWidth, yHeight);
    int redValue = 0;
    for(color p: theImgSection.pixels) {
      redValue += (p >> 16) & 0xFF; // Like red(), but faster
    }
    int theAverage = int(redValue/pixelCount);
    
    return theAverage;
  }

}
