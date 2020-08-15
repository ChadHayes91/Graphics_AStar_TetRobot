vec Up = V(0,0,1);
TETROBOT BOT = new TETROBOT();
TETROBOT GHOST = new TETROBOT();



class TETROBOT // class for manipulaitng TETROBOTs
{
    pt[] Feet = new pt[4];  // feet positions
    color[] col = new color[4]; // the color of each foot/hip
    int a=0, b=1, c=2, d=3; // I use these to remember which hip is which\
    float legSegLength;

    // **********************************
    // Added by Steven and Chad

    int front = a;
    int left = c;
    int right = b;
    int floating = d;
    pt[] Hips = new pt[4];  // hip positions
    pt[] Knees = new pt[4]; // knee positions
    pt[] oldPositions = new pt[4]; // the positions of the feet before the current move started
    pt[] oldHipPositions = new pt[4];
    float bodyRise = 0;
    pt bodyCentroid = P(0,0,0);
    float bodySize = 0;
    float centroidHipDrop = 0;

    // **********************************

    TETROBOT() {}



    /* declareBot()
    * ------------
    * This function initializes all data structures in the robot.  Sets the arrays for the feet and hips
    * using a default point constructor and initializes the colors array.
    */
    void declareBot() 
    {
        for (int i = 0; i < 4; i++) Feet[i]=P();
        for (int i = 0; i < 4; i++) Hips[i]=P();
        col[0]=magenta;
        col[1]=orange;
        col[2]=dgreen;
        col[3]=blue;
    }     



    /* resetBot()
    * ------------
    * This function puts the robot back where it began at the center of the terrain with its first three feet on the ground.
    * Also resets any variables that may have changed during motion.
    * --------------------------------------------------------------
    * Parameters
    *   - r: the distance from the center of the initial CET to each vertex, or the radius of the circle
    *        containing the three vertices initially on the ground.
    */
    void resetBot(float r)
    {
        pt X = P(); // center of initial CET
        for (int i=0; i<3; i++) Feet[i]=R(P(X,V(-r,0,0)),2.*PI*i/3,X); // three points on the z=0 plane
        pt A=Feet[0], B=Feet[1], C=Feet[2];
        pt O = P(A,B,C); // centroid of triangle
        float e=(d(A,B)+d(B,C)+d(C,A))/3; // average edge length (in case we rin on non equilateral triangles)
        pt D = P(O,e*sqrt(2./3),Up);
        Feet[3]=D;
        a=0; b=1; c=2; d=3;
        
        // calculate geometric variables
        legSegLength = V(Feet[0], Feet[1]).norm() * 0.6;
        bodyRise = V(O, BotCentroid()).norm();
        bodyCentroid = BotCentroid();
        bodySize = r / 4;
        
        // Set initial hip positions
        Hips[a] = P(bodyCentroid, V( 0.25, V(BotCentroid(), Feet[a])));
        Hips[b] = P(bodyCentroid, V( 0.25, V(BotCentroid(), Feet[b])));
        Hips[c] = P(bodyCentroid, V( 0.25, V(BotCentroid(), Feet[c])));
        Hips[d] = P(bodyCentroid, V( 0.25, V(BotCentroid(), Feet[d])));
        centroidHipDrop = V(bodyCentroid, P(Hips[a], Hips[b], Hips[c])).norm();

        // reset foot location trackers
        front = a;
        floating = d;
        right = b;
        left = c;

        // reset old position arrays
        for (int i = 0; i < 4; i++)
        {
            oldPositions[i] = Feet[i]; 
            oldHipPositions[i] = Hips[i];
        }

        // Set knee locations
        for (int i = 0; i < 4; i++) {
            Knees[i] = getKneeLoc(Hips[i], Feet[i]);
        }
    }     



    /* botCentroid()
    * -------------
    * Returns the centroid of the robot's four feet in the form of a pt object.
    */
    pt BotCentroid() {
        return P(Feet[0],Feet[1],Feet[2],Feet[3]);  // average of the 4 vertices
    }



