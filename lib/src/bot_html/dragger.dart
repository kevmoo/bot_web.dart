part of bot_html;

// a laughably incomplete version of dragger from the closure library
// http://closure-library.googlecode.com/svn/docs/class_goog_fx_Dragger.html
// ...but it works for what I need now

class Dragger {
  final Element _element;
  final StreamController<Vector> _dragDeltaHandle;
  final StreamController<CancelableEventArgs> _dragStartHandle;

  Point _clientLoc;

  Dragger(this._element) :
    _dragDeltaHandle = new StreamController<Vector>(),
    _dragStartHandle = new StreamController<CancelableEventArgs>() {
    _element.onMouseDown.listen(_onMouseDown);
    window.onMouseMove.listen(_handleMove);
    window.onMouseUp.listen(_endDrag);
    window.onBlur.listen(_endDrag);
  }

  Stream<Vector> get dragDelta => _dragDeltaHandle.stream;

  Stream<CancelableEventArgs> get dragStart => _dragStartHandle.stream;

  bool get isDragging => _clientLoc != null;

  void _onMouseDown(MouseEvent event) {
    assert(!isDragging);
    final args = new CancelableEventArgs();
    _dragStartHandle.add(args);
    if(!args.isCanceled) {
      event.preventDefault();
      _clientLoc = event.client;
    }
  }

  void _handleMove(MouseEvent event) {
    if(isDragging) {

      final newLoc = event.client;

      final delta = newLoc - _clientLoc;
      _dragDeltaHandle.add(delta);

      _clientLoc = newLoc;
    }
  }

  void _endDrag(Event event) {
    if(isDragging) {
      _clientLoc = null;
    }
  }
}
