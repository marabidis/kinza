import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:kinza/core/models/address.dart';
import 'package:kinza/core/models/cart_item.dart';
import 'package:kinza/core/services/order_service.dart';
import 'package:kinza/core/services/phone_auth_service.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class CheckoutScreen extends StatefulWidget {
  final int total;
  final Address? initialAddress;

  const CheckoutScreen({super.key, required this.total, this.initialAddress});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  /* ───────────────── controllers ───────────────── */
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _addrCtrl;
  final _phoneCtrl = TextEditingController();
  final _commentCtrl = TextEditingController();
  final _phoneMask = MaskTextInputFormatter(
    mask: '+# (###) ###-##-##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  /* ───────────────── state ───────────────── */
  String _payment = 'card';
  bool _loading = false;
  DateTime? _lastSend;
  Timer? _ticker;
  int _secondsLeft = 0;

  /* ───────────────── services ───────────────── */
  final _auth = PhoneAuthService();
  final _order = OrderService();

  @override
  void initState() {
    super.initState();
    _addrCtrl = TextEditingController(
      text: widget.initialAddress?.fullLine ?? '',
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _addrCtrl.dispose();
    _phoneCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _secondsLeft = 60;
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft == 0) t.cancel();
    });
  }

  Future<bool> _sendCode(String phone) async {
    _lastSend = DateTime.now();
    final ok = await _auth.sendCode(phone);
    if (ok) _startCooldown();
    return ok;
  }

  Future<String?> _askCode() async {
    String? code;
    await showModalBottomSheet<String?>(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Введите код из SMS',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              PinCodeTextField(
                appContext: context,
                length: 4,
                autoFocus: true,
                animationType: AnimationType.fade,
                keyboardType: TextInputType.number,
                cursorColor: Theme.of(context).primaryColor,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  fieldHeight: 60,
                  fieldWidth: 50,
                  borderRadius: BorderRadius.circular(8),
                  activeColor: Theme.of(context).primaryColor,
                  selectedColor: Theme.of(context).primaryColor,
                  inactiveColor: Colors.grey.shade300,
                  activeFillColor: Colors.white,
                  selectedFillColor: Colors.white,
                  inactiveFillColor: Colors.white,
                ),
                animationDuration: const Duration(milliseconds: 200),
                enableActiveFill: true,
                onCompleted: (value) {
                  code = value;
                  Navigator.of(ctx).pop(value);
                },
                onChanged: (_) {},
                beforeTextPaste: (_) => false,
              ),
              const SizedBox(height: 12),
              if (_secondsLeft > 0)
                Text(
                  'Код можно отправить повторно через $_secondsLeft с',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                )
              else if (_lastSend != null)
                TextButton(
                  onPressed: () {
                    final phone = '+${_phoneMask.getUnmaskedText()}';
                    _sendCode(phone);
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Отправить ещё раз'),
                ),
            ],
          ),
        );
      },
    );
    return code;
  }

  void _showError(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    String? jwt = await _auth.token;
    final phone = '+${_phoneMask.getUnmaskedText()}';
    if (jwt == null) {
      if (!await _sendCode(phone)) {
        _showError('Не удалось отправить код');
        setState(() => _loading = false);
        return;
      }
      final code = await _askCode();
      if (code == null) {
        setState(() => _loading = false);
        return;
      }
      jwt = await _auth.confirmCode(phone, code);
      if (jwt == null) {
        _showError('Неверный или истёкший код');
        setState(() => _loading = false);
        return;
      }
    }

    final orderId = await _order.createOrder(
      jwt: jwt,
      phone: phone,
      address: _addrCtrl.text.trim(),
      payment: _payment,
      comment:
          _commentCtrl.text.trim().isEmpty ? null : _commentCtrl.text.trim(),
      total: widget.total,
    );

    await Hive.box<CartItem>('cartBox').clear();

    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => _SuccessPage(orderId: orderId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Оформление заказа')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _addrCtrl,
                decoration: const InputDecoration(labelText: 'Адрес доставки'),
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Укажите адрес'
                            : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'Телефон'),
                keyboardType: TextInputType.phone,
                inputFormatters: [_phoneMask],
                validator:
                    (_) =>
                        _phoneMask.getUnmaskedText().length == 11
                            ? null
                            : 'Неверный телефон',
              ),
              const SizedBox(height: 8),
              if (_secondsLeft > 0)
                Text(
                  'Код можно отправить повторно через $_secondsLeft с',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _payment,
                decoration: const InputDecoration(labelText: 'Оплата'),
                items: const [
                  DropdownMenuItem(
                    value: 'card',
                    child: Text('Картой курьеру'),
                  ),
                  DropdownMenuItem(value: 'cash', child: Text('Наличными')),
                ],
                onChanged: (v) => setState(() => _payment = v ?? 'card'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _commentCtrl,
                decoration: const InputDecoration(
                  labelText: 'Комментарий к заказу',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Итого: ${widget.total} ₽',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child:
                        _loading
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Подтвердить'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessPage extends StatelessWidget {
  final String orderId;
  const _SuccessPage({required this.orderId});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 72, color: Colors.green),
          const SizedBox(height: 16),
          Text(
            'Заказ $orderId создан!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            child: const Text('На главную'),
          ),
        ],
      ),
    ),
  );
}