    /* showBot()
    * ------------
    * Displays the robot on the screen at its current location.  The disply can be customized using the
    * global variables defined at the top of TetRobot.pde.  This version automatically displays green
    * caplets at full opacity.  The version below can be used to customize color and opacity.
    * ---------------------------------------------------------------------------------------
    * Parameters
    *   - w: the thickness of each caplet
    *   - r: the radius of each foot
    */
    void showBot (float w, float r)
    {
        noStroke();
        if(showTet)
        {
            for(int i=0; i<4; i++) {fill(col[i]);  show(Feet[i],r); } // shows tet vertices as balls
            fill(green); for (int v=0; v<3; v++)  for (int u=v+1; u<4; u++) caplet(Feet[v],w,Feet[u],w); // shows tet edges as cylinders
            pt X = P(Feet[b],0.2,V(Feet[b],P(Feet[a],Feet[c])));    
            pt Y = P(Feet[c],0.2,V(Feet[c],P(Feet[b],Feet[a])));     
            fill(red); if(showArrow) arrow(X,Y,5); // shows arrow in the wedge of the rotation axis
        }
        if(showBody) showCore(); // shows the tetRobot core (body)
    }


    /* showBot()
    * ------------
    * Displays the robot on the screen at its current location.  The disply can be customized using the
    * global variables defined at the top of TetRobot.pde.
    * ----------------------------------------------------
    * Parameters
    *   - w: the thickness of each caplet
    *   - r: the radius of each foot
    *   - colBeams: the color of the caplets.  Can be specified using hex or color name.
    *   - opacity: an integer between 0 and 255 specifying the opacity of the robot.
    */
    void showBot (float w, float r, color colBeams, int opacity)
    {
        if(opacity<1) return;
        noStroke();

        // To show the large tetrahedron
        if(showTet)
        {
            // Show all feet
            fill(col[a], opacity);  show(Feet[a],r);
            fill(col[b], opacity);  show(Feet[b],r);
            fill(col[c], opacity);  show(Feet[c],r); 
            fill(col[d], opacity);  show(Feet[d],r);

            // Show all beams
            fill(colBeams, opacity); 
            caplet(Feet[a],w,Feet[b],w);
            caplet(Feet[a],w,Feet[c],w);
            caplet(Feet[a],w,Feet[d],w);
            caplet(Feet[b],w,Feet[c],w);
            caplet(Feet[b],w,Feet[d],w);
            caplet(Feet[c],w,Feet[d],w);
        }

        if(showBody) showCore(255); 
        if(showLegs)
        {
            for (int i = 0; i < 4; i++) {
                fill(grey);
                caplet(Hips[i], r, Knees[i], 2*r/3);    // Hip to knee
                sphere(Knees[i], 2*r/3);                // Knee
                caplet(Knees[i], 2*r/3, Feet[i], r/3);  // Knee to feet
            }
            
            // Show all feet
            fill(col[a], opacity);  show(Feet[a],2*r/3);
            fill(col[b], opacity);  show(Feet[b],2*r/3);
            fill(col[c], opacity);  show(Feet[c],2*r/3); 
            fill(col[d], opacity);  show(Feet[d],2*r/3);
        }  
    }


    /* showTile()
    * ------------
    * Displays the base triangle (or CET) of the robot's current position.
    * --------------------------------------------------------------------
    * Parameters
    *   - w: the thickness of each caplet
    *   - r: the radius of each foot
    */
    void showTile (float w, float r) // shows the base triangle
    {
        fill(col[front]);  show(Feet[front],r);
        fill(col[left]);  show(Feet[left],r);
        fill(col[right]);  show(Feet[right],r);
        fill(cyan); 
        caplet(Feet[front],w,Feet[right],w);
        caplet(Feet[front],w,Feet[left],w);
        caplet(Feet[left],w,Feet[right],w);
    }



