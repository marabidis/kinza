import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:kinza/core/models/cart_item.dart';
import 'package:kinza/core/services/order_service.dart';
import 'package:kinza/core/services/phone_auth_service.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CheckoutScreen extends StatefulWidget {
  final int total;
  const CheckoutScreen({super.key, required this.total});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  /* ───────────────── controllers ───────────────── */
  final _formKey = GlobalKey<FormState>();
  final _addrCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _commentCtrl = TextEditingController();
  final _phoneMask = MaskTextInputFormatter(
    mask: '+# (###) ###-##-##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  /* ───────────────── state ───────────────── */
  String _payment = 'card';
  bool _loading = false;
  DateTime? _lastSend; // для cooldown
  Timer? _ticker;
  int _secondsLeft = 0;

  /* ───────────────── services ───────────────── */
  final _auth = PhoneAuthService();
  final _order = OrderService();

  @override
  void dispose() {
    _ticker?.cancel();
    _addrCtrl.dispose();
    _phoneCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  /* ───────────────── helpers ───────────────── */

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
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Введите код из SMS'),
          content: TextField(
            controller: ctrl,
            maxLength: 4,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(counterText: ''),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                if (ctrl.text.length == 4) {
                  code = ctrl.text;
                  Navigator.pop(ctx);
                }
              },
              child: const Text('ОК'),
            ),
          ],
        );
      },
    );
    return code;
  }

  void _showError(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  /* ───────────────── FLOW ───────────────── */

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    // 0️⃣ проверяем сохранённый токен
    String? jwt = await _auth.token;

    final phone = '+${_phoneMask.getUnmaskedText()}';
    if (jwt == null) {
      // 1️⃣ отправляем код
      if (!await _sendCode(phone)) {
        _showError('Не удалось отправить код');
        setState(() => _loading = false);
        return;
      }

      // 2️⃣ диалог ввода кода
      final code = await _askCode();
      if (code == null) {
        setState(() => _loading = false);
        return;
      }

      // 3️⃣ подтверждаем
      jwt = await _auth.confirmCode(phone, code);
      if (jwt == null) {
        _showError('Неверный или истёкший код');
        setState(() => _loading = false);
        return;
      }
    }

    // 4️⃣ создаём заказ
    final orderId = await _order.createOrder(
      jwt: jwt,
      phone: phone,
      address: _addrCtrl.text.trim(),
      payment: _payment,
      comment:
          _commentCtrl.text.trim().isEmpty ? null : _commentCtrl.text.trim(),
      total: widget.total,
    );

    // 5️⃣ очищаем корзину
    await Hive.box<CartItem>('cartBox').clear();

    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => _SuccessPage(orderId: orderId)),
    );
  }

  /* ───────────────── UI ───────────────── */

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
              if (_secondsLeft == 0 && _lastSend != null)
                TextButton(
                  onPressed:
                      () => _sendCode(
                        '+${_phoneMask.getUnmaskedText()}',
                      ), // повторный send
                  child: const Text('Отправить ещё раз'),
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

/* ───────────────── success page ───────────────── */

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
