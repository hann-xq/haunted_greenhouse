final int RECIPE_LINES = 3;
final int MAX_PER_LINE = 2;

final float CARD_X = 16;
final float CARD_Y = 8;
final float CARD_WIDTH = 240;
final float CARD_HEIGHT = 208;
final float CARD_TITLE_Y = 55;
final float LINE_TEXT_X = 80;
final float FIRST_LINE_Y = 92;
final float LINE_SPACING = 36;
final float ICON_X = 44;
final float CHECK_X = 210;

class Recipe {
  String[] species = new String[RECIPE_LINES];
  int[] neededCounts = new int[RECIPE_LINES];
  int[] collectedCounts = new int[RECIPE_LINES];

  void generate(ArrayList<Plant> plants) {
    // Shuffle the species names and take the first few, so no species is on the card twice
    StringList pool = new StringList();
    for (String name : ALL_SPECIES) {
      pool.append(name);
    }
    pool.shuffle();

    for (int i = 0; i < RECIPE_LINES; i++) {
      species[i] = pool.get(i);
      int available = countOnBench(plants, species[i]);
      int most = min(MAX_PER_LINE, available);
      neededCounts[i] = int(random(1, most + 1));   // random() never reaches most + 1, so 1..most
      collectedCounts[i] = 0;
    }
  }

  int countOnBench(ArrayList<Plant> plants, String speciesName) {
    int count = 0;
    for (Plant plant : plants) {
      if (plant.species.equals(speciesName)) {
        count++;
      }
    }
    return count;
  }

  int lineOf(String speciesName) {
    for (int i = 0; i < RECIPE_LINES; i++) {
      if (species[i].equals(speciesName)) {
        return i;
      }
    }
    return -1;
  }

  boolean wants(String speciesName) {
    int line = lineOf(speciesName);
    if (line == -1) {
      return false;
    }
    return collectedCounts[line] < neededCounts[line];
  }

  void addCollected(String speciesName) {
    int line = lineOf(speciesName);
    if (line != -1) {
      collectedCounts[line]++;
    }
  }

  boolean isComplete() {
    for (int i = 0; i < RECIPE_LINES; i++) {
      if (collectedCounts[i] < neededCounts[i]) {
        return false;
      }
    }
    return true;
  }

  int totalNeeded() {
    int total = 0;
    for (int i = 0; i < RECIPE_LINES; i++) {
      total += neededCounts[i];
    }
    return total;
  }

  int totalCollected() {
    int total = 0;
    for (int i = 0; i < RECIPE_LINES; i++) {
      total += collectedCounts[i];
    }
    return total;
  }

  void display() {
    image(recipeCardImage, CARD_X, CARD_Y, CARD_WIDTH, CARD_HEIGHT);

    fill(INK);
    textAlign(CENTER, CENTER);
    textSize(22);
    text("Recipe", CARD_X + CARD_WIDTH / 2, CARD_TITLE_Y);

    textAlign(LEFT, CENTER);
    textSize(17);
    for (int i = 0; i < RECIPE_LINES; i++) {
      float lineY = FIRST_LINE_Y + i * LINE_SPACING;   // vertical centre of this line
      image(plantImageFor(species[i]), ICON_X, lineY - 17.5, 28, 35);
      text(displayName(species[i]) + "  " + collectedCounts[i] + "/" + neededCounts[i], LINE_TEXT_X, lineY);
      if (collectedCounts[i] >= neededCounts[i]) {
        image(checkImage, CHECK_X, lineY - 12, 24, 24);
      }
    }
  }
}