    /* showCore()
    * ------------
    * Displays the body of the robot.  Can be called with or without an opacity parameter.
    * Without an opacity parameter, the body will be shown at full opacity.
    * ---------------------------------------------------------------------
    * Parameters
    *   - opacity (optional): an integer between 0 and 255 specifying the opacity of the body.
    */
    void showCore()
    {
        showCore(255);
    }
    void showCore(int opacity)
    {
        fill(col[a], opacity);  show(Hips[a],15);
        fill(col[b], opacity);  show(Hips[b],15);
        fill(col[c], opacity);  show(Hips[c],15); 
        fill(col[d], opacity);  show(Hips[d],15);
        fill(red, opacity); 

        show(Hips[0], Hips[1], Hips[2]);
        show(Hips[0], Hips[1], Hips[3]);
        show(Hips[0], Hips[2], Hips[3]);
        show(Hips[3], Hips[1], Hips[2]);
    }



    /* fullRollBot()
    * ------------
    * Performs a full rolling motion of the robot.  This should be called once all four feet are on the ground.
    * For the first move, or any move where a foot starts in the air, use partialRollBot().
    * -------------------------------------------------------------------------------------
    * Parameters
    *   - t: a float indicating how far along in the move to set the robot.  Should be from -1 to 1.
    *   - dir: a char indicating the direction of the move, 'R', 'L', or 'O'.
    */
    void fullRollBot(float t, char dir)
    {  
        pt endPt = getEndPoint(dir);  // The point where the flying foot will land
        // Set the position of the flying foot.
        Feet[floating] = getFootLoc(oldPositions[floating], endPt, t);
        // Set the positions of the hips
        rotateBody(dir, t);

        // Set the positions of the knees
        Knees[floating] = getKneeLoc(Hips[floating], Feet[floating]);
        Knees[front] = getKneeLoc(Hips[front], Feet[front]);
        Knees[right] = getKneeLoc(Hips[right], Feet[right]);
        Knees[left] = getKneeLoc(Hips[left], Feet[left]);
    }



    /* getFootLoc()
    * ------------
    * Gets the location of a point moving in a semicircular motion from point D0 to point D1 at the time
    * specified by the parameter t.
    * -----------------------------
    * Parameters
    *   - D0: a pt indicating the start location of the foot.
    *   - D1: a pt indicating the end location of the foot.
    *   - time: a float indicating how far along in the move to set the foot.  Should be from -1 to 1.
    */
    pt getFootLoc(pt D0, pt D1, float time) {
        vec Up = V(0,0,1);
        float t = (time + 1.0) / 2.0;
        Up.normalize();
        vec start = V(P(D0, D1), D0);
        vec mid = V(start.norm(), Up);
        float alpha = atan2(N(start, mid).norm(), d(start, mid));
        if (alpha == 0) return D1;
        vec top = A(V(sin((1 - (t * 2)) * alpha), start), V(sin((t * 2) * alpha), mid));
        vec movVec = top.div(sin(alpha));
        pt returnVal = P(P(D0, D1), movVec);
        
        /*if (Float.isNaN(returnVal.x)) {
            System.out.println("GetFootLoc NaN"); 
        }*/
        
        return returnVal;
    }


 //<>//
    /* getKneeLoc()
    * ------------
    * Determines where the knee should go given the locations of the hip and foot.  The hip and foot
    * should not be more than 2 * legSegLengh distance apart.  The knee will be placed directly above
    * the midpoint of the line between the hip and foot, on a line normal to the line from hip to foot.
    * -------------------------------------------------------------------------------------------------
    * Parameters
    *   - Hip: a pt indicating the location of the hip.
    *   - Foot: a pt indicating the location of the foot.
    */
    pt getKneeLoc(pt Hip, pt Foot)
    {
        vec hipToFoot = V(Hip, Foot);               // The vec between the hip and foot
        float d = hipToFoot.norm();                 // The distance between the hip and foot
        float theta = acos(d / (2 * legSegLength)); // The angle between hipToFoot and the vector from hip to knee
        float rise = sin(theta) * legSegLength;     // The height of the knee above hipToFoot perpendicularly

        vec normal = cross(V(0,0,-1), hipToFoot);
        vec riseVec = cross(normal, hipToFoot).normalize();
        riseVec = V(rise, riseVec);
        pt mid = P(Hip, V(0.5, hipToFoot));

        return P(mid, riseVec);
    }



