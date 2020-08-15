// 6491-2019-P1 
// Base-code: Jarek ROSSIGNAC
// Student 1: Steven HILLERMAN
// Student 2: Michael C. HAYES
import processing.pdf.*;    // to save screen shots as PDFs, does not always work: accuracy problems, stops drawing or messes up some curves !!!
import java.awt.Toolkit;
import java.awt.datatransfer.*;
import java.lang.*;
import java.util.ArrayList;
//  ******************* Basecode for P2 ***********************
Boolean 
  rolling=false,
  animating=false, 
  tracking=true,
  showTet=false,
  showTiles=false,
  showGhost=false,
  showBody=true,
  smooth=true,
  interactive=false,
  PickedFocus=false, 
  center=true, 
  track=false, 
  showLegs=true,
  showReference = false,
  showArrow=false,
  trackMouse=false,
  highlightMouse=true;
float 
  rBase=200,  // radius of base triangle
  t=0, 
  s=0,
  e=1;
int
  f=0, maxf=30, level=4, method=5;
  
static final int n_obstacles = 30;
static final int minObstCoord = -900;
static final int maxObstCoord = 2800;
static final int obstBuffer = 500;
static final int coordRange = maxObstCoord - minObstCoord;
static final int minRadius = 20;
static final int maxRadius = 60;

int k=0; // current step in instruction string
  
String  //S="RRLROOLRLRLLLRLRLLRLRLR"; 
    // S="RLRLRRRRLRLRLLLLRLRLRRRRLRLRLLLLRLRLRO";
    //S="LRLRRRLRLRRRLRLRRRLRLRLRLRRRLRLRRRLRLRRRLRLR"; 
    //S="LRLRLRRLRLRRLRLRLRLLRLRLL"; 
    // S="LLLRRRLLLRRRORORORLLLRRRLLL";
    S = "";
float defectAngle=0;
//pts P = new pts(); // polyloop in 3D
//pts Q = new pts(); // second polyloop in 3D

obst[] obstacles = new obst[n_obstacles];
  
void setup() {
  size(1000, 1000, P3D); // P3D means that we will do 3D graphics
  //size(600, 600, P3D); // P3D means that we will do 3D graphics
  stevenPic = loadImage("../data/steven.jpg");  // load image from file pic.jpg in folder data *** replace that file with your pic of your own face
  chadPic = loadImage("../data/chad.png");
  textureMode(NORMAL);          
  noSmooth();
  frameRate(30);
  GHOST.declareBot();
  BOT.declareBot();
  BOT.resetBot(rBase);
  _LookAtPt.reset(BOT.BotCentroid(),10);
  
  // Create obstacles
  for (int i = 0; i < n_obstacles; i++) {
    float x = (float)(Math.random() * coordRange) + minObstCoord;
    float y = (float)(Math.random() * coordRange) + minObstCoord;
    while (abs(x) < obstBuffer && abs(y) < obstBuffer) {
      x = (float)(Math.random() * coordRange) + minObstCoord;
      y = (float)(Math.random() * coordRange) + minObstCoord;
    }
    float r = (float)(Math.random() * (maxRadius-minRadius)) + minRadius;
    obstacles[i] = new obst(P(x, y, 0), r);
  }
}

