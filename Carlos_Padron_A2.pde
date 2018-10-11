/*
written by Carlos Padrón (padron.ca@gmail.com, carlos.florez.16@ucl.ac.uk)
Second assignment for Introduction to Programming, Mres Spatial Data Science and Visualisation, CASA, UCL.
Description: A multi note step sequencer which can play different notes.
*/
//_________________________________________________________________________________libraries
import processing.sound.*;

//_________________________________________________________________________________global variables
//beats per minute, 120 is roughly similar to moderato. Controls the speed of the playhead.
int bpm = 120;  
//an array that stores the position of the top left corner of control buttons
float [][] buttonPosition = new float [3][2];
//the size of the control button 
int buttonSize = 50;
//an array storing the frequencies. 
float [] frequencies = {783.991, 698.456, 659.255, 587.330, 523.251, 493.883, 440.0};
//amount of horizontal keys. Each key represents a beat.
int keys = 24;
//size of the keys
int keySize = 50;
//margin between the border and the keys and buttons
int margin = 5;
//musical notes
int notes = 7;
//an array that stores the position of the top left corner of every key
float [][][] keyPosition = new float [notes][keys][2];
//the speed of the playhead in pixels. It is associated to the beats per minute.
float pixelPerMillisecond = (keySize*bpm)/60000.0;
//a boolean value that controls the playhead and the music
boolean play = false;
//elapsed time of the music
long playElapsedTime = 0;
//it stores the current position of the playhead
float playheadPos = 0;
//an array that storeys which keys have been selected
boolean [][] selection = new boolean [notes][keys];
//creates an array of sine oscillators
SinOsc[] sine = new SinOsc[notes];
//stores snapshops of the time
long timePoint = 0;

//_________________________________________________________________________________body
void setup() 
{
  size(1210,415);
  //instaties an oscilator for each note
  for (int i = 0; i < notes; i++)
  {
    sine[i] = new SinOsc(this);
    //sets volume to 0
    sine[i].amp(0);
    //sets frequency
    sine[i].freq(frequencies[i]);
    //start oscillators
    sine[i].play();
  }
  //default song, twinkle, twinkle little star
  selection[6][0] = true;
  selection[2][0] = true;
  selection[4][0] = true;
  selection[4][1] = true;  
  selection[6][1] = true;
  selection[2][2] = true;
  selection[2][3] = true;
  selection[1][4] = true;
  selection[3][4] = true;
  selection[6][4] = true;
  selection[1][5] = true;
  selection[3][5] = true;
  selection[6][5] = true;
  selection[2][6] = true;
  selection[3][8] = true;
  selection[3][9] = true;
  selection[4][10] = true;
  selection[6][10] = true;
  selection[4][11] = true;
  selection[6][11] = true;
  selection[5][12] = true;
  selection[5][13] = true;
  selection[6][14] = true;
  selection[6][15] = true;
  selection[2][16] = true;
  selection[4][16] = true;
  selection[2][17] = true;
  selection[4][17] = true;
  selection[3][18] = true;
  selection[3][19] = true;
  selection[4][20] = true;
  selection[6][20] = true;
  selection[4][21] = true;
  selection[6][21] = true;
  selection[5][22] = true;
} 
void draw()
{
  background(255);
  controls();
  keyboard();
  playhead();
  play();
}
//_________________________________________________________________________________functions
//draw three buttons (play, stop, reset) on a portion of the screen.
void controls()
{
  //translates origin to the portion of the screen where the buttons go
  pushMatrix();
  translate(0, height - buttonSize - margin);
  rectMode(CORNER);
  
  //it creates three rectangles and its logos. all the rectangles are separated by the margin
  for (int i = 0; i < 3; i++)
  {
    translate(margin, 0);
    int x = 0;
    int y = 0;
    //it stores the screen value of the corners of the buttons for external reference
    buttonPosition[i][0] = screenX(x, y);
    buttonPosition[i][1] = screenY(x, y);    
    //controls the colour of the buttons depending if they are pressed or not
    if (mousePressed == true && mouseX >= buttonPosition[0][0] && mouseX <= buttonPosition[0][0] + buttonSize && mouseY >= buttonPosition[0][1] && mouseY <= buttonPosition[0][1] + buttonSize && i == 0)
    {
      fill(150);  
    }
    else if (mousePressed == true && mouseX >= buttonPosition[1][0] && mouseX <= buttonPosition[1][0] + buttonSize && mouseY >= buttonPosition[1][1] && mouseY <= buttonPosition[1][1] + buttonSize && i == 1)
    {
       fill(150);  
    }
    else if (mousePressed == true && mouseX >= buttonPosition[2][0] && mouseX <= buttonPosition[2][0] + buttonSize && mouseY >= buttonPosition[2][1] && mouseY <= buttonPosition[2][1] + buttonSize && i == 2)
    {
       fill(150);  
    }
    else
    {
      fill(255);
    }
    //draws the rectangle of the button
    rect(x, y, buttonSize, buttonSize);
    //draws play button logo
    if (i == 0)
    {
      if (play == true) 
      {
        fill(255,0,0);  
      }
      else
      {
        fill(255);
      }
      triangle(buttonSize/10, buttonSize/10, buttonSize - (buttonSize/10), buttonSize/2, buttonSize/10, buttonSize - (buttonSize/10));
    }
    //draws stop button logo
    else if (i == 1)
    {
      if (play == false) 
      {
        fill(255,0,0);  
      }
      else
      {
        fill(255);
      }
      rect(buttonSize/10, buttonSize/10, buttonSize - 2*(buttonSize/10), buttonSize - 2*(buttonSize/10));
    }
    //draws reset button logo
    else
    {
      triangle(buttonSize - (buttonSize/10), buttonSize/10, buttonSize - (buttonSize/10), buttonSize - (buttonSize/10), buttonSize/2, buttonSize/2);
      triangle(buttonSize/2, buttonSize/10, buttonSize/2, buttonSize - (buttonSize/10), buttonSize/10, buttonSize/2);
    }
    //moves to next button position
    translate(buttonSize, 0);
  }
  popMatrix();
  fill(255);
}

