/*
    Classe modélisant un Bird-oid (agent autonome)
*/
class Boid implements IDrawable {


    PVector position;
    PVector velocity;
    PVector acceleration;

    int size;
    float maxSpeed;
    float maxForce;
    float wanderAngle; // Angle utilisé pour l'errance de l'agent
    float sightAngle;


    // OBSTACLE TEMP
    int obstacleRadius = 30;
    float anticipationFactor = 2;
    float maxObstacleForce = 15;


    Boid(float x, float y) {
        this.position = new PVector(x, y);
        this.velocity = new PVector(random(-1,1), random(-1,1)); // Vitesse initiale arbitraire
        this.velocity.setMag(random(1,3));  // Vitesse initiale aleatoire
        this.acceleration = new PVector(0, 0);

        this.size = 5; // Parametre de taille du triangle
        this.maxSpeed = maxSpeedSlider.getValue(); // Vitesse maximale de l'agent
        this.maxForce = 0.05; // Norme maximale que peut avoir une force appliquée à l'agent

        this.wanderAngle = 0; // Angle permettant à l'agent d'avoir un mouvement aléatoire
        this.sightAngle = sightAngleSlider.getValue()*PI/100; // Angle du champ de vision de l'agent (rad)
    }


    /* Gere la collision de l'agent avec le bord */
    void edges() {
        if(this.position.x > width) {
            this.position.x = 0;
            //this.velocity.mult(-1);
            //this.position.x = width;
        } else if(this.position.x < 0) {
            this.position.x = width;
            //this.velocity.mult(-1);
            //this.position.x = 0;
        }
        
        if(this.position.y > height) {
            this.position.y = 0;
            //this.velocity.mult(-1);
            //this.position.y = height;
        } else if(this.position.y < 0) {
            this.position.y = height;
            //this.velocity.mult(-1);
            //this.position.y = 0;
        }
    }

    /* Applique une force à l'agent. Doit etre dans la methode flock */
    void applyForce(PVector force) {
        this.acceleration.add(force);
    }



    void update() {
        
        this.maxSpeed = maxSpeedSlider.getValue();
        this.sightAngle = sightAngleSlider.getValue()*PI/100;
        
        this.velocity.add(this.acceleration); // Vitesse obtenue en intégrant l'accélération
        this.velocity.limit(this.maxSpeed); // Limite de vitesse à laquelle peut se déplacer l'agent
        this.position.add(this.velocity); // Position obtenue en intégrant la vitesse
        
        if(wanderForceCheckBox.getArrayValue()[0] == 1) this.wander(); // Mouvement aléatoire de errance
        this.acceleration.set(0, 0); // L'accélération est recalculée en fonction de la force à chaque actualisation

    }

    /* Gère le comportement de l'agent dans un groupe. Elle applique à l'agent les forces :
        - alignement, pour que l'agent suive la direction générale du groupe
        - cohesion, pour que l'agent s'ajoute à un groupe
        - separation, pour maintenir une distance minimale entre l'agent et les autres membres du groupe */
   /* void flock(ArrayList<Boid> boids, ArrayList<Obstacle> obstacles) {
        PVector alignment = align(boids);
        PVector cohesion = cohesion(boids);
        PVector separation = separation(boids);

        // Modification de l'influence de chaque force en fonction des sliders
        alignment.mult(alignForceSlider.getValue());
        cohesion.mult(cohesionForceSlider.getValue());
        separation.mult(separationForceSlider.getValue());

        applyForce(separation);
        applyForce(alignment);
        applyForce(cohesion);

        
        for(Obstacle obstacle : obstacles) {
            applyForce(obstacleAvoidance(obstacle));
        }
        
    }*/

