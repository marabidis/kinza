// lib/features/address/presentation/screens/address_list_screen.dart

import 'package:flutter/material.dart';
import 'package:kinza/core/models/address.dart';
import 'package:kinza/core/services/address_service.dart';
import 'package:kinza/features/address/presentation/screens/address_edit_screen.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({Key? key}) : super(key: key);

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  final _service = AddressService();
  late Future<List<Address>> _futureAddresses;
  int? _selectedId;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _futureAddresses = _service.fetchForCurrentUser();
    });
  }

  Future<void> _addOrEdit({Address? initial}) async {
    final edited = await Navigator.push<Address>(
      context,
      MaterialPageRoute(builder: (_) => AddressEditScreen(initial: initial)),
    );
    if (edited == null) return;

    if (initial == null) {
      // создаём новый
      final created = await _service.create(edited);
      if (created == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось сохранить адрес')),
        );
        return;
      }
    } else {
      // обновляем
      final ok = await _service.update(edited);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось обновить адрес')),
        );
        return;
      }
    }

    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои адреса'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addOrEdit(),
          ),
        ],
      ),
      body: FutureBuilder<List<Address>>(
        future: _futureAddresses,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Ошибка: ${snap.error}'));
          }

          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text('У вас ещё нет адресов'));
          }
          // При первом отображении выбираем дефолтный
          if (_selectedId == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _selectedId =
                    list
                        .firstWhere(
                          (a) => a.isDefault,
                          orElse: () => list.first,
                        )
                        .id;
              });
            });
          }

          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final a = list[i];
              return ListTile(
                leading: Radio<int>(
                  value: a.id,
                  groupValue: _selectedId,
                  onChanged: (v) => setState(() => _selectedId = v),
                ),
                title: Text(a.typeLabel),
                subtitle: Text(a.fullLine),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _addOrEdit(initial: a),
                ),
                onTap: () => setState(() => _selectedId = a.id),
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FutureBuilder<List<Address>>(
        future: _futureAddresses,
        builder: (_, snap) {
          final enabled = _selectedId != null;
          return FloatingActionButton.extended(
            icon: const Icon(Icons.check),
            label: const Text('Доставить сюда'),
            onPressed:
                enabled
                    ? () async {
                      final list = await _futureAddresses;
                      final chosen = list.firstWhere(
                        (a) => a.id == _selectedId,
                      );
                      Navigator.pop(context, chosen);
                    }
                    : null,
          );
        },
      ),
    );
  }
}
