import 'package:flutter/material.dart';
import 'package:flutter_kinza/styles/app_constants.dart';

class HorizontalMenu extends AppBar {
  final Function(String) onCategoryChanged;
  final String activeCategory;

  HorizontalMenu({
    required this.onCategoryChanged,
    required this.activeCategory,
    Key? key,
  }) : super(key: key);

  @override
  HorizontalMenuState createState() => HorizontalMenuState();
}

class HorizontalMenuState extends State<HorizontalMenu> {
  late ScrollController scrollController;
  GlobalKey keyForCategoryPizza = GlobalKey();
  GlobalKey keyForCategoryGrill = GlobalKey();
  GlobalKey keyForCategoryHachapuri = GlobalKey();
  GlobalKey keyForCategorySideDishes = GlobalKey();
  // Добавьте ключи для других категорий, если они есть

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void setActiveCategory(String category) {
    setState(() {
      widget.onCategoryChanged(category);
      scrollToCategory(category);
    });
  }

  void scrollToCategory(String category) {
    GlobalKey? categoryKey;
    switch (category) {
      case 'Пиццы':
        categoryKey = keyForCategoryPizza;
        break;
      case 'Блюда на мангале':
        categoryKey = keyForCategoryGrill;
        break;
      case 'Хачапури':
        categoryKey = keyForCategoryHachapuri;
        break;
      case 'К блюду':
        categoryKey = keyForCategorySideDishes;
        break;
      // Добавьте обработку для других категорий, если они есть
    }

    if (categoryKey != null && categoryKey.currentContext != null) {
      Scrollable.ensureVisible(categoryKey.currentContext!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Container(
        width: MediaQuery.of(context).size.width,
        height: 34,
        child: ListView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          children: [
            MenuButton(
              key: keyForCategoryPizza,
              title: 'Пиццы',
              isActive: widget.activeCategory == 'Пиццы',
              onTap: () => setActiveCategory('Пиццы'),
            ),
            MenuButton(
              key: keyForCategoryGrill,
              title: 'Блюда на мангале',
              isActive: widget.activeCategory == 'Блюда на мангале',
              onTap: () => setActiveCategory('Блюда на мангале'),
            ),
            MenuButton(
              key: keyForCategoryHachapuri,
              title: 'Хачапури',
              isActive: widget.activeCategory == 'Хачапури',
              onTap: () => setActiveCategory('Хачапури'),
            ),
            MenuButton(
              key: keyForCategorySideDishes,
              title: 'К блюду',
              isActive: widget.activeCategory == 'К блюду',
              onTap: () => setActiveCategory('К блюду'),
            ),
            // Добавьте здесь другие категории, если они есть.
          ],
        ),
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final String title;
  final bool isActive;
  final Function()? onTap;
  final GlobalKey key;

  MenuButton({
    required this.title,
    this.isActive = false,
    this.onTap,
    required this.key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor =
        isActive ? AppColors.orange : Color.fromRGBO(195, 195, 195, 1);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
        onPressed: onTap,
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(0.0),
          backgroundColor: MaterialStateProperty.all(backgroundColor),
          padding: MaterialStateProperty.all(
              EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          )),
        ),
        child: Container(
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(fontSize: 16, color: AppColors.white),
          ),
        ),
      ),
    );
  }
}
