//variables

int buildingN = 4;
int groundLineHeight = 40;
int groundLineColour = 0;
int groundLineFill = 100;
int groundLineThickness = 4;
int buildingLineColour = 0;
int buildingLineWidth = 1;
int[] buildingOrigin = {10, 80, 145, 180};
int[] buildingStoreys = {20, 12, 6, 30};
int[] buildingWidthMeters = {50, 60, 30, 60};
int[] buildingColour = {#f24718, #f2cd5e, 150, #b71616};
int storeyHeight = 3;
int windowSize = 2;
int windowMinimunSpacing = 2;
float windowHeightRatio = 2;
int[] doorSize = {3,3};
int[] treeSize = {5,10};
int treeSpacing = 20;

//pixels per meter
int scale = 4;

//body
void setup(){
  size(1000, 500);
  background(#87ceeb);
  //creates as many buildings as buildingN
  for (int i = 0; i < buildingN; i++) {
    building(buildingOrigin[i], buildingWidthMeters[i], buildingStoreys[i], buildingColour[i]);
  }
  //draws the trees
  trees();
  //draws the ground line
  groundLine();
}

//draws a building
void building(int buildingX, int buildingWidth, int buildingHeight, int colour){
  //converts meters into pixels
  int buildingWidthPix = buildingWidth*scale;
  int buildingHeightPix = buildingHeight*scale*storeyHeight;
  int buildingXPix = buildingX*scale;
  int buildingYPix = height-groundLineHeight-buildingHeightPix;
  int windowSizePix = windowSize*scale;
  int storeyHeightPix = storeyHeight*scale;

  //draws building
  stroke(buildingLineColour);
  strokeWeight(buildingLineWidth);
  fill(colour);
  rectMode(CORNER);
  rect(buildingXPix, buildingYPix, buildingWidthPix, buildingHeightPix);
  
  //adds windows to every storey over the ground level
  for (int i = 0; i < buildingHeight-1; i++) {
    //calculates the amount of required windows but leaving space between them
    float windowN = buildingWidth/(windowSize+windowMinimunSpacing);
    //calculates the space between windows
    float windowSpacingX = buildingWidthPix/(windowN+1);
    float windowSpacingY = storeyHeightPix/windowHeightRatio;
    
    //draws every window per storey
    for (int j = 0; j < windowN; j++) {
        float windowX = buildingXPix+((j+1)*(windowSpacingX));
        float windowY = buildingYPix+(i*storeyHeightPix+windowSpacingY);
    rectMode(CENTER);
    fill(200);
    rect(windowX, windowY, windowSizePix, windowSizePix);
    
    //draws doors at ground level
    float doorX = buildingXPix+buildingWidthPix/2;
    float doorY = height-groundLineHeight-doorSize[1];
    rect(doorX, doorY, doorSize[0]*scale, doorSize[1]*scale);
    }
   }
  //adds doors
  //rect(originX, groundLineHeight-height, width, height);
}

//draws ground line of street profile
void groundLine(){
  fill(groundLineFill);
  noStroke();
  rectMode(CORNER);
  rect(0, height-groundLineHeight, width, groundLineHeight);
  stroke(groundLineColour);
  strokeWeight(groundLineThickness);
  line(0, height-groundLineHeight, width, height-groundLineHeight);
}

//draws trees every 20 meters
void trees(){
  float treeY = height-groundLineHeight-(treeSize[1]*scale);
  float treeN = width/(treeSpacing*scale);
  float treeSpacingX = width/(treeN+1);
  float crownWidhtPix = treeSize[0]*scale;
  float crownHeightPix = (0.66)*(treeSize[1]*scale);
  
  ellipseMode(CORNER);
  for (int i = 0; i < treeN; i++) {
    float treeX = (i+1)*(treeSpacingX);
    fill(0,200,0,100);
    strokeWeight(1);
    ellipse(treeX, treeY, crownWidhtPix, crownHeightPix);
    ellipse(treeX+(1*scale), treeY, crownWidhtPix, crownHeightPix);
    strokeWeight(2);
    line(treeX+crownWidhtPix/2, treeY+1*scale, treeX+crownWidhtPix/2, height-groundLineHeight);
  }
}