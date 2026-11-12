
// Needs the "Sound" library (Sketch -> Import Library -> Manage Libraries -> "Sound").

import processing.sound.*;

// ---------- Game states ----------
final int STATE_PLAYING = 0;
final int STATE_HELP = 1;
final int STATE_WON = 2;
int gameState = STATE_PLAYING;

// ---------- Plants ----------
final int NUM_PLANTS = 12;
final String[] ALL_SPECIES = { "bulbkin", "snapjaw", "moonbell", "bristlekin" };
final float PLANT_BASE_Y = 470;
final float FIRST_PLANT_X = 135;    // plant i stands at FIRST_PLANT_X + i * PLANT_SPACING
final float PLANT_SPACING = 84;     // keeps the row clear of the props at both ends of the bench

// ---------- Noise ----------
final float NOISE_THRESHOLD = 0.08;
final float NOISE_MAX = 0.25;
final float MIC_SMOOTHING = 0.2;
final int CALM_DOWN_FRAMES = 60;

// ---------- Colours ----------
final color INK = #3d2a1c;
final color CREAM = #f7ecd0;
final color QUIET_GREEN = color(122, 140, 62);
final color LOUD_RED = color(196, 88, 60);

// ---------- Images ----------
PImage greenhouseImage;
PImage[] plantImages = new PImage[ALL_SPECIES.length];
PImage[] characterImages = new PImage[3];
PImage disturbedImage, sparkleImage, pipFullImage, pipEmptyImage;
PImage recipeCardImage, noiseMeterImage, basketImage, checkImage;
PImage panelImage, buttonImage, closeButtonImage, helpButtonImage;
PFont uiFont;

// ---------- World ----------
ArrayList<Plant> plants = new ArrayList<Plant>();
Player player;
Recipe recipe = new Recipe();

// ---------- Buttons ----------
Button helpButton, closeButton, restartButton, resumeButton, winRestartButton;

// ---------- Microphone ----------
AudioIn mic;
Amplitude amplitude;
boolean micWorking = false;
float micLevel = 0;
int calmDownTimer = 0;


void setup() {
  size(1280, 720);
  uiFont = createFont("Georgia", 40, true);
  textFont(uiFont);

  loadAllImages();

  // Plant i gets species i % 4, so the four species take turns along the bench
  // and every species has 3 plants. They are created once and reset by resetGame().
  for (int i = 0; i < NUM_PLANTS; i++) {
    float x = FIRST_PLANT_X + i * PLANT_SPACING;
    int speciesIndex = i % ALL_SPECIES.length;
    plants.add(new Plant(x, PLANT_BASE_Y, ALL_SPECIES[speciesIndex], plantImages[speciesIndex]));
  }

  // Key 1 = Pip, 2 = Bram, 3 = Wren
  player = new Player(characterImages[0]);

  helpButton = new Button(1196, 12, 72, 72, helpButtonImage, "", true);
  closeButton = new Button(930, 140, 48, 48, closeButtonImage, "", true);
  restartButton = new Button(420, 500, 200, 58, buttonImage, "Restart", false);
  resumeButton = new Button(660, 500, 200, 58, buttonImage, "Resume", false);
  winRestartButton = new Button(540, 500, 200, 58, buttonImage, "Restart", false);

  setupMicrophone();
  setupWeather();
  resetGame();
  gameState = STATE_HELP;
}


void draw() {
  readMicrophone();
  updateCalmDown();
  updateWeather();

  if (gameState == STATE_PLAYING) {
    player.update();
  }
  boolean roomIsDisturbed = calmDownTimer > 0;
  for (Plant plant : plants) {
    plant.update(roomIsDisturbed);
  }

  // Draw back to front: background, rain on the glass, plants on the bench,
  // player on the floor, weather light over the scene, HUD, menus.
  image(greenhouseImage, 0, 0, 1280, 720);
  drawWeatherOutside();
  for (Plant plant : plants) {
    boolean showPips = gameState == STATE_PLAYING && plant.isInReach(player);
    plant.display(showPips);
  }
  player.display();
  drawWeatherLight();

  recipe.display();
  drawNoiseMeter();
  drawCollectedCounter();
  drawWeatherLabel();
  helpButton.display();

  if (gameState == STATE_HELP) {
    drawHelpMenu();
  } else if (gameState == STATE_WON) {
    drawWinScreen();
  }
}


