//Final coursework A50 for Introduction to Programming BENVGACH, UCL.
//Student code: SN12013268
//The code compare a set of given images and returns a list of closer images.

//--------------------variables
//image closest to london's image. The id works as follows: reduce or original size, method, images sorted from the most to the least similar.
int [][][] closestImages;
//monitors if the closest image has been computed. The id works as follows: reduce or original size, method.
boolean [][] closestImageComputed;
//monitors the current menu and the current image
int currentRank;
int currentMenu = 0;
//monitors if edges have been computed for the images
boolean edgesComputed = false;
//array that sotres the images
aerialImage [] images;
//boolean that monitors if the image has been loaded
boolean imagesLoaded = false;
//boolean that monitors if the size of the images has been checked
boolean imagesSizesChecked = false;
//london image location within the array
int londonImageIndex;
//london image dimensions
int londonImageWidth;
int londonImageHeigth;
//creates an array that stores all menus. 0: main menu, 1: compare reduced images, 2: compare original size image and 3: compare performance of methods
menu [] menu;
//monitors if images has been reduced
boolean reducedImagesComputed = false;
//controls size of reduced images
int reduceWidth = 20;
int reduceHeight = 15;
//controls output text
String output = "";
//current directory
String path;
//monitors if pre-processing has been done
boolean preprocessingReady = false;
//monitors if images are of same size
boolean sameSizeImages = true;
//monitor if stats are ready
boolean statsReady = false;
//array that store time of every method. The id works as follows: reduce or original size, method.
int[][] statsTime;

void setup()
{
  //sets canvas size
  size(960, 600);
  //sets color mode to HSB as it has advantages over RGB for image comparison (Chmelar and Benkrid 2014) and (Schwarz, Cowan, and Beatty 1987)
  colorMode(HSB);
  //creates all menus. 0: main menu, 1: compare reduced images, 2: compare original size image and 3: compare performance of methods
  menu = new menu[4];
  String [][] text = new String[4][4];
  char [] buttonOrientations = {'v', 'h', 'h', 'h'};
  int [] buttonAxis = {width/2, 65, 65, 65};
  int [] buttonOrigin = {200, 80, 80, 110};
  int [] buttonAmount = {4,6,6,2};
  int [] buttonHeight = {50, 50, 50, 50};
  int [] buttonWidth = {300, 145, 145, 200};
  String [][] buttonText = new String[4][6]; 
  text[0][0] = "Final assignment A50: image comparison.\nModule: Introduction to Programming for Architecture and Design, BENVGACH\nStudent number: SN12013268\nDate: 02/01/2018"; 
  text[1][0] = "Reduced image comparison";
  text[1][1] = "Target image";
  text[1][2] = "Comparing image";  
  text[2][0] = "Original size image comparison";
  text[2][1] = "Target image";
  text[2][2] = "Comparing image";  
  text[3][0] = "Performace of methods";
  buttonText[0][0] = "Load images and start pre-processing";
  buttonText[0][1] = "Compare reduced images";
  buttonText[0][2] = "Compare original size images";
  buttonText[0][3] = "Compare performance of methods";
  buttonText[1][0] = "Euclidean distance,\nbrightness";
  buttonText[1][1] = "Euclidean distance,\nbrightness";
  buttonText[1][2] = "Chamfer distance";
  buttonText[1][3] = "Brightness average";
  buttonText[1][4] = "Next image";
  buttonText[1][5] = "Main menu";
  buttonText[2][0] = "Euclidean distance";
  buttonText[2][1] = "Euclidean distance,\nbrightness";
  buttonText[2][2] = "Chamfer distance";
  buttonText[2][3] = "Brightness average";
  buttonText[2][4] = "Next image";
  buttonText[2][5] = "Main menu";
  buttonText[3][0] = "Compare performace";
  buttonText[3][1] = "Main menu";
  for (int i = 0; i < 4; i++)
  {
    menu[i]= new menu(i, buttonAxis[i], buttonOrientations[i], text[i], buttonAmount[i], buttonOrigin[i], buttonText[i], buttonWidth[i], buttonHeight[i]);
  }
  //instantiates array that store time of every method. The id works as follows: reduce or original size, method.
  statsTime = new int[2][4];
}
void draw()
{
  //displayes the current menu
  menu[currentMenu].displayMenu();
}
//--------------------classes
//class that helps the image comparison
class aerialImage
{
  //stores the image
  PImage image;
  //stores the reduced image and the edge image. it is not required for any calculation. It is meant only for debugging.
  PImage reducedImage;
  PImage edgeImage;
  //array of normalized images. The id works as follows: reduce or original size, color attribute (h,s,b), new pixel value. Reduced images only have brightness channel.
  float [][][] normalizedImage;
  //monitors if the image has been normalized
  boolean isNormalized = false;
  //monitors if the images has been reduced
  boolean isReduced = false;
  //array of differential between images. The id works as follows: reduce or original size, color attribute (h,s,b), pixel. Reduced images only have brightness channel.
  float [][][] differential;
  //array of distances. The id works as follows:  reduce or original size, distance (euclidean and others)
  float [][] distance;
  //edges of the image. reduce or original size, pixel. Reduced images only have brightness channel.
  float [][] edges;
  //lenght or arrays
  int originalSizeLength;
  int reduceSizeLength;
  