    void flock(Boid[] boids, ArrayList<Obstacle> obstacles) {
        PVector alignment = align(boids);
        PVector cohesion = cohesion(boids);
        PVector separation = separation(boids);

        // Modification de l'influence de chaque force en fonction des sliders
        alignment.mult(alignForceSlider.getValue());
        cohesion.mult(cohesionForceSlider.getValue());
        separation.mult(separationForceSlider.getValue());

        applyForce(separation);
        applyForce(alignment);
        applyForce(cohesion);

        
        for(Obstacle obstacle : obstacles) {
            applyForce(obstacleAvoidance(obstacle));
        }
        
    }


    /* Permet à l'agent d'avoir un mouvement en partie aléatoire, pour ne pas se déplacer qu'en ligne droite s'il n'appartient à aucun groupe.
        
        Elle génère un cercle devant l'agent.
        A chaque actualisation on prend un point sur ce cercle. Il est choisi aléatoirement autour de la direction du vecteur vitesse.
        A partir de ce point, on crée une force qui force l'agent à aligner son vecteur vitesse sur ce point */
    void wander() {
        // vecteur 100 pixels devant qui correspondra à la vitesse désirée après process.
        PVector wanderPoint = this.velocity.copy(); // Initialement, wanderPoint est aligné avec la vitesse
        wanderPoint.setMag(100);
        wanderPoint.add(this.position);
        
        /*fill(255, 0, 0);
        noStroke();
        circle(wanderPoint.x, wanderPoint.y, 8); */
        
        int wanderRadius = 50; // Rayon du cercle sur lequel on prend les valeurs d'angle
        /* noFill();
        stroke(255);
        circle(wanderPoint.x, wanderPoint.y, wanderRadius*2); */

        float theta = this.wanderAngle + this.velocity.heading(); // L'angle correspondant au point sélectionné sur le cercle est calculé à partir de la direction du vecteur vitesse

        // Conversion de l'angle sélection en coordonnées cartésiennes
        float x = wanderRadius*cos(theta);
        float y = wanderRadius*sin(theta);

        wanderPoint.add(x,y); // Fait dévier le vecteur wanderPoint initialement aligné avec le vecteur vitesse

        /* fill(0,255,0);
        noStroke();
        circle(wanderPoint.x, wanderPoint.y, 16); */

        PVector steering = wanderPoint.sub(this.position); // Force à appliquer a l'agent pour le faire dévier vers le point désiré
        steering.limit(this.maxForce); // Norme de la force limitée pour que l'agent ne s'aligne pas instantanément sur la position calculée.

        //steering.mult(wanderSlider.getValue());

        applyForce(steering);

        float displaceRange = 2;
        this.wanderAngle = random(-displaceRange, displaceRange);
    }



    /* Fonction calculant le vecteur force à appliquer à l'agent pour le faire s'aligner sur les autres membres du groupe */
    PVector align(Boid[] boids) {
        float perceptionRadius = 50 * alignPerceptionRadiusSlider.getValue(); // Distance maximale à laquelle doit se trouver un autre agent pour être considéré comme son voisin
        int neighborCount = 0; // Compte le nombre de voisins de l'agent à une distance plus petite de 100 
        //PVector desiredSpeed = new PVector(0, 0);
        PVector steering = new PVector(0,0);

        for(Boid other : boids) {
            PVector comparisionVector = PVector.sub(other.position, this.position);
            // Calcule la distance du boid avec tous les autres
            //float d = dist(this.position.x, this.position.y, other.position.x, other.position.y);
            float d = PVector.dist(this.position, other.position);
            float diffAngle = PVector.angleBetween(comparisionVector, this.velocity);
            if((d < perceptionRadius) && (other != this) && (diffAngle < this.sightAngle)) {
                //desiredSpeed.add(other.velocity); // Prend en compte la vitesse des voisins les plus proches du boid
                steering.add(other.velocity);
                neighborCount++;
            }
            
        }

        // steering.add(other.velocity);

        // steering.setMag(this.maxSpeed).sub(this.velocity).limit(this.maxForce);

        if(neighborCount >  0) {
            //desiredSpeed.div(neighborCount); // Valeur moyenne des vecteurs vitesse de tous les voisins de l'agent
            /*desiredSpeed.setMag(this.maxSpeed);
            steering = desiredSpeed.sub(this.velocity); // Force à appliquer au boid pour qu'il change de direction
            steering.limit(this.maxForce); // Limite la force pour qu'il ne tourne pas instantanément*/

            steering.setMag(this.maxSpeed).sub(this.velocity).limit(this.maxForce);
        }

        showFovIfChecked(showAlignFovCheckBox, perceptionRadius);
        return steering;
        
    }


