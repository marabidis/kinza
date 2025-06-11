// lib/ui/widgets/ingredient_customize_sheet.dart

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kinza/core/models/product.dart';

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
    // Берём первоначальные и добавляем все default
    final defaultOpts = widget.options.where((o) => o.isDefault).toList();
    _selected = [
      ...widget.initiallySelected,
      ...defaultOpts.where((d) => !widget.initiallySelected.contains(d))
    ];
  }

  Widget buildRemoveChips(List<IngredientOption> removeOpts) {
    final cs = Theme.of(context).colorScheme;
    final txt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: removeOpts.map((opt) {
          final isRem = _selected.contains(opt);
          final canRemove = opt.canRemove;
          final chip = FilterChip(
            label: Text(opt.ingredient.name),
            labelStyle: txt.bodySmall?.copyWith(
              fontSize: 13,
              height: 1.2,
              fontWeight: FontWeight.w600,
              color: isRem ? cs.onSurface : cs.onSurfaceVariant,
            ),
            selected: isRem,
            onSelected: canRemove
                ? (sel) {
                    HapticFeedback.lightImpact();
                    setState(() {
                      if (sel)
                        _selected.add(opt);
                      else
                        _selected.remove(opt);
                    });
                  }
                : null,
            selectedColor: cs.primary.withOpacity(.12),
            checkmarkColor: cs.primary,
            backgroundColor: canRemove
                ? cs.surface.withOpacity(.10)
                : cs.surface.withOpacity(.04),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isRem
                  ? BorderSide(color: cs.primary, width: 1)
                  : BorderSide(
                      color: canRemove ? Colors.transparent : cs.outlineVariant,
                      width: 1,
                    ),
            ),
          );

          // Оборачиваем в кастомную диагональную волну, если НЕ выбрано
          if (!isRem) {
            return _buildDiagonalCurvedStrike(
              child: chip,
              color: Colors.white.withOpacity(0.85),
              strokeWidth: 3, // толщина, как в скрине
            );
          } else {
            return chip;
          }
        }).toList(),
      ),
    );
  }

  /// Кастомный Widget для изогнутой диагональной линии (CustomPaint поверх чипа)
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final txt = Theme.of(context).textTheme;
    final topInset = MediaQuery.of(context).viewPadding.top;

    final addOpts =
        widget.options.where((o) => o.canAdd && !o.isDefault).toList();
    final removeOpts = widget.options.where((o) => o.isDefault).toList();

    // --- исправлено: extraSum теперь считает только НЕ дефолтные ---
    final extraSum = _selected
        .where((o) => !o.isDefault)
        .fold<int>(0, (sum, o) => sum + o.addPrice);

    Widget buildSectionTitle(String text) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: txt.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
        );

    Widget buildGrid(List<IngredientOption> list) {
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

          void onTapDown(TapDownDetails _) => setState(() => _pressed.add(opt));
          void onTapUp(TapUpDetails _) => setState(() => _pressed.remove(opt));
          void onTapCancel() => setState(() => _pressed.remove(opt));
          void onTap() {
            HapticFeedback.lightImpact();
            setState(() {
              if (isSel)
                _selected.remove(opt);
              else
                _selected.add(opt);
            });
          }

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            onTapDown: onTapDown,
            onTapUp: onTapUp,
            onTapCancel: onTapCancel,
            child: AnimatedScale(
              scale: isPressed ? 0.96 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSel
                      ? cs.primary.withOpacity(.12)
                      : cs.surface.withOpacity(.15),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      isSel ? Border.all(color: cs.primary, width: 1) : null,
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
                              child: CircularProgressIndicator(strokeWidth: 2)),
                          errorWidget: (_, __, ___) => const Icon(
                              Icons.broken_image,
                              size: 48,
                              color: Colors.grey),
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
                      style:
                          txt.labelLarge?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.97,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Фиксированная шапка с эффектом стекла
                Padding(
                  padding: EdgeInsets.only(top: topInset),
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(26)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: Container(
                        height: 56,
                        color: cs.surface.withOpacity(0.32),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          widget.sheetTitle,
                          style: txt.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),

                // Основной контент
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.zero,
                    children: [
                      const SizedBox(height: 12),
                      buildSectionTitle('Добавить по вкусу'),
                      const SizedBox(height: 8),
                      buildGrid(addOpts),
                      const SizedBox(height: 16),
                      buildSectionTitle('Убрать ингредиенты'),
                      const SizedBox(height: 8),
                      buildRemoveChips(removeOpts),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // Кнопка «Применить / Добавить»
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      16, 8, 16, MediaQuery.of(context).viewPadding.bottom + 8),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, _selected),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        extraSum > 0
                            ? 'Добавить +$extraSum ₽'
                            : 'Применить изменения',
                        style: txt.titleLarge?.copyWith(
                            color: cs.onPrimary, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Painter для изогнутой диагональной линии (по центру чипа)
/// Painter для диагональной волнистой линии,
/// заточенной под подпись FilterChip-а.
class _CurvedDiagonalStrikePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _CurvedDiagonalStrikePainter({
    required this.color,
    this.strokeWidth = 3, // ≈ 3 px, как в макете
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // ────────── узловые точки ──────────
    final start = Offset(
      size.width * 0.06, // ~6 % от левого края
      size.height * 0.78, // низ текста
    );

    final end = Offset(
      size.width * 0.94, // ~94 % от левого края
      size.height * 0.28, // верх текста
    );

    // Контрольные точки даём симметрично,
    // поэтому изгиб будет ровно посередине.
    final ctrl1 = Offset(
      size.width * 0.33,
      start.dy - size.height * 0.06, // лёгкий подъём вверх
    );

    final ctrl2 = Offset(
      size.width * 0.67,
      end.dy + size.height * 0.06, // такой же «отскок» вниз
    );

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(ctrl1.dx, ctrl1.dy, ctrl2.dx, ctrl2.dy, end.dx, end.dy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CurvedDiagonalStrikePainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
