// Noise meter
final float METER_X = 510;
final float METER_Y = 14;
final float METER_SLOT_X = METER_X + 64;   // the slot inside the meter sprite
final float METER_SLOT_Y = METER_Y + 20;
final float METER_SLOT_WIDTH = 180;
final float METER_SLOT_HEIGHT = 16;

// Basket counter
final float BASKET_X = 1100;
final float BASKET_Y = 14;
final float BASKET_TEXT_X = 1160;
final float BASKET_TEXT_Y = 42;

// Weather label
final float WEATHER_LABEL_RIGHT = 1268;
final float WEATHER_LABEL_Y = 92;
final float WEATHER_LABEL_HEIGHT = 28;
final float WEATHER_LABEL_PADDING = 12;

// Help menu and the win screen
final float PANEL_X = 260;
final float PANEL_Y = 100;
final float PANEL_WIDTH = 760;
final float PANEL_HEIGHT = 520;
final float PANEL_TITLE_Y = 185;
final float BODY_X = 320;
final float BODY_Y = 250;
final float BODY_WIDTH = 640;
final float BODY_HEIGHT = 220;


void drawNoiseMeter() {
  image(noiseMeterImage, METER_X, METER_Y, 260, 56);

  float barWidth = constrain(map(micLevel, 0, NOISE_MAX, 0, METER_SLOT_WIDTH), 0, METER_SLOT_WIDTH);
  noStroke();
  if (micLevel > NOISE_THRESHOLD) {
    fill(LOUD_RED);
  } else {
    fill(QUIET_GREEN);
  }
  rect(METER_SLOT_X, METER_SLOT_Y, barWidth, METER_SLOT_HEIGHT, 6);

  float thresholdX = METER_SLOT_X + map(NOISE_THRESHOLD, 0, NOISE_MAX, 0, METER_SLOT_WIDTH);
  stroke(CREAM);
  strokeWeight(2);
  line(thresholdX, METER_SLOT_Y - 3, thresholdX, METER_SLOT_Y + METER_SLOT_HEIGHT + 3);
  noStroke();

  if (calmDownTimer > 0) {
    fill(0);
    textAlign(CENTER, TOP);
    textSize(16);
    text("Shh... too loud!", METER_X + 130, METER_Y + 60);
  }
  if (!micWorking) {
    fill(INK);
    textAlign(CENTER, TOP);
    textSize(14);
    text("no microphone found", METER_X + 130, METER_Y + 60);
  }
}

void drawCollectedCounter() {
  image(basketImage, BASKET_X, BASKET_Y, 60, 54);
  fill(INK);
  textAlign(LEFT, CENTER);
  textSize(22);
  text(recipe.totalCollected() + "/" + recipe.totalNeeded(), BASKET_TEXT_X, BASKET_TEXT_Y);
}

void drawWeatherLabel() {
  String label;
  if (hasWeather) {
    label = CITY_NAME + "   " + round(tempC) + "°C   " + weatherDescription(currentWeatherCode());
  } else {
    label = "Weather offline";
  }
  if (TEST_WEATHER_CODE >= 0 || TEST_NIGHT) {
    label += " (test)";
  }

  textSize(15);
  float labelWidth = textWidth(label) + 2 * WEATHER_LABEL_PADDING;
  float labelX = WEATHER_LABEL_RIGHT - labelWidth;

  fill(CREAM, 235);
  stroke(INK);
  strokeWeight(2);
  rect(labelX, WEATHER_LABEL_Y, labelWidth, WEATHER_LABEL_HEIGHT, 12);
  noStroke();

  fill(INK);
  textAlign(LEFT, CENTER);
  text(label, labelX + WEATHER_LABEL_PADDING, WEATHER_LABEL_Y + WEATHER_LABEL_HEIGHT / 2 - 1);
}

void drawPanel(String title) {
  noStroke();
  fill(40, 26, 16, 115);
  rect(0, 0, width, height);

  image(panelImage, PANEL_X, PANEL_Y, PANEL_WIDTH, PANEL_HEIGHT);

  fill(INK);
  textAlign(CENTER, CENTER);
  textSize(34);
  text(title, PANEL_X + PANEL_WIDTH / 2, PANEL_TITLE_Y);
}

void drawHelpMenu() {
  drawPanel("How to play");

  String howToPlay =
    "Collect every plant on your recipe card.\n"
    + "• Walk up to a plant: the three leaves above it show it is in reach. "
    + "Click it 3 times to pick it.\n"
    + "• Plants are shy. When it gets too loud they are startled and can't be picked "
    + "until it is quiet again. Keep an eye on the noise meter.\n"
    + "• Picked plants grow back after a moment. Only plants on the recipe count "
    + "towards your basket.\n\n"
    + "Move: arrow keys or W A S D     Collect: mouse click     Character: 1 / 2 / 3";

  fill(INK);
  textAlign(LEFT, TOP);
  textSize(17);
  textLeading(23);
  text(howToPlay, BODY_X, BODY_Y, BODY_WIDTH, BODY_HEIGHT);

  closeButton.display();
  restartButton.display();
  resumeButton.display();
}

void drawWinScreen() {
  drawPanel("Recipe complete!");

  String message =
    "Your basket is full: you gathered all " + recipe.totalNeeded()
    + " plants on the recipe.\n\n"
    + "The plant-creatures will be well looked after.\n"
    + "Press Restart for a new recipe.";

  fill(INK);
  textAlign(CENTER, TOP);
  textSize(20);
  textLeading(28);
  text(message, BODY_X, BODY_Y + 20, BODY_WIDTH, BODY_HEIGHT);

  winRestartButton.display();
}
