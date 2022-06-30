import controlP5.*;

ControlP5 cp5;

Slider maxSpeedSlider;

Slider sightAngleSlider;

// Force de separation 
Slider separationForceSlider;
Slider separationPerceptionRadiusSlider;
CheckBox showSeparationFovCheckBox;

// Force de cohesion 
Slider cohesionForceSlider;
Slider cohesionPerceptionRadiusSlider;
CheckBox showCohesionFovCheckBox;

// Force d'alignement
Slider alignForceSlider;
Slider alignPerceptionRadiusSlider;
CheckBox showAlignFovCheckBox;

// Errance
CheckBox wanderForceCheckBox;

// QuadTree
CheckBox showQuadTreeCheckBox;
CheckBox showQuadTreePerceptionCheckBox;
Slider quadTreePerceptionRadiusSlider;

RadioButton boidObstacleRadioButton;

Button settingsMenuButton;
Accordion settingsMenu;
boolean showSettings = false;

PFont titleFont;


void setupUI() {
    cp5 = new ControlP5(this); // Initialisation de ControlP5
    titleFont = createFont("Arial", 12);
    setupSettingsMenu();
}

void setupSettingsMenu() {
    settingsMenuButton = cp5.addButton("SettingsButton").setCaptionLabel("Settings").setValue(0).setPosition(5,2).setSize(60, 16);


    // ================== MENU DEROULANT ===================
    settingsMenu = cp5.addAccordion("Settings").setPosition(5, 22).setWidth(150).addItem(setupBoidsManagerGroup()).addItem(setupTerrainManagerGroup());

    settingsMenu.setCollapseMode(Accordion.MULTI);
    settingsMenu.setVisible(showSettings);

    maxSpeedSlider.setValue(2);
    separationForceSlider.setValue(1);
    separationPerceptionRadiusSlider.setValue(1);
    cohesionForceSlider.setValue(1);
    cohesionPerceptionRadiusSlider.setValue(1);
    alignForceSlider.setValue(1);
    alignPerceptionRadiusSlider.setValue(1);
    sightAngleSlider.setValue(100);
    quadTreePerceptionRadiusSlider.setValue(1);
}


Group setupTerrainManagerGroup() {
    Group terrainManagerGroup = cp5.addGroup("TerrainManagerGroup").setLabel("Terrain Manager").setBackgroundColor(color(138, 175, 255, 180)).setHeight(20);
    terrainManagerGroup.setBackgroundHeight(140);

    float y=4;
    cp5.addTextlabel("QuadTreeLabel")
    .setText("Quad Tree")
    .setFont(titleFont)
    .setPosition(2, y)
    .setColorValue(color(22, 34, 108))
    .moveTo(terrainManagerGroup)
    ;

    y+=20;
    showQuadTreeCheckBox = cp5.addCheckBox("ShowQuadTree").setPosition(4, y).setSize(13, 13).addItem("QuadTree", 0).moveTo(terrainManagerGroup);

    y+=15;
    showQuadTreePerceptionCheckBox = cp5.addCheckBox("QuadTreePerceptionRadius").setPosition(4, y).setSize(13, 13).addItem("Perception", 0).moveTo(terrainManagerGroup);

    y+=20;
    quadTreePerceptionRadiusSlider = cp5.addSlider("PerceptionRadius").setColorForeground(color(95, 211, 189)).setPosition(4, y).setSize(144, 20).setRange(0, 5).moveTo(terrainManagerGroup);
    quadTreePerceptionRadiusSlider.getCaptionLabel().align(ControlP5.LEFT, ControlP5.CENTER);
    quadTreePerceptionRadiusSlider.getValueLabel().align(ControlP5.RIGHT, ControlP5.CENTER);

    y+=25;
    boidObstacleRadioButton = cp5.createRadioButton("boidObstacle").setPosition(4, y).setSize(15, 15).setItemPerRows(2).setSpacingColumn(50).addItem("Boid", 1).addItem("Obs", 2).moveTo(terrainManagerGroup);
    return terrainManagerGroup;
}



