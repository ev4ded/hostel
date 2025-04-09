import 'package:flutter/material.dart';
import 'package:minipro/student/components/custompainter.dart';

class Defaultpainter extends Custompainter {
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
    path_0.moveTo(size.width * 0.2323833, size.height * 0.1314143);
    path_0.quadraticBezierTo(size.width * 0.1750917, size.height * 0.6116571,
        size.width * 0.2840500, size.height * 0.7938000);
    path_0.quadraticBezierTo(size.width * 0.3949333, size.height * 0.9087571,
        size.width * 0.7373167, size.height * 0.9383000);
    path_0.quadraticBezierTo(size.width * 0.7928750, size.height * 0.6870286,
        size.width * 0.7313833, size.height * 0.1297000);
    path_0.quadraticBezierTo(size.width * 0.4268417, size.height * 0.0658286,
        size.width * 0.2323833, size.height * 0.1314143);
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

    // Layer 1

    Paint paint_fill_1 = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255)
      ..style = PaintingStyle.fill
      ..strokeWidth = size.width * 0.00
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    Path path_1 = Path();
    path_1.moveTo(size.width * double.nan, size.height * double.nan);

    canvas.drawPath(path_1, paint_fill_1);

    // Layer 1

    Paint paint_stroke_1 = Paint()
      ..color = const Color.fromARGB(255, 33, 150, 243)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * double.nan
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    canvas.drawPath(path_1, paint_stroke_1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
