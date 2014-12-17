import processing.serial.*;

Serial myPort;        
boolean debug = true;
float inString;
float inFloat0, inFloat1;
float[] list = new float[0];
float[] etlist = new float[0];
PFont f1, f2, f3, f4, f5, f6;
int index;
float rank;
float percentage;
int trapDistance = 1000;
int SgraphH = 38; //Speed graph scale
int ETgraphH = 1500000; //ET graph scale
int valueX = 0;
int valueY = 0;
boolean graph30 = false, graph690 = false, secondValue = false;
color c1, c2, c3 = color(220, 0, 0), c4 = color(220, 0, 0), c5 = color(220, 0, 0);
int boxX = 295, boxY = 430, boxSize = 15; //Graph 30 box
int totalLength = 12000;
float averageSpeed;

void setup () {
  size(1280, 700);
  index = 0;

  //Load list from textfile
  String loadlist[] = loadStrings("list.txt");
  for (int i = 0; i < loadlist.length; i++) {
    String[] split = split(loadlist[i], ',');
    list = append(list, float(split[0]));
    etlist = append(etlist, float(split[1]));
    index++;
  }  

  if (debug = false) {
    println(Serial.list());
    myPort = new Serial(this, Serial.list()[1], 9600);
    myPort.bufferUntil('\n');
  }

  //Create fonts
  f1 = createFont("Arial Unicode MS", 20);
  f2 = createFont("Arial Unicode MS", 240);
  f3 = createFont("Arial Unicode MS", 35);
  f4 = createFont("Arial Unicode MS", 15);
  f5 = createFont("Arial Unicode MS", 15);
  f6 = createFont("Arial Unicode MS", 12);

  //Run sub routines
  create();
  buttonCheck();
  graph();
}

void draw () {
  //  stroke(225);
  //  fill(225);
  //  rectMode(CORNER);
  //  rect(0, 0, 500, 20);
  //  fill(0);
  //  text(mouseX, 20, 20);
  //  text(mouseY, 50, 20);
  //  text(mouseX - valueX, 80, 20);
  //  text(mouseY - valueY, 110, 20);
}

void mousePressed() {
  //Check if Mouse is over button and toggle Graph on
  if (mouseX > boxX && mouseX < boxX+boxSize && mouseY >boxY && mouseY < boxY+boxSize) {
    if (graph30) {
      graph30 = false;
      c3 = color(220, 0, 0);
    } 
    else {
      graph30 = true;
      c3 = color(0, 220, 0);
    }
    //Run sub routines
    create();
    buttonCheck();
    graph();
  } 

  //Check if Mouse is over button and toggle Graph on
  if (mouseX > boxX+100 && mouseX < boxX+100+boxSize && mouseY >boxY && mouseY < boxY+boxSize) {
    if (graph690) {
      graph690 = false;
      c4 = color(220, 0, 0);
    } 
    else {
      graph690 = true;
      c4 = color(0, 220, 0);
    }
    //Run sub routines
    create();
    buttonCheck();
    graph();
  }

  //Check if Mouse is over button and toggle second display value
  if (mouseX > boxX+200 && mouseX < boxX+200+boxSize && mouseY >boxY && mouseY < boxY+boxSize) {
    if (secondValue) {
      secondValue = false;
      c5 = color(220, 0, 0);
    } 
    else {
      secondValue = true;
      c5 = color(0, 220, 0);
    }
    //Run sub routines
    create();
    buttonCheck();
    graph();
  }
}

void serialEvent (Serial myPort) {

  String inString = myPort.readStringUntil('\n');
  if (inString != null) {
    inString = trim(inString);
    String[] split = split(inString, ',');
    inFloat0 = float(split[0]);
    inFloat1 = float(split[1]);

    index++;
    float speed = trapDistance / inFloat0 *  360;
    list = append(list, speed);
    float et = inFloat1;
    etlist = append(etlist, et); 

    //Run sub routines
    create();
    buttonCheck();
    graph();
  }
}

void delay(int delay)
{
  int time = millis();
  while (millis () - time <= delay);
}

void create() {

  //Clear screen
  background(225);

  //Sorting
  float[] sortlist = new float[index+1];
  sortlist = sort(list);
  float[] sortetlist = new float[index+1];
  sortetlist = sort(etlist);

  //Calculate rank
  int pos = 1; 
  while (list[index-1] > sortlist[pos - 1]) {
    pos++;
  }
  if (pos == 1) {
    rank = 0;
  }
  else {
    rank = (pos / float(sortlist.length));
  }

  //Calculate Percentage of Speed
  percentage = list[index-1] / sortlist[sortlist.length -1]; 

  //Speed colour for fastest and slowest 
  if (index != 0) {
    if (list[index-1] < sortlist[1]) {
      c1 = color(240, 0, 0);
    } 
    else if (list[index-1] > sortlist[index-1]) {
      c1 = color(0, 240, 0);
    }
    else {
      c1 = color(255);
    }
  } 
  else {
    c1 = color(255);
  }  

  //ET colour for fastest and slowest 
  if (index != 0) {
    if (etlist[index-1] < sortetlist[1]) {
      c2 = color(0, 240, 0);
    } 
    else if (etlist[index-1] > sortetlist[index-1]) {
      c2 = color(240, 0, 0);
    }
    else {
      c2 = color(255);
    }
  } 
  else {
    c2 = color(255);
  }

  //Boxes
  rectMode(CORNER);
  stroke(0);
  fill(c1);
  rect(15, 15, width-30, 200); //Speed
  fill(c2);
  rect(15, 230, width-30, 200); //ET
  fill(255);
  rect(15, height - 255, 125, 240); //Left 
  rect(155, height -255, 125, 240); //Left
  rect(width - 140, height - 255, 125, 240); //Right
  rect(width - 280, height - 255, 125, 240); //Right

  //Text
  fill(0);
  textFont(f3);
  textAlign(CENTER);
  text("Speed", 78, height - 220);
  text("ET", width - 78, height - 220);
  text("ET", 218, height - 220);
  text("Speed", width - 218, height - 220);
  textFont(f4);
  textAlign(LEFT);
  text("Trap Distance: " + trapDistance + "mm", 2, height - 2);

  //Big Numbers
  textAlign(CENTER);
  textFont(f2);
  text(String.format("%.2f", list[index-1])+" km/h", width/2, 200); //Speed

  //Second Big Number
  if (secondValue) {
    text(String.format("%.3f", ((etlist[index-1])/100000))+" sec", width/2, 415); //ET
  } 
  else {
    averageSpeed = totalLength / etlist[index-1] * 360;
    text(String.format("%.2f", averageSpeed)+" km/h", width/2, 415); //ET Speed
  }

  //Last 10
  for (int i = 0; i <= index-1 && i < 10; i++) {
    textAlign(LEFT);
    textFont(f5);
    text((index-1 - i + 1)+". "+String.format("%.2f", list[index-1 - i])+" km/h", 23, (height - 200 + (i * 20)));
  }

  //Last 10 ET
  for (int i = 0; i <= index-1 && i < 10; i++) {
    textAlign(LEFT);
    textFont(f5);
    text((index-1 - i + 1)+". "+String.format("%.3f", (etlist[index-1 - i])/100000)+" sec", 163, (height - 200 + (i * 20)));
  }

  //Fastest 
  for (int i = 0; i <= index-1 && i < 10; i++) {
    textAlign(CENTER);
    textFont(f5);
    text((i+1)+". "+String.format("%.2f", sortlist[sortlist.length - (i+1)])+" km/h", width - 220, (height - 200 + (i * 20)));
  }

  //Fastest ET
  for (int i = 0; i <= index-1 && i < 10; i++) {
    textAlign(CENTER);
    textFont(f5);
    text((i+1)+". "+String.format("%.3f", (sortetlist[i])/100000)+" sec", width - 80, (height - 200 + (i * 20)));
  }

  //Create string for saving to text file
  String[] listString = new String[index-1+1];
  for (int i = 0; i < index-1+1; i++) {
    listString[i] = (Float.toString(list[i]) + ',' + Float.toString(etlist[i]));
  }

  //Save to text file
  saveStrings("list.txt", listString);

  //Graph with curves
  //  beginShape();
  //  stroke(125, 125, 255);
  //  for (int i = 1; i <= index && i < 34; i++) {
  //    float y = map(list[index - (i - 1)], 0, SgraphH, 150, 0);      
  //    curveVertex((width + 25 - (i * 25)), 25 + y);
  //  }
  //  endShape();
}