  //constructor
  aerialImage(PImage image)
  {
    //assigns object variables
    this.image = image;
    originalSizeLength = image.pixels.length;
    //loads images' pixels into its arrays
    image.loadPixels();
    //instantiate arrays
    differential = new float [2][3][image.pixels.length]; 
    distance = new float [2][4];
    //instatiates array that stores the normalized image. The id works as follows:  reduce or original size, color attribute (h,s,b), pixel.
    normalizedImage = new float[2][3][originalSizeLength];
    //instantiates array that stores edges. The id works as follows:  reduce or original size, pixel.
    edges = new float[2][image.pixels.length];
  }
  //compares images 
  void compareImages(int reducedOrOriginal, int method)
  {
    //checks initial time
    int time = millis();
    //channels to compare and length of pixels. Changes depending if the comparison is for the reduced or the original size image
    int colourChannels;
    int lengthOfPixels;
    if (reducedOrOriginal == 0)
    {
      colourChannels = 1;
      lengthOfPixels = reduceSizeLength;
    }
    else 
    {
      colourChannels = 3;
      lengthOfPixels = originalSizeLength;      
    }
    //for every colour attribute and for every pixel calculates the difference between the image and the target image
    for (int i = 0; i < colourChannels; i++)
    {
      for (int j = 0; j < lengthOfPixels; j++)
      {
        differential[reducedOrOriginal][i][j] = normalizedImage[reducedOrOriginal][i][j] - images[londonImageIndex].normalizedImage[reducedOrOriginal][i][j];
      }
    }
    //calculates euclidean distance
    if (method == 0)
    {
      float value = 0;
      for (int i = 0; i < lengthOfPixels; i++)
      {
        if (reducedOrOriginal == 0)
        {
          value = value + pow(differential[reducedOrOriginal][0][i], 2);
        }
        else
        {
          value = value + pow(differential[reducedOrOriginal][0][i], 2) + pow(differential[reducedOrOriginal][1][i], 2) + pow(differential[reducedOrOriginal][2][i], 2);          
        }
      }
      distance[reducedOrOriginal][method] = sqrt(value);
    }
    //calculates euclidean distance only for brightness
    else if (method == 1)
    {
      float value = 0;
      for (int i = 0; i < lengthOfPixels; i++)
      {
        if (reducedOrOriginal == 0)
        {
          value = value + pow(differential[reducedOrOriginal][0][i], 2);
        }
        else
        {
          value = value + pow(differential[reducedOrOriginal][2][i], 2);          
        }
      }
      distance[reducedOrOriginal][method] = sqrt(value);      
    }
    //calculates chaumfer distance
    else if (method == 2)
    {
      //search radius
      int radius;
      //length of pixels
      int imageWidth;
      int imageHeight;
      //sets value to use depending if the comparison is for the reduce or original size image    
      if (reducedOrOriginal == 0)
      {
        imageWidth = reduceWidth;
        imageHeight = reduceHeight;
        radius = 10;
      }
      else 
      {
        imageWidth = londonImageWidth;
        imageHeight = londonImageHeigth;
        radius = 100;
      }      
      //transformes pixels array to matrix for easier manipulation
      float [][] imageValues = new float [imageHeight][imageWidth];
      float [][] londonValues = new float [imageHeight][imageWidth];
      for (int i = 0; i < lengthOfPixels; i++)
      {
        int row = i/imageWidth;
        int column = i%imageWidth;
        imageValues[row][column] = edges[reducedOrOriginal][i];
        londonValues[row][column] = images[londonImageIndex].edges[reducedOrOriginal][i];
      } 
      //creates two values that will defined the final distance
      float totaldistance = 0;
      int count = 0;
      //for every row and every column containing and edge it looks for the closes edge pixel in the target image. if not found it increases the radius up to 100 pixels
      for (int i = 0; i < imageHeight; i++)
      { 
        for (int j = 0; j < imageWidth; j++)
        {
          //if the pixel is an edge
          if (imageValues[i][j] == 1 )
          {
            count = count + 1;
            //for every search radius
            for (int k = 0; k < radius; k++)
            {
              //defines the values of the target image. 
              float xMaxTarget;
              float xMinTarget;
              float yMinTarget;
              float yMaxTarget;
              //check that the target pixel is within the image. In that case it ignores the target value 
              if (i-k < 0)
              {
                yMinTarget = 0;
              }
              else
              {
                yMinTarget = londonValues[i-k][j];
              }
              if (i+k >= imageHeight-1 )
              {
                yMaxTarget = 0;
              }
              else
              {
                yMaxTarget = londonValues[i+k][j];
              }         
              if (j-k < 0 )
              {
                xMinTarget = 0;
              }
              else
              {
                xMinTarget = londonValues[i][j-k];
              }
              if (j+k >= imageWidth-1 )
              {
                xMaxTarget = 0;
              }
              else
              {
                xMaxTarget = londonValues[i][j+k];
              }   
              //increses distance if nothing found
              totaldistance = totaldistance + k;
              //checks if the target pixel is an edge. If yes, continues with the next edge pixel
              if (xMaxTarget == 1 || xMinTarget == 1 || yMaxTarget == 1 || yMinTarget == 1 )
              {
                break;
              }
            }
          }
        }
       //obtains the average distance per edge pixel. Not all images contain the same amount of edges so an average distance is more accurate than an total distance 
       distance[reducedOrOriginal][method] = totaldistance/count; 
      }
    }  
    //calculates brightness average
    else if (method == 3)
    {
      float value = 0;
      float valueLondon = 0;
      for (int i = 0; i < lengthOfPixels; i++)
      {
        value = value + normalizedImage[reducedOrOriginal][reducedOrOriginal*2][i];
      }
      for (int i = 0; i < lengthOfPixels; i++)
      {
        valueLondon = valueLondon + images[londonImageIndex].normalizedImage[reducedOrOriginal][reducedOrOriginal*2][i];
      }
      distance[reducedOrOriginal][method] = sqrt(pow((value/lengthOfPixels) - (valueLondon/lengthOfPixels), 2));
    }
    //checks final time
    statsTime[reducedOrOriginal][method] = millis()-time; 
  }
  //detects edges
  void detectEdges(int reducedOrOriginal)
  {
    //channels to compare and length of pixels
    int brightnessChannel;
    int lengthOfPixels;
    int imageHeight;
    int imageWidth;
    //sets value to use depending if the comparison is for the reduce or original size image        
    if (reducedOrOriginal == 0)
    {
      brightnessChannel = 0;
      lengthOfPixels = reduceSizeLength;
      imageWidth = reduceWidth;
      imageHeight = reduceHeight;
    }
    else
    {
      brightnessChannel = 2;
      lengthOfPixels = originalSizeLength;      
      imageWidth = londonImageWidth;
      imageHeight = londonImageHeigth;
    }
    //creates the reduced image. it is not required for any calculation. It is meant only for debugging.
    edgeImage = createImage(imageWidth, imageHeight, HSB);
    edgeImage.loadPixels();
    //detects edges only for brightness. it ignores borders of the image
    float maxValue = 0;
    for (int i = 0; i < lengthOfPixels ; i++)
    {
      //checks if pixels is in the border of the image. if pixel is in the border, it is declare no edge. edges are difficult to detect on edges due reduce amount of sorrounding pixels
      if (i < imageWidth || i > lengthOfPixels - imageWidth || i % imageWidth == 0 || i % (imageWidth+1) == 0)
      {
        edges[reducedOrOriginal][i] = 0;
        //It is meant only for debugging.
        edgeImage.pixels[i] = color(0,0,100*edges[reducedOrOriginal][i]);
      }
      else 
      {
        float xmin = normalizedImage[reducedOrOriginal][brightnessChannel][i-1];
        float xmax = normalizedImage[reducedOrOriginal][brightnessChannel][i+1];
        float ymin = normalizedImage[reducedOrOriginal][brightnessChannel][i-imageWidth];
        float ymax = normalizedImage[reducedOrOriginal][brightnessChannel][i+imageWidth];      
        float x = normalizedImage[reducedOrOriginal][brightnessChannel][i];
        float dx1 = x-xmin;
        float dx2 = x-xmax;
        float dy1 = x-ymin;
        float dy2 = x-ymax;
        edges[reducedOrOriginal][i] = sqrt(pow(dx1, 2)+pow(dx2, 2)+pow(dy1,2)+pow(dy2,2));
        if (edges[reducedOrOriginal][i] > maxValue)
        {
          maxValue = edges[reducedOrOriginal][i];
        }  
      }
    }
    //coverts values into binary for easier computing. It uses a threshold of 15% of the highest edge value.
    for (int i = 0; i < lengthOfPixels ; i++)
    {
      if(edges[reducedOrOriginal][i]/maxValue > 0.15)
      {
        edges[reducedOrOriginal][i] = 1;
        //It is meant only for debugging.
      }
      else
      {
        edges[reducedOrOriginal][i] = 0;
      }
      edgeImage.pixels[i] = color(0,0,255*edges[reducedOrOriginal][i]);
    }
    edgeImage.updatePixels();
  }
  //normalizes the values of the images using the formula newPixelValue = (pixelValue - min)/(max - min)
  void normalizeImages()
  {
    //for each colour channel
    for (int i = 0; i < 3; i++)
    {
      float max = 0;
      float min = 255;
      //calculates the max and min pixel values
      for (int j = 0; j < image.pixels.length; j++)
      {
        float value = 0;
        if (i == 0) value = hue(image.pixels[j]);
        else if (i == 1) value = saturation(image.pixels[j]);
        else value = brightness(image.pixels[j]);
        if (value > max) max = value;
        if (value < min) min = value;
      }
      //calculates standard value
      for (int j = 0; j < image.pixels.length; j++)
      {
        float value = 0;
        if (i == 0) value = hue(image.pixels[j]);
        else if (i == 1) value = saturation(image.pixels[j]);
        else value = brightness(image.pixels[j]);
        normalizedImage[1][i][j] = (value - min)/(max-min);
      }
    }
    isNormalized = true;
  }
  //reduce dimension of images by averaging pixel values for each neighbourhood. 
  //To keep it simple, the reduce images will only have "brightness" values.
  void reduceDimension(int newWidth, int newHeight)
  { 
    //creates the reduced image. it is not required for any calculation. It is meant only for debugging.
    reducedImage = createImage(newWidth, newHeight, HSB);
    reducedImage.loadPixels();
    //sets array length
    reduceSizeLength = newWidth*newHeight;
    //calculates neighbourhood size
    int neighbourhoodWidth = londonImageWidth/newWidth;
    int neighbourhoodHeight = londonImageHeigth/newHeight;
    //transformes pixels array to matrix for easier manipulation
    float [][] originalValues = new float [londonImageHeigth][londonImageWidth];
    for (int i = 0; i < image.pixels.length; i++)
    {
      int row = i/londonImageWidth;
      int column = i%londonImageWidth;
      originalValues[row][column] = normalizedImage[1][2][i];
    } 
    //creates an array to store average pixel values of each neighbourhood. ID: row, column, values
    float [][] averagePixelValues = new float[newHeight][newWidth];
    for (int i = 0; i < newHeight; i++)
    {
      for (int j = 0; j < newHeight; j++)
      {
        averagePixelValues[i][j] = 0;
      }
    }
    //sums up all pixels for each neighbourhood
    for (int i = 0; i < londonImageHeigth; i++)
    {
      for (int j = 0; j < londonImageWidth; j++)
      {
        averagePixelValues[i/neighbourhoodHeight][j/neighbourhoodWidth] = averagePixelValues[i/neighbourhoodHeight][j/neighbourhoodWidth] + originalValues[i][j];
      }
    }
    //it gets average for each neighbourhood
    for (int i = 0; i < newHeight; i++)
    {
      for (int j = 0; j < newWidth; j++)
      {
        normalizedImage[0][0][(i*newWidth)+j] = averagePixelValues[i][j]/(neighbourhoodWidth*neighbourhoodHeight);
        //only meant for debugging
        reducedImage.pixels[(i*newWidth)+j] = color(0, 0, 100*normalizedImage[0][0][(i*newWidth)+j]);
      }
    }
    reducedImage.updatePixels();
    isReduced = true;
  }
}
//class that builds up buttons
class button
{
  int x;
  int y;
  int buttonWidth;
  int buttonHeight;
  int buttonStrokeWidth;
  int minX;
  int maxX;
  int minY;
  int maxY;
  String text;
  //constructor
  button(int x, int y, int buttonWidth, int buttonHeight, String text)
  {
    this.x = x;
    this.y = y;
    this.buttonWidth = buttonWidth;
    this.buttonHeight = buttonHeight;
    this.minX = x-(buttonWidth/2);
    this.maxX = x+(buttonWidth/2);
    this.minY = y-(buttonHeight/2);
    this.maxY = y+(buttonHeight/2);
    this.text = text;
  }
  //draws button
  void drawButton()
  {
    //sets the stroke width for pressed buttons
    if (mousePressed == true && mouseX > minX && mouseX < maxX && mouseY > minY && mouseY < maxY) 
    {
      buttonStrokeWidth = 3;
    }
    else buttonStrokeWidth = 1;
    pushStyle();
    rectMode(CENTER);
    noFill();
    stroke(255);
    strokeWeight(buttonStrokeWidth);
    rect(x, y, buttonWidth, buttonHeight);
    textAlign(CENTER, CENTER);
    textSize(15);
    text(text, x, y);
    popStyle();
  }
}
//class that builds up menus
class menu
{
  int buttonAmount;
  int buttonAxis;
  char buttonOrientation;
  int buttonOrigin;
  int buttonWidth;
  int buttonHeight;
  String[] buttonText;
  String[] text;
  button [] buttons;
  int id;
  int method;
  //constructor
  menu(int id, int buttonAxis, char buttonOrientation, String[] text, int buttonAmount, int buttonOrigin, String [] buttonText, int buttonWidth, int buttonHeight)
  {
    this.buttonAmount = buttonAmount;
    this.buttonAxis = buttonAxis;
    this.buttonOrientation = buttonOrientation;
    this.buttonOrigin = buttonOrigin;
    this.buttonWidth = buttonWidth;
    this.buttonHeight = buttonHeight;
    this.text = text;
    this.buttons = new button[buttonAmount];
    this.id = id;
    //creates all buttons  
    for (int i = 0; i < buttonAmount; i++)
    {
      int x;
      int y;
      if (buttonOrientation == 'v') 
      {
        x = buttonAxis;
        y = buttonOrigin+(i*(buttonHeight+10));
      }
      else
      {
        x = buttonOrigin+(i*(buttonWidth+10));
        y = buttonAxis;
      }
      buttons[i] = new button(x, y, buttonWidth, buttonHeight, buttonText[i]);
    }
    
  }
  //displayes the menu
  void displayMenu()
  {
    pushStyle();
    background(50);
    //heading
    textAlign(LEFT);
    textSize(20);
    text(text[0], 10, 30);
    //buttons
    for (int i = 0; i < buttonAmount; i++)
    {
      buttons[i].drawButton();
    }
    //displays the images for the respective menu
    if (currentMenu == 1 || currentMenu == 2)
    {
      textSize(15);
      text(text[1], 10, 150);
      text(text[2], 480, 150);
      PImage target = images[londonImageIndex].image.get();
      target.resize(480, 360);
      image(target, 0, 160);
      //shows images if the values for the current method have been computed
      if (closestImageComputed[currentMenu - 1][method] == true)
      {
        int currentImage = closestImages[currentMenu - 1][method][currentRank];
        String distance = String.valueOf(images[currentImage].distance[currentMenu - 1][method]);
        String methodText = "";
        if (method == 0 && currentMenu == 2)
        {
          methodText = "Euclidean distance";
        }
        else if (((method == 0 || method == 1) && currentMenu == 1) || (method == 1 && currentMenu == 2))
        {
          methodText = "Euclidean (b only)";          
        }
        else if (method == 2)
        {
          methodText = "Chamfer distance";              
        }        
        else if (method == 3)
        {
          methodText = "Brightness average";              
        }
        if (currentImage == closestImages[currentMenu - 1][method][0])
        {
          text(", "+methodText+", most similar, d:" + distance, 610, 150);
        }
        else
        {
          text(", "+methodText+", d:" + distance, 610, 150);          
        }
        PImage comparingImage = images[currentImage].image.get();
        comparingImage.resize(480, 360);
        image(comparingImage, 480, 160);
        //only meant for debugging
        //image(images[currentImage].reducedImage, 480, 160);
        //image(images[currentImage].edgeImage, 480, 160);
      }
    }
    //show stats
    if (statsReady == true && currentMenu == 3)
    {
      pushMatrix();
      translate(width/5, 0);
      //for every method
      for (int i = 0; i < 4; i++)
      {
        pushStyle();
        textSize(15);
        textAlign(CENTER, CENTER);
        String [] texts = {"Euclidean distance", "Euclidean (b only)", "Chamfer distance", "Brightness average"};
        text(texts[i], 0, 150);
        //for every size
        int index = -1;
        pushStyle();
        textSize(15);
        for (int j = 0; j < 2; j++)
        { 
          String [] texts2 = {"Reduced", "Original"};
          text(texts2[j], index*50, 170);
          text(statsTime[j][i], index*50, 190);
          pushMatrix();
          translate(0, 20);
          for (int k = 0; k < 10; k++)
          {
            if (i==0 && j==0 && k==0)
            {
              String [] texts3 = {"Time (ms)", "First 10\nmost similar"};
              text(texts3[0],-110, 170);
              text(texts3[1],-110, 210);
            }
            //image closest to london's image. The id works as follows: reduce or original size, method, images sorted from the most to the least similar.
            text(closestImages[j][i][k],index*50, 190);
            translate(0, 20);
          }
          popMatrix();
          index = index*(-1);
        }
        translate(width/5, 0);
        popStyle();
        popStyle();
      }
      popMatrix();
    }
    //output
    textSize(15);
    text("Output:", 10, 570);
    text(output, 10, 585);    
    popStyle();
  }
}
//--------------------functions
//check that all images have the same size
void checkSizes()
{
  //checks that all images have the same width and heigth than the london image
  londonImageWidth = images[londonImageIndex].image.width;
  londonImageHeigth = images[londonImageIndex].image.height;
  for (int i = 0; i < images.length; i++)
  {
    if (images[i].image.width != londonImageWidth || images[i].image.height != londonImageHeigth)
    {
      sameSizeImages = false;
    }
  }
  if (sameSizeImages == false)
  {   
    output ="loaded images are not of the same size";
  }
}
//finds closest image to london after comparison
int[] closestImage(int reducedOrOriginal, int method)
{
  int[] index = new int[images.length - 1];
  ////sorts all images based on distance to the target image. It exludes the target image
  ////for every space in the ranking list
  float previousDistance = 0;
  for (int i = 0; i < images.length - 1; i++)
  {
    float value = 1000000;
    //find smaller distance. It ignores the one already in the ranking
    for (int j = 0; j < images.length; j++)
    {
      //changes winner if it founds an image with smaller distance
      if (images[j].distance[reducedOrOriginal][method] > previousDistance && images[j].distance[reducedOrOriginal][method] < value && j != londonImageIndex)
      {
        value = images[j].distance[reducedOrOriginal][method];
        index[i] = j;
      }
    }
    previousDistance = value;
  }
  return index;
}
//load images
void loadAllImages()
{
  //current directory
  path = sketchPath();
  //list files in the aerial_images folder
  File directory = new File(path+"/Aerial_images");
  File[] files = directory.listFiles();
  //declaring the image array
  images = new aerialImage[files.length];
  //loads all images except for london image
  for (int i = 0; i < files.length; i++)
  {
    images[i] = new aerialImage(loadImage(path+"/Aerial_images/"+files[i].getName()));
    if (files[i].getName().equals("LDN.jpg"))
    {
      londonImageIndex = i;
    }
  }
  //instatiates the arrays that will store the closest images and the array that monitors if the closest images has been computed. the id works as follows: reduce or original size, amount of methods
  closestImages = new int[2][4][files.length];
  closestImageComputed = new boolean[2][4];
  for (int i = 0; i < 2; i++)
  {
    for (int j = 0; j < 4; j++)
    {
      closestImageComputed[i][j] = false;
    }
  }
  //lets the system knows that the images have been loaded
  imagesLoaded = true; 
}
//controls mouse interactions
void mousePressed()
{
  //loops through all buttons of current menu
  for (int i = 0; i < menu[currentMenu].buttons.length; i++)
  {
    //checks if mouse is overlapping button
    if (mouseX > menu[currentMenu].buttons[i].minX && mouseX < menu[currentMenu].buttons[i].maxX && mouseY > menu[currentMenu].buttons[i].minY && mouseY < menu[currentMenu].buttons[i].maxY)
    {
      //load images
      if (currentMenu == 0 && i == 0 && imagesLoaded == false)
      {
        //lets the system knows that the images are being loaded
        output ="Please wait. Images being loaded, checked and normalized.";    
      }
      else if (currentMenu == 1 && (i == 0 || i == 1  || i == 2 || i == 3))
      {
        if(reducedImagesComputed == false)
        {
          output = "Please wait. Images being reduced and compared.";
        }
        else
        {
          output = "Done. Images compared.";
        }
      }
      else if (currentMenu == 2 && (i == 0 || i == 1  || i == 2 || i == 3))
      {
        if(reducedImagesComputed == false)
        {
          output = "Please wait. Images being compared.";
        }
        else
        {
          output = "Done. Images compared.";
        }
      }     
    }
  }
}
void mouseReleased()
{
  //loops through all buttons of current menu
  for (int i = 0; i < menu[currentMenu].buttons.length; i++)
  {
    //checks if mouse is overlapping button
    if (mouseX > menu[currentMenu].buttons[i].minX && mouseX < menu[currentMenu].buttons[i].maxX && mouseY > menu[currentMenu].buttons[i].minY && mouseY < menu[currentMenu].buttons[i].maxY)
    {
      //load images, chech sizes and normalizes images
      if (currentMenu == 0 && i == 0 && imagesLoaded == false)
      {
        //load images
        loadAllImages();
        //check that all images have the same size
        checkSizes();
        if (sameSizeImages == true) 
        {
          //standardizes the values of the images
          for (int j = 0; j < images.length; j++)
          {
            images[j].normalizeImages();
          }
          preprocessingReady = true;
          output ="Done. Images loaded, size checked and normalized";
        }
      }
      //jumps to other menus
      else if (currentMenu == 0 && i != 0)
      {
        if (preprocessingReady == true)
        {
          currentMenu = i;
        }
        else 
        {
          output = "Please load images";
        }
      }
      //starts comparison of images 
      else if ((currentMenu == 1 || currentMenu == 2) && (i == 0 || i == 1  || i == 2 || i == 3))
      {
        //checks if images have been reduced, if not, proceeds to reduce them
        if(currentMenu == 1 && reducedImagesComputed == false)
        {
          //reduces every image
          for (int j = 0; j < images.length; j++)
          {
            images[j].reduceDimension(reduceWidth, reduceHeight);
          }
          reducedImagesComputed = true;
        }
        //check if edges have been computed. If not, proceeds to do so
        if(i == 2 && edgesComputed == false)
        {
          //detects edges for every image
          for (int j = 0; j < images.length; j++)
          {
            images[j].detectEdges(0);
            images[j].detectEdges(1);
          }
          edgesComputed = true;
        }        
        //checks if images have been compared for the particular method and size. if not, it proceeds to compute them
        if (closestImageComputed[currentMenu - 1][i] == false)
        {
          //compares every image
          for (int j = 0; j < images.length; j++)
          {
            images[j].compareImages(currentMenu-1, i);
          }
        }        
        //sets the current method for the current menu
        menu[currentMenu].method = i;
        //finds closest image to london
        closestImages[currentMenu - 1][i] = closestImage(currentMenu - 1, i);
        currentRank = 0;
        closestImageComputed[currentMenu - 1][i] = true;
      }
      //circles around images
      else if ((currentMenu == 1 || currentMenu == 2) && i == 4)
      {
        //resets the counter if the reached the limit of images
        if (currentRank + 1 ==  images.length-1)
        {
          currentRank = 0;
        }
        else
        {
          currentRank = currentRank + 1;
        }
      }
      //shows statisitcs
      else if ((currentMenu == 3) && i == 0)
      {
         //checks if images have been reduced, if not, proceeds to reduce them
        if(reducedImagesComputed == false)
        {
          //reduces every image
          for (int j = 0; j < images.length; j++)
          {
            images[j].reduceDimension(reduceWidth, reduceHeight);
          }
          reducedImagesComputed = true;
        }
        //check if edgeshave been computed. If not, proceeds to do so
        if(edgesComputed == false)
        {
          //detects edges for every image
          for (int j = 0; j < images.length; j++)
          {
            images[j].detectEdges(0);
            images[j].detectEdges(1);
          }
          edgesComputed = true;
        }        
        //checks if images have been compared for all method and size. if not, it proceeds to compute them
        for (int j = 0; j < 2; j++)
        {
          for (int k = 0; k < 4; k++)
          {
            if (closestImageComputed[j][k] == false)
            {
              for (int m = 0; m < images.length; m++)
              {
                images[m].compareImages(j, k);
              }
              closestImages[j][k] = closestImage(j, k);
              closestImageComputed[j][k] = true; 
            }
          }
        }
        statsReady = true;
      }
      //jumps back to main menu
      else if (currentMenu !=0 && i ==  menu[currentMenu].buttons.length - 1)
      {
        currentMenu = 0;
      }      
    }
  }
}