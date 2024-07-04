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
  final int totalPrice; // Добавлено поле для общей суммы заказа

  OrderForm({
    Key? key,
    required this.onSubmit,
    required this.updateDelivery,
    required this.deliveryMethodNotifier,
    required this.totalPrice, // Передаем общую сумму заказа
  }) : super(key: key);

  @override
  OrderFormState createState() => OrderFormState();
}

class OrderFormState extends State<OrderForm>
    with SingleTickerProviderStateMixin {
  final nameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final addressController = TextEditingController();
  final commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    phoneNumberController.addListener(_phoneListener);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        widget.deliveryMethodNotifier.value = _tabController.index == 0
            ? DeliveryMethod.courier
            : DeliveryMethod.pickup;
        widget.updateDelivery(widget.deliveryMethodNotifier.value);
      });
    }
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  void _phoneListener() {
    var text = phoneNumberController.text;

    if (text.startsWith("8")) {
      phoneNumberController.text = "+7${text.substring(1)}";
      phoneNumberController.selection = TextSelection.fromPosition(
          TextPosition(offset: phoneNumberController.text.length));
    }

    if (text.length > 12) {
      phoneNumberController.text = text.substring(0, 12);
      phoneNumberController.selection = TextSelection.fromPosition(
          TextPosition(offset: phoneNumberController.text.length));
    }
  }

  bool validate() {
    return _formKey.currentState?.validate() ?? false;
  }

  Map<String, dynamic> getFormData() {
    return {
      'method': widget.deliveryMethodNotifier.value,
      'name': nameController.text,
      'phoneNumber': phoneNumberController.text,
      'address': addressController.text,
      'comment': commentController.text,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(25.0),
          ),
          padding: EdgeInsets.all(4),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(25.0),
            ),
            labelColor: AppColors.black,
            unselectedLabelColor: AppColors.black,
            labelStyle:
                TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(color: AppColors.black),
            indicatorSize: TabBarIndicatorSize.tab,
            overlayColor: MaterialStateProperty.all(
                Colors.transparent), // Убираем фоновый цвет при клике
            tabs: [
              Tab(text: 'Доставка курьером'),
              Tab(text: 'Самовывоз'),
            ],
            indicatorColor: Colors.transparent,
            dividerHeight:
                0, // fixed tab bar default indicator size. Author: Dima
          ),
        ),
        Container(
          height: 0.5,
          color: Colors.transparent, // Делаем линию под табами прозрачной
        ),
        SizedBox(height: 16),
        Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: nameController,
                labelText: "Имя",
                validator: (value) => value!.isEmpty ? "Введите имя" : null,
              ),
              _buildTextField(
                controller: phoneNumberController,
                labelText: "Номер телефона",
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return "Введите номер";
                  if (!isNumeric(value.replaceAll("+", "")))
                    return "Введите корректный номер";
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[0-9+]")),
                ],
              ),
              if (widget.deliveryMethodNotifier.value == DeliveryMethod.courier)
                _buildTextField(
                  controller: addressController,
                  labelText: "Адрес доставки",
                  validator: (value) => value!.isEmpty ? "Введите адрес" : null,
                ),
              _buildTextField(
                controller: commentController,
                labelText: "Комментарий к заказу",
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      child: TextFormField(
        controller: controller,
        onChanged: (value) {
          HapticFeedback.selectionClick();
          _formKey.currentState?.validate();
        },
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: AppColors.black),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.black),
          ),
          disabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
        keyboardType: keyboardType,
        validator: validator,
        inputFormatters: inputFormatters,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    phoneNumberController.removeListener(_phoneListener);
    phoneNumberController.dispose();
    nameController.dispose();
    addressController.dispose();
    commentController.dispose();
    super.dispose();
  }
}
