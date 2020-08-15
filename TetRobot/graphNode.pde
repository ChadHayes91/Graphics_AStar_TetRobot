class GraphNode
{
    public pt location;
    public GraphNode parent;
    public char dirFromParent;
    public float distFromStart;
    public float heuristicValue;
    public float mixed;
    public ArrayList<Character> pathTo;
    
    public pt front;
    public pt right;
    public pt left;
  
    public GraphNode(pt front, pt left, pt right)
    {
        this.front = front;
        this.right = right;
        this.left = left;
        this.location = P(front, left, right);
        this.location.z = 0;
        this.dirFromParent = 'S';
        this.parent = null;
        this.mixed = 0;
        this.pathTo = new ArrayList<Character>();
    }
    
    public GraphNode(GraphNode parent, char dir, pt goalPt)
    {
        if (dir == 'R') {
            this.right = parent.right;
            this.left = parent.front;
            this.front = getEndPoint(parent, dir);
        } else if (dir == 'L') {
            this.left = parent.left;
            this.right = parent.front;
            this.front = getEndPoint(parent, dir);
        } else if (dir == 'O') {
            this.right = parent.left;
            this.left = parent.right;
            this.front = getEndPoint(parent, dir);
        }
        
        this.location = P(front, left, right);
        this.location.z = 0;
        
        this.dirFromParent = dir;
        this.distFromStart = parent.distFromStart + distance(this.location, parent.location, false);
        this.heuristicValue = distance(this.location, goalPt, false);
        this.mixed = this.distFromStart + this.heuristicValue;
        this.pathTo = new ArrayList<Character>(parent.pathTo);
        this.pathTo.add(new Character(dir));
        this.parent = parent;
    }
    
    public void setNumbers(float g, float h)
    {
        this.distFromStart = g;
        this.heuristicValue = h;
        this.mixed = g + h;
    }
    
    private pt getEndPoint(GraphNode reference, char dir)
    {
        pt anchor = P(0,0,0);
        vec direction = V(0,0,0);
        if (dir == 'R') {
            anchor = reference.front;
            direction = V(reference.left, reference.right);
        } else if (dir == 'L') {
            anchor = reference.front;
            direction = V(reference.right, reference.left);
        } else if (dir == 'O') {
            anchor = reference.left;
            direction = V(reference.front, reference.right);
        }

        pt end = P(anchor, direction);
        return end;
    }
}
