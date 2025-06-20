class OrderItem {
  final int productId; // kinza id
  final String titleCached;
  final int price; // ₽
  final int qty;
  final double? weight; // кг
  int get total =>
      weight != null ? (price * (weight! * 10).round()) : price * qty;

  OrderItem({
    required this.productId,
    required this.titleCached,
    required this.price,
    required this.qty,
    this.weight,
  });

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
    productId: j['productId'] as int,
    titleCached: j['titleCached'] as String,
    price: j['price'] as int,
    qty: j['qty'] as int,
    weight: (j['weight'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'titleCached': titleCached,
    'price': price,
    'qty': qty,
    if (weight != null) 'weight': weight,
    'total': total,
  };
}
