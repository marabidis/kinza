import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  OrderForm({Key? key, required this.onSubmit}) : super(key: key);

  @override
  OrderFormState createState() => OrderFormState();
}

class OrderFormState extends State<OrderForm> {
  final nameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final addressController = TextEditingController();
  final commentController = TextEditingController();

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  @override
  void initState() {
    super.initState();
    phoneNumberController.addListener(_phoneListener);
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

  DeliveryMethod _method = DeliveryMethod.courier;
  final _formKey = GlobalKey<FormState>();

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
              setState(() {
                _method = value!;
              });
            },
          ),
          RadioListTile<DeliveryMethod>(
            title: const Text('Доставка курьером'),
            value: DeliveryMethod.courier,
            groupValue: _method,
            onChanged: (DeliveryMethod? value) {
              setState(() {
                _method = value!;
              });
            },
          ),
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(labelText: "Имя"),
            validator: (value) => value!.isEmpty ? "Введите имя" : null,
          ),
          TextFormField(
            controller: phoneNumberController,
            decoration: InputDecoration(labelText: "Номер телефона"),
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
            TextFormField(
              controller: addressController,
              decoration: InputDecoration(labelText: "Адрес доставки"),
              validator: (value) => value!.isEmpty ? "Введите адрес" : null,
            ),
          TextFormField(
            controller: commentController,
            decoration: InputDecoration(labelText: "Комментарий к заказу"),
          ),
        ],
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
    nameController.dispose();
    phoneNumberController.removeListener(_phoneListener);
    phoneNumberController.dispose();
    addressController.dispose();
    commentController.dispose();
    super.dispose();
  }
}
