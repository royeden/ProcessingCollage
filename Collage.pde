/*
  Cómo usar:
  * En la carpeta donde este guardado el código, crear una carpeta llamada data y ahí agregar las imágenes.
    Tienen que llamarse todas igual: <nombre> (<número>).<extensión>
    EJ: "foto (1).jpg"
  
  * Revisar las instrucciones para configurar cada sección.

  * Controles:
    Barra espaciadora: Guardar la imagen.
    P: Pausa o reanudar.
    R: Reiniciar y elegir una nueva imagen.
    T: Pausar captura automática de imagen.
    Y: No reiniciar la imagen después de guardarla automáticamente.
    S: Cambiar la forma que se dibuja (al azar, rectángulos, elípses, triángulos o combinaciones entre 2 formas).
    D: Usar formas regulares o irregulares (cuadrados o rectángulos, círculos o elípses, triángulos equiláteros o triángulos).
    X: Tomar los recortes en base a la posición del mouse o tomar recortes al azar de imágenes al azar.
    C: Tomar los recortes en base a un rango alrededor de la posición del mouse o tomar recortes al azar de imágenes al azar.
    V: Pegar los recortes en base a la posición del mouse o tomar recortes al azar de imágenes al azar.
    B: Pegar los recortes en base a un rango alrededor de la posición del mouse o tomar recortes al azar de imágenes al azar.
    N: Pegar los recortes al azar o tomar recortes al azar de imágenes al azar.
*/


// CONFIGURACIÓN DE IMÁGENES
int IMAGES_LENGTH = 4; // Cantidad de imágenes en la carpeta data
PImage images[] = new PImage[IMAGES_LENGTH]; // Esta lista contiene todas las imágenes

// Nombre que comparten todas las imágenes (en este caso foto (<número>).jpg)
String NAME = "foto";
String EXTENSION = ".jpg"; // Extensión
String SAVE_IMAGE_NAME = "foto "; // Nombre que comparten todas las imágenes (en este caso foto (<número>).jpg)
String SAVE_IMAGE_EXTENSION = ".jpg"; // Extensión

// Todas las imágenes en la carpeta data/ tienen que llamarse NAME (<number>).EXTENSION
String getImage(int index) {
  return NAME + " (" + (index + 1) + ")" + EXTENSION; 
}

// CONFIGURACIÓN INICIAL
int FRAMERATE = 1; // FPS to calculate the whole algorithm / FPS para calcular de vuelta el algoritmo entero

// Índice forma inicial de los recortes que va a realizar el programa
int SHAPE_MODE = 0; // { "ALL", "ELLIPSE", "RECTANGLE", "TRIANGLE", "ELLIPSE_RECTANGLE", "ELLIPSE_TRIANGLE", "RECTANGLE_TRIANGLE" }
boolean ALL_SIDES_ARE_EQUAL = true; // Usar solamente formas con lados iguales (triángulos equiláteros, cuadrados y círculos)
boolean RANDOM_PASTE = false; // Todos los recortes se pegan en posiciones al azar (Si no, se pegan en el mismo lugar del que se tomaron en la imágen)
boolean MOUSE_CUT = false; // Hacer recortes según la posición del mouse
boolean MOUSE_PASTE = false; // Pegar los recortes según la posición del mouse
boolean MOUSE_CUT_RANGE_ENABLED = false; // Los recortes se generan en un rango alrededor del mouse si mouse cut está activo
int MOUSE_CUT_RANGE = 200; // Rango de los cortes con el mouse (en píxeles)
boolean MOUSE_PASTE_RANGE_ENABLED = false; // Los recortes se pegan en un rango alrededor del mouse si mouse paste está activo
int MOUSE_PASTE_RANGE = 200; // Rango de los pegados con el mouse (en píxeles)
int MASKS_PER_FRAME = 1; // Recortes (y pegados) hechos por frame
int MIN_SHAPE_SIDE_SIZE = 50; // Mínimo tamaño para cada figura (en píxeles)
int MAX_SHAPE_SIDE_SIZE = 0; // Máximo tamaño para cada figura (en píxeles). Si el valor es 0, va a tomar un valor al azar
int MIN_SHAPE_SIDE_RATIO = 16; // Mínimo tamaño para cada figura (basado en un ratio calculado del valor máximo entre la altura y el ancho de las imágenes)
int MAX_SHAPE_SIDE_RATIO = 8; // Máximo tamaño para cada figura (basado en un ratio calculado del valor máximo entre la altura y el ancho de las imágenes)
boolean RANDOM_IMAGE_ON_RESET = true; // Máximo tamaño para cada figura (basado en un ratio calculado del valor máximo entre la altura y el ancho de las imágenes)


// CONFIGURACIÓN DEL RELOJ
boolean TIMEOUT = true; // Capturar imágenes en intervalos de tiempo
boolean RESET_ON_TIMEOUT = true; // Reiniciar al finalizar el intervalo de tiempo
int FIXED_INTERVAL = 0; // Intervalo fijo entre cada captura automática
int INTERVAL_MIN_MINUTES = 1; // Mínima cantidad de minutos antes de un intervalo al azar
int INTERVAL_MAX_MINUTES = 10; // Máxima cantidad de minutos que puede durar un intervalo al azar

// VARIABLES INTERNAS - NO TOCAR AL MENOS QUE SEPAS LO QUE ESTÁS HACIENDO
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