    /* partialRollBot()
    * -----------------
    * Performs a partial rolling motion on the robot.  This should only be called when he floating foot
    * starts in the air.  
    * -------------------------------------------------------------------------------------
    * Parameters
    *   - t: a float indicating how far along in the move to set the robot.  Should be from -1 to 1.
    *   - dir: a char indicating the direction of the move, 'R', 'L', or 'O'.
    */
    void partialRollBot(float t, char dir)
    {  
        // Calculate axis of rotation
        Axis rotationAxis = getRotationAxis(dir);

        int moving = 0;
        vec angleCalcVec = V(0,0,0);
        if (dir == 'R') {
            moving = left;
            angleCalcVec = A( V(oldPositions[left], oldPositions[front]), V(oldPositions[left], oldPositions[right]) );
        } else if (dir == 'L') {
            moving = right;
            angleCalcVec = A( V(oldPositions[right], oldPositions[front]), V(oldPositions[right], oldPositions[left]) );
        } else if (dir == 'O') {
            moving = front;
            angleCalcVec = A( V(oldPositions[front], oldPositions[left]), V(oldPositions[front], oldPositions[right]) );
        } else {
            System.out.println("Bad direction command");
        }

        // Calculate angle of rotation
        vec midpointVec = V(0.5, rotationAxis.direction);
        pt mid = P(rotationAxis.anchor, midpointVec);
        float dotProd = d(angleCalcVec, V(mid, oldPositions[floating]));
        float angle = (float) Math.acos( dotProd / (angleCalcVec.norm() * V(mid, oldPositions[floating]).norm()) );

        // Calculate the points at the middle of the rotation and the current point in the rotation
        pt midFront = Rotation(oldPositions[floating], rotationAxis.direction, rotationAxis.anchor, angle / 2.0);
        pt endFront = Rotation(midFront, rotationAxis.direction, rotationAxis.anchor, (angle / 2.0) * t);
          
        // Roll two points around the axis 
        Feet[floating] = endFront;

        // Set hip locations
        rotateBody(dir, t);

        // Set knee locations
        Knees[floating] = getKneeLoc(Hips[floating], Feet[floating]);
        Knees[front] = getKneeLoc(Hips[front], Feet[front]);
        Knees[right] = getKneeLoc(Hips[right], Feet[right]);
        Knees[left] = getKneeLoc(Hips[left], Feet[left]);
    }



