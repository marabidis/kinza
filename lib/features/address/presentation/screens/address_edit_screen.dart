//
// Экран создания / редактирования адреса.
//
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kinza/core/models/address.dart';

class AddressEditScreen extends StatefulWidget {
  const AddressEditScreen({Key? key, this.initial}) : super(key: key);

  final Address? initial;

  @override
  State<AddressEditScreen> createState() => _AddressEditScreenState();
}

class _AddressEditScreenState extends State<AddressEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late AddressType _type;
  late TextEditingController _streetCtrl;
  late TextEditingController _houseCtrl;
  late TextEditingController _flatCtrl;
  late TextEditingController _commentCtrl;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final a = widget.initial;
    _type = a?.type ?? AddressType.home;
    _streetCtrl = TextEditingController(text: a?.street ?? '');
    _houseCtrl = TextEditingController(text: a?.house ?? '');
    _flatCtrl = TextEditingController(text: a?.flat ?? '');
    _commentCtrl = TextEditingController(text: a?.comment ?? '');
  }

  @override
  void dispose() {
    _streetCtrl.dispose();
    _houseCtrl.dispose();
    _flatCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final candidate = Address(
      id: widget.initial?.id ?? 0,
      type: _type,
      street: _streetCtrl.text.trim(),
      house: _houseCtrl.text.trim(),
      flat: _flatCtrl.text.trim().isEmpty ? null : _flatCtrl.text.trim(),
      comment:
          _commentCtrl.text.trim().isEmpty ? null : _commentCtrl.text.trim(),
      lat: widget.initial?.lat,
      lng: widget.initial?.lng,
      isDefault: widget.initial?.isDefault ?? false,
    );

    // Возвращаем заполненный объект — фактический create/update выполняется в списке
    Navigator.pop(context, candidate);

    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initial == null ? 'Новый адрес' : 'Редактировать адрес',
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              /* Тип адреса */
              DropdownButtonFormField<AddressType>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Тип адреса'),
                items:
                    AddressType.values
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e.name[0].toUpperCase() + e.name.substring(1),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 12),

              /* Улица */
              TextFormField(
                controller: _streetCtrl,
                decoration: const InputDecoration(labelText: 'Улица'),
                validator:
                    (v) =>
                        v == null || v.trim().isEmpty ? 'Укажите улицу' : null,
              ),
              const SizedBox(height: 12),

              /* Дом / корпус (required в Strapi) */
              TextFormField(
                controller: _houseCtrl,
                decoration: const InputDecoration(labelText: 'Дом / корпус'),
                validator:
                    (v) =>
                        v == null || v.trim().isEmpty
                            ? 'Укажите дом / корпус'
                            : null,
              ),
              const SizedBox(height: 12),

              /* Квартира / офис */
              TextFormField(
                controller: _flatCtrl,
                decoration: const InputDecoration(
                  labelText: 'Квартира / офис (необязательно)',
                ),
              ),
              const SizedBox(height: 12),

              /* Комментарий */
              TextFormField(
                controller: _commentCtrl,
                decoration: const InputDecoration(
                  labelText: 'Комментарий курьеру (необязательно)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              /* Кнопка Сохранить / Обновить */
              ElevatedButton(
                onPressed: _isSaving ? null : _onSave,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isSaving
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Text(
                          widget.initial == null ? 'Сохранить' : 'Обновить',
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
