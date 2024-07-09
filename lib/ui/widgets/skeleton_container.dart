import 'package:flutter/material.dart';

class MainSkeletonContainer extends StatelessWidget {
  final bool rounded;
  final double radius;
  final double? width;
  final double? height;
  final Color? color;
  final Widget? child;
  final EdgeInsetsGeometry margin;

  const MainSkeletonContainer({
    Key? key,
    this.child,
    this.width,
    this.color,
    this.height = 12.0,
    this.radius = 35.0,
    this.rounded = false,
    this.margin = EdgeInsets.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(rounded ? 100 : radius),
        child: Container(
          width: width,
          height: height,
          color: color ?? Theme.of(context).disabledColor,
        ),
      ),
    );
  }
}
