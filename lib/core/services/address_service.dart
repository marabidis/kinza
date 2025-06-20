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

  Future<String?> _jwt() => PhoneAuthService().token;

  Future<List<Address>> fetchRemote() async {
    final tok = await _jwt();
    if (tok == null) return _box.values.toList();

    final res = await _api.client.get(
      Uri.parse('${_api.baseUrl}/addresses'),
      headers: {'Authorization': 'Bearer $tok'},
    );
    if (res.statusCode == 200) {
      final list =
          (jsonDecode(res.body)['data'] as List)
              .map((e) => Address.fromJson(e))
              .toList();
      await _box.clear();
      await _box.addAll(list);
      return list;
    }
    return _box.values.toList();
  }

  Future<Address?> create(Address addr) async {
    final tok = await _jwt();
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
      final created = Address.fromJson(jsonDecode(res.body)['data']);
      await _box.add(created);
      return created;
    }
    return null;
  }

  Future<bool> update(Address addr) async {
    final tok = await _jwt();
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
      if (idx != -1) _box.putAt(idx, addr);
      return true;
    }
    return false;
  }

  Future<bool> delete(int id) async {
    final tok = await _jwt();
    if (tok == null) return false;
    final res = await _api.client.delete(
      Uri.parse('${_api.baseUrl}/addresses/$id'),
      headers: {'Authorization': 'Bearer $tok'},
    );
    if (res.statusCode == 200) {
      _box.values.where((e) => e.id == id).forEach((e) => e.delete());
      return true;
    }
    return false;
  }

  List<Address> get cached => _box.values.toList();
}
