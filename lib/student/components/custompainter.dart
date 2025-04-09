import 'package:flutter/widgets.dart';

class Custompainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Layer 1

    Paint paint_fill_0 = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255)
      ..style = PaintingStyle.fill
      ..strokeWidth = size.width * 0.00
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    Path path_0 = Path();
    path_0.moveTo(size.width * 0.2818083, size.height * 0.3826286);
    path_0.cubicTo(
        size.width * 0.3176333,
        size.height * 0.6395429,
        size.width * 0.3676000,
        size.height * 0.6015143,
        size.width * 0.3860500,
        size.height * 0.6681286);
    path_0.cubicTo(
        size.width * 0.3861750,
        size.height * 0.7547286,
        size.width * 0.4557917,
        size.height * 0.8124143,
        size.width * 0.6142500,
        size.height * 0.8288429);
    path_0.cubicTo(
        size.width * 0.6977000,
        size.height * 0.6354286,
        size.width * 0.5485000,
        size.height * 0.4921286,
        size.width * 0.5952917,
        size.height * 0.3489714);
    path_0.quadraticBezierTo(size.width * 0.5236667, size.height * 0.3555857,
        size.width * 0.4648083, size.height * 0.1731000);
    path_0.quadraticBezierTo(size.width * 0.4426583, size.height * 0.3004857,
        size.width * 0.2818083, size.height * 0.3826286);
    path_0.close();

    canvas.drawPath(path_0, paint_fill_0);

    // Layer 1

    Paint paint_stroke_0 = Paint()
      ..color = const Color.fromARGB(255, 33, 150, 243)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.00
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    canvas.drawPath(path_0, paint_stroke_0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