Group setupBoidsManagerGroup() {
    Group boidsManagerGroup = cp5.addGroup("BoidsManagerGroup").setLabel("Boids Manager").setBackgroundColor(color(138, 175, 255, 180)).setHeight(20);
    boidsManagerGroup.setBackgroundHeight(430);
    
    float y = 4;
    cp5.addTextlabel("SpeedLabel")
    .setText("Speed")
    .setFont(titleFont)
    .setPosition(2, y)
    .setColorValue(color(22, 34, 108))
    .moveTo(boidsManagerGroup)
    ;
    y+=20;
    maxSpeedSlider = cp5.addSlider("MaxSpeed").setColorForeground(color(95, 211, 189)).setPosition(4, y).setSize(144, 20).setRange(0, 5).moveTo(boidsManagerGroup).setNumberOfTickMarks(6);

    maxSpeedSlider.getCaptionLabel().align(ControlP5.LEFT, ControlP5.CENTER);
    maxSpeedSlider.getValueLabel().align(ControlP5.RIGHT, ControlP5.CENTER);


    // =================== UI CHAMP DE VUE DE L'AGENT ======================
    y+=25;
    cp5.addTextlabel("SightLabel")
    .setText("Sight")
    .setFont(titleFont)
    .setPosition(2, y)
    .setColorValue(color(22, 34, 108))
    .moveTo(boidsManagerGroup)
    ;

    y+=20;
    sightAngleSlider = cp5.addSlider("SightAngle").setColorForeground(color(95, 211, 189)).setPosition(4, y).setSize(144, 20).setRange(0, 100).moveTo(boidsManagerGroup);

    sightAngleSlider.getCaptionLabel().align(ControlP5.LEFT, ControlP5.CENTER);
    sightAngleSlider.getValueLabel().align(ControlP5.RIGHT, ControlP5.CENTER);


    // ====================  UI FORCE DE SEPARATION ====================
    y+=25;
    cp5.addTextlabel("SeparationLabel")
    .setText("Separation")
    .setFont(titleFont)
    .setPosition(2, y)
    .setColorValue(color(22, 34, 108))
    .moveTo(boidsManagerGroup)
    ;

    y+=20;
    separationForceSlider = cp5.addSlider("SeparationForce").setColorForeground(color(95, 211, 189)).setPosition(4, y).setSize(144, 20).setRange(0, 5).moveTo(boidsManagerGroup);

    separationForceSlider.getCaptionLabel().align(ControlP5.LEFT, ControlP5.CENTER);
    separationForceSlider.getValueLabel().align(ControlP5.RIGHT, ControlP5.CENTER);

    y+=25;
    separationPerceptionRadiusSlider = cp5.addSlider("PercceptionRadius").setColorForeground(color(95, 211, 189)).setPosition(4, y).setSize(144, 20).setRange(0, 5).moveTo(boidsManagerGroup);

    separationPerceptionRadiusSlider.getCaptionLabel().align(ControlP5.LEFT, ControlP5.CENTER);
    separationPerceptionRadiusSlider.getValueLabel().align(ControlP5.RIGHT, ControlP5.CENTER);

    y+=20;
    showSeparationFovCheckBox = cp5.addCheckBox("ShowSeparationFov").setPosition(4, y).setSize(13, 13).addItem("Separation FOV", 0).moveTo(boidsManagerGroup);


    // ====================  UI FORCE DE COHESION ====================
    y+=25;
    cp5.addTextlabel("CohesionLabel")
    .setText("Cohesion")
    .setFont(titleFont)
    .setPosition(2, y)
    .setColorValue(color(22, 34, 108))
    .moveTo(boidsManagerGroup)
    ;

    y+=20;
    cohesionForceSlider = cp5.addSlider("CohesionForce").setColorForeground(color(95, 211, 189)).setPosition(4, y).setSize(144, 20).setRange(0, 5).moveTo(boidsManagerGroup);

    cohesionForceSlider.getCaptionLabel().align(ControlP5.LEFT, ControlP5.CENTER);
    cohesionForceSlider.getValueLabel().align(ControlP5.RIGHT, ControlP5.CENTER);

    y+=25;
    cohesionPerceptionRadiusSlider = cp5.addSlider("CohesionRadius").setColorForeground(color(95, 211, 189)).setPosition(4, y).setSize(144, 20).setRange(0, 5).moveTo(boidsManagerGroup);

    cohesionPerceptionRadiusSlider.getCaptionLabel().align(ControlP5.LEFT, ControlP5.CENTER);
    cohesionPerceptionRadiusSlider.getValueLabel().align(ControlP5.RIGHT, ControlP5.CENTER);

    y+=20;
    showCohesionFovCheckBox = cp5.addCheckBox("ShowCohesionFov").setPosition(4, y).setSize(13, 13).addItem("Cohesion FOV", 0).moveTo(boidsManagerGroup);


    // ====================  UI FORCE D'ALIGNEMENT ====================
    y+=25;
    cp5.addTextlabel("AlignLabel")
    .setText("Align")
    .setFont(titleFont)
    .setPosition(2, y)
    .setColorValue(color(22, 34, 108))
    .moveTo(boidsManagerGroup)
    ;
    y+=20;
    alignForceSlider = cp5.addSlider("AlignForce").setColorForeground(color(95, 211, 189)).setPosition(4, y).setSize(144, 20).setRange(0, 5).moveTo(boidsManagerGroup);

    alignForceSlider.getCaptionLabel().align(ControlP5.LEFT, ControlP5.CENTER);
    alignForceSlider.getValueLabel().align(ControlP5.RIGHT, ControlP5.CENTER);

    y+=25;
    alignPerceptionRadiusSlider = cp5.addSlider("AlignRadius").setColorForeground(color(95, 211, 189)).setPosition(4, y).setSize(144, 20).setRange(0, 5).moveTo(boidsManagerGroup);

    alignPerceptionRadiusSlider.getCaptionLabel().align(ControlP5.LEFT, ControlP5.CENTER);
    alignPerceptionRadiusSlider.getValueLabel().align(ControlP5.RIGHT, ControlP5.CENTER);

    y+=20;
    showAlignFovCheckBox = cp5.addCheckBox("ShowAlignFov").setPosition(4, y).setSize(13, 13).addItem("Align FOV", 0).moveTo(boidsManagerGroup);

    y+=20;
    wanderForceCheckBox = cp5.addCheckBox("WanderForce").setPosition(4, y).setSize(13, 13).addItem("Enable Wander", 0).moveTo(boidsManagerGroup);
    return boidsManagerGroup;
}


/* Fonction gérant les events sur les différents composants de l'interface de contrôle */
void controlEvent(ControlEvent event) {
    if(event.isFrom("SettingsButton")) {
        if(settingsMenu != null) {
            showSettings = !showSettings;
            settingsMenu.setVisible(showSettings);
        }
    } else if(event.isFrom("ShowFov")) {
        
    }
}