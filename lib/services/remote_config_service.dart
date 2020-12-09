import 'package:firebase/firebase.dart';

const String SAME_DAY_ORDER = "same_day_order";

class RemoteConfigService {
  final RemoteConfig _remoteConfig;
  final defaults = <String, dynamic>{SAME_DAY_ORDER: true};

  static RemoteConfigService _instance;
  static RemoteConfigService get instance {
    if (_instance == null) {
      _instance = RemoteConfigService._(remoteConfig: remoteConfig());
    }

    return _instance;
  }

  bool get canOrderSameDay => _remoteConfig.getBoolean(SAME_DAY_ORDER);

  RemoteConfigService._({RemoteConfig remoteConfig})
      : _remoteConfig = remoteConfig;

  Future initialise({bool debugging = false}) async {
    try {
      _remoteConfig.defaultConfig = defaults;
      _remoteConfig.settings.fetchTimeoutMillis =
          debugging ? Duration(seconds: 5) : Duration(hours: 1);

      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      print(
          'Unable to fetch remote config. Cached or default values will be used');
    }
  }
}
