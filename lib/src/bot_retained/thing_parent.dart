part of bot_retained;

abstract class ThingParent {
  void childInvalidated(Thing child);
  AffineTransform getTransformToRoot();
  Stream get invalidated;
}
