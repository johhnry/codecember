import java.util.List;
import java.util.Stack;

float margin = 50;

LSystem lsystem;
int patterns = 0;


/*
* Custom transform class storing a location and a rotation
* Acts like a turtle with states
*/
class Transform {
  PVector location;
  float rotation;

  Transform(float x, float y, float rotation) {
    location = new PVector(x, y);
    this.rotation = rotation;
  }

  Transform(float x, float y) {
    this(x, y, 0);
  }

  void rotate(float amount) {
    rotation += amount;
  }

  void move(float amount) {
    location.add(PVector.fromAngle(rotation).mult(amount));
  }

  Transform copy() {
    return new Transform(location.x, location.y, rotation);
  }
}


/*
* The Rule class storing the pattern to replace
*/
class Rule {
  private String pattern, replace;

  public Rule(String pattern, String replace) {
    this.pattern = pattern;
    this.replace = replace;
  }

  public String getPattern() {
    return pattern;
  }

  public String getReplace() {
    return replace;
  }

  public String toString() {
    return pattern + " -> " + replace;
  }
}


/*
* Recursively generate a random pattern string used to produce a rule
* Give the length and the maximum depth of the pattern (with [ ])
*/
String generateRandomPattern(int length, int depth) {
  if (length == 0) return "";

  String result;
  float r = random(1);
  if (r < 0.2 && depth >= 1 && length > 1) {
    result = "[" + generateRandomPattern(length - 1, depth - 1) + "]";
  } else {
    if (r < 0.25) result = "+";
    else if (r > 0.25 && r < 0.5) result = "-";
    else result = "F";
  }

  return result + generateRandomPattern(length - 1, depth);
}


/*
* The L system class
 * https://en.wikipedia.org/wiki/L-system
 */
class LSystem {
  private String state;
  private float forward, rotation;
  private List<Rule> rules;
  private int step = 0;

  // The stack of transforms, used with [ and ]
  private Stack<Transform> transformStack;

  // The previous transform, useful to draw a line
  private Transform previousTransform;

  // The current position in the string of actions
  private int currentPosition = 0;

  public LSystem(String axiom, float forward, float rotation) {
    this.state = axiom;
    this.forward = forward;
    this.rotation = radians(rotation);
    this.rules = new ArrayList<Rule>();

    // Initialize the transform stack
    transformStack = new Stack<Transform>();
    previousTransform = new Transform(0, 0, 0);
    transformStack.push(previousTransform.copy());
  }

  // Add a rule to the L system
  public void addRule(Rule rule) {
    rules.add(rule);
  }

  // Apply all the rules
  public void step() {
    for (Rule rule : rules) {
      state = state.replaceAll(rule.getPattern(), rule.getReplace());
    }
    step++;
  }

  // Do count steps
  public void steps(int count) {
    for (int i = 0; i < count; i++) step();
  }

  public void display() {
    if (currentPosition == state.length()) return;

    Transform currentTransform = transformStack.peek();
    
    // For the current character check for each possibility
    switch(state.charAt(currentPosition)) {
    case 'F': // Move forward
      currentTransform.move(forward);

      stroke(0, 200);
      noFill();
      strokeWeight(1);
      line(previousTransform.location.x, previousTransform.location.y, currentTransform.location.x, currentTransform.location.y);
      previousTransform = currentTransform.copy();

      break;
    case '+': // Rotate left
      currentTransform.rotate(-rotation);
      break;
    case '-': // Rotate right
      currentTransform.rotate(rotation);
      break;
    case '[': // Store transform
      transformStack.push(currentTransform.copy());
      break;
    case ']': // Restore transform
      transformStack.pop();
      previousTransform = transformStack.peek().copy();
      break;
    }
    
    // Increase the position in the list
    currentPosition++;
  }

  public String getState() {
    return state;
  }

  public int getStep() {
    return step;
  }
  
  // Display the rules on the screen
  public void displayRules() {
    textAlign(CENTER, CENTER);
    fill(0);
    for (int i = 0; i < rules.size(); i++) {
      text(rules.get(i).toString(), width / 2, (i + 1) * 20);
    }

    text("angle : " + ceil(degrees(rotation)) + "°", width / 2, (rules.size() + 1) * 20);
  }
}

void setup() {
  size(500, 500);

  // Initialize the view
  resetView();
}


/*
* Clear the window and create a new L system
 */
void resetView() {
  background(255);

  // Get random angle and speed
  float angle = int(random(10, 50));
  float move = map(angle, 10, 50, 20, 5);

  // Create the L system and add a random generated pattern
  lsystem = new LSystem("F", move, angle);
  lsystem.addRule(new Rule("F", generateRandomPattern(7, 3)));

  // Compute replacement steps
  lsystem.steps(6);

  // Display the rules on the screen
  lsystem.displayRules();
}


void draw() {
  // Display the L system for 100 steps
  pushMatrix();
  translate(width / 2, height / 2);
  rotate(-HALF_PI);
  for (int i = 0; i < 100; i++) lsystem.display();
  popMatrix();

  // Load a new L-system after a certain time or the drawing is finished
  if (frameCount % 150 == 0 || lsystem.currentPosition == lsystem.getState().length()) {
    resetView();
  }
}
