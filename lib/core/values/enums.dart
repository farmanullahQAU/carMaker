enum DualToneDirection { horizontal, vertical, diagonal, radial }

enum CircularTextDirection { clockwise, anticlockwise }

enum CircularTextPosition { outside, inside }

enum StartAngleAlignment { start, center, end }

// Define panel types as an enum
enum PanelType {
  shapes, // index 0
  shapeEditor, // index 1
  stickers, // index 2
  color, // index 3
  text, // index 4
  advancedImage, // index 5
  charts, // index 6
  icons,
  // chartEditor, // index 7
  none,
}

enum Direction { clockwise, counterClockwise }

enum Placement { inside, outside, middle }

enum ChartType { linearProgress, circularProgress, radialProgress }
