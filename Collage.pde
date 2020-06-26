/*
  How to use:
  * In the folder where the code is stored, create a data folder and add the images there.
    All of them have to share the same name: <name> (<número>).<extension>
    EJ: "photo (1).jpg"
  
  * Check the instruccions to configure each section.

  * Controls:
    Space bar: Save the image.
    P: Pause or resume.
    R: Reset and pick a new image.
    T: Pause automatic image saving.
    Y: Don't reset the image after saving it.
    S: Change the shape that's drawn (random, rectangle, ellipse, triangle or combinations between 2 shapes).
    D: User regular or irregular shapes (squares or rectangles, circles or ellipses, equilateral triangles o triangles).
    X: Cut the images based on mouse position or take random cuts from random positions in any image.
    C: Cut the images based on a range around the mouse position o or take random cuts from random positions in any image.
    V: Paste the cut-ups based on mouse position or take random cuts from random positions in any image.
    B: Paste the cut-ups based on arange around the mouse position o or take random cuts from random positions in any image..
    N: Paste the cut-ups randomly from random images.
*/


// IMAGES CONFIG
int IMAGES_LENGTH = 4; // Amount of images in the data folder
PImage images[] = new PImage[IMAGES_LENGTH]; // This array holds all the images

// Name shared between images (In this case foto (<number>).jpg)
String NAME = "foto";
String EXTENSION = ".jpg"; // Extension
String SAVE_IMAGE_NAME = "foto "; // Name shared between images (In this case foto (<number>).jpg)
String SAVE_IMAGE_EXTENSION = ".jpg"; // Extension

// All the images in data/ should be named "<NAME> (<number>).<EXTENSION>"
String getImage(int index) {
  return NAME + " (" + (index + 1) + ")" + EXTENSION; 
}

// INITIAL CONFIGURATION
int FRAMERATE = 1; // FPS to calculate the whole algorithm

// Index of the initial shape that the program will cut
int SHAPE_MODE = 0; // { "ALL", "ELLIPSE", "RECTANGLE", "TRIANGLE", "ELLIPSE_RECTANGLE", "ELLIPSE_TRIANGLE", "RECTANGLE_TRIANGLE" }
boolean ALL_SIDES_ARE_EQUAL = true; // Only use shapes that are same-sided (equilateral triangles, squares and circles)
boolean RANDOM_PASTE = false; // All cut-ups are pasted in random positions (If not, they're pasted in the same position they were cut from)
boolean MOUSE_CUT = false; // Cut-ups are based on mouse position
boolean MOUSE_PASTE = false; // Cut-ups are pasted on mouse position
boolean MOUSE_CUT_RANGE_ENABLED = false; // Cut-ups are taken from a range around the mouse if mouse cut is active
int MOUSE_CUT_RANGE = 200; // Range of mouse cuts (in pixels)
boolean MOUSE_PASTE_RANGE_ENABLED = false; // Cut-ups are pasted from a range around the mouse if mouse paste is active
int MOUSE_PASTE_RANGE = 200; // Range of mouse paste (in pixels)
int MASKS_PER_FRAME = 1; // Cut-ups made (and pasted) per frame
int MIN_SHAPE_SIDE_SIZE = 50; // Minimum size for each shape (in pixels)
int MAX_SHAPE_SIDE_SIZE = 0; // Maximum size for each shape (in pixels). If the value is 0, it will be random
int MIN_SHAPE_SIDE_RATIO = 16; // Minimum size for each shape (ratio calculated from max between width/height of the images)
int MAX_SHAPE_SIDE_RATIO = 8; // Maximum size for each shape (ratio calculated from max between width/height of the images)
boolean RANDOM_IMAGE_ON_RESET = true; // Maximum size for each shape (ratio calculated from max between width/height of the images)


