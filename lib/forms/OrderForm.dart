import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kinza/styles/app_constants.dart';

enum DeliveryMethod { pickup, courier }

String deliveryMethodToString(DeliveryMethod method) {
  switch (method) {
    case DeliveryMethod.pickup:
      return 'Самовывоз';
    case DeliveryMethod.courier:
      return 'Доставка курьером';
    default:
      return 'Неизвестный метод';
  }
}

class OrderForm extends StatefulWidget {
  final Function(DeliveryMethod, String?, String?, String?, String?) onSubmit;
  final ValueNotifier<DeliveryMethod> deliveryMethodNotifier;
  final Function(DeliveryMethod value) updateDelivery;
  final int totalPrice;

  const OrderForm({
    Key? key,
    required this.onSubmit,
    required this.updateDelivery,
    required this.deliveryMethodNotifier,
    required this.totalPrice,
  }) : super(key: key);

  @override
  OrderFormState createState() => OrderFormState();
}

class OrderFormState extends State<OrderForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _commentController = TextEditingController();

  late TabController _tabController;

  String? _nameError;
  String? _phoneError;
  String? _addressError;
  String? _commentError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _phoneController.addListener(_formatPhone);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    final value = _tabController.index == 0
        ? DeliveryMethod.courier
        : DeliveryMethod.pickup;
    widget.deliveryMethodNotifier.value = value;
    widget.updateDelivery(value);
    HapticFeedback.mediumImpact();
    setState(() {});
  }

  void _formatPhone() {
    final text = _phoneController.text;
    if (text.startsWith('8')) {
      _phoneController.text = '+7${text.substring(1)}';
      _phoneController.selection = TextSelection.fromPosition(
          TextPosition(offset: _phoneController.text.length));
    }
    if (_phoneController.text.length > 12) {
      _phoneController.text = _phoneController.text.substring(0, 12);
      _phoneController.selection = TextSelection.fromPosition(
          TextPosition(offset: _phoneController.text.length));
    }
  }

  bool _isNumeric(String value) =>
      double.tryParse(value.replaceAll("+", "")) != null;

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _phoneController.removeListener(_formatPhone);
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 0),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _buildTabBar(),
          const SizedBox(height: 18),
          Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(
                  _nameController,
                  'Имя',
                  (v) {
                    final error = v!.isEmpty ? 'Введите имя' : null;
                    setState(() {
                      _nameError = error;
                    });
                    return null;
                  },
                ),
                SizedBox(height: 16),
                _buildTextField(
                  _phoneController,
                  'Номер телефона',
                  (v) {
                    String? error;
                    if (v == null || v.isEmpty) {
                      error = 'Введите номер';
                    } else if (!_isNumeric(v)) {
                      error = 'Введите корректный номер';
                    } else {
                      error = null;
                    }
                    setState(() {
                      _phoneError = error;
                    });
                    return null;
                  },
                  TextInputType.number,
                  [FilteringTextInputFormatter.allow(RegExp("[0-9+]"))],
                ),
                SizedBox(height: 16),
                if (widget.deliveryMethodNotifier.value ==
                    DeliveryMethod.courier)
                  _buildTextField(
                    _addressController,
                    'Адрес доставки',
                    (v) {
                      final error = v!.isEmpty ? 'Введите адрес' : null;
                      setState(() {
                        _addressError = error;
                      });
                      return null;
                    },
                  ),
                if (widget.deliveryMethodNotifier.value ==
                    DeliveryMethod.courier)
                  const SizedBox(height: 16),
                _buildTextField(
                  _commentController,
                  'Комментарий к заказу',
                  (v) {
                    setState(() {
                      _commentError = null;
                    });
                    return null;
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF4F6F9),
        borderRadius: BorderRadius.circular(25.0),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(25.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        labelColor: AppColors.black,
        unselectedLabelColor: Colors.grey.shade500,
        labelStyle: AppStyles.buttonTextStyle.copyWith(fontSize: 16),
        unselectedLabelStyle: AppStyles.buttonTextStyle.copyWith(
          fontSize: 16,
          color: Colors.grey.shade500,
          fontWeight: FontWeight.w500,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        tabs: const [
          Tab(text: 'Доставка курьером'),
          Tab(text: 'Самовывоз'),
        ],
        indicatorColor: Colors.transparent,
        dividerHeight: 0,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelText, [
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  ]) {
    String? errorText;
    if (controller == _nameController) {
      errorText = _nameError;
    } else if (controller == _phoneController) {
      errorText = _phoneError;
    } else if (controller == _addressController) {
      errorText = _addressError;
    } else if (controller == _commentController) {
      errorText = _commentError;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller,
            style: AppStyles.bodyTextStyle.copyWith(fontSize: 15),
            onChanged: (_) {
              HapticFeedback.selectionClick();
              if (validator != null) {
                validator(controller.text);
              }
              _formKey.currentState?.validate();
            },
            decoration: InputDecoration(
              labelText: labelText,
              labelStyle: AppStyles.bodyTextStyle.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide:
                    const BorderSide(color: Color(0xFFF4F6F9), width: 2),
              ),
              filled: true,
              fillColor: Color(0xFFF4F6F9),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide:
                    const BorderSide(color: Color(0xFFF4F6F9), width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide:
                    const BorderSide(color: Color(0xFF4141E7), width: 2),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide:
                    const BorderSide(color: Color(0xFFF4F6F9), width: 2),
              ),
              errorText: null,
              errorStyle: const TextStyle(fontSize: 12, height: 1),
            ),
            keyboardType: keyboardType,
            validator: (_) => null,
            inputFormatters: inputFormatters,
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Text(
                errorText,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  height: 1.1,
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool validate() {
    final nameError = _nameController.text.isEmpty ? 'Введите имя' : null;
    final phoneError = _phoneController.text.isEmpty
        ? 'Введите номер'
        : (!_isNumeric(_phoneController.text)
            ? 'Введите корректный номер'
            : null);
    final addressError =
        widget.deliveryMethodNotifier.value == DeliveryMethod.courier &&
                _addressController.text.isEmpty
            ? 'Введите адрес'
            : null;

    setState(() {
      _nameError = nameError;
      _phoneError = phoneError;
      _addressError = addressError;
      _commentError = null;
    });

    return nameError == null && phoneError == null && addressError == null;
  }

  Map<String, dynamic> getFormData() => {
        'method': widget.deliveryMethodNotifier.value,
        'name': _nameController.text,
        'phoneNumber': _phoneController.text,
        'address': _addressController.text,
        'comment': _commentController.text,
      };
}
