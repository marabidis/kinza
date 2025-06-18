// lib/ui/widgets/ingredient_customize_sheet.dart
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kinza/core/models/ingredient_option.dart';

class IngredientCustomizeSheet extends StatefulWidget {
  const IngredientCustomizeSheet({
    super.key,
    required this.options,
    required this.initiallySelected,
    required this.sheetTitle,
  });

  final List<IngredientOption> options;
  final List<IngredientOption> initiallySelected;
  final String sheetTitle;

  @override
  State<IngredientCustomizeSheet> createState() =>
      _IngredientCustomizeSheetState();
}

class _IngredientCustomizeSheetState extends State<IngredientCustomizeSheet> {
  late List<IngredientOption> _selected;
  final Set<IngredientOption> _pressed = {};

  @override
  void initState() {
    super.initState();
    final defaults = widget.options.where((o) => o.isDefault).toList();
    _selected = [
      ...widget.initiallySelected,
      ...defaults.where((d) => !widget.initiallySelected.contains(d)),
    ];
  }

  /*─────────────────────── CHIPS (remove) ───────────────────────*/
  Widget buildRemoveChips(List<IngredientOption> removeOpts) {
    final cs = Theme.of(context).colorScheme;
    final txt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: removeOpts.map((opt) {
          final isRemoved = _selected.contains(opt);
          final canRemove = opt.canRemove;

          final chip = FilterChip(
            label: Text(opt.ingredient.name),
            labelStyle: txt.bodySmall?.copyWith(
              fontSize: 13,
              height: 1.2,
              fontWeight: FontWeight.w600,
              color: isRemoved ? cs.onSurface : cs.onSurfaceVariant,
            ),
            selected: isRemoved,
            selectedColor: cs.primaryContainer.withOpacity(.18),
            checkmarkColor: cs.primary,
            backgroundColor: canRemove
                ? cs.surfaceContainerHighest.withOpacity(.14)
                : cs.surfaceContainerHighest.withOpacity(.06),
            onSelected: canRemove
                ? (sel) {
                    HapticFeedback.lightImpact();
                    setState(
                        () => sel ? _selected.add(opt) : _selected.remove(opt));
                  }
                : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isRemoved
                  ? BorderSide(color: cs.primary, width: 1)
                  : BorderSide(
                      color: canRemove ? Colors.transparent : cs.outlineVariant,
                      width: 1,
                    ),
            ),
          );

          return isRemoved
              ? chip
              : _buildDiagonalCurvedStrike(
                  child: chip,
                  color: cs.onSurfaceVariant.withOpacity(.75),
                  strokeWidth: 2.6,
                );
        }).toList(),
      ),
    );
  }

  /*─────────────────────── STRIKE helper ───────────────────────*/
  Widget _buildDiagonalCurvedStrike({
    required Widget child,
    required Color color,
    double strokeWidth = 2.8,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _CurvedDiagonalStrikePainter(
                color: color,
                strokeWidth: strokeWidth,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /*──────────────────────── GRID (add-ons) ──────────────────────*/
  Widget buildGrid(List<IngredientOption> list) {
    final cs = Theme.of(context).colorScheme;
    final txt = Theme.of(context).textTheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      itemCount: list.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisExtent: 140,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (_, i) {
        final opt = list[i];
        final isSel = _selected.contains(opt);
        final isPressed = _pressed.contains(opt);
        final url = opt.ingredient.photo?.mediumUrl ??
            opt.ingredient.photo?.thumbnailUrl ??
            opt.ingredient.photo?.url ??
            '';

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => isSel ? _selected.remove(opt) : _selected.add(opt));
          },
          onTapDown: (_) => setState(() => _pressed.add(opt)),
          onTapUp: (_) => setState(() => _pressed.remove(opt)),
          onTapCancel: () => setState(() => _pressed.remove(opt)),
          child: AnimatedScale(
            scale: isPressed ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSel
                    ? cs.primaryContainer.withOpacity(.18)
                    : dark
                        ? cs.surfaceContainerHighest.withOpacity(.15)
                        : Colors.white.withOpacity(.90),
                borderRadius: BorderRadius.circular(16),
                border: isSel ? Border.all(color: cs.primary, width: 1) : null,
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (url.isNotEmpty)
                    Expanded(
                      child: CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.broken_image,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    opt.ingredient.name,
                    style: txt.bodySmall?.copyWith(
                      fontSize: 13,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${opt.addPrice} ₽',
                    style: txt.labelLarge?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /*──────────────────────────── BUILD ───────────────────────────*/
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final txt = Theme.of(context).textTheme;
    final topInset = MediaQuery.of(context).viewPadding.top;

    final addOpts =
        widget.options.where((o) => o.canAdd && !o.isDefault).toList();
    final removeOpts = widget.options.where((o) => o.isDefault).toList();
    final extraSum = _selected
        .where((o) => !o.isDefault)
        .fold<int>(0, (s, o) => s + o.addPrice);

    Widget sectionTitle(String t, {double top = 20}) => Padding(
          padding: EdgeInsets.fromLTRB(16, top, 16, 8),
          child: Text(
            t,
            style: txt.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
        );

    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.97,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            children: [
              /*──────── HEADER ───────*/
              Padding(
                padding: EdgeInsets.only(top: topInset),
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(26)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                    child: Container(
                      height: 56,
                      color: cs.surfaceContainerHighest.withOpacity(.42),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        widget.sheetTitle,
                        style: txt.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),

              /*──────── CONTENT ───────*/
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: EdgeInsets.zero,
                  children: [
                    sectionTitle('Добавить по вкусу', top: 12),
                    buildGrid(addOpts),
                    sectionTitle('Убрать ингредиенты', top: 16),
                    buildRemoveChips(removeOpts),
                  ],
                ),
              ),

              /*──────── BUTTON ───────*/
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  MediaQuery.of(context).viewPadding.bottom + 8,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, _selected),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      extraSum > 0
                          ? 'Добавить +$extraSum ₽'
                          : 'Применить изменения',
                      style: txt.titleLarge?.copyWith(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*─────────────────── PAINTER (diagonal strike) ───────────────────*/
class _CurvedDiagonalStrikePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  const _CurvedDiagonalStrikePainter({
    required this.color,
    this.strokeWidth = 2.6,
  });

  @override
  void paint(Canvas c, Size s) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final start = Offset(s.width * 0.06, s.height * 0.78);
    final end = Offset(s.width * 0.94, s.height * 0.28);
    final ctrl1 = Offset(s.width * 0.33, start.dy - s.height * 0.06);
    final ctrl2 = Offset(s.width * 0.67, end.dy + s.height * 0.06);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        ctrl1.dx,
        ctrl1.dy,
        ctrl2.dx,
        ctrl2.dy,
        end.dx,
        end.dy,
      );

    c.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CurvedDiagonalStrikePainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
