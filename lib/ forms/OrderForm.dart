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

  OrderForm({
    Key? key,
    required this.onSubmit,
    required this.updateDelivery,
    required this.deliveryMethodNotifier,
  }) : super(key: key);

  @override
  OrderFormState createState() => OrderFormState();
}

class OrderFormState extends State<OrderForm> {
  final nameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final addressController = TextEditingController();
  final commentController = TextEditingController();
  DeliveryMethod _method;
  final _formKey = GlobalKey<FormState>();

  OrderFormState() : _method = DeliveryMethod.courier;

  @override
  void initState() {
    super.initState();
    _method = widget.deliveryMethodNotifier.value;
    widget.deliveryMethodNotifier.addListener(_onDeliveryMethodChanged);
    phoneNumberController.addListener(_phoneListener);
  }

  void _onDeliveryMethodChanged() {
    setState(() {
      _method = widget.deliveryMethodNotifier.value;
    });
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

    _formKey.currentState?.validate(); // Добавленная строка
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          RadioListTile<DeliveryMethod>(
            title: const Text('Самовывоз'),
            value: DeliveryMethod.pickup,
            groupValue: _method,
            onChanged: (DeliveryMethod? value) {
              HapticFeedback.lightImpact();
              widget.deliveryMethodNotifier.value = value!;
              widget.updateDelivery(value);
            },
            activeColor: AppColors.black, // Цвет активного радиокнопки
          ),
          RadioListTile<DeliveryMethod>(
            title: const Text('Доставка курьером'),
            value: DeliveryMethod.courier,
            groupValue: _method,
            onChanged: (DeliveryMethod? value) {
              HapticFeedback.lightImpact();
              widget.deliveryMethodNotifier.value = value!;
              widget.updateDelivery(value);
            },
            activeColor: AppColors.black, // Цвет активного радиокнопки
          ),
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
              FilteringTextInputFormatter.allow(
                  RegExp("[0-9+]")), // разрешает только цифры и знак +
            ],
          ),
          if (_method == DeliveryMethod.courier)
            _buildTextField(
              controller: addressController,
              labelText: "Адрес доставки",
              validator: (value) => value!.isEmpty ? "Введите адрес" : null,
            ),
          _buildTextField(
            controller: commentController,
            labelText: "Комментарий к заказу",
          ),
        ],
      ),
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
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          border: UnderlineInputBorder(
            borderSide: BorderSide(
              width: 1.0,
              color: Colors.grey,
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              width: 1.0,
              color: Colors.grey,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              width: 1.0,
              color: AppColors.black,
            ),
          ),
          disabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              width: 1.0,
              color: Colors.grey,
            ),
          ),
        ),
        keyboardType: keyboardType,
        validator: validator,
        inputFormatters: inputFormatters,
      ),
    );
  }

  bool validate() {
    return _formKey.currentState!.validate();
  }

  Map<String, dynamic> getFormData() {
    return {
      'method': deliveryMethodToString(_method),
      'name': nameController.text,
      'phoneNumber': phoneNumberController.text,
      'address': addressController.text,
      'comment': commentController.text,
    };
  }

  bool validateAndSaveForm() {
    if (validate()) {
      _formKey.currentState!.save();
      widget.onSubmit(
        _method,
        nameController.text,
        phoneNumberController.text,
        addressController.text,
        commentController.text,
      );
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    widget.deliveryMethodNotifier.removeListener(_onDeliveryMethodChanged);
    nameController.dispose();
    phoneNumberController.removeListener(_phoneListener);
    phoneNumberController.dispose();
    addressController.dispose();
    commentController.dispose();
    super.dispose();
  }
}
