import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:kinza/core/constants/storage_keys.dart';
import 'package:kinza/core/models/address.dart';
import 'package:kinza/core/services/api_client.dart';

class AddressService {
  AddressService({ApiClient? apiClient})
    : _api = apiClient ?? ApiClient.instance,
      _storage = const FlutterSecureStorage();

  final ApiClient _api; // baseUrl уже оканчивается на /api
  final FlutterSecureStorage _storage;
  final Box<Address> _box = Hive.box<Address>('addresses');

  Future<String?> get _jwt async => _storage.read(key: kJwtKey);

  /*────────────────────────── LOAD ──────────────────────────*/
  Future<List<Address>> fetchForCurrentUser() async {
    final token = await _jwt;
    if (token == null) return _box.values.toList();

    final uri = Uri.parse('${_api.baseUrl}/users/me?populate=addresses');
    final res = await _api.client.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    debugPrint('fetch() ${res.statusCode} ${res.request?.url}');

    if (res.statusCode != 200) {
      throw Exception('Не удалось получить адреса: ${res.statusCode}');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;

    // addrField бывает [] или {data:[…]}
    final addrField = body['addresses'];
    List<dynamic> raw;
    if (addrField is Map<String, dynamic>) {
      raw = addrField['data'] as List<dynamic>? ?? [];
    } else if (addrField is List) {
      raw = addrField;
    } else {
      raw = [];
    }

    final list =
        raw
            .cast<Map<String, dynamic>>()
            .map(Address.fromJson) // безопасно
            .toList();

    _box
      ..clear()
      ..addAll(list);

    return list;
  }

  /*────────────────────────── CREATE ──────────────────────────*/
  Future<Address?> create(Address addr) async {
    final token = await _jwt;
    if (token == null) {
      debugPrint('create() → null jwt');
      return null;
    }

    // id текущего пользователя
    final meRes = await _api.client.get(
      Uri.parse('${_api.baseUrl}/users/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (meRes.statusCode != 200) return null;
    final userId =
        (jsonDecode(meRes.body) as Map<String, dynamic>)['id'] as int;

    final res = await _api.client.post(
      Uri.parse('${_api.baseUrl}/addresses'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'data': addr.toJson(userId: userId)}),
    );

    debugPrint('create() → ${res.statusCode}: ${res.body}');
    if (res.statusCode != 200 && res.statusCode != 201) return null;

    final created = Address.fromJson(
      jsonDecode(res.body)['data'] as Map<String, dynamic>,
    );
    await _box.add(created);
    return created;
  }

  /*────────────────────────── UPDATE ──────────────────────────*/
  Future<bool> update(Address addr) async {
    final token = await _jwt;
    if (token == null) {
      debugPrint('update() → null jwt');
      return false;
    }

    final uri = Uri.parse('${_api.baseUrl}/addresses/${addr.id}');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({'data': addr.toJson()});

    // ─── временный лог ───
    debugPrint(
      'update() → request\n'
      'URL: $uri\n'
      'Headers: $headers\n'
      'Body: $body',
    );

    final res = await _api.client.put(uri, headers: headers, body: body);

    debugPrint('update() → ${res.statusCode}: ${res.body}');

    if (res.statusCode == 200) {
      final i = _box.values.toList().indexWhere((a) => a.id == addr.id);
      if (i != -1) await _box.putAt(i, addr);
      return true;
    }
    return false;
  }
}