// CLOCK CONFIGURATION / CONFIGURACIÓN DEL RELOJ
boolean TIMEOUT = true; // Capture images in time intervals
boolean RESET_ON_TIMEOUT = true; // Reset after the timeout runs
int FIXED_INTERVAL = 0; // Image interval
int INTERVAL_MIN_MINUTES = 1; // Minimum amount of minutes before each random timeout
int INTERVAL_MAX_MINUTES = 10; // Maximum amount of minutes that can ellapse for each random timeout

// INTERNAL VARIABLES - DON'T TOUCH UNLESS YOU KNOW WHAT YOU'RE DOING
boolean paused = false;
int imageWidth = 0, imageHeight = 0;
int ellapsed;
int timeout = 0;
int savedImageNumber = 0;
int currentBackgroundImageIndex = 0;

String SHAPES[] = {
  "ALL",
  "ELLIPSE",
  "RECTANGLE",
  "TRIANGLE",
  "ELLIPSE_RECTANGLE",
  "ELLIPSE_TRIANGLE",
  "RECTANGLE_TRIANGLE"
};

float getRange(boolean active, int range) {
  return active ? random(-1, 1) * range : 0;
}

FloatDict mappedMouse = new FloatDict();

FloatDict getMappedMouse() {
  mappedMouse.set("x", MOUSE_CUT || MOUSE_PASTE
    ? constrain(mouseX, 0, imageWidth)
    : 0
  );
  mappedMouse.set("y", MOUSE_CUT || MOUSE_PASTE
    ? constrain(mouseY, 0, imageHeight)
    : 0
  );
  return mappedMouse;
}

void drawBackground() {
  clear();
  background(0);
  currentBackgroundImageIndex = RANDOM_IMAGE_ON_RESET
    ? floor(random(IMAGES_LENGTH))
    : (currentBackgroundImageIndex == IMAGES_LENGTH - 1)
      ? currentBackgroundImageIndex + 1
      : 0;
  image(images[currentBackgroundImageIndex], 0, 0);
}

void togglePause() {
  paused = !paused;
}

void saveImage() {
  PGraphics frame = createGraphics(imageWidth, imageHeight);
  frame.beginDraw();
  frame.image(get(0, 0, imageWidth, imageHeight), 0, 0);
  frame.endDraw();
  frame.save(SAVE_IMAGE_NAME + savedImageNumber + SAVE_IMAGE_EXTENSION);
  println("Saved: " + SAVE_IMAGE_NAME + savedImageNumber + SAVE_IMAGE_EXTENSION);
  savedImageNumber++;
}

boolean chance(int percentage) {
  return floor(random(0, 100)) > percentage;
}

int generateRandomTimeout() {
  return millis() + (
    FIXED_INTERVAL != 0
      ? FIXED_INTERVAL
      : round(
          1000 * random(INTERVAL_MIN_MINUTES * 60,
          INTERVAL_MAX_MINUTES * 60)
      )
    );
}

void useTimeout() {
  ellapsed = millis();
  println("Remaining: " + round((timeout - ellapsed) / 1000) + " seconds");
  if (ellapsed >= timeout) {
    if (timeout != 0) saveImage();
    if (RESET_ON_TIMEOUT) drawBackground();
    timeout = generateRandomTimeout();
  }
}

void drawEllipse(PGraphics graphics, int gWidth, int gHeight) {
  graphics.ellipseMode(CENTER);
  graphics.ellipse(gWidth / 2, gHeight / 2, gWidth, gHeight);
}

void drawRectangle(PGraphics graphics, int gWidth, int gHeight) {
  graphics.rectMode(CENTER);
  graphics.rect(gWidth / 2, gHeight / 2, gWidth, gHeight);
}

void drawTriangle(PGraphics graphics, int gWidth, int gHeight) {
  graphics.translate(gWidth / 2, gHeight / 2);
  graphics.rotate(
    radians(random(360))
  );
  graphics.triangle(
    -gWidth / 2,
    gHeight / 2,
    gWidth / 2,
    gHeight / 2,
    0,
    -gHeight / 2
  );
}

