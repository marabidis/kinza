import 'dart:async';
import 'dart:developer' as dev;
import 'dart:ui' as ui show FragmentProgram, FragmentShader;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// {@template shimmer}
/// A widget that creates a shimmering effect similar
/// to a moving highlight or reflection.
/// This is commonly used as a placeholder or loading indicator.
/// {@endtemplate}
/// {@category shaders}
class Shimmer extends StatefulWidget {
  /// {@macro shimmer}
  const Shimmer({
    this.color,
    this.backgroundColor,
    this.speed = 15 / 8000000,
    this.stripeWidth = .2,
    this.size = const Size(128, 28),
    this.cornerRadius = 10,
    this.initialSeed = .0,
    this.alignment = Alignment.center,
    bool? isSecondary,
    super.key,
  }) : _isSecondary = isSecondary ?? false;

  /// Shimmer with secondary colors.
  /// {@macro shimmer}
  const Shimmer.secondary({
    this.color,
    this.backgroundColor,
    this.speed = 15 / 8000000,
    this.stripeWidth = .2,
    this.size = const Size(128, 28),
    this.cornerRadius = 10,
    this.initialSeed = .0,
    this.alignment = Alignment.center,
    super.key,
  }) : _isSecondary = true;

  /// The asset path to the shader code.
  static const String _shaderAsset = 'assets/shaders/shimmer.frag';

  /// The color used for the shimmering effect,
  /// usually a light color for contrast.
  /// If not specified, defaults to the color
  /// set in the current theme's `ColorScheme.onSurface`.
  final Color? color;

  /// The color of the widget's background.
  /// Should typically contrast with [color].
  /// If not specified, defaults to the color
  /// set in the current theme's `ColorScheme.surface`.
  final Color? backgroundColor;

  /// The radius of the corners of the widget in logical pixels.
  /// Defaults to 8 logical pixels.
  final double cornerRadius;

  /// The speed of the shimmering effect, in logical pixels per microsecond.
  /// Defaults to `15 / 8000000`.
  final double speed;

  /// The width of the stripes in the shimmering effect,
  /// expressed as a fraction of the widget's width.
  /// Defaults to 0.1, meaning each stripe will be 1/10th of the widget's width.
  final double stripeWidth;

  /// The size of the widget in logical pixels.
  /// Defaults to a size of 128 logical pixels wide and 28 logical pixels tall.
  final Size size;

  /// The initial offset of the shimmering effect.
  /// Expressed as a fraction of the widget's width.
  /// Defaults to 0.0,
  /// meaning the shimmering effect starts at the leading edge of the widget.
  final double initialSeed;

  /// The alignment of the widget within its parent.
  final AlignmentGeometry alignment;

  final bool _isSecondary;

  @override
  State<Shimmer> createState() => _ShimmerState();

  /// The default height of the [Shimmer] widget.
  static double height = 12;

  /// Get color for [Shimmer]
  // static Color getColor(
  //   BuildContext context, {
  //   bool isSecondary = false,
  // }) {
  //   final theme = Theme.of(context);
  //   final color = theme.uiTheme.color.onBackground.darken(0.03);
  //   return isSecondary
  //       ? theme.isDark
  //           ? color
  //           : theme.uiTheme.color.secondaryBackground.darken(0.03)
  //       : color;
  // }

  /// Get background color for [Shimmer]
  // static Color getBackgroundColor(
  //   BuildContext context, {
  //   bool isSecondary = false,
  // }) {
  //   final theme = Theme.of(context);
  //   final color = theme.uiTheme.color.onBackground.lighten(0.01);
  //   return isSecondary
  //       ? theme.isDark
  //           ? color
  //           : theme.uiTheme.color.background
  //       : color;
  // }

  /// Get children color for [Shimmer]
  // static Color getChildrenColor(
  //   BuildContext context, {
  //   bool isSecondary = false,
  // }) {
  //   final theme = Theme.of(context);
  //   final color = theme.uiTheme.color.secondaryBackground.lighten(0.01);
  //   return isSecondary
  //       ? color
  //       : theme.isDark
  //           ? color
  //           : theme.uiTheme.color.background;
  // }
}

