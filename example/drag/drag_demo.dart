import 'dart:html';
import 'package:bot/bot.dart';
import 'package:bot_web/bot_retained.dart';

main() {
  CanvasElement canvas = querySelector("#content");
  var demo = new DraggerDemo(canvas);
  demo.requestFrame();
}

class DraggerDemo {
  final Stage _stage;
  final AffineTransform _tx;

  bool _frameRequested = false;
  final Thing _thing;

  factory DraggerDemo(CanvasElement canvas) {
    final image = new SpriteThing.horizontalFromUrl(
        'disasteroids2_master.png', 28, 28, 16, 29, new Coordinate(35, 354));

    MouseManager.setCursor(image, 'pointer');

    var tx = image.addTransform();

    var rootPanel = new CanvasThing(500, 500);
    rootPanel.add(image);

    var stage = new Stage(canvas, rootPanel);

    return new DraggerDemo._internal(stage, tx, image);
  }

  DraggerDemo._internal(this._stage, this._tx, this._thing) {
    _stage.invalidated.listen(_onStageInvalidated);

    new MouseManager(_stage);

    MouseManager.setDraggable(_thing, true);
    MouseManager.getDragStream(_thing).listen(_onDrag);
  }

  void requestFrame() {
    if (!_frameRequested) {
      _frameRequested = true;
      window.requestAnimationFrame(_onFrame);
    }
  }

  void _onStageInvalidated(args) {
    requestFrame();
  }

  void _onDrag(ThingDragEventArgs args) {
    final delta = args.delta;
    _tx.translate(delta.x, delta.y);
    requestFrame();
  }

  void _onFrame(double highResTime) {
    _stage.draw();
    _frameRequested = false;
    requestFrame();
  }
}