    /* Fonction gérant la cohésion de l'agent avec les autres membres du groupe */
    PVector cohesion(Boid[] boids) {
        float perceptionRadius = 50 * cohesionPerceptionRadiusSlider.getValue(); // Distance maximale à laquelle doit se trouver un autre agent pour être considéré comme son voisin
        int neighborCount = 0; // Compte le nombre de voisins de l'agent à une distance plus petite de 100 
        //PVector desiredPosition = new PVector(0, 0);
        PVector steering = new PVector(0,0);

        for(Boid other : boids) {
            PVector comparisionVector = PVector.sub(other.position, this.position);
            // Calcule la distance du boid avec tous les autres
            //float d = dist(this.position.x, this.position.y, other.position.x, other.position.y);

            //float d = PVector.dist(this.position, other.position);
            //float dsq = (this.position.x-other.position.x)*(this.position.x-other.position.x) + (this.position.y-other.position.y)*(this.position.y-other.position.y);
            float dSquarred = distSquarred(this.position.x-other.position.x, this.position.y-other.position.y);
            float diffAngle = abs(PVector.angleBetween(comparisionVector, this.velocity));
            if((dSquarred < square(perceptionRadius)) && (other != this) && (diffAngle < this.sightAngle)) {
                //desiredPosition.add(other.position); // Prend en compte la vitesse des voisins les plus proches du boid
                steering.add(other.position);

                neighborCount++;
            }
            
        }

        if(neighborCount >  0) {
            /*desiredPosition.div(neighborCount); // Position moyenne de tous les voisins de l'agent (equivalent à une force)
            desiredPosition.sub(this.position); // Force à appliquer au boid pour qu'il change de direction
            desiredPosition.setMag(this.maxSpeed); // Fixe la nome du vecteur pointant vers la position désirée à maxSpeed
            steering = desiredPosition.sub(this.velocity);
            steering.limit(this.maxForce); // Limite la force pour qu'il ne tourne pas instantanément
            */
            steering.div(neighborCount).sub(this.position).setMag(this.maxSpeed).sub(this.velocity).limit(this.maxForce);
        }

        // steering.add(other.position);
        // steering.div(neighborCount).sub(this.position).setMag(this.maxSpeed).sub(this.velocity).limit(this.maxForce);

        showFovIfChecked(showCohesionFovCheckBox, perceptionRadius);
        
        return steering;

        
    }


    /* Fonction gérant la distance minimale de l'agent à ses voisins */
    PVector separation(Boid[] boids) {
        float perceptionRadius = 25 * separationPerceptionRadiusSlider.getValue(); // Distance maximale à laquelle doit se trouver un autre agent pour être considéré comme son voisin
        int neighborCount = 0; // Compte le nombre de voisins de l'agent à une distance plus petite de 100 
        //PVector desiredPosition = new PVector(0, 0);
        PVector steering = new PVector(0,0);
        PVector diff;

        for(Boid other : boids) {
            PVector comparisionVector = PVector.sub(other.position, this.position);
            // Calcule la distance du boid avec tous les autres
            //float d = dist(this.position.x, this.position.y, other.position.x, other.position.y);
            // float d = PVector.dist(this.position, other.position);
            float dSquarred = distSquarred(this.position.x-other.position.x, this.position.y-other.position.y);

            float diffAngle = PVector.angleBetween(comparisionVector, this.velocity);
            if((dSquarred < square(perceptionRadius)) && (other != this) && (diffAngle < this.sightAngle)) {
                diff = new PVector().sub(this.position, other.position);
                diff.div(sqrt(dSquarred));
                //desiredPosition.add(diff); // Prend en compte la vitesse des voisins les plus proches du boid
                steering.add(diff);
                neighborCount++;
            }
            
        }

        // steering.add(diff);
        // steering.setMag(this.maxSpeed).sub(this.velocity).limit(this.maxForce);

        
        if(neighborCount >  0) {
            /*desiredPosition.setMag(this.maxSpeed); // Fixe la nome du vecteur pointant vers la position désirée à maxSpeed
            steering = desiredPosition.sub(this.velocity);
            steering.limit(this.maxForce); // Limite la force pour qu'il ne tourne pas instantanément*/
            steering.setMag(this.maxSpeed).sub(this.velocity).limit(this.maxForce);
        }

        showFovIfChecked(showSeparationFovCheckBox, perceptionRadius);
        return steering;
        
    }

