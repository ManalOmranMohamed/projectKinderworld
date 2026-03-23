import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceIdentityService {
  DeviceIdentityService({
    required SharedPreferences sharedPreferences,
    Uuid? uuid,
  })  : _sharedPreferences = sharedPreferences,
        _uuid = uuid ?? const Uuid();

  static const String _deviceIdKey = 'device_identity.installation_id';

  final SharedPreferences _sharedPreferences;
  final Uuid _uuid;

  Future<String> getDeviceId() async {
    final existing = _sharedPreferences.getString(_deviceIdKey)?.trim();
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final generated = _uuid.v4();
    await _sharedPreferences.setString(_deviceIdKey, generated);
    return generated;
  }
}
