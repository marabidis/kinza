// lib/features/cart/presentation/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _commentCtrl = TextEditingController();

  final _phoneMask = MaskTextInputFormatter(
    mask: '+# (###) ###-##-##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  String _payment = 'card';
  bool _loading = false;

  final _auth = PhoneAuthService();
  final _order = OrderService();

  @override
  void dispose() {
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  /*──────────────────────────── FLOW ─────────────────────────────*/

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final phone = '+${_phoneMask.getUnmaskedText()}';

    // 1. /send
    if (!await _auth.sendCode(phone)) {
      _showError('Не удалось отправить код');
      setState(() => _loading = false);
      return;
    }

    // 2. ask code ui
    final code = await _askCode();
    if (code == null) {
      setState(() => _loading = false);
      return;
    }

    // 3. /confirm
    final jwt = await _auth.confirmCode(phone, code);
    if (jwt == null) {
      _showError('Неверный или истёкший код');
      setState(() => _loading = false);
      return;
    }

    // 4. create order
    final orderId = await _order.createOrder(
      jwt: jwt,
      phone: phone,
      address: _addressCtrl.text,
      payment: _payment,
      comment:
          _commentCtrl.text.trim().isEmpty ? null : _commentCtrl.text.trim(),
      total: widget.total,
    );

    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => _SuccessPage(orderId: orderId)),
    );
  }

  /*──────────────────────── UI HELPERS ─────────────────────────*/

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

  /*───────────────────────────── UI ───────────────────────────────*/

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
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Адрес доставки'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Укажите адрес' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'Телефон'),
                keyboardType: TextInputType.phone,
                inputFormatters: [_phoneMask],
                validator: (v) => _phoneMask.getUnmaskedText().length == 11
                    ? null
                    : 'Неверный телефон',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _payment,
                items: const [
                  DropdownMenuItem(
                      value: 'card', child: Text('Картой курьеру')),
                  DropdownMenuItem(value: 'cash', child: Text('Наличными')),
                ],
                onChanged: (v) => setState(() => _payment = v ?? 'card'),
                decoration: const InputDecoration(labelText: 'Оплата'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _commentCtrl,
                decoration:
                    const InputDecoration(labelText: 'Комментарий к заказу'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Итого: ${widget.total} ₽',
                      style: Theme.of(context).textTheme.titleLarge),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
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

/*──────────────────────── Success page ──────────────────────────*/

class _SuccessPage extends StatelessWidget {
  final String orderId;
  const _SuccessPage({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 72, color: Colors.green),
            const SizedBox(height: 16),
            Text('Заказ $orderId создан!',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('На главную'),
            ),
          ],
        ),
      ),
    );
  }
}
