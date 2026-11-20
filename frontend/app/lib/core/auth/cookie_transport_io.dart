import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CookieTransport {
  PersistCookieJar? _jar;

  Future<PersistCookieJar> _cookies() async {
    final current = _jar;
    if (current != null) return current;
    final jar = PersistCookieJar(
      ignoreExpires: false,
      storage: SecureCookieStorage(),
    );
    _jar = jar;
    return jar;
  }

  Future<void> configure(Dio dio) async {
    dio.interceptors.add(CookieManager(await _cookies()));
  }

  Future<Map<String, String>> headers(Uri uri) async {
    final cookies = await (await _cookies()).loadForRequest(uri);
    if (cookies.isEmpty) return const {};
    return {
      'Cookie': cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; '),
    };
  }

  Future<void> clear() async => (await _cookies()).deleteAll();
}

final sessionCookies = CookieTransport();

/// Persists the cookie jar in the Android/iOS secure storage, but never lets a
/// storage failure break a request. When the platform keystore returns a
/// corrupted entry (for example after a backup restore), the cookie jar falls
/// back to memory so sign-in still works for the current session.
class SecureCookieStorage extends Storage {
  static const _prefix = 'cookie_jar:';
  // FlutterSecureStorage returns this string (instead of throwing) when
  // resetOnError drops unreadable data.
  static const _resetSentinel = 'Data has been reset';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      // Drops unreadable values instead of failing every read after a key
      // invalidation. Only the cookie jar lives under this storage.
      resetOnError: true,
    ),
  );

  final Map<String, String> _memory = {};

  @override
  Future<void> init(bool persistSession, bool ignoreExpires) async {}

  @override
  Future<String?> read(String key) async {
    try {
      final value = await _storage.read(key: '$_prefix$key');
      if (value == null || value == _resetSentinel) return _memory[key];
      return value;
    } catch (error) {
      debugPrint('SecureCookieStorage read failed: $error');
      return _memory[key];
    }
  }

  @override
  Future<void> write(String key, String value) async {
    _memory[key] = value;
    try {
      await _storage.write(key: '$_prefix$key', value: value);
    } catch (error) {
      debugPrint('SecureCookieStorage write failed: $error');
    }
  }

  @override
  Future<void> delete(String key) async {
    _memory.remove(key);
    try {
      await _storage.delete(key: '$_prefix$key');
    } catch (error) {
      debugPrint('SecureCookieStorage delete failed: $error');
    }
  }

  @override
  Future<void> deleteAll(List<String> keys) async {
    for (final key in keys) {
      await delete(key);
    }
  }
}
