class Obstacle implements IDrawable {
    int radius;
    PVector position;
    float x, y;

    Obstacle(float x, float y, int radius) {
        this.radius = radius;
        this.position = new PVector(x, y);
        this.x = x;
        this.y = y;
    }

    void show() {
        noStroke();
        fill(245, 106, 106);
        ellipseMode(RADIUS);
        circle(position.x, position.y, radius);
    }
}