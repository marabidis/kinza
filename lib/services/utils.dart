/// Карта приоритетов категорий. Категории с более низким числовым значением будут отображаться первыми.
final categoryPriorities = {
  'Пицца': 1,
  'Блюда на мангале': 2,
  'Хачапури': 3,
  'К блюду': 4,
  // ... другие категории
};

/// Сортирует список [data] на основе приоритетов категорий, определенных в [categoryPriorities].
/// Категории с неизвестными приоритетами будут помещены в конец списка.
List<Map<String, dynamic>> sortCategories(List<Map<String, dynamic>> data) {
  data.sort((a, b) {
    final categoryA = a['category'];
    final categoryB = b['category'];
    final priorityA = categoryPriorities[categoryA] ?? 999;
    final priorityB = categoryPriorities[categoryB] ?? 999;
    return priorityA.compareTo(priorityB);
  });
  return data;
}
