import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:kinza/core/models/address.dart';
import 'package:kinza/core/services/api_client.dart';
import 'package:kinza/core/services/phone_auth_service.dart';

class AddressService {
  AddressService({ApiClient? api})
    : _api = api ?? ApiClient.instance,
      _box = Hive.box<Address>('addresses');

  final ApiClient _api;
  final Box<Address> _box;

  Future<String?> get _jwt async => PhoneAuthService().token;

  /// Загружает адреса текущего пользователя (/users/me?populate=addresses).
  Future<List<Address>> fetchForCurrentUser() async {
    final tok = await _jwt;
    if (tok == null) return _box.values.toList();

    final res = await _api.client.get(
      Uri.parse('${_api.baseUrl}/users/me?populate=addresses'),
      headers: {'Authorization': 'Bearer $tok'},
    );

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      final attrs = decoded['data']['attributes'] as Map<String, dynamic>;
      final raw = attrs['addresses']?['data'] as List<dynamic>? ?? [];

      // парсим каждую запись в Address
      final list =
          raw.cast<Map<String, dynamic>>().map(Address.fromJson).toList();

      await _box.clear();
      await _box.addAll(list);
      return list;
    }

    // на не-200 возвращаем локальный кеш
    return _box.values.toList();
  }

  /// Создаёт новый адрес на сервере и сохраняет в Hive.
  Future<Address?> create(Address addr) async {
    final tok = await _jwt;
    if (tok == null) return null;

    final res = await _api.client.post(
      Uri.parse('${_api.baseUrl}/addresses'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $tok',
      },
      body: jsonEncode({'data': addr.toJson()}),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = (jsonDecode(res.body)['data'] as Map<String, dynamic>);
      final created = Address.fromJson(data);
      await _box.add(created);
      return created;
    }

    return null;
  }

  /// Обновляет адрес на сервере и в Hive.
  Future<bool> update(Address addr) async {
    final tok = await _jwt;
    if (tok == null) return false;

    final res = await _api.client.put(
      Uri.parse('${_api.baseUrl}/addresses/${addr.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $tok',
      },
      body: jsonEncode({'data': addr.toJson()}),
    );

    if (res.statusCode == 200) {
      final idx = _box.values.toList().indexWhere((e) => e.id == addr.id);
      if (idx != -1) {
        await _box.putAt(idx, addr);
      }
      return true;
    }

    return false;
  }

  /// Удаляет адрес на сервере и из Hive.
  Future<bool> delete(int id) async {
    final tok = await _jwt;
    if (tok == null) return false;

    final res = await _api.client.delete(
      Uri.parse('${_api.baseUrl}/addresses/$id'),
      headers: {'Authorization': 'Bearer $tok'},
    );
    if (res.statusCode != 200) return false;

    // удаляем все записи с этим id
    final keysToDelete =
        _box.keys.where((k) {
          final a = _box.get(k);
          return a != null && a.id == id;
        }).toList();

    for (final key in keysToDelete) {
      await _box.delete(key);
    }

    return true;
  }

  /// Локальный кеш.
  List<Address> get cached => _box.values.toList();
}
