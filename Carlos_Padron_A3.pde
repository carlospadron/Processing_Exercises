/* 
third assignment for Introduction to Programming. Mres Spatial Data Science, CASA, UCL.
written by Carlos Padrón. carlos.florez.16@ucl.ac.uk; padron.ca@gmail.com
*/

//___________________________________________________________global variables
//range of possible angles for new position (measured in radians)
float angleRange = PI/6;
//size of the board
int boardLimit = 600;
//camera horizontal distance from avatar
int cameraDistance = 50;
//camera mode (first person = 1  or hovering = 0)
int cameraMode = 0;
//amount of snowmen allowed 
int snowmenLimit = 100;
//maximun speed of agents (units per frame). The avatar is allowed to go up to ten times faster.
float speedLimit = 1;
//amount of trees allowed 
int treeLimit = 200;
//amount of agents (it includes the avatar)
int agentLimit = snowmenLimit + treeLimit + 1;
//array to store agents
agent[] agents = new agent[agentLimit]; 

//___________________________________________________________body
void setup() 
{
  size(1024, 600, P3D);
  //avatar or user
  agents[0] = new agent(2);
  //generates trees in random locations
  for (int i = 1; i < treeLimit+1; i++)
  {
    agents[i] = new agent(0);
  }
  //generates snowmen in random locations
  for (int i = treeLimit+1; i < agentLimit; i++)
  {
    agents[i] = new agent(1);
  }
  //assigns position
  for (int i = 0; i < agentLimit; i++)
  {
    agents[i].firstPosition();
  }
}
void draw()
{
  //resets background
  background(200);
  //draws a grid over the floor
  grid();
  //draw trees, snowmen and avatar
  for (int i = 0; i < agentLimit; i++)
  {
    agents[i].update();
  }
  //set lights

  lights();

  //write instructions
  pushStyle();
  pushMatrix();
  textMode(SHAPE);
  textSize(3);
  fill(0);
  textAlign(CENTER);
  translate(agents[0].x, agents[0].y, 0);
  rotate(agents[0].direction+PI/2);
  text("Use mouse to change direction", 0, 4, 0);
  text("Use UP arrowto move", 0, 7, 0);
  text("Use + or - to change speed", 0, 10, 0);
  text("Use * to change view mode", 0, 13, 0);
  text("Use 0 to save images", 0, 16, 0);
  popMatrix();
  popStyle();
  //sets camera
  cam();
}

//___________________________________________________________functions
//sets camera
void cam()
{
  //hovering camera
  if (cameraMode == 0)
  {
    //calculates the position of the camera based on avatar position and direction. 
    float opposeDirection = agents[0].direction-PI;
    PVector v1 = PVector.fromAngle(opposeDirection);
    v1.setMag(cameraDistance);
    PVector v2 = new PVector(agents[0].x, agents[0].y);
    PVector cameraPos2D = v1.add(v2);
    //set camera
    perspective(PI/3.0, width/height, cameraDistance/10.0, cameraDistance*10.0);
    camera(cameraPos2D.x, cameraPos2D.y, cameraDistance, agents[0].x, agents[0].y, 20, 0, 0, -1);
  }
  //first person view
  else
  {
    //calculates the position of the camera based on avatar position and direction. 
    PVector v1 = PVector.fromAngle(agents[0].direction);
    v1.setMag(cameraDistance);
    PVector v2 = new PVector(agents[0].x, agents[0].y);
    PVector cameraPos2D = v1.add(v2);
    PVector v3 = PVector.fromAngle(agents[0].direction);
    v3.setMag(cameraDistance);
    PVector cameraFocus = v2.add(v3);
    //set camera
    perspective(PI/3.0, width/height, 1, 500);
    camera(agents[0].x, agents[0].y, 1.9, cameraPos2D.x, cameraPos2D.y, 1.9, 0, 0, -1);
  }
}
//draws a grid over the floor spaced 50 meters in each direction
void grid()
{
  //horizontal lines
  pushStyle();
  pushMatrix();
  stroke(125);
  for (int i = 0; i <= boardLimit/50; i++)
  {
    line(0,0,0, boardLimit, 0, 0);
    translate(0, 50, 0);
  }
  popMatrix();
  //vertical lines
  pushMatrix();
  for (int i = 0; i <= boardLimit/50; i++)
  {
    line(0,0,0, 0, boardLimit, 0);
    translate(50, 0, 0);
  }
  popMatrix();
  popStyle();
}
////moves avatar
void keyPressed() 
{
  //makes the avatar move forward
  if (key == CODED) 
  {
    if (keyCode == UP ) 
    {
      agents[0].move = true;
    }
  }
  //increases speed. only works if the avatar is moving
  else if (key == '+')
  {
    float newSpeed = agents[0].speed + 1;
    if (newSpeed > speedLimit*10)
    {
      agents[0].speed = speedLimit*10;
    }
    else 
    {
      agents[0].speed = newSpeed;
    }
  }
  //reduces speed. only works if the avatar is moving
  else if (key == '-')
  {
    float newSpeed = agents[0].speed - 1;
    if (newSpeed < 0)
    {
      agents[0].speed = 0;
    }
    else 
    {
      agents[0].speed = newSpeed;
    }
  }
  //changes camera
  else if (key == '*')
  {
    if (cameraMode == 0)
    {
      cameraMode = 1;
    }
    else 
    {
      cameraMode = 0;
    }
  }
  else if (key == '0') 
  {
    saveFrame("images/image.png");
  }
}
//saves images
void keyReleased() 
{
  if (key == CODED) 
  {
    if (keyCode == UP ) 
    {
      agents[0].move = false;
    }
  }
}
////___________________________________________________________classes
class agent
{
  //type of the agent. 0 for tree, 1 for snowmen, 2 for avatar
  int type;
  // x position
  float x;
  //y position
  float y;
  //speed
  float speed;
  //direction
  float direction;
  //trigger that controls if the avatar moves or not
  boolean move = false;
  
