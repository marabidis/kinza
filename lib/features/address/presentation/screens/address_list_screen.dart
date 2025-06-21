import 'package:flutter/material.dart';
import 'package:kinza/core/models/address.dart';
import 'package:kinza/core/services/address_service.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({Key? key}) : super(key: key);

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  late Future<List<Address>> _future;
  int? _selectedId;

  @override
  void initState() {
    super.initState();
    _future = AddressService().fetchForCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои адреса')),
      body: FutureBuilder<List<Address>>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Ошибка загрузки: ${snap.error}'));
          }
          final list = snap.data ?? [];
          if (_selectedId == null && list.isNotEmpty) {
            _selectedId =
                list
                    .firstWhere((a) => a.isDefault, orElse: () => list.first)
                    .id;
          }
          if (list.isEmpty) {
            return const Center(
              child: Text('У вас ещё нет сохранённых адресов'),
            );
          }
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final a = list[i];
              return RadioListTile<int>(
                value: a.id,
                groupValue: _selectedId,
                onChanged: (v) => setState(() => _selectedId = v),
                title: Text(a.typeLabel),
                subtitle: Text(a.fullLine),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            _selectedId == null
                ? null
                : () async {
                  final list = await _future;
                  final chosen = list.firstWhere((a) => a.id == _selectedId);
                  Navigator.pop(context, chosen);
                },
        icon: const Icon(Icons.check),
        label: const Text('Доставить сюда'),
      ),
    );
  }
}