void draw() {
  background(255);
  hint(ENABLE_DEPTH_TEST); 
  pushMatrix();   // to ensure that we can restore the standard view before writing on the canvas
  setView();  // see pick tab
  showFloor(); // draws dance floor as yellow mat
  doPick(); // sets Of and axes for 3D GUI (see pick Tab)
  
  if (highlightMouse) {
    fill(white);
    show(pick(mouseX, mouseY), 7);
  }
  
  // Show obstacles
  for (int i = 0; i < n_obstacles; i++) {
    obstacles[i].showObst();
  }
  
  if (trackMouse) {
    if (f==0) {
      pt goalPt = pick(mouseX, mouseY); //<>//
      if (abs(goalPt.x) < maxObstCoord * 1.5 && abs(goalPt.y) < maxObstCoord * 1.5) { 
        char nextMove = calcNextMove(goalPt);
        if (nextMove != 'S') {
          S = S + nextMove;
          animating = true;
          rolling=true;
        }
      }
    }
  }
  
  // For animating robot motion
  if(animating)  
  {
    f++; // advance frame counter
    
    // For the end of each move
    if (f>maxf)
    {
      f=0;
      if(k<S.length())
      {
        // Update robot status variables (front and floating identifiers)
        BOT.updateFootLocations(S.charAt(k));
      }
      else rolling=false;
      k++;
    } 
    
    // For animating the moves

    // Get a smooth time variable
    if(smooth) t=-cos(PI*f/maxf);
    else t=2.*f/maxf-1;

    // Roll the bot a small amount each frame
    if(rolling) {
      if(k<S.length())
      {
        if (k == 0) BOT.partialRollBot(t, S.charAt(k));
        else BOT.fullRollBot(t, S.charAt(k));
      }
    }

    // Show the bot at the end of each frame
    
    /*System.out.println("Dir: " + command);
    System.out.println("Hip[0] - x: " + BOT.Hips[0].x + ", y: " + BOT.Hips[0].y + ", z: " + BOT.Hips[0].z);
    System.out.println("Hip[1] - x: " + BOT.Hips[1].x + ", y: " + BOT.Hips[1].y + ", z: " + BOT.Hips[1].z);
    System.out.println("Hip[2] - x: " + BOT.Hips[2].x + ", y: " + BOT.Hips[2].y + ", z: " + BOT.Hips[2].z);
    System.out.println("Hip[3] - x: " + BOT.Hips[3].x + ", y: " + BOT.Hips[3].y + ", z: " + BOT.Hips[3].z + "\n");*/
    
    BOT.showBot(5,15, green, 255);

    if(k==S.length()) animating=false; // If we have reached the end of our instruction string, stop animating
    if(tracking&&!mousePressed) F =_LookAtPt.move(BOT.BotCentroid()); // Reset the centroid to the center of the new bot location
  }
  
  // Show all tiles leading up to the current location
  if (showTiles)
  {
    int i=0;
    GHOST.resetBot(rBase);
    
    // Show all tiles leading up to current tile
    while (i<=k && i<S.length()) 
    {
      GHOST.showTile(5, 15);
      GHOST.instantRollBot(S.charAt(i));
      i++;
    }
  }
  
  // Show faded "ghost" tetrahedra at old locations
  if (showGhost)
  {
    int i=0;
    GHOST.resetBot(rBase);
    
    // Show all tetrahedra leading up to current tile
    while (i<k && i<S.length()) 
    {
      boolean oldLegs = showLegs;
      boolean oldBody = showBody;
      boolean oldTet = showTet;
      showLegs = false;
      showBody = false;
      showTet = true;
      GHOST.showBot(5, 15, grey, (int)(200 * ((float)(i+1)/(k+1))));
      GHOST.instantRollBot(S.charAt(i));
      i++;
      showLegs = oldLegs;
      showBody = oldBody;
      showTet = oldTet;
    }
  }
  
  /*if(interactive)
  {
    int i=0;
    GHOST.resetBot(rBase);
    
    // Show all tiles leading up to current tile
    while (i<k && i<S.length()) 
    {
      GHOST.showBot(5, 15, grey, (int)(200 * ((float)(i+1)/(k+1))));
      GHOST.instantRollBot(S.charAt(i));
      BOT.instantRollBot(S.charAt(i));
      i++;
    }
    BOT.showBot(5, 15, red, 255);
    
    if(!animating)
    {
        
      // STUDENTS    
      
      if(tracking&&!mousePressed)   F =_LookAtPt.move(GHOST.BotCentroid()); // F = BOT.BotCentroid();
    }
  }*/
  
  //if(!animating && !interactive) BOT.showBot(5,15,yellow,255);
  if(!animating) BOT.showBot(5,15,yellow,255);
 
  popMatrix(); // done with 3D drawing. Restore front view for writing text on canvas
  hint(DISABLE_DEPTH_TEST); // no z-buffer test to ensure that help text is visible
  scribeHeader("S="+S+", path="+S.substring(0,min(k,S.length()))+", k="+k+", t="+nf(t,1,3),1);

  // used for demos to show red circle when mouse/key is pressed and what key (disk may be hidden by the 3D model)
  if(mousePressed) {stroke(cyan); strokeWeight(3); noFill(); ellipse(mouseX,mouseY,20,20); strokeWeight(1);}
  if(keyPressed) {stroke(red); fill(white); ellipse(mouseX+14,mouseY+20,26,26); fill(red); text(key,mouseX-5+14,mouseY+4+20); strokeWeight(1); }
  if(scribeText) {fill(black); displayHeader();} // dispalys header on canvas, including my face
  if(scribeText && !filming) displayFooter(); // shows menu at bottom, only if not filming
  if(filming && (animating || change)) saveFrame("FRAMES/F"+nf(frameCounter++,4)+".tif");  // save next frame to make a movie
  change=false; // to avoid capturing frames when nothing happens (change is set uppn action)
  change=true;
  }
  
  