    /* rotateBody()
    * -------------
    * Sets the positions of the hips based on the current progress of the move.
    * -------------------------------------------------------------------------
    * Parameters
    *   - t: a float indicating how far along in the move to set the robot.  Should be from -1 to 1.
    *   - dir: a char indicating the direction of the move, 'R', 'L', or 'O'.
    */
    void rotateBody(char dir, float t) {

        pt[] rotatedHips = new pt[4];

        Axis rotationAxis = getHipRotationAxis(dir);

        int moving = 0;
        int stationary1 = 0;
        int stationary2 = 0;
        pt endPoint = P(0,0,0);
        if (dir == 'R') {
            moving = left;
            stationary1 = right;
            stationary2 = front;
            endPoint = P(oldHipPositions[front], V(oldHipPositions[left], oldHipPositions[right]));
        } else if (dir == 'L') {
            moving = right;
            stationary1 = left;
            stationary2 = front;
            endPoint = P(oldHipPositions[front], V(oldHipPositions[right], oldHipPositions[left]));
        } else if (dir == 'O') {
            moving = front;
            stationary1 = right;
            stationary2 = left;
            endPoint = P(oldHipPositions[left], V(oldHipPositions[front], oldHipPositions[right]));
        } else {
            System.out.println("Bad direction command");
        }

        // Calculate angle of rotation
        vec midpointVec = V(0.5, rotationAxis.direction);
        pt mid = P(rotationAxis.anchor, midpointVec);
        float dotProd = d(V(mid, endPoint), V(mid, oldHipPositions[floating]));
        float angle = (float) Math.acos( dotProd / (V(mid, endPoint).norm() * V(mid, oldHipPositions[floating]).norm()) );

        pt midFront = Rotation(oldHipPositions[floating], rotationAxis.direction, rotationAxis.anchor, angle / 2.0);
        pt midFloating = Rotation(oldHipPositions[moving], rotationAxis.direction, rotationAxis.anchor, angle / 2.0);

        pt endFront = Rotation(midFront, rotationAxis.direction, rotationAxis.anchor, (angle / 2.0) * t);
        pt endFloating = Rotation(midFloating, rotationAxis.direction, rotationAxis.anchor, (angle / 2.0) * t);
          
        // Roll two points around the axis 
        rotatedHips[floating] = endFront;
        rotatedHips[moving] = endFloating;
        rotatedHips[stationary1] = oldHipPositions[stationary1];
        rotatedHips[stationary2] = oldHipPositions[stationary2];

        pt rotatedBodyCentroid = P(rotatedHips[a], rotatedHips[b], rotatedHips[c], rotatedHips[d]);

        bodyCentroid = BotCentroid();
        bodyCentroid.z = bodyRise;

        vec trans = V(rotatedBodyCentroid, bodyCentroid);

        pt ha = P(rotatedHips[a], trans);
        pt hb = P(rotatedHips[b], trans);
        pt hc = P(rotatedHips[c], trans);
        pt hd = P(rotatedHips[d], trans);
        
        if (Float.isNaN(ha.x)) {
            int breaker = 0;
            System.out.println("NaN"); //<>//
        }

        Hips[a] = ha;
        Hips[b] = hb;
        Hips[c] = hc;
        Hips[d] = hd;
    }



    // dir parameter added by Steven Hillerman
    // Instantly rolls the robot in the direction specified
    void instantRollBot(char dir)
    {
        // Calculate axis of rotation
        Axis rotationAxis = getRotationAxis(dir);

        // Calculate end point
        int moving = 0;
        vec angleCalcVec = V(0,0,0);
        if (dir == 'R') {
            moving = left;
            angleCalcVec = A( V(oldPositions[left], oldPositions[front]), V(oldPositions[left], oldPositions[right]) );
        } else if (dir == 'L') {
            moving = right;
            angleCalcVec = A( V(oldPositions[right], oldPositions[front]), V(oldPositions[right], oldPositions[left]) );
        } else if (dir == 'O') {
            moving = front;
            angleCalcVec = A( V(oldPositions[front], oldPositions[left]), V(oldPositions[front], oldPositions[right]) );
        } else {
            System.out.println("Bad direction command");
        }

        // Calculate angle or rotation
        vec midpointVec = V(0.5, rotationAxis.direction);
        pt mid = P(rotationAxis.anchor, midpointVec);
        float dotProd = d(angleCalcVec, V(mid, oldPositions[floating]));
        float angle = (float) Math.acos( dotProd / (angleCalcVec.norm() * V(mid, oldPositions[floating]).norm()) );

        pt endFront = Rotation(oldPositions[floating], rotationAxis.direction, rotationAxis.anchor, angle);
        pt endFloating = Rotation(oldPositions[moving], rotationAxis.direction, rotationAxis.anchor, angle);
          
        // Roll two points around the axis 
        Feet[floating] = endFront;
        Feet[moving] = endFloating;

        updateFootLocations(dir);
    }

