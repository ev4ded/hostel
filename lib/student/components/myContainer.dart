import 'package:flutter/material.dart';

class Mycontainer extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final Widget? child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BoxShadow? boxShadow;

  const Mycontainer({
    super.key,
    this.width = double.infinity,
    this.height = 100,
    this.color = Colors.lightBlueAccent,
    this.child,
    this.borderRadius = 10.0,
    this.padding = const EdgeInsets.all(8.0),
    this.margin = const EdgeInsets.all(8.0),
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow != null ? [boxShadow!] : [],
      ),
      child: child,
    );
  }
}
