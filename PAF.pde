
Flock flock; // Instance du terrain
Quadtree qtree;
Circle queryCircle;
//ArrayList<Boid> querriedBoids;
Boid[] querriedBoids;

int boidNumber = 300;
int obstacleNumber = 5;



//Grid grid;

void setup() {
    size(800, 800);
    setupUI();

    // AMELIORATION PASSER LA LISTE DES BOIDS ET OBSTACLES EN PARAMETRE ICI
    this.flock = new Flock(); // Initialisation du terrain


    // Ajout de tous les agents au terrain
    for (int i = 0; i < boidNumber; i++) {
        Boid b = new Boid(random(width), random(height));
        flock.addBoid(b); // width-200 pour laisser de la place pour le panneau de contrôle
    }

    // Ajout des obstacles
    for(int i = 0; i < obstacleNumber; i++) {
        flock.addObstacle(new Obstacle(random(20, width-15), random(20, height-20), 10));
    }
    
}


void draw() {
    background(255, 255, 242);

    qtree = new Quadtree (new Rectangle (width/2 , height/2 , width/2 , height/2) , 8); // Recréation de l'arbre
    
    // Insertion de tous les boids dans l'arbre (n operations)
    for (Boid boid : flock.boids) {
        qtree.insert(boid);
        
    }


    // Recuperation des voisins de chaque boid (n log(n) operations en moyenne)
    for (Boid boid : flock.boids) {
        queryCircle = new Circle(boid.position.x, boid.position.y, 60 * quadTreePerceptionRadiusSlider.getValue());

        if(showQuadTreePerceptionCheckBox.getArrayValue()[0] == 1) {
            queryCircle.show();
        }
        
        querriedBoids = qtree.query(queryCircle, null);
        boid.flock(querriedBoids, flock.obstacles); // Gestion du comportement au sein des groupes
        boid.update(); // Actualisation de la position et des forces
        boid.edges(); // Gestion des bords du terrain
        boid.show(); // Affichage des agents
    }

    // Affichage des obstacles
    for(Obstacle obs : flock.obstacles) {
        obs.show();
    }

    qtree.show();
}

void mousePressed() {

    // Ajout de 5 boids a chaque click
    for(int i = 0; i< 5; i++) {
        flock.addBoid(new Boid(mouseX + random(-10, 10), mouseY + random(-10, 10)));
    }
}

