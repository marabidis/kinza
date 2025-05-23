import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Для вибрации!
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_kinza/styles/app_constants.dart';
import 'package:flutter_kinza/models/product.dart';

class CatalogItemWidget extends StatefulWidget {
  final Product? product;
  final bool isChecked;
  final bool isSkeleton;
  final VoidCallback? onAddToCart;
  final VoidCallback? onRemoveFromCart;

  const CatalogItemWidget({
    Key? key,
    this.product,
    this.onAddToCart,
    this.onRemoveFromCart,
    this.isChecked = false,
    this.isSkeleton = false,
  }) : super(key: key);

  @override
  State<CatalogItemWidget> createState() => _CatalogItemWidgetState();
}

class _CatalogItemWidgetState extends State<CatalogItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _plusScale;
  late Animation<double> _cardScale;
  late bool _isInCart;

  @override
  void initState() {
    super.initState();

    _isInCart = widget.isChecked;

    _controller = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _plusScale = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.3, end: 1), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _cardScale = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1.04), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.04, end: 1), weight: 60),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant CatalogItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isChecked != widget.isChecked) {
      setState(() {
        _isInCart = widget.isChecked;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- SKELTON UI ---
  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.025),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Картинка
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Заголовок
                    Container(
                      height: 16,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    SizedBox(height: 6),
                    // Описание
                    Container(
                      height: 12,
                      width: 160,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    SizedBox(height: 6),
                    Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        // Цена
                        Container(
                          width: 56,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        Spacer(),
                        // Кнопка
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // --- END SKELTON ---

  // Новый: метка теперь РЕАЛЬНО над фото и не обрезается!
  Widget _buildPhotoWithMark() {
    final mark = widget.product?.mark;
    Color? backgroundColor;
    String text = '';
    if (mark == 'острая') {
      backgroundColor = AppColors.red;
      text = 'острая';
    } else if (mark == 'дети обожают') {
      backgroundColor = AppColors.pink;
      text = 'дети обожают';
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildImage(),
        if (mark == 'острая' || mark == 'дети обожают')
          Positioned(
            top: -8,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: backgroundColor!.withOpacity(0.23),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImage() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl:
              widget.product?.imageUrl?.thumbnailUrl ?? 'placeholder_image_url',
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 72,
              height: 72,
              color: Colors.white,
            ),
          ),
          errorWidget: (context, url, error) => Icon(Icons.error, size: 72),
          fit: BoxFit.cover,
          width: 72,
          height: 72,
        ),
      ),
    );
  }

  void _handlePlusMinusTap() {
    HapticFeedback.mediumImpact();
    _controller.forward(from: 0);
    setState(() {
      _isInCart = !_isInCart;
    });
    if (_isInCart) {
      widget.onAddToCart?.call();
    } else {
      widget.onRemoveFromCart?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSkeleton) {
      return _buildSkeleton();
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardScale.value,
          child: Container(
            margin: EdgeInsets.symmetric(
              vertical: 6,
              horizontal: 4,
            ),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFFDFDFD),
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.025),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildPhotoWithMark(),
                SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product?.title ?? "",
                          style: AppStyles.catalogItemTitleStyle.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          widget.product?.description ?? "",
                          style: AppStyles.catalogItemDescriptionStyle.copyWith(
                            fontSize: 12,
                            color: Color(0xFF67768C),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 7),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                  color: Color(0xFFE9E9E9),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                widget.product != null
                                    ? 'от ${widget.product!.price}₽'
                                    : '',
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Spacer(),
                            Transform.scale(
                              scale: _plusScale.value,
                              child: IconButton(
                                icon: Icon(
                                  _isInCart
                                      ? Icons.remove_circle_outline
                                      : Icons.add_circle_outline,
                                  color:
                                      _isInCart ? Colors.red : AppColors.green,
                                ),
                                splashRadius: 18,
                                onPressed: _handlePlusMinusTap,
                                tooltip: _isInCart
                                    ? 'Удалить из корзины'
                                    : 'Добавить в корзину',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
