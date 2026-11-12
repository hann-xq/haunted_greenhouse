class Button {
  float x, y;
  float w, h;
  PImage img;
  String label;
  boolean isRound;

  Button(float x, float y, float w, float h, PImage img, String label, boolean isRound) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.img = img;
    this.label = label;
    this.isRound = isRound;
  }

  boolean isMouseOver() {
    if (isRound) {
      return dist(mouseX, mouseY, x + w / 2, y + h / 2) < w / 2;
    }
    return mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;
  }

  void display() {
    if (isMouseOver()) {
      tint(225);
    }
    image(img, x, y, w, h);
    noTint();

    if (!label.equals("")) {
      fill(CREAM);
      textAlign(CENTER, CENTER);
      textSize(22);
      text(label, x + w / 2, y + h / 2 - 3);
    }
  }
}