//draws a 5 notes keyboard
void keyboard() 
{
  pushMatrix();
  translate(margin, margin);
  //fit creates a rectangle for every note and key.
  for (int i = 0; i < notes; i++)
  {
    pushMatrix();
    for (int j = 0; j < keys; j++)
    {
      keyPosition[i][j][0] = screenX(0, 0);
      keyPosition[i][j][1] = screenY(0, 0);
      //controls the colour of the key if it is selected or not
      if (selection[i][j] == true)
      {
        fill(0,0,255);
      }
      else
      {
        fill(255);
      }
      rect(0, 0, keySize, keySize);
      translate(keySize, 0);
      fill(255);
    }
    popMatrix();
    translate(0, keySize);
  }
  popMatrix();
}
//plays the sine in the right moment
void play()
{
  float keyPerMillisecond = bpm/60000.0;
  int currentKey = (int)((playElapsedTime+1)*keyPerMillisecond);
  int currentKeyKeyboard = currentKey%keys;
  //plays the notes in the current beat. 
  for (int i = 0; i < notes; i++)
  {
    if (selection[i][currentKeyKeyboard] == true && play == true)
    {
      sine[i].amp(0.25);
    }
    else
    {
      sine[i].amp(0.0);
    }
  }
}
//draws playhead
void playhead()
{
  //runs a playhead only if play is true. The speed is controlled by bpm or beats per minute. It also records the time spent on playing the music excluding pause time.    
  if (play == true)
  {
    long elapsedTime = millis() - timePoint;
    playElapsedTime = playElapsedTime + elapsedTime;
    float currentPixel = (playElapsedTime+1)*pixelPerMillisecond;
    timePoint = millis();
    playheadPos = currentPixel%(keySize*keys);
    pushMatrix();
    translate(margin, margin);
    stroke(255,0,0);
    line(playheadPos, 0, playheadPos, keySize*notes);
    stroke(0);
    popMatrix();
  }
  //pauses playhead if play is false.
  else if (play == false)
  {
    pushMatrix();
    translate(margin, margin);
    stroke(255,0,0);
    line(playheadPos, 0, playheadPos, keySize*notes);
    stroke(0);
    popMatrix();
  }
  
}
//controls what happens when the user presses on the screen
void mousePressed()
{
  //it plays the music and the playhead if the user clicks on the play button
  if (mouseX >= buttonPosition[0][0] && mouseX <= buttonPosition[0][0] + buttonSize && mouseY >= buttonPosition[0][1] && mouseY <= buttonPosition[0][1] + buttonSize && play == false)
  {
    timePoint = millis();
    play = true;
  }
  //it stops the music and the playhead if the user clicks on the stop/pause button
  else if (mouseX >= buttonPosition[1][0] && mouseX <= buttonPosition[1][0] + buttonSize && mouseY >= buttonPosition[1][1] && mouseY <= buttonPosition[1][1] + buttonSize && play == true)
  {
    play = false;
  }
  //it resets the music and the playhead if the user clicks on the rewind/reset button
  else if (mouseX >= buttonPosition[2][0] && mouseX <= buttonPosition[2][0] + buttonSize && mouseY >= buttonPosition[2][1] && mouseY <= buttonPosition[2][1] + buttonSize)
  {
    playElapsedTime = 0;
    playheadPos = 0;
  }
  for (int i = 0; i < notes; i++)
  {
    for (int j = 0; j < keys; j++)
    {
      if (mouseX >= keyPosition[i][j][0] && mouseX <= keyPosition[i][j][0] + keySize && mouseY >= keyPosition[i][j][1] && mouseY <= keyPosition[i][j][1] + keySize)
      {
        if (selection[i][j] == false)
        {
          selection[i][j] = true;
        }
        else if (selection[i][j] == true)
        {
          selection[i][j] = false;      
        }
      }
    }
  }
}