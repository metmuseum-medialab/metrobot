
PImage img1, img2, canvasImg, differenceImg;
int sampleWidth = 70;
int sampleHeight = 70;
//int[] compareFrame;
int loopWidth,loopHeight; //how many positions do we check for matching?
//PVector matchingCoord = new PVector(0,0); //store the location of our matching coordinate
int matchingCoordX = 0;
int matchingCoordY = 0;
int recordSum = 100000000; //store our best sum
int index; //where are we in pixel coordinates when looking through the image
PGraphics doodle; // a pgraphic of our doodle, or "signature", in this example, generated at random


void setup() {
  size(780, 350);
  img1=loadImage("img1.jpg"); //our goal image
  img2=loadImage("img2.jpg"); //a subsample of our goal imge
  
  sampleWidth = img2.width; //set the size of our sampled region
  sampleHeight = img2.height;//set the size of our sampled region
  //===========================CREATE CANVAS (EQUIVALENT TO WEBCAM IMAGE)==
  canvasImg = createImage(img1.width, img1.height, RGB); //create blank image, to be filled in with the webcam image later
  differenceImg = createImage(img1.width, img1.height, RGB); //create blank difference image
  canvasImg.loadPixels();
  for (int i = 0; i < canvasImg.pixels.length; i++) {
    canvasImg.pixels[i] = color(255); //
  }
  canvasImg.updatePixels();
  //===========================END CREATE CANVAS====================
  loopWidth = img1.width - sampleWidth - 1; //how many steps in our image matching loop
  loopHeight = img1.height - sampleHeight - 1;//how many steps in our image matching loop
  
}//
void draw() {
  background(255);
  tint(0, 153, 204, 126); //make the image a little blue so we can tell between the two
  image(img1, 0, 0); //draw the goal image
  noTint();
  //image(canvasImg,0,0);
  img2 = getSampleSig(sampleWidth, sampleHeight);
  img2.loadPixels();
  recordSum = 100000000;
  for(int i = 0; i<loopHeight; i++){
    for(int j = 0; j<loopWidth; j++){
      //int sampleCornerX = j;
      //int sampleCornerY = i;
      //index = j + i*img2.width;
      int movementSum = 0; // Amount of movement in the section
      //println(j,i);
      for(int k = 0; k<sampleHeight-1; k++){
        for(int l = 0; l<sampleWidth-1; l++){
          int globalX = j+l;
          int globalY = i+k;
          index = globalX + globalY*img1.width;
          color existingColor = img1.pixels[index];
          color signatureColor = img2.pixels[l + k*sampleWidth];
          //WE ASSUME THE IMAGE IS ALREADY IN BLACK AND WHITE, THUS R,G,B ARE THE SAME
          int currR = (existingColor >> 16) & 0xFF;//get red of color
          int prevR = (signatureColor >> 16) & 0xFF; //get red of color
          int diffR = abs(currR - prevR);
          movementSum +=diffR;
      }//end sampleLoop l 
      }//end sampleLoop k
      if(movementSum < recordSum){
        recordSum = movementSum;
        matchingCoordX = j;
        matchingCoordY = i;
      }
    }
  }
  println(matchingCoordX,matchingCoordY);
  image(img2,matchingCoordX,matchingCoordY);//position the image at the matching coordinate
  //update our canvas image to contain this little drawing (doesn't have to happen if we're using a webcam)
  for(int i = 0; i<sampleHeight-1; i++){
        for(int j = 0; j<sampleWidth-1; j++){
          int canvasIndex = (matchingCoordX + j) + (matchingCoordY+i)*img1.width;
          int theSampleIndex = j + i*sampleWidth;
          canvasImg.pixels[canvasIndex] = img2.pixels[theSampleIndex];
        }
  }
  canvasImg.updatePixels();
}


//====================FUNCTION FOR GENERATING RANDOM "SIGNATURES"======================
//====================FUNCTION FOR GENERATING RANDOM "SIGNATURES"======================
//====================FUNCTION FOR GENERATING RANDOM "SIGNATURES"======================
PGraphics getSampleSig(int sWidth, int sHeight) {
  //a simple function for drawing an ugly bunch of lines
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
      if(i == 0 || i == vertexCount-1){
      pg.curveVertex(vx, vy);
      }
      pg.curveVertex(vx, vy);
    }
  }
  pg.endShape();
  pg.endDraw();
  return pg;
}