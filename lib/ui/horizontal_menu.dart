import 'package:flutter/material.dart';

class HorizontalMenu extends AppBar {
  final Function(String) onCategoryChanged;

  HorizontalMenu({required this.onCategoryChanged});

  @override
  _HorizontalMenuState createState() => _HorizontalMenuState();
}

class _HorizontalMenuState extends State<HorizontalMenu> {
  String activeCategory = 'Пиццы'; // Изначально активна категория 'Пиццы'

  void setActiveCategory(String category) {
    setState(() {
      activeCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent, // Прозрачный фон AppBar
      elevation: 0, // Убираем тень AppBar
      title: Container(
        width: 390, // Фиксированная ширина меню
        height: 34, // Высота меню
        child: ListView(
          scrollDirection: Axis.horizontal, // Горизонтальная прокрутка
          children: [
            MenuButton(
              title: 'Пиццы',
              isActive: activeCategory == 'Пиццы',
              onTap: () {
                setActiveCategory('Пиццы');
                widget.onCategoryChanged('Пиццы');
              },
            ), // Первый раздел активный
            MenuButton(
              title: 'Блюда на мангале',
              isActive: activeCategory == 'Блюда на мангале',
              onTap: () {
                setActiveCategory('Блюда на мангале');
                widget.onCategoryChanged('Блюда на мангале');
              },
            ),
            MenuButton(
              title: 'Хачапури',
              isActive: activeCategory == 'Хачапури',
              onTap: () {
                setActiveCategory('Хачапури');
                widget.onCategoryChanged('Хачапури');
              },
            ),
            MenuButton(
              title: 'К блюду',
              isActive: activeCategory == 'К блюду',
              onTap: () {
                setActiveCategory('К блюду');
                widget.onCategoryChanged('К блюду');
              },
            ),
            // Добавьте другие категории меню по аналогии
          ],
        ),
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final String title;
  final bool isActive;
  final Function()? onTap; // Функция обратного вызова при нажатии

  MenuButton({
    required this.title,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = isActive
        ? Color.fromRGBO(255, 105, 0, 1) // Фон активной кнопки
        : Color.fromRGBO(195, 195, 195, 1); // Фон неактивных кнопок

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8), // Отступы между кнопками
      child: ElevatedButton(
        onPressed: onTap, // Используем функцию обратного вызова при нажатии
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(0.0), // Убираем тень
          backgroundColor:
              MaterialStateProperty.all(backgroundColor), // Цвет фона кнопки
          padding: MaterialStateProperty.all(EdgeInsets.symmetric(
              horizontal: 16, vertical: 8)), // Отступы внутри кнопки
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50), // Задайте радиус здесь
            ),
          ),
        ),
        child: Container(
          alignment: Alignment.center, // Выравнивание текста по центру
          child: Text(
            title,
            style: TextStyle(
                fontSize: 16, color: Colors.white), // Стиль текста на кнопке
          ),
        ),
      ),
    );
  }
}