// Use A* to calculate next move  
char calcNextMove(pt goalPt) {
    // Calculate start and end points
    GraphNode start = new GraphNode(BOT.oldPositions[BOT.front], BOT.oldPositions[BOT.left], BOT.oldPositions[BOT.right]);    
    
    ArrayList<Character> path = new ArrayList<Character>();
    ArrayList<GraphNode> explored = new ArrayList<GraphNode>();
    ArrayList<GraphNode> frontier = new ArrayList<GraphNode>();
    
    frontier.add(start);
    
    while(frontier.size() > 0)
    {
        GraphNode current = minMixed(frontier);
        
        frontier.remove(current);
        
        // Check if goal pt is in current triangle
        if (ptInTriangle(current.left, current.right, current.front, goalPt)) {
            path = current.pathTo; //<>//
            break;
        }
        
        // Calculate neighbors
        ArrayList<GraphNode> neighbors = new ArrayList<GraphNode>();
        GraphNode rightMove = new GraphNode(current, 'R', goalPt);
        GraphNode leftMove = new GraphNode(current, 'L', goalPt);
        GraphNode oppMove = new GraphNode(current, 'O', goalPt);
        if (isLegalMove(rightMove.left, rightMove.front, rightMove.right)) neighbors.add(rightMove);
        else if (ptInTriangle(rightMove.left, rightMove.front, rightMove.right, goalPt)) {
            path = current.pathTo;
            break;
        }
        if (isLegalMove(leftMove.left, leftMove.front, leftMove.right)) neighbors.add(leftMove);
        else if (ptInTriangle(leftMove.left, leftMove.front, leftMove.right, goalPt)) {
            path = current.pathTo;
            break;
        }
        if (isLegalMove(oppMove.left, oppMove.front, oppMove.right)) neighbors.add(oppMove);
        else if (ptInTriangle(oppMove.left, oppMove.front, oppMove.right, goalPt)) {
            path = current.pathTo;
            break;
        }
        
        for (int i = 0; i < neighbors.size(); i++) {
            if (!nodeInListWithLowerMixed(frontier, neighbors.get(i)) && !nodeInListWithLowerMixed(explored, neighbors.get(i))) {
                frontier.add(neighbors.get(i));
            }
        }
        
        explored.add(current);
    }
    
    if (path.size() < 1) return 'S';
    return path.get(0);
}


boolean nodeInListWithLowerMixed(ArrayList<GraphNode> list, GraphNode node)
{
    for (int i = 0; i < list.size(); i++) {
        if (list.get(i).location.x == node.location.x && list.get(i).location.y == node.location.y
            && list.get(i).mixed < node.mixed) return true;
    }
    
    return false;
}


GraphNode minMixed(ArrayList<GraphNode> nodes)
{
    GraphNode min = nodes.get(0);
    for (int i = 1; i < nodes.size(); i++) {
        if (nodes.get(i).mixed < min.mixed) min = nodes.get(i);
    }
    
    return min;
}

/*
if (trackMouse) {
    if (f==0) {
      // Calculate next move
      //S="";
      //k=0;
      pt Right = BOT.getEndPoint('R');
      pt Left = BOT.getEndPoint('L');
      pt Opp = BOT.getEndPoint('O');
      pt Mouse = pick(mouseX, mouseY);
      
      float inf = 10000000;
      float dR = inf, dL = inf, dO = inf;
      
      if (isLegalMove(BOT.Feet[BOT.right], BOT.Feet[BOT.front], Right)) dR = distance(Right, Mouse, false);
      if (isLegalMove(BOT.Feet[BOT.left], BOT.Feet[BOT.front], Left)) dL = distance(Left, Mouse, false);
      if (isLegalMove(BOT.Feet[BOT.right], BOT.Feet[BOT.left], Opp)) dO = distance(Opp, Mouse, false);
      
      float minimum = minimum(dR, dL, dO);
      char next;
      
      if (minimum == dR) {
        next = 'R';
      }
      else if (minimum == dL) {
        next = 'L';
      }
      else {
        next = 'O';
      }
      
      S = S + next;
      animating = true;
      rolling=true;
    }
  }*/
