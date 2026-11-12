final float PLANT_WIDTH = 80;
final float PLANT_HEIGHT = 100;
final int CLICKS_TO_COLLECT = 3;
final float REACH_DISTANCE = 90;
final int RESPAWN_FRAMES = 60;
final int SPARKLE_FRAMES = 20;

final float BOUNCE_HEIGHT = 2;
final float BOUNCE_SPEED = 0.05;
final float DISTURBED_BOUNCE_FACTOR = 4;   // startled plants bounce 4x faster

final float PIP_SIZE = 22;
final float PIP_SPACING = 24;
final float PIP_GAP = 26;               // pips sit this far above the plant
final float DISTURBED_GAP = 44;         // startle marks sit this far above the plant

class Plant {
  float x;
  float baseY;
  String species;
  PImage img;

  float bounceY;            // how far the plant is lifted (0 = on the bench)
  boolean isGoingUp = true;

  int clickCount = 0;
  boolean isCollected = false;
  boolean isDisturbed = false;
  int respawnTimer = 0;
  int sparkleTimer = 0;

  Plant(float x, float baseY, String species, PImage img) {
    this.x = x;
    this.baseY = baseY;
    this.species = species;
    this.img = img;

    bounceY = random(BOUNCE_HEIGHT);
  }

  void reset() {
    isCollected = false;
    clickCount = 0;
    respawnTimer = 0;
    sparkleTimer = 0;
  }

  void update(boolean roomIsDisturbed) {
    isDisturbed = roomIsDisturbed;

    float speed = BOUNCE_SPEED;
    if (isDisturbed) {
      speed = BOUNCE_SPEED * DISTURBED_BOUNCE_FACTOR;
    }
    if (isGoingUp) {
      bounceY += speed;
    } else {
      bounceY -= speed;
    }
    if (bounceY >= BOUNCE_HEIGHT) {
      isGoingUp = false;
    }
    if (bounceY <= 0) {
      isGoingUp = true;
    }

    if (sparkleTimer > 0) {
      sparkleTimer--;
    }

    if (isCollected && respawnTimer > 0) {
      respawnTimer--;
      if (respawnTimer == 0) {
        isCollected = false;
        clickCount = 0;
      }
    }
  }

  void display(boolean showPips) {
    if (!isCollected) {
      image(img, x - PLANT_WIDTH / 2, baseY - PLANT_HEIGHT - bounceY, PLANT_WIDTH, PLANT_HEIGHT);

      if (showPips) {
        drawPips();
      }
      if (isDisturbed) {
        float marksY = baseY - PLANT_HEIGHT - DISTURBED_GAP;
        if (showPips) {
          marksY -= PIP_GAP;
        }
        image(disturbedImage, x - 36, marksY, 72, 42);
      }
    }
    if (sparkleTimer > 0) {
      drawSparkle();
    }
  }

  void drawPips() {
    float rowWidth = (CLICKS_TO_COLLECT - 1) * PIP_SPACING + PIP_SIZE;
    float startX = x - rowWidth / 2;
    float pipY = baseY - PLANT_HEIGHT - PIP_GAP;
    for (int i = 0; i < CLICKS_TO_COLLECT; i++) {
      PImage pip = pipEmptyImage;
      if (i < clickCount) {
        pip = pipFullImage;
      }
      image(pip, startX + i * PIP_SPACING, pipY, PIP_SIZE, PIP_SIZE);
    }
  }

  void drawSparkle() {
    float progress = 1 - (float) sparkleTimer / SPARKLE_FRAMES;
    float size = 64 * (1 + progress * 0.5);
    float centreY = baseY - PLANT_HEIGHT / 2;
    tint(255, 255 * (1 - progress));
    image(sparkleImage, x - size / 2, centreY - size / 2, size, size);
    noTint();
  }

  boolean isMouseOver() {
    return mouseX > x - PLANT_WIDTH / 2 && mouseX < x + PLANT_WIDTH / 2
      && mouseY > baseY - PLANT_HEIGHT && mouseY < baseY;
  }

  boolean isInReach(Player player) {
    return abs(player.x - x) <= REACH_DISTANCE;
  }

  boolean registerClick() {
    clickCount++;
    return clickCount >= CLICKS_TO_COLLECT;
  }

  void collect() {
    isCollected = true;
    sparkleTimer = SPARKLE_FRAMES;
    respawnTimer = RESPAWN_FRAMES;
  }
}
