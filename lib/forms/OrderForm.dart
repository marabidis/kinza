// lib/ui/widgets/order_form.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kinza/models/delivery_method.dart';
import 'package:flutter_kinza/theme/app_styles.dart';

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
  final _nameCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _addrCtl = TextEditingController();
  final _commentCtl = TextEditingController();

  late final TabController _tabs = TabController(length: 2, vsync: this)
    ..addListener(_onTab);

  String? _nameErr, _phoneErr, _addrErr;

  // ──────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _phoneCtl.addListener(_formatPhone);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _nameCtl.dispose();
    _phoneCtl.dispose();
    _addrCtl.dispose();
    _commentCtl.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────────
  void _onTab() {
    if (_tabs.indexIsChanging) return;
    final m = _tabs.index == 0 ? DeliveryMethod.courier : DeliveryMethod.pickup;
    widget.deliveryMethodNotifier.value = m;
    widget.updateDelivery(m);
    HapticFeedback.mediumImpact();
    setState(() {});
  }

  void _formatPhone() {
    var t = _phoneCtl.text;
    if (t.startsWith('8')) t = '+7${t.substring(1)}';
    if (t.length > 12) t = t.substring(0, 12);
    _phoneCtl
      ..text = t
      ..selection = TextSelection.fromPosition(TextPosition(offset: t.length));
  }

  bool _isNumeric(String v) => double.tryParse(v.replaceAll('+', '')) != null;

  // ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(.035),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        children: [
          Center(
            child: SizedBox(width: 340, child: _tabBar(cs, theme)),
          ),
          const SizedBox(height: 18),
          Form(
            key: _formKey,
            child: Column(
              children: [
                _field(_nameCtl, 'Имя', _validateName, cs, theme),
                const SizedBox(height: 16),
                _field(
                    _phoneCtl,
                    'Номер телефона',
                    _validatePhone,
                    cs,
                    theme,
                    TextInputType.number,
                    [FilteringTextInputFormatter.allow(RegExp('[0-9+]'))]),
                if (widget.deliveryMethodNotifier.value ==
                    DeliveryMethod.courier) ...[
                  const SizedBox(height: 16),
                  _field(_addrCtl, 'Адрес доставки', _validateAddr, cs, theme),
                ],
                const SizedBox(height: 16),
                _field(_commentCtl, 'Комментарий к заказу', (_) => null, cs,
                    theme),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── widgets ───────────────────────────────
  Widget _tabBar(ColorScheme cs, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceVariant,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: _tabs,
        indicator: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withOpacity(.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: cs.onSurface,
        unselectedLabelColor: cs.onSurfaceVariant,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(fontSize: 15),
        unselectedLabelStyle: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 15,
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500),
        indicatorSize: TabBarIndicatorSize.tab,
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        dividerHeight: 0,
        tabs: const [
          Tab(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text('Курьером'))),
          Tab(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text('Самовывоз'))),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController ctl,
    String label,
    String? Function(String?)? validator,
    ColorScheme cs,
    ThemeData theme, [
    TextInputType? kb,
    List<TextInputFormatter>? fmt,
  ]) {
    String? err;
    if (ctl == _nameCtl) err = _nameErr;
    if (ctl == _phoneCtl) err = _phoneErr;
    if (ctl == _addrCtl) err = _addrErr;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: ctl,
            keyboardType: kb,
            inputFormatters: fmt,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15),
            onChanged: (_) {
              HapticFeedback.selectionClick();
              validator?.call(ctl.text);
              _formKey.currentState?.validate();
            },
            decoration: InputDecoration(
              labelText: label,
              labelStyle: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
              filled: true,
              fillColor: cs.surfaceVariant,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: cs.surfaceVariant, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: cs.surfaceVariant, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: cs.primary, width: 2),
              ),
              errorText: null,
            ),
            validator: (_) => null,
          ),
          if (err != null)
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Text(err,
                  style: const TextStyle(color: Colors.red, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  // ────────────────────── validation helpers ───────────────────────
  String? _validateName(String? v) {
    _nameErr = v!.isEmpty ? 'Введите имя' : null;
    return null;
  }

  String? _validatePhone(String? v) {
    _phoneErr = (v == null || v.isEmpty)
        ? 'Введите номер'
        : (!_isNumeric(v) ? 'Введите корректный номер' : null);
    return null;
  }

  String? _validateAddr(String? v) {
    _addrErr = v!.isEmpty ? 'Введите адрес' : null;
    return null;
  }

  // ───────────────────────── external api ──────────────────────────
  bool validate() {
    _validateName(_nameCtl.text);
    _validatePhone(_phoneCtl.text);
    if (widget.deliveryMethodNotifier.value == DeliveryMethod.courier) {
      _validateAddr(_addrCtl.text);
    } else {
      _addrErr = null;
    }
    setState(() {});
    return _nameErr == null && _phoneErr == null && _addrErr == null;
  }

  Map<String, dynamic> getFormData() => {
        'method': widget.deliveryMethodNotifier.value,
        'name': _nameCtl.text,
        'phoneNumber': _phoneCtl.text,
        'address': _addrCtl.text,
        'comment': _commentCtl.text,
      };
}
