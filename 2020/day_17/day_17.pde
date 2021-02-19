import java.util.List;

float margin = 100;

/**
 * 2D Point class
 */
class Point {
  float x, y;

  Point(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void display() {
    strokeWeight(5);
    point(x, y);
  }

  /**
   * Return the distance from another point
   */
  float distanceFrom(Point other) {
    return sqrt(pow(other.y - y, 2) + pow(other.x - x, 2));
  }

  boolean equals(Object o) {
    if (this == o)
      return true;
    if (o == null)
      return false;
    if (getClass() != o.getClass())
      return false;
    Point point = (Point) o;
    return x == point.x && y == point.y;
  }
}


/**
 * Edge class, storing two points
 */
class Edge {
  Point a, b;

  Edge(Point a, Point b) {
    this.a = a;
    this.b = b;
  }


  boolean equals(Object o) {
    if (this == o)
      return true;
    if (o == null)
      return false;
    if (getClass() != o.getClass())
      return false;
    Edge edge = (Edge) o;
    return (a.equals(edge.a) && b.equals(edge.b)) || 
      (a.equals(edge.b) && b.equals(edge.a));
  }
}


/**
 * Circle class storing a center point and a radius
 */
class Circle {
  Point center;
  float radius;

  Circle(float x, float y, float radius) {
    center = new Point(x, y);
    this.radius = radius;
  }

  void display() {
    noFill();
    circle(center.x, center.y, radius * 2);
  }

  /**
   * Return true if the point is inside the circle
   */
  boolean isPointInside(Point point) {
    return point.distanceFrom(center) <= radius;
  }
}


/**
 * Triangle class holding 3 points
 */
class Triangle {
  Point a, b, c;
  Circle circumcenter = null;

  Triangle(Point a, Point b, Point c) {
    this.a = a;
    this.b = b;
    this.c = c;
  }

  Triangle(Edge edge, Point point) {
    this(edge.a, edge.b, point);
  }

  void display() {
    noFill();
    strokeWeight(1);
    triangle(a.x, a.y, b.x, b.y, c.x, c.y);
  }

  /**
   * Return true if the triangle has point as a vertex
   */
  boolean contains(Point p) {
    return a.equals(p) || b.equals(p) || c.equals(p);
  }

  /**
   * Compute the circumcenter circle
   * See : https://en.wikipedia.org/wiki/Circumscribed_circle#Triangles
   */
  Circle computeCircumcenter() {
    float d = 2 * (a.x * (b.y - c.y) + b.x * (c.y - a.y) + c.x * (a.y - b.y));

    float axy = pow(a.x, 2) + pow(a.y, 2);
    float bxy = pow(b.x, 2) + pow(b.y, 2);
    float cxy = (pow(c.x, 2) + pow(c.y, 2));

    float x = (1 / d) * (axy * (b.y - c.y) + bxy * (c.y - a.y) + cxy * (a.y - b.y));
    float y = (1 / d) * (axy * (c.x - b.x) + bxy * (a.x - c.x) + cxy * (b.x - a.x));

    float radius = dist(a.x, a.y, x, y);

    return new Circle(x, y, radius);
  }

  /**
   * Return the circumcenter if cached, otherwise compute it
   */
  Circle getCircumcenter() {
    if (circumcenter == null) {
      circumcenter = computeCircumcenter();
    }
    return circumcenter;
  }

  /**
   * Get list of edges
   */
  List<Edge> getEdges() {
    List<Edge> edges = new ArrayList<Edge>();
    edges.add(new Edge(a, b));
    edges.add(new Edge(b, c));
    edges.add(new Edge(c, a));
    return edges;
  }

  /**
   * Return true if the edge is shared
   */
  boolean shareEdge(Edge edge) {
    return getEdges().contains(edge);
  }

  @Override
    boolean equals(Object o) {
    if (this == o)
      return true;
    if (o == null)
      return false;
    if (getClass() != o.getClass())
      return false;
    Triangle triangle = (Triangle) o;
    return a.equals(triangle.a) && b.equals(triangle.b) && c.equals(triangle.c);
  }
}


/**
 * Custom class for parametric line equation
 * Useful to compute the super triangle
 */
class ParametricLine {
  float a, b;

  ParametricLine(Point p1, Point p2) {
    a = (p2.y - p1.y) / (p2.x - p1.x);
    b = p1.y - a * p1.x;
  }

  /**
   * Returns f(x) = ax + b
   */
  float eval(float x) {
    return a * x + b;
  }

  /**
   * Compute the intersection between two lines if exists
   */
  Point findIntersection(ParametricLine other) {
    if (a == other.a) return null;
    float xInter = (other.b - b) / (a - other.a);
    return new Point(xInter, eval(xInter));
  }