void drawMasks() {
  for (int  i = 0; i < MASKS_PER_FRAME; i++) {
    boolean sidesAreEqual = ALL_SIDES_ARE_EQUAL || chance(50);
    int maskWidth, maskHeight;
    if (sidesAreEqual) {
      maskWidth = round(
        random(
          MIN_SHAPE_SIDE_SIZE != 0
            ? MIN_SHAPE_SIDE_SIZE
            : max(imageWidth, imageHeight) / MIN_SHAPE_SIDE_RATIO,
          MAX_SHAPE_SIDE_SIZE != 0
            ? MAX_SHAPE_SIDE_SIZE
            : max(imageWidth, imageHeight) / MAX_SHAPE_SIDE_RATIO
        )
      );
      maskHeight = maskWidth;
    } else {
      maskWidth = round(
        random(
          MIN_SHAPE_SIDE_SIZE != 0
            ? MIN_SHAPE_SIDE_SIZE
            : min(imageWidth, imageHeight) / MIN_SHAPE_SIDE_RATIO,
          MAX_SHAPE_SIDE_SIZE != 0
            ? MAX_SHAPE_SIDE_SIZE
            : min(imageWidth, imageHeight) / MAX_SHAPE_SIDE_RATIO
        )
      );
      maskHeight = round(
        random(
          MIN_SHAPE_SIDE_SIZE != 0
            ? MIN_SHAPE_SIDE_SIZE
            : min(imageWidth, imageHeight) / MIN_SHAPE_SIDE_RATIO,
          MAX_SHAPE_SIDE_SIZE != 0
            ? MAX_SHAPE_SIDE_SIZE
            : min(imageWidth, imageHeight) / MAX_SHAPE_SIDE_RATIO
        )
      );
    }

    PGraphics mask = createGraphics(maskWidth, maskHeight);
    mask.beginDraw();
    String shape = SHAPES[SHAPE_MODE] == "ALL" ? SHAPES[floor(random(SHAPES.length - 1)) + 1] : SHAPES[SHAPE_MODE];

    switch(shape) {
      case "ELLIPSE":
        drawEllipse(mask, maskWidth, maskHeight);
        break;
      case "RECTANGLE":
        drawRectangle(mask, maskWidth, maskHeight);
        break;
      case "TRIANGLE":
        drawTriangle(mask, maskWidth, maskHeight);
        break;
      case "ELLIPSE_RECTANGLE":
        if (chance(50))
          drawEllipse(mask, maskWidth, maskHeight);
        else 
          drawRectangle(mask, maskWidth, maskHeight);
        break;
      case "ELLIPSE_TRIANGLE":
        if (chance(50))
          drawEllipse(mask, maskWidth, maskHeight);
        else
          drawTriangle(mask, maskWidth, maskHeight);
        break;
      case "RECTANGLE_TRIANGLE":
        if (chance(50))
          drawRectangle(mask, maskWidth, maskHeight);
        else
          drawTriangle(mask, maskWidth, maskHeight);
        break;
    }
    mask.endDraw();
    
    int x = round(
      MOUSE_CUT
        ? constrain(
            getMappedMouse().get("x") + getRange(MOUSE_CUT_RANGE_ENABLED, MOUSE_CUT_RANGE),
            0,
            imageWidth - maskWidth
          )
        : random(imageWidth - maskWidth)
      );
    int y = round(
      MOUSE_CUT
        ? constrain(
            getMappedMouse().get("y") + getRange(MOUSE_CUT_RANGE_ENABLED, MOUSE_CUT_RANGE),
            0,
            imageHeight - maskHeight
          )
        : random(imageHeight - maskHeight)
      );

    PImage image = images[floor(random(IMAGES_LENGTH))].get(x, y, maskWidth, maskHeight);
    image.mask(mask);

    float imageX = MOUSE_PASTE
      ? constrain(
          getMappedMouse().get("x") + getRange(MOUSE_PASTE_RANGE_ENABLED, MOUSE_PASTE_RANGE),
          0,
          imageWidth - maskWidth
        )
      : RANDOM_PASTE
        ? round(random(imageWidth - maskWidth))
        : x;

    float imageY = MOUSE_PASTE
      ? constrain(
          getMappedMouse().get("y") + getRange(MOUSE_PASTE_RANGE_ENABLED, MOUSE_PASTE_RANGE),
          0,
          imageHeight - maskHeight
        )
      : RANDOM_PASTE
        ? round(random(imageHeight - maskHeight))
        : y;

    image(image, imageX, imageY);
    
    println(
      SHAPES[SHAPE_MODE],
      imageX,
      imageY,
      maskWidth,
      maskHeight,
      shape
    );
  }
}