  //contructor
  agent(int type)
  {
    //assigns attributes
    this.type = type;
    //defines attributes for trees
    if (type == 0) 
    {
      speed = 0;
      direction = 0;
    }
    //defines attributes for agents
    else if (type == 1)
    {
      speed = random(speedLimit);
      direction = random(PI);
    }
    //defines attributes for avatar
    else 
    {
      speed = speedLimit;
      direction = random(PI);
    }
  }
  //checks if position is free in the map
  boolean positionTaken(float x, float y)
  {
    for (int i = 0; i < agentLimit; i++)
    {
      //checks map for x and y. if x or y is taken or position out of board, return 1
      if ((x > boardLimit) || (y > boardLimit) || (x < 0.0) || (y < 0.0) || (agents[i].x == x) && (agents[i].y == y))
      {
        return true;
      }
    }
    return false;
  }
  //sets position
  void firstPosition() 
  {
    float newX = random(boardLimit);
    float newY = random(boardLimit);
    //sets original position. checks that new proposals are not already taken
    while (positionTaken(newX, y))
    {
      newX = random(boardLimit);
      newY = random(boardLimit);
    }   
    x = newX;
    y = newY;
  }
  void newPosition()
  {
    //sets new position to snowmen
    if (type == 1)
    {
      //sets a new direction slightly different than the previous to produce a more natural movement
      direction = direction + random(-angleRange/2, angleRange/2);
      //calculates the new position based on current position, new direction and speed
      PVector v1 = PVector.fromAngle(direction);
      v1.setMag(speed);
      PVector v2 = new PVector(x, y);
      PVector newPos = v1.add(v2);
      //tests if new position is taken. If true, the agent turns around
      if (positionTaken(newPos.x, newPos.y))
      {
        direction = direction + PI;
      }
      else
      {
        //assigns new position and updates map
        x = newPos.x;
        y = newPos.y;
      }
    }  
    //sets new position to avatar
    else if (move == true)
    {
      
      //calculates the new position based on current position, new direction and speed
      PVector v1 = PVector.fromAngle(direction);
      v1.setMag(speed);
      PVector v2 = new PVector(x, y);
      PVector newPos = v1.add(v2);
      //tests if new position is taken. 
      if (positionTaken(newPos.x, newPos.y) == false)
      {
        //assigns new position and updates map
        x = newPos.x;
        y = newPos.y;
      }
    }   
  }
  void update() 
  {
    pushMatrix();
    translate(x, y, 0);
    //draws a tree
    if (type == 0) 
    {
      pushStyle();
      noStroke();
      fill(#75580f);
      box(0.3, 0.3, 3.0);
      translate(0, 0, 3.0);
      fill(#219931);
      sphere(3);
      popStyle();
    }
    //draws a snowman
    else if (type == 1)
    {
      newPosition();
      pushStyle();
      noStroke();
      fill(#e8eef2);
      translate(0, 0, 0.5);
      sphere(1);
      translate(0, 0, 1);
      sphere(0.6);
      translate(0, 0, 0.6);
      sphere(0.3);
      popStyle();
    }
    //draws a blue snowman that serves as avatar
    else 
    {
      //obtains direction from mouse
      direction = (mouseX/(64*PI));  
      newPosition();
      pushStyle();
      noStroke();
      fill(#5ec3ff);
      translate(0, 0, 0.5);
      sphere(1);
      translate(0, 0, 1);
      sphere(0.6);
      translate(0, 0, 0.6);
      sphere(0.3);
      popStyle();
    }   
    popMatrix();
  }
} 