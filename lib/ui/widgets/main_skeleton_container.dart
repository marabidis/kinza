import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MainSkeletonContainer extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final EdgeInsets? margin;
  final bool rounded;
  final Color? color; // <- индивидуальный цвет если надо

  const MainSkeletonContainer({
    Key? key,
    required this.width,
    required this.height,
    this.radius = 8,
    this.margin,
    this.rounded = false,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    // Более контрастные цвета shimmer для разных тем
    Color baseColor;
    Color highlightColor;

    if (brightness == Brightness.dark) {
      baseColor = color ?? const Color(0xFF2B2F38); // чуть светлее фона
      highlightColor = const Color(0xFF383C45); // заметно светлее
    } else {
      baseColor = color ?? const Color(0xFFE8EAEC); // чуть темнее white
      highlightColor = const Color(0xFFF7F7FA); // почти белый
    }

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: rounded
              ? BorderRadius.circular(height / 2)
              : BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
