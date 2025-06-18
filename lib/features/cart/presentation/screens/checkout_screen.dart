import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Checkout screen for Kinza pizza-delivery app.
///
/// Flow:
/// 1. User sees cart summary.
/// 2. Fills address, phone, payment, comment.
/// 3. On "Confirm order" → triggers auth flow if no JWT, then creates order.
///
/// Note: real networking/auth logic injected via callbacks.
class CheckoutScreen extends StatefulWidget {
  /// Current cart total (₽).
  final int total;

  /// Callback: send code to phone (returns true if sent).
  final Future<bool> Function(String phone) onSendCode;

  /// Callback: confirm code (returns jwt).
  final Future<String?> Function(String phone, String code) onConfirmCode;

  /// Callback: create order (returns orderId).
  final Future<String> Function({
    required String jwt,
    required String phone,
    required String address,
    required String payment,
    String? comment,
  }) onCreateOrder;

  const CheckoutScreen({
    super.key,
    required this.total,
    required this.onSendCode,
    required this.onConfirmCode,
    required this.onCreateOrder,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _comment = TextEditingController();
  String _payment = 'card';
  bool _loading = false;

  @override
  void dispose() {
    _address.dispose();
    _phone.dispose();
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final phone = _phone.text;
    // 1️⃣ Send code
    if (!await widget.onSendCode(phone)) {
      _showError('Не удалось отправить код');
      setState(() => _loading = false);
      return;
    }

    // 2️⃣ Ask for code
    final code = await _askCode();
    if (code == null) {
      setState(() => _loading = false);
      return;
    }

    // 3️⃣ Confirm
    final jwt = await widget.onConfirmCode(phone, code);
    if (jwt == null) {
      _showError('Неверный код');
      setState(() => _loading = false);
      return;
    }

    // 4️⃣ Create order
    final orderId = await widget.onCreateOrder(
      jwt: jwt,
      phone: phone,
      address: _address.text,
      payment: _payment,
      comment: _comment.text.isEmpty ? null : _comment.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => _SuccessPage(orderId: orderId),
      ),
    );
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
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: const InputDecoration(counterText: ''),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
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

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Оформление заказа')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _address,
                    decoration:
                        const InputDecoration(labelText: 'Адрес доставки'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Укажите адрес' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phone,
                    decoration: const InputDecoration(labelText: 'Телефон'),
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        v == null || v.length < 10 ? 'Неверный телефон' : null,
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
                    controller: _comment,
                    decoration: const InputDecoration(
                        labelText: 'Комментарий к заказу'),
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
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Подтвердить'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
            const Icon(Icons.check_circle, size: 72),
            const SizedBox(height: 16),
            Text('Заказ $orderId создан!',
                style: Theme.of(context).textTheme.headlineSmall),
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
}