void changeShapeMode() {
  SHAPE_MODE = (SHAPE_MODE == (SHAPES.length - 1) ? 0 : SHAPE_MODE + 1);
}

void toggleRegularShapes() {
  ALL_SIDES_ARE_EQUAL = !ALL_SIDES_ARE_EQUAL;
}

void toggleRandomPaste() {
  RANDOM_PASTE = !RANDOM_PASTE;
}

void toggleMouseCut() {
  if (MOUSE_CUT_RANGE_ENABLED) toggleMouseCutRange();
  MOUSE_CUT = !MOUSE_CUT;
}

void toggleMouseCutRange() {
  if (!MOUSE_CUT) toggleMouseCut();
  MOUSE_CUT_RANGE_ENABLED = !MOUSE_CUT_RANGE_ENABLED;
}

void toggleMousePaste() {
  if (MOUSE_CUT_RANGE_ENABLED) toggleMousePasteRange();
  MOUSE_PASTE = !MOUSE_PASTE;
}

void toggleMousePasteRange() {
  if (!MOUSE_PASTE) toggleMousePaste();
  MOUSE_PASTE_RANGE_ENABLED = !MOUSE_PASTE_RANGE_ENABLED;
}

void toggleTimeout() {
  TIMEOUT = !TIMEOUT;
}

void toggleResetOnTimeout() {
  RESET_ON_TIMEOUT = !RESET_ON_TIMEOUT;
}

void setup() {
  noFill();
  noStroke();
  fullScreen();
  frameRate(FRAMERATE);
  // imageMode(CENTER);
  for (int i = 0; i < IMAGES_LENGTH; i++) {
    String file = getImage(i);
    PImage image = loadImage(file);
    images[i] = image;
    if (image.height > height) image.resize(0, height);
    if (image.width > width) image.resize(width, 0);
    if (image.width > imageWidth) imageWidth = image.width;
    if (image.height > imageHeight) imageHeight = image.height;
    println("Loaded file: " + file + "\n" + "W: " + image.width + "\n" + "H: " + image.height);
  }
  if (TIMEOUT) useTimeout();
  else drawBackground();
}

void draw() {
  if (!paused) drawMasks();
  if (TIMEOUT) useTimeout();
}

void keyPressed() {
  switch(key) {
    case ' ':
      saveImage();
      break;
    case 'r':
    case 'R':
      drawBackground();
      break;
    case 't':
    case 'T':
      toggleTimeout();
      break;
    case 'y':
    case 'Y':
      toggleResetOnTimeout();
      break;
    case 's':
    case 'S':
      changeShapeMode();
      break;
    case 'd':
    case 'D':
      toggleRegularShapes();
      break;
    case 'p':
    case 'P':
      togglePause();
      break;
    case 'x':
    case 'X':
      toggleMouseCut();
      break;
    case 'c':
    case 'C':
      toggleMouseCutRange();
      break;
    case 'v':
    case 'V':
      toggleMousePaste();
      break;
    case 'b':
    case 'B':
      toggleMousePasteRange();
      break;
    case 'n':
    case 'N':
      toggleRandomPaste();
      break;
  }
}

void mousePressed() {
  if (paused) togglePause();
}

void mouseReleased() {
  if (!paused) togglePause();
}
