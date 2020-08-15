## Graphics TetRobot Pathfinding with A*

Link to GitHub Page: https://chadhayes91.github.io/Pathfinding_TetRobot/

Project for CS 6491 Computer Graphics at Georgia Tech. This project was a two-man group effort with Steven Hillerman (also currently a GT student). Base code for 3D rendering was provided by the instructor: Jarek Rossignac.

This project showcases concepts from Computer Graphics, as well as pathfinding using specifically A* from Artificial Intelligence. The project also uses a significant number of applications of geometry and operations from linear algebra.

This project is coded in Java and needs software called Processing for actual rendering. If you'd like to run the code yourself, download Processing at: https://processing.org/, download the code posted above, open "TetRobot.pde," and run it in Processing.

Depending on your screen resolution, you might want to change the window size (it is defined in the "TetRobot.pde" code on line 60.)

### Key Commands:

The TetRobot initially stays in place until the command 't' is given to start the TetRobot's mouse tracking. This is so the user has time to move their mouse to the desired location
before the TetRobot begins movement. 

<ol> 
  <li> &nbsp; 'm': highlight mouse </li>
<li> &nbsp; 't': toggle mouse tracking navigation (starts false) </li>
<li> &nbsp; 'r': reset </li>
<li> &nbsp; 'g': reset and begin animation </li>
<li> &nbsp; 'a': start/pause animation </li>
<li> &nbsp; '#': show/hide tiles </li>
<li> &nbsp; '^': show/hide current tetrahedron </li>
<li> &nbsp; 'h': show/hide ghost tetrahedra </li>
<li> &nbsp; 'b': show/hide body </li>
<li> &nbsp; 'l': show/hide legs </li>
<li> &nbsp; '-': toggle smooth motion </li>
</ol>

The TetRobot always moves towards the user's current mouse location. There also exists red cylindrical obstacles with
varying radius values throughout the canvas which the TetRobot cannot pass through. Putting your mouse somewhere behind an obstacle should be sufficient for testing this
functionality. In addition, if you put your mouse cursor inside of an obstacle (so the TetRobot has no way of actually getting to the goal), the TetRobot should go as close
to the goal as it can before stopping animation. Moving the cursor again to another location should make the TetRobot start moving again.
