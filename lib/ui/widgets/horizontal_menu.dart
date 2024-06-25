import 'package:flutter/material.dart';
import 'package:flutter_kinza/styles/app_constants.dart';

class HorizontalMenu extends AppBar {
  final Function(String) onCategoryChanged;
  final ValueNotifier<String?> activeCategoryNotifier;

  HorizontalMenu({
    required this.onCategoryChanged,
    required this.activeCategoryNotifier,
    Key? key,
  }) : super(key: key);

  @override
  _HorizontalMenuState createState() => _HorizontalMenuState();
}

class _HorizontalMenuState extends State<HorizontalMenu> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 60, // Увеличиваем высоту AppBar
      titleSpacing: 0, // Убираем отступы заголовка AppBar
      title: ValueListenableBuilder<String?>(
        valueListenable: widget.activeCategoryNotifier,
        builder: (context, value, child) {
          return Container(
            height: 40, // Увеличиваем высоту контейнера
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero, // Убираем отступы контейнера ListView
              children: [
                _menuButton('Пицца', value),
                _menuButton('Блюда на мангале', value),
                _menuButton('Хачапури', value),
                _menuButton('К блюду', value),
                // Добавьте здесь другие категории, если они есть.
              ],
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
          ), // Увеличиваем вертикальный отступ
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
