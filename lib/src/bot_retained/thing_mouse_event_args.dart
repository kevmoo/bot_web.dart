part of bot_retained;

class ThingMouseEventArgs {
  final Thing thing;
  final MouseEvent sourceEvent;

  ThingMouseEventArgs(this.thing, this.sourceEvent) {
    assert(thing != null);
    assert(sourceEvent != null);
  }

  bool get shiftKey => sourceEvent.shiftKey;
}
