// ---------- Location ----------
final String CITY_NAME = "Enschede";
final float LATITUDE = 52.22;
final float LONGITUDE = 6.89;

// ---------- Testing ----------
// The real weather on exam day might just be "cloudy". To show another look, set
// TEST_WEATHER_CODE to a weather code: 0 clear, 45 fog, 63 rain, 95 thunderstorm.
// -1 = use the live weather. TEST_NIGHT = true shows the night look.
final int TEST_WEATHER_CODE = -1;
final boolean TEST_NIGHT = false;

// ---------- Effects ----------
final float WINDOW_BOTTOM = 420;
final int NUM_DROPS = 160;
final float RAIN_SPEED_MIN = 10;
final float RAIN_SPEED_MAX = 16;
final float LIGHTNING_CHANCE = 0.004;   // during a storm: about one flash every 4 seconds
final int LIGHTNING_FRAMES = 12;

// ---------- Live values ----------
float tempC = 0;
int weatherCode = 0;
float cloudCover = 0;
boolean isDay = true;
boolean hasWeather = false;

// Rain: drop i is at (dropX[i], dropY[i]) and falls dropSpeed[i] pixels per frame.
float[] dropX = new float[NUM_DROPS];
float[] dropY = new float[NUM_DROPS];
float[] dropSpeed = new float[NUM_DROPS];
int lightningTimer = 0;


void setupWeather() {
  // Spread the drops over the glass so the rain doesn't start as one line at the top.
  for (int i = 0; i < NUM_DROPS; i++) {
    dropX[i] = random(width);
    dropY[i] = random(WINDOW_BOTTOM);
    dropSpeed[i] = random(RAIN_SPEED_MIN, RAIN_SPEED_MAX);
  }
  fetchWeather();
}


void fetchWeather() {
  String url = "https://api.open-meteo.com/v1/forecast"
    + "?latitude=" + LATITUDE
    + "&longitude=" + LONGITUDE
    + "&current=temperature_2m,weather_code,cloud_cover,is_day";

  try {
    JSONObject response = loadJSONObject(url);
    JSONObject current = response.getJSONObject("current");
    tempC = current.getFloat("temperature_2m");
    weatherCode = current.getInt("weather_code");
    cloudCover = current.getFloat("cloud_cover");
    isDay = current.getInt("is_day") == 1;
    hasWeather = true;
  }
  catch (Exception e) {
    println("Weather not available: " + e);
  }
}

void updateWeather() {
  for (int i = 0; i < NUM_DROPS; i++) {
    dropY[i] += dropSpeed[i];
    dropX[i] -= 1.5;
    // A drop that reaches the bench starts again just above the top of the screen.
    if (dropY[i] > WINDOW_BOTTOM) {
      dropY[i] = random(-40, 0);
      dropX[i] = random(width);
    }
    // Drops blown off the left edge come back on the right.
    if (dropX[i] < 0) {
      dropX[i] += width;
    }
  }

  if (lightningTimer > 0) {
    lightningTimer--;
  } else if (isStormy() && random(1) < LIGHTNING_CHANCE) {
    lightningTimer = LIGHTNING_FRAMES;
  }
}

void drawWeatherOutside() {
  if (isRaining()) {
    stroke(80, 100, 135, 180);
    strokeWeight(2);
    for (int i = 0; i < NUM_DROPS; i++) {
      line(dropX[i], dropY[i], dropX[i] - 4, dropY[i] + 20);
    }
    noStroke();
  }
}

void drawWeatherLight() {
  noStroke();

  float clouds = cloudCover;
  if (isRaining()) {
    clouds = max(clouds, 80);
  }
  fill(80, 85, 100, map(clouds, 0, 100, 0, 60));
  rect(0, 0, width, height);

  if (isFoggy()) {
    fill(240, 236, 225, 90);
    rect(0, 0, width, height);
  }

  if (isNight()) {
    fill(25, 30, 70, 140);
    rect(0, 0, width, height);
  }

  if (lightningTimer > 0) {
    // Bright at the start of the flash, fading out as the timer counts down.
    fill(255, 250, 235, map(lightningTimer, 0, LIGHTNING_FRAMES, 0, 130));
    rect(0, 0, width, height);
  }
}


// ---------- What is the weather? ----------
// Weather codes, as listed in the Open-Meteo docs:
// 0-3 clear to overcast, 45/48 fog, 51-57 drizzle, 61-67 rain,
// 80-82 rain showers, 95-99 thunderstorm

int currentWeatherCode() {
  if (TEST_WEATHER_CODE >= 0) {
    return TEST_WEATHER_CODE;
  }
  return weatherCode;
}

boolean isNight() {
  return TEST_NIGHT || !isDay;
}

boolean isRaining() {
  int code = currentWeatherCode();
  return (code >= 51 && code <= 67) || (code >= 80 && code <= 82) || code >= 95;
}

boolean isStormy() {
  return currentWeatherCode() >= 95;
}

boolean isFoggy() {
  int code = currentWeatherCode();
  return code == 45 || code == 48;
}

String weatherDescription(int code) {
  if (code == 0) return "Clear";
  if (code <= 2) return "Partly cloudy";
  if (code == 3) return "Overcast";
  if (code == 45 || code == 48) return "Fog";
  if (code >= 51 && code <= 57) return "Drizzle";
  if (code >= 61 && code <= 67) return "Rain";
  if (code >= 80 && code <= 82) return "Rain showers";
  if (code >= 95) return "Thunderstorm";
  return "Unknown";
}