    /* Evitement des obstacles */
    PVector obstacleAvoidance(Obstacle obstacle) {
        PVector obstacleAvoidanceSpeed = new PVector(0, 0);
        PVector orientedFieldOfView = new PVector(0, 0);
        PVector steeringForce = new PVector(0, 0);

        boolean obstacleVisible = false;

        float numPoints = 170;
        float step = 1/numPoints;
        float theta = 0;
        float i = 0;
        float d = 0;

        PVector posCopy = this.position.copy();
        PVector velCopy = this.velocity.copy();

        //orientedFieldOfView = posCopy.add(velCopy.rotate(theta).setMag(obstacleRadius));

        
        // Determination de la nouvelle direction
        do {
            posCopy = this.position.copy();
            velCopy = this.velocity.copy();

            
            theta = 2*PI*step*i;

            orientedFieldOfView = posCopy.add(velCopy.rotate(theta).setMag(obstacleRadius));

            /*noStroke();
            fill(0, 255, 0);
            circle(orientedFieldOfView.x, orientedFieldOfView.y, 2);*/
            d = dist(orientedFieldOfView.x, orientedFieldOfView.y, obstacle.position.x, obstacle.position.y);

            if( i <= 0) i = -i + 1;
            else i = -i;
        } while (d < anticipationFactor * obstacle.radius);

        if(theta != 0) {
            obstacleAvoidanceSpeed.add(velCopy.rotate(theta));
            obstacleVisible = true;
        }
        
        if(obstacleVisible) {
            //obstacleAvoidanceSpeed.div(numberNeighbor);
            obstacleAvoidanceSpeed.setMag(maxSpeed);
            steeringForce = obstacleAvoidanceSpeed.sub(this.velocity);
            steeringForce.limit(maxObstacleForce);

        }
        
        return steeringForce;
    }



    // ========================= AFFICHAGE BOID + DEBUG ============================

    /* Gère l'affichage de l'agent */
    void show() {
        //stroke(255);
        //strokeWeight(2);
        noStroke();
        fill(22, 34, 108);
        
        push();
        translate(this.position.x, this.position.y); // Translation à la position de l'agent
        rotate(this.velocity.heading()); // L'agent pointe vers la cible
        triangle(-this.size, -this.size/2, -this.size, this.size/2, this.size, 0); // Coordonnées des points du triangle
        pop();
        

    }


    void showFovIfChecked(CheckBox controller, float perceptionRadius) {
        if(controller.getArrayValue()[0] == 1) {
            float currentHeading = this.velocity.heading();
            pushMatrix();
            translate(this.position.x, this.position.y);
            rotate(currentHeading);
            fill(95, 211, 189, 90);
            arc(0, 0, perceptionRadius*2, perceptionRadius*2, -this.sightAngle, this.sightAngle);
            popMatrix();
        }
    }

    float distSquarred(float x, float y) {
        return x*x+y*y;
    }

    float square(float x) {
        return x*x;
    }

}