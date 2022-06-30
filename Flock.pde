class Flock {


    ArrayList<Boid> boids;
    ArrayList<Obstacle> obstacles;

    Flock() {
        boids = new ArrayList<Boid>();
        obstacles = new ArrayList<Obstacle>();
    }

    void addBoid(Boid boid) {
        boids.add(boid);
    }

    void removeBoid(Boid boid) {
        boids.remove(boid);
    }


    void addObstacle(Obstacle obs) {
        obstacles.add(obs);
    }

}