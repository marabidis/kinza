import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MainSkeletonContainer extends StatelessWidget {
  final bool rounded;
  final double radius;
  final double? width;
  final double? height;
  final Widget? child;
  final EdgeInsetsGeometry margin;
  final Duration shimmerDelay;

  const MainSkeletonContainer({
    Key? key,
    this.child,
    this.width,
    this.height = 12.0,
    this.radius = 35.0,
    this.rounded = false,
    this.margin = EdgeInsets.zero,
    this.shimmerDelay = const Duration(milliseconds: 180),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(rounded ? 100 : radius);

    final skeletonBox = Container(
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[300]!,
            Colors.grey[200]!,
            Colors.grey[300]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: borderRadius,
      ),
      child: child,
    );

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: Duration(milliseconds: 1200),
      child: skeletonBox,
    );
  }
}