void graph() {
  //Create graph area
  fill(255);
  rectMode(CENTER);
  rect(width/2, height - 135, 690, 240);
  stroke(192);
  for (int i = 1; i < 30.; i++) {
    line((((width - 690)/2) + (i * (690/30))), 446, ((((width - 690)/2) + (i * (690/30)))), 684);
  }
  for (int i = 1; i < 10; i++) {
    line(((width - 690)/2)+1, (445 + (i * 24)), (width - (width - 690)/2)-1, (445 + (i * 24)));
  }  

  //Graph last 690
  if (graph690) {
    stroke(0, 170, 0);
    for (int i = 1; i <= index-1 && i < 690; i++) {
      float start = map(list[index-1 - (i - 1)], 0, SgraphH, 240, 0);
      float end = map(list[index-1 - i], 0, SgraphH, 240, 0);
      line(((width - (width - 690)/2) + 1 - (i)), 445 + start, ((width- (width - 690)/2) + 1 - ((i + 1))), 445 + end);
    }
  }

  //Graph last 690
  if (graph690) {
    stroke(120, 0, 120);
    for (int i = 1; i <= index-1 && i < 690; i++) {
      float start = map(etlist[index-1 - (i - 1)], 0, ETgraphH, 240, 0);
      float end = map(etlist[index-1 - i], 0, ETgraphH, 240, 0);
      line(((width - (width - 690)/2) + 1 - (i)), 445 + start, ((width- (width - 690)/2) + 1 - ((i + 1))), 445 + end);
    }
  }

  //Graph last 30 speeds
  if (graph30) {
    stroke(0, 0, 240);
    for (int i = 1; i <= index-1 && i < 31; i++) {
      float start = map(list[index-1 - (i - 1)], 0, SgraphH, 240, 0);
      float end = map(list[index-1 - i], 0, SgraphH, 240, 0);
      line(((width - (width - 690)/2) + 23 - (i * 23)), 445 + start, ((width- (width - 690)/2) + 23 - ((i + 1) * 23)), 445 + end);
    }
  }

  //Graph last 30 ETs
  if (graph30) {
    stroke(240, 0, 0);
    for (int i = 1; i <= index-1 && i < 31; i++) {
      float start = map(etlist[index-1 - (i - 1)], 0, ETgraphH, 240, 0);
      float end = map(etlist[index-1 - i], 0, ETgraphH, 240, 0);
      line(((width - (width - 690)/2) + 23 - (i * 23)), 445 + start, ((width- (width - 690)/2) + 23 - ((i + 1) * 23)), 445 + end);
    }
  }

  fill(0);
  textAlign(LEFT);
  text("0", width / 2 - 345, height - 15);
  text(SgraphH, width / 2 - 345, height - 243);
}

void buttonCheck() {
  //Draw box and text for graph selection
  rectMode(CORNER);
  textFont(f6);
  textAlign(LEFT);

  stroke(0);  
  fill(0);
  text("Graph last 30", boxX+20, boxY+13);
  fill(c3);
  rect(boxX, boxY, boxSize, boxSize);

  stroke(0);  
  fill(0);
  text("Graph last 690", boxX+120, boxY+13);
  fill(c4);
  rect(boxX+100, boxY, boxSize, boxSize);

  stroke(0);  
  fill(0);
  text("Toggle Second Val", boxX+220, boxY+13);
  fill(c5);
  rect(boxX+200, boxY, boxSize, boxSize);
}

void keyPressed() {
  valueX = mouseX;
  valueY = mouseY;
  if (key == 'n') {
    float speed = trapDistance / random(100, 500) * 3.6;
    list = append(list, speed);
    float et = random(3, 15);
    etlist = append(etlist, et);
  }
}