    void placeBot(pt A, pt B, pt C, int pa, int pb, int pc, int pd) 
    {
        Feet[pa] = A;
        Feet[pb] = B;
        Feet[pc] = C;
        vec relUp = cross(V(A,C), V(C, B));
        relUp.normalize();
        relUp.mul(((sqrt(6) / 3) * V(A,B).norm()));
        Feet[pd] = P(P(A, B, C), relUp);
    }



    // Returns a vector for the axis of rotation for the move specified by dir
    Axis getRotationAxis(char dir)
    {
        vec direction = V(0,0,0);
        pt anchor = P(0,0,0);
        if (dir == 'R')
        {
            direction = V(Feet[front], Feet[right]);
            anchor = Feet[front];
        } else if (dir == 'L')
        {
            direction = V(Feet[left], Feet[front]);
            anchor = Feet[left];
        } else if (dir == 'O')
        {
            direction = V(Feet[right], Feet[left]);
            anchor = Feet[right];
        } else {
            System.out.println("Bad direction command");
        }

        Axis a = new Axis(direction, anchor);

        return a;
    }

    // Returns a vector for the axis of rotation for the move specified by dir
    Axis getHipRotationAxis(char dir)
    {
        vec direction = V(0,0,0);
        pt anchor = P(0,0,0);
        if (dir == 'R')
        {
            direction = V(oldHipPositions[front], oldHipPositions[right]);
            anchor = oldHipPositions[front];
        } else if (dir == 'L')
        {
            direction = V(oldHipPositions[left], oldHipPositions[front]);
            anchor = oldHipPositions[left];
        } else if (dir == 'O')
        {
            direction = V(oldHipPositions[right], oldHipPositions[left]);
            anchor = oldHipPositions[right];
        } else {
            System.out.println("Bad direction command");
        }

        Axis a = new Axis(direction, anchor);

        return a;
    }

    pt getEndPoint(char dir)
    {
        pt anchor = P(0,0,0);
        vec direction = V(0,0,0);
        if (dir == 'R') {
            anchor = Feet[front];
            direction = V(Feet[left], Feet[right]);
        } else if (dir == 'L') {
            anchor = Feet[front];
            direction = V(Feet[right], Feet[left]);
        } else if (dir == 'O') {
            anchor = Feet[left];
            direction = V(Feet[front], Feet[right]);
        }

        pt end = P(anchor, direction);
        return end;
    }


    void updateFootLocations(char dir) {
        if (dir == 'R') {
            int oldLeft = left;
            left = front;
            front = floating;
            floating = oldLeft;     
        } else if (dir == 'L') {
            int oldRight = right;
            right = front;
            front = floating;
            floating = oldRight; 
        } else if (dir == 'O') {
            int oldFront = front;
            int oldRight = right;
            front = floating;
            floating = oldFront;
            right = left;
            left = oldRight;
        }

        for (int i = 0; i < 4; i++) {
            oldPositions[i] = Feet[i]; 
            oldHipPositions[i] = Hips[i];
        }
    }

    void moveBot(vec displacement) {
        for (int i = 0; i < 4; i++) {
            Feet[i] = P(Feet[i], displacement);  
        }
    }


    void placeBot(pt A, pt B, pt C) // puts the bot tet so that one of its facs is the triangle ABC
    {
        pt O = P(A,B,C); // centroid of triangle
        float e=(d(A,B)+d(B,C)+d(C,A))/3; // average edge length
        pt D = P(O,e*sqrt(2./3),Up);
        Feet[0].setTo(A); Feet[1].setTo(B); Feet[2].setTo(C); Feet[3].setTo(D);
    }
     
} // END TETROBOT CLASS


class Axis {
    vec direction;
    pt anchor;

    Axis(vec Dir, pt Anchor) {
        direction = Dir;
        anchor = Anchor;
    }
}
