import 'package:flutter/material.dart';
import 'package:flutter_kinza/styles/app_constants.dart';

class HorizontalMenu extends StatefulWidget implements PreferredSizeWidget {
  final Function(String) onCategoryChanged;
  final ValueNotifier<String?> activeCategoryNotifier;

  const HorizontalMenu({
    required this.onCategoryChanged,
    required this.activeCategoryNotifier,
    Key? key,
  }) : super(key: key);

  @override
  _HorizontalMenuState createState() => _HorizontalMenuState();

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class _HorizontalMenuState extends State<HorizontalMenu> {
  final ScrollController _scrollController = ScrollController();

  final Map<String, String> _categoryEmojis = const {
    'Пицца': '🍕',
    'Блюда на мангале': '🍖',
    'Хачапури': '🧀',
    'К блюду': '🥗',
  };

  final List<String> _categories = const [
    'Пицца',
    'Блюда на мангале',
    'Хачапури',
    'К блюду',
  ];

  late final Map<String, GlobalKey> _itemKeys = {
    for (var c in _categories) c: GlobalKey()
  };

  @override
  void initState() {
    super.initState();
    widget.activeCategoryNotifier.addListener(_scrollToActiveCategory);
  }

  @override
  void dispose() {
    widget.activeCategoryNotifier.removeListener(_scrollToActiveCategory);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToActiveCategory() {
    final active = widget.activeCategoryNotifier.value;
    if (active == null) return;

    final key = _itemKeys[active];
    final ctx = key?.currentContext;
    if (ctx == null) return;

    final box = ctx.findRenderObject() as RenderBox;
    final itemWidth = box.size.width;
    final itemPosition =
        box.localToGlobal(Offset.zero, ancestor: context.findRenderObject()).dx;

    final screenWidth = MediaQuery.of(context).size.width;
    final currentOffset = _scrollController.offset;

    double target =
        currentOffset + itemPosition - (screenWidth / 2 - itemWidth / 2);

    target = target.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
    );
  }

  // Вынесем эмодзи отдельно, чтобы паддинг применялся только к ним.
  Widget _emojiWidget(String emoji) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(
          emoji,
          style: const TextStyle(
            fontSize: 20, // или 22 — можно подобрать визуально
            height: 1.0,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      toolbarHeight: 60,
      titleSpacing: 0,
      title: ValueListenableBuilder<String?>(
        valueListenable: widget.activeCategoryNotifier,
        builder: (_, active, __) => SizedBox(
          height: 44,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final cat = _categories[i];
              final isActive = cat == active;
              final emoji = _categoryEmojis[cat] ?? '';

              return _MenuButton(
                key: _itemKeys[cat],
                emoji: emoji,
                text: cat,
                active: isActive,
                onTap: () {
                  if (!isActive) {
                    widget.activeCategoryNotifier.value = cat;
                    widget.onCategoryChanged(cat);
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppColors.orange : Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.orange.withOpacity(0.19),
                    blurRadius: 15,
                    offset: Offset(0, 4),
                  ),
                ]
              : [],
          border: Border.all(
            color: active
                ? AppColors.orange
                : AppColors.whitegrey.withOpacity(0.22),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Эмодзи с нижним паддингом, чтобы не было обрезания
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                emoji,
                style: const TextStyle(
                  fontSize: 20,
                  height: 1.0,
                ),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              text,
              style: AppStyles.buttonTextStyle.copyWith(
                fontSize: 15,
                color: active ? Colors.white : AppColors.black,
                fontWeight: active ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
