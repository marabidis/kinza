import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_kinza/theme/app_theme.dart';
import 'package:flutter/services.dart';

class HorizontalMenu extends StatefulWidget {
  final List<String> categories;
  final String? activeCategory;
  final Function(String) onCategoryChanged;

  const HorizontalMenu({
    Key? key,
    required this.categories,
    required this.activeCategory,
    required this.onCategoryChanged,
  }) : super(key: key);

  static const Map<String, String> _emojis = {
    'Пицца': '🍕',
    'Блюда на мангале': '🍖',
    'Хачапури': '🧀',
    'К блюду': '🥗',
  };

  @override
  State<HorizontalMenu> createState() => _HorizontalMenuState();
}

class _HorizontalMenuState extends State<HorizontalMenu> {
  late final List<GlobalKey> _itemKeys =
      List.generate(widget.categories.length, (_) => GlobalKey());

  @override
  void didUpdateWidget(covariant HorizontalMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Аккуратно! Только если категория сменилась через scroll вертикального списка,
    // тогда доцентровываем выбранную кнопку (автоматически)
    if (widget.activeCategory != oldWidget.activeCategory) {
      SchedulerBinding.instance
          .addPostFrameCallback((_) => _ensureActiveVisible());
    }
  }

  void _ensureActiveVisible() {
    final idx = widget.categories.indexOf(widget.activeCategory ?? '');
    if (idx == -1) return;

    final ctx = _itemKeys[idx].currentContext;
    if (ctx == null) return;

    Scrollable.ensureVisible(
      ctx,
      alignment: 0.5,
      curve: Curves.fastOutSlowIn,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppTheme.menuHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.menuRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            // почти-невидимый цвет, чтобы BackdropFilter работал и "между" кнопками
            color: Colors.white.withOpacity(0.01),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              itemCount: widget.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final cat = widget.categories[i];
                return _MenuButton(
                  key: _itemKeys[i],
                  emoji: HorizontalMenu._emojis[cat] ?? '',
                  text: cat,
                  active: cat == widget.activeCategory,
                  // onTap только смена категории, без ensureVisible
                  onTap: () => widget.onCategoryChanged(cat),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/* ---------- helper: десатурация ---------- */
const _kGray = ColorFilter.matrix(<double>[
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
]);
/* ----------------------------------------- */

class _MenuButton extends StatelessWidget {
  final String emoji;
  final String text;
  final bool active;
  final VoidCallback onTap;

  const _MenuButton({
    Key? key,
    required this.emoji,
    required this.text,
    required this.active,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final emojiWidget = active
        ? Text(emoji,
            style: TextStyle(fontSize: AppTheme.menuEmojiSize, height: 1))
        : ColorFiltered(
            colorFilter: _kGray,
            child: Text(emoji,
                style: TextStyle(fontSize: AppTheme.menuEmojiSize, height: 1)),
          );

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick(); // вот здесь!
        onTap();
      },
      child: AnimatedContainer(
        duration: AppTheme.animFast,
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.menuButtonPadH,
          vertical: AppTheme.menuButtonPadV,
        ),
        decoration: BoxDecoration(
          color: active
              ? cs.surface
              : Colors
                  .transparent, // неактивные полностью прозрачны, blur виден!
          borderRadius: BorderRadius.circular(AppTheme.menuButtonRadius),
          border: Border.all(
            color: active ? cs.primary : cs.outlineVariant.withOpacity(0.36),
            width: active ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: emojiWidget,
            ),
            const SizedBox(width: 5),
            Text(
              text,
              style: TextStyle(
                fontSize: AppTheme.menuFontSize,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? cs.primary : cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