  void display(float from, float to) {
    strokeWeight(1);
    line(from, eval(from), to, eval(to));
  }
}


/**
 * Return a random point inside the window with margins
 */
Point randomPoint() {
  float randomX = random(margin, width - margin);
  float randomY = random(margin, height - margin);

  return new Point(randomX, randomY);
}


/**
 * Scatter random points on the canvas and return them as a list
 */
List<Point> pointScatter(int nPoints) {
  List<Point> points = new ArrayList<Point>();

  for (int i = 0; i < nPoints; i++) {
    points.add(randomPoint());
  }

  return points;
}


/**
 * Compute a triangle containing all the given points
 */
Triangle superTriangle(List<Point> points) {
  Point first = points.get(0);
  float minX = first.x, maxX = first.x;
  float minY = first.y, maxY = first.y;

  // Find bounding box of point cloud
  for (int i = 1; i < points.size(); i++) {
    Point point = points.get(i);

    if (point.x < minX) minX = point.x;
    if (point.x > maxX) maxX = point.x;
    if (point.y < minY) minY = point.y;
    if (point.y > maxY) maxY = point.y;
  }

  Point leftCorner = new Point(minX - 100, maxY + 10);
  Point rightCorner = new Point(maxX + 100, maxY + 10);

  // Construct sides as lines
  ParametricLine leftSide = new ParametricLine(leftCorner, new Point(minX - 5, minY - 5));
  ParametricLine rightSide = new ParametricLine(rightCorner, new Point(maxX + 5, minY - 5));

  // Compute intersection
  Point upCorner = leftSide.findIntersection(rightSide);

  return new Triangle(leftCorner, upCorner, rightCorner);
}


/**
 * Bowyer–Watson algorithm for computing delaunay triangulation
 * See : https://en.wikipedia.org/wiki/Bowyer%E2%80%93Watson_algorithm
 */
List<Triangle> delaunayTriangulate(List<Point> points) {
  List<Triangle> triangulation = new ArrayList<Triangle>();

  // Add the super triangle
  Triangle superTriangle = superTriangle(points);
  triangulation.add(superTriangle);

  // For every point
  for (Point point : points) {
    List<Triangle> badTriangles = new ArrayList<Triangle>();

    // Fill the array of bad triangles
    for (int i = triangulation.size() - 1; i >= 0; i--) {
      Triangle triangle = triangulation.get(i);

      // If the point is inside the circumcenter
      if (triangle.getCircumcenter().isPointInside(point)) {
        badTriangles.add(triangle);
      }
    }

    List<Edge> closeMesh = new ArrayList<Edge>();

    // For every bad triangle
    for (int i = 0; i < badTriangles.size(); i++) {
      // Get its list of edges
      List<Edge> edges = badTriangles.get(i).getEdges();

      // For every edge of that bad triangle
      for (Edge edge : edges) {
        boolean shared = false;

        // For every other bad triangles
        for (int j = 0; j < badTriangles.size(); j++) {
          // If it's different and share an edge
          if (j != i && badTriangles.get(j).shareEdge(edge)) {
            shared = true;
            break;
          }
        }

        // If it's not shared add it to the mesh
        if (!shared) closeMesh.add(edge);
      }
    }

    // Remove bad triangles from the triangulation
    for (Triangle badTriangle : badTriangles) {
      triangulation.remove(badTriangle);
    }

    // Re triangulate the mesh
    for (Edge edge : closeMesh) {
      triangulation.add(new Triangle(edge, point));
    }
  }

  // Remove triangles that have points connected to the super triangle
  for (int i = triangulation.size() - 1; i >= 0; i--) {
    Triangle triangle = triangulation.get(i);
    if (superTriangle.contains(triangle.a) || superTriangle.contains(triangle.b) || superTriangle.contains(triangle.c)) {
      triangulation.remove(i);
    }
  }

  return triangulation;
}


List<Point> points;
List<Triangle> triangulation;
float time = 0;


void setup() {
  size(500, 500);

  points = pointScatter(5);
  triangulation = delaunayTriangulate(points);
}


void draw() {
  background(255);

  // Display triangles
  for (int i = 0; i < triangulation.size(); i++) {
    Triangle triangle = triangulation.get(i);
    stroke(0, map(i, 0, triangulation.size(), 0, 255));
    triangle.display();
  }

  // Display points
  for (Point point : points) {
    point.display();
  }

  // Randomly add a point and retriangulate
  if (random(1) < 0.3) {
    points.add(randomPoint());
    triangulation = delaunayTriangulate(points);
  }
}