final class _ShimmerShaderLoader
    with ChangeNotifier
    implements ValueListenable<ui.FragmentShader?> {
  _ShimmerShaderLoader() {
    _loadShader().ignore();
  }

  @override
  ui.FragmentShader? get value => _shader;
  ui.FragmentShader? _shader;

  /// Whether the shader is still loading.
  bool get inProgress => _inProgress;
  bool _inProgress = true;

  Future<void> _loadShader() async {
    _inProgress = true;
    try {
      final program = await ui.FragmentProgram.fromAsset(Shimmer._shaderAsset)
          .timeout(const Duration(seconds: 5));
      final shader = program.fragmentShader();
      _shader = shader;
    } on Object catch (error, stackTrace) {
      if (kReleaseMode) return; // Dont log errors in release mode.

      // Thats fine for HTML Renderer and unsupported platforms.
      if (error is UnsupportedError) return;
      dev.log(
        'Failed to load shader: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'Shimmer',
      );
    }
    _inProgress = false;
    notifyListeners();
  }
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  /// Shader value notifier.
  static final _ShimmerShaderLoader _shader = _ShimmerShaderLoader();

  /// Elapsed time notifier.
  late final ValueNotifier<Duration> _elapsed =
      ValueNotifier<Duration>(Duration.zero);

  /// Widget value notifier for shader mutation.
  late final ValueNotifier<Shimmer> _widget = ValueNotifier<Shimmer>(widget);

  /// Theme notifier for shader mutation.
  final ValueNotifier<ThemeData> _theme = ValueNotifier<ThemeData>(ThemeData());

  /// Animated ticker.
  late final Ticker _ticker;

  /// Custom painter.
  late final CustomPainter _painter;

  @override
  void initState() {
    super.initState();
    _widget.value = widget;
    _ticker = createTicker((elapsed) => _elapsed.value = elapsed);
    _painter = _ShimmerPainter(
      elapsedListenable: _elapsed,
      widgetListenable: _widget,
      themeListenable: _theme,
      shaderListenable: _shader,
      isSecondary: widget._isSecondary,
    );
    if (_shader.value != null) {
      _ticker.start();
    } else if (_shader.inProgress) {
      _shader.addListener(_onShaderLoaded);
    }
  }

  void _onShaderLoaded() {
    _shader.removeListener(_onShaderLoaded);
    if (_shader.value == null) return;
    if (!mounted) return;
    if (_ticker.isActive) return;
    _ticker.start();
  }

  @override
  void didUpdateWidget(covariant Shimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.color?.hashCode != oldWidget.color?.hashCode ||
        widget.backgroundColor?.hashCode !=
            oldWidget.backgroundColor?.hashCode ||
        widget.stripeWidth != oldWidget.stripeWidth ||
        widget.size != oldWidget.size ||
        widget.speed != oldWidget.speed ||
        widget.initialSeed != oldWidget.initialSeed ||
        widget.cornerRadius != oldWidget.cornerRadius) {
      _widget.value = widget;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme.value = Theme.of(context);
  }

  @override
  void dispose() {
    _shader.removeListener(_onShaderLoaded);
    _ticker
      ..stop()
      ..dispose();
    _elapsed.dispose();
    _theme.dispose();
    _widget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Align(
        alignment: widget.alignment,
        child: SizedBox.fromSize(
          size: widget.size,
          child: CustomPaint(
            size: widget.size,
            painter: _painter,
            willChange: true,
          ),
        ),
      );
}

class _ShimmerPainter extends CustomPainter {
  _ShimmerPainter({
    required this.elapsedListenable,
    required this.widgetListenable,
    required this.themeListenable,
    required this.shaderListenable,
    this.isSecondary = false,
  }) : super(
          repaint: Listenable.merge(
            [
              elapsedListenable,
              widgetListenable,
              themeListenable,
              shaderListenable,
            ],
          ),
        );

  final bool isSecondary;
  final ValueListenable<Duration> elapsedListenable;
  final ValueListenable<Shimmer> widgetListenable;
  final ValueListenable<ThemeData> themeListenable;
  final ValueListenable<ui.FragmentShader?> shaderListenable;

  Duration get elapsed => elapsedListenable.value;
  Shimmer get widget => widgetListenable.value;
  ThemeData get theme => themeListenable.value;
  ui.FragmentShader? get shader => shaderListenable.value;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint();
    if (shader case ui.FragmentShader shader) {
      final seed = widget.initialSeed + elapsed.inMicroseconds * widget.speed;
      final color = widget.color ?? Colors.grey;
      final backgroundColor = widget.backgroundColor ?? Colors.grey[300]!;
      paint.shader = shader
        ..setFloat(0, size.width)
        ..setFloat(1, size.height)
        ..setFloat(2, seed)
        ..setFloat(3, color.r)
        ..setFloat(4, color.g)
        ..setFloat(5, color.b)
        ..setFloat(6, color.a)
        ..setFloat(7, backgroundColor.r)
        ..setFloat(8, backgroundColor.g)
        ..setFloat(9, backgroundColor.b)
        ..setFloat(10, backgroundColor.a)
        ..setFloat(11, widget.stripeWidth);
      canvas
        ..clipRRect(RRect.fromRectAndRadius(
          rect,
          Radius.circular(widget.cornerRadius),
        ))
        ..drawRect(rect, paint);
    } else {
      final backgroundColor = widget.backgroundColor ?? Colors.grey[300]!;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(widget.cornerRadius)),
        paint..color = backgroundColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ShimmerPainter oldDelegate) => true;
}
