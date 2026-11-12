final float PLAYER_WIDTH = 128;
final float PLAYER_HEIGHT = 220;
final float PLAYER_SPEED = 4;
final float PLAYER_DEPTH_SPEED = 2.4;
final float PLAYER_START_X = 640;
final float PLAYER_START_Y = 680;
final float FLOOR_TOP = 620;
final float FLOOR_BOTTOM = 710;

class Player {
  float x;
  float y;
  PImage img;

  boolean movingLeft = false;
  boolean movingRight = false;
  boolean movingUp = false;
  boolean movingDown = false;

  Player(PImage img) {
    this.img = img;
    resetPosition();
  }

  void resetPosition() {
    x = PLAYER_START_X;
    y = PLAYER_START_Y;
  }

  void update() {
    float dx = 0;
    float dy = 0;
    if (movingLeft)  dx -= PLAYER_SPEED;
    if (movingRight) dx += PLAYER_SPEED;
    if (movingUp)    dy -= PLAYER_DEPTH_SPEED;
    if (movingDown)  dy += PLAYER_DEPTH_SPEED;

    x = constrain(x + dx, PLAYER_WIDTH / 2, width - PLAYER_WIDTH / 2);
    y = constrain(y + dy, FLOOR_TOP, FLOOR_BOTTOM);
  }

  void display() {
    noStroke();
    fill(INK, 60);
    ellipse(x, y, 100, 18);

    image(img, x - PLAYER_WIDTH / 2, y - PLAYER_HEIGHT, PLAYER_WIDTH, PLAYER_HEIGHT);
  }

  void setMoveKey(char k, int code, boolean isDown) {
    if (k == 'a' || k == 'A' || (k == CODED && code == LEFT))  movingLeft = isDown;
    if (k == 'd' || k == 'D' || (k == CODED && code == RIGHT)) movingRight = isDown;
    if (k == 'w' || k == 'W' || (k == CODED && code == UP))    movingUp = isDown;
    if (k == 's' || k == 'S' || (k == CODED && code == DOWN))  movingDown = isDown;
  }
}
