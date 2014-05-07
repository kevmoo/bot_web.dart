part of bot_html;

class CanvasUtil {
  /**
   * (√2 - 1) * 4 / 3;
   */
  static const double KAPPA = 0.55228474983079339840225163227959743809289583383593;

  static Size getCanvasSize(CanvasElement canvasElement) {
    return new Size(canvasElement.width, canvasElement.height);
  }

  static void setTransform(CanvasRenderingContext2D ctx, AffineTransform tx){
    requireArgumentNotNull(ctx, 'ctx');
    requireArgumentNotNull(tx, 'tx');

    ctx.setTransform(tx.scaleX, tx.shearY, tx.shearX,
      tx.scaleY, tx.translateX, tx.translateY);
  }

  static void transform(CanvasRenderingContext2D ctx, AffineTransform tx){
    requireArgumentNotNull(ctx, 'ctx');
    requireArgumentNotNull(tx, 'tx');

    ctx.transform(tx.scaleX, tx.shearY, tx.shearX,
      tx.scaleY, tx.translateX, tx.translateY);
  }

  static void centeredCircle(CanvasRenderingContext2D ctx,
                             num x, num y, num radius) {
    ellipse(ctx, x - radius, y - radius, radius * 2, radius * 2);
  }

  static void star(CanvasRenderingContext2D ctx, num x, num y,
                   num outterRadius, [int pointCount = 5]) {
    requireArgumentNotNull(ctx, 'ctx');
    requireArgument(isValidNumber(x), 'x');
    requireArgument(isValidNumber(y), 'y');
    requireArgument(isValidNumber(outterRadius), 'outterRadius');
    requireArgument(outterRadius >= 0, 'outterRadius');
    requireArgument(isValidNumber(pointCount), 'pointCount');
    requireArgument(pointCount >= 5, 'pointCount');

    final sliceSize = math.PI / pointCount;

    // some day I'll document how I found this
    // It was a lot of paper + WolframAlpha
    // value is the ratio of the inner radius to the outter radius
    // to give the star 'clean lines'
    final innerRatio = math.cos(2 * sliceSize) / math.cos(sliceSize);

    final center = new Coordinate(x, y);
    final tx = new AffineTransform();
    final outterVect = new Vector(0, -outterRadius);
    final innerVect = outterVect.scale(innerRatio);

    ctx.beginPath();

    for(var i = 0; i < pointCount; i++) {
      // outter point
      var radians = i * 2 * sliceSize;
      tx.setToRotation(radians, x, y);
      var point = outterVect + center;
      point = tx.transformCoordinate(point);
      if(i == 0) {
        ctx.moveTo(point.x, point.y);
      }
      else {
        ctx.lineTo(point.x, point.y);
      }

      // inner point
      radians = radians + sliceSize;
      tx.setToRotation(radians, x, y);
      point = innerVect + center;
      point = tx.transformCoordinate(point);
      ctx.lineTo(point.x, point.y);
    }
    ctx.closePath();
  }

  static void drawImage(CanvasRenderingContext2D ctx, ImageElement img,
                        Rectangle sourceBox, [Rectangle targetBox = null]) {

    if(targetBox == null) {
      targetBox = new Rectangle(0, 0, sourceBox.width, sourceBox.height);
    }

    ctx.drawImageToRect(img, targetBox, sourceRect: sourceBox);
  }

  static void ellipse(CanvasRenderingContext2D ctx,
                      num x, num y, num width, num height) {
    var hB = (width / 2) * KAPPA,
      vB = (height / 2) * KAPPA,
      eX = x + width,
      eY = y + height,
      mX = x + width / 2,
      mY = y + height / 2;
    ctx.beginPath();
    ctx.moveTo(x, mY);
    ctx.bezierCurveTo(x, mY - vB, mX - hB, y, mX, y);
    ctx.bezierCurveTo(mX + hB, y, eX, mY - vB, eX, mY);
    ctx.bezierCurveTo(eX, mY + vB, mX + hB, eY, mX, eY);
    ctx.bezierCurveTo(mX - hB, eY, x, mY + vB, x, mY);
    ctx.closePath();
  }
}
