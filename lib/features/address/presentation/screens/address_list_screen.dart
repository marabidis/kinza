import 'package:flutter/material.dart';
import 'package:kinza/core/models/address.dart';
import 'package:kinza/core/services/address_service.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

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
    final cs = Theme.of(context).colorScheme;
    final txt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Мои адреса')),
      body: FutureBuilder<List<Address>>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Ошибка: ${snap.error}'));
          }
          final list = snap.data ?? [];
          if (_selectedId == null && list.isNotEmpty) {
            _selectedId =
                list
                    .firstWhere((e) => e.isDefault, orElse: () => list.first)
                    .id;
          }
          if (list.isEmpty) {
            return const Center(child: Text('У вас ещё нет адресов'));
          }
          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 80, top: 8),
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final a = list[i];
              return RadioListTile<int>(
                value: a.id,
                groupValue: _selectedId,
                onChanged: (v) => setState(() => _selectedId = v),
                title: Text(a.typeLabel, style: txt.titleMedium),
                subtitle: Text(
                  a.fullLine,
                  style: txt.bodySmall?.copyWith(color: cs.outline),
                ),
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
                  final chosen = (await _future).firstWhere(
                    (e) => e.id == _selectedId,
                  );
                  if (!mounted) return;
                  Navigator.pop<Address>(context, chosen);
                },
        icon: const Icon(Icons.check),
        label: const Text('Доставить сюда'),
      ),
    );
  }
}
