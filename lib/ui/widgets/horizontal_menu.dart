import 'package:flutter/material.dart';
import 'package:flutter_kinza/styles/app_constants.dart';

class HorizontalMenu extends StatefulWidget implements PreferredSizeWidget {
  final Function(String) onCategoryChanged;
  final ValueNotifier<String?> activeCategoryNotifier;

  HorizontalMenu({
    required this.onCategoryChanged,
    required this.activeCategoryNotifier,
    Key? key,
  }) : super(key: key);

  @override
  _HorizontalMenuState createState() => _HorizontalMenuState();

  @override
  Size get preferredSize => Size.fromHeight(60);
}

class _HorizontalMenuState extends State<HorizontalMenu> {
  final ScrollController _scrollController = ScrollController();

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
    final activeCategory = widget.activeCategoryNotifier.value;
    if (activeCategory != null) {
      final categoryIndex = _categories.indexOf(activeCategory);
      if (categoryIndex != -1) {
        final categoryWidth = 100.0; // Adjust as needed
        final position = categoryIndex * categoryWidth;
        if (position < _scrollController.offset) {
          _scrollController.animateTo(
            position,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else if (position >
            _scrollController.offset +
                MediaQuery.of(context).size.width -
                categoryWidth) {
          _scrollController.animateTo(
            position - MediaQuery.of(context).size.width + categoryWidth,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    }
  }

  List<String> get _categories => [
        'Пицца',
        'Блюда на мангале',
        'Хачапури',
        'К блюду',
        // Add other categories here.
      ];

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 60,
      titleSpacing: 0,
      title: ValueListenableBuilder<String?>(
        valueListenable: widget.activeCategoryNotifier,
        builder: (context, value, child) {
          return Container(
            height: 40,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return _menuButton(category, value);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _menuButton(String category, String? selectedCategory) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        onPressed: () {
          widget.activeCategoryNotifier.value = category;
          widget.onCategoryChanged(category);
        },
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(0.0),
          backgroundColor: MaterialStateProperty.all(
            selectedCategory == category
                ? AppColors.orange
                : AppColors.whitegrey,
          ),
          padding: MaterialStateProperty.all(
            EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ),
        child: Center(
          child: Text(
            category,
            style: AppStyles.buttonTextStyle.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
