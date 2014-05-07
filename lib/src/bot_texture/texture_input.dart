part of bot_texture;

class TextureInput {
  final String name;
  final Rectangle frame;
  final bool rotated;
  final bool trimmed;
  final Rectangle sourceColorRect;
  final Size sourceSize;
  final ImageElement image;

  TextureInput(this.name, this.frame, this.rotated, this.trimmed,
      this.sourceColorRect, this.sourceSize, this.image);

  factory TextureInput.fromHash(String keyName, Map<String, dynamic> map,
      ImageElement image) {
    final frame = _parseRect(map['frame']);
    final sourceColorRect = _parseRect(map['spriteSourceSize']);
    final sourceSize = _parseCoordinate(map['sourceSize']);

    return new TextureInput(keyName, frame, map['rotated'], map['trimmed'],
        sourceColorRect, sourceSize, image);
  }

  String toString() => this.name;

  static Rectangle _parseRect(Map<String, dynamic> input) {
    var coord = new Coordinate(input['x'], input['y']);
    var size = new Size(input['w'], input['h']);

    return new Box.fromCoordSize(coord, size);
  }

  static Size _parseCoordinate(Map<String, dynamic> input) {
    return new Size(input['w'], input['h']);
  }
}