void resetGame() {
  for (Plant plant : plants) {
    plant.reset();
  }
  recipe.generate(plants);
  calmDownTimer = 0;
  player.resetPosition();
  gameState = STATE_PLAYING;
}


// ---------- Input ----------

void keyPressed() {
  player.setMoveKey(key, keyCode, true);

  if (key == '1') player.img = characterImages[0];
  if (key == '2') player.img = characterImages[1];
  if (key == '3') player.img = characterImages[2];
}

void keyReleased() {
  player.setMoveKey(key, keyCode, false);
}

void mousePressed() {
  if (gameState == STATE_PLAYING) {
    if (helpButton.isMouseOver()) {
      gameState = STATE_HELP;
    } else {
      clickPlantUnderMouse();
    }
  } else if (gameState == STATE_HELP) {
    if (closeButton.isMouseOver() || resumeButton.isMouseOver()) {
      gameState = STATE_PLAYING;
    } else if (restartButton.isMouseOver()) {
      resetGame();
    }
  } else if (gameState == STATE_WON) {
    if (winRestartButton.isMouseOver()) {
      resetGame();
    }
  }
}

void clickPlantUnderMouse() {
  for (Plant plant : plants) {
    if (plant.isCollected || plant.isDisturbed || !plant.isInReach(player)) {
      continue;
    }
    if (plant.isMouseOver()) {
      boolean isPicked = plant.registerClick();
      if (isPicked) {
        if (recipe.wants(plant.species)) {
          recipe.addCollected(plant.species);
        }
        plant.collect();
        if (recipe.isComplete()) {
          gameState = STATE_WON;
        }
      }
      break;
    }
  }
}


// ---------- Microphone ----------

void setupMicrophone() {
  try {
    mic = new AudioIn(this, 0);
    mic.start();
    amplitude = new Amplitude(this);
    amplitude.input(mic);
    micWorking = true;
  }
  catch (Exception e) {
    println("Microphone not available: " + e.getMessage());
    micWorking = false;
  }
}

void readMicrophone() {
  if (!micWorking) {
    return;
  }
  float rawLevel = amplitude.analyze();
  // lerp moves micLevel only part of the way to the new value each frame,
  // so one short click or breath doesn't spike the level.
  micLevel = lerp(micLevel, rawLevel, MIC_SMOOTHING);
}

void updateCalmDown() {
  if (micLevel > NOISE_THRESHOLD) {
    calmDownTimer = CALM_DOWN_FRAMES;   // too loud -> keep resetting to 1 second
  } else if (calmDownTimer > 0) {
    calmDownTimer--;                    // quiet -> count down to calm
  }
}


// ---------- Loading ----------

void loadAllImages() {
  greenhouseImage = loadArt("greenhouse_background.png");

  for (int i = 0; i < ALL_SPECIES.length; i++) {
    plantImages[i] = loadArt("greenhouse_sprites/plant_" + ALL_SPECIES[i] + ".png");
  }

  characterImages[0] = loadArt("greenhouse_sprites/char_pip.png");
  characterImages[1] = loadArt("greenhouse_sprites/char_bram.png");
  characterImages[2] = loadArt("greenhouse_sprites/char_wren.png");

  disturbedImage = loadArt("fx/fx_disturbed.png");
  sparkleImage = loadArt("fx/fx_sparkle.png");

  pipFullImage = loadArt("ui/ui_pip_full.png");
  pipEmptyImage = loadArt("ui/ui_pip_empty.png");
  recipeCardImage = loadArt("ui/ui_recipe_card.png");
  noiseMeterImage = loadArt("ui/ui_noise_meter.png");
  basketImage = loadArt("ui/ui_basket.png");
  checkImage = loadArt("ui/ui_check.png");
  panelImage = loadArt("ui/ui_panel.png");
  buttonImage = loadArt("ui/ui_button.png");
  closeButtonImage = loadArt("ui/ui_close_button.png");
  helpButtonImage = loadArt("ui/ui_help_button.png");
}

PImage loadArt(String fileName) {
  PImage img = loadImage(fileName);
  if (img == null) {
    throw new RuntimeException("Missing image: put " + fileName + " in the sketch's data folder");
  }
  return img;
}

PImage plantImageFor(String species) {
  for (int i = 0; i < ALL_SPECIES.length; i++) {
    if (ALL_SPECIES[i].equals(species)) {
      return plantImages[i];
    }
  }
  return null;
}

String displayName(String species) {
  return species.substring(0, 1).toUpperCase() + species.substring(1);
}
