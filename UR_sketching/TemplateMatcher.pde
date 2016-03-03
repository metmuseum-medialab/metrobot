// this class is used to implement the matching algorithm.

class TemplateMatcher {

  void TemplateMatcher() { } // constructor is useless - this is kind of a static class but not static so we can use random()
    

  MarkOrientation placeSignature(GoalDrawing goalDrawing, CanvasStatus canvasStatus, Signature thisSignature) {
    println("HEYYYY!");
    
    //return new MarkOrientation(new PVector(APP_WIDTH/2, APP_HEIGHT/2), (random(1)+.5), random(360));


  //PVector getSignatureLocation(PImage cameraPI, PImage goalPI, PImage signaturePI, float scale) {
//    PImage goalImage = goalDrawing.goalImg.copy();
//    PImage canvasImage = canvasStatus.canvasImg.copy();
    return new MarkOrientation(new PVector(vRobotDrawingSpace.x/2, vRobotDrawingSpace.y/2), 1, 0);
//    PImage signatureImage = signaturePI.copy();

/*
    goalImage.resize(int(goalImage.width*scale), 0);
    canvasImage.resize(int(canvasImage.width*scale), 0);
    signatureImage.resize(int(signatureImage.width*scale), 0);


    PImage differenceImg = createImage(goalImg.width, goalImg.height, RGB); //create blank difference image
    differenceImg = getDifferenceImage(goalImage, canvasImage);//GET THE MACRO DIFFERENCE BETWEEN OUR CANVAS AND OUR GOAL IMAGE
    differenceImg.loadPixels();
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
    for (int i = 0; i<loopHeight; i++) { //for EVERY signature sized square in the difference image, compare the signature to this image to see how well we match
      for (int j = 0; j<loopWidth; j++) {
        int movementSum = 0; // Amount of movement in the section
        int goalPixelAverage = 0;
        int cameraPixelAverage = 0;
        boolean darkerThanGoal = false; //is our actual drawing darker than the goal image?  In this case, skip this calculation...
        goalPixelAverage = getAverageColor(goalImage, j, i, sWidth, sHeight);
        cameraPixelAverage = getAverageColor(canvasImage, j, i, sWidth, sHeight);
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
*/

  }

}
