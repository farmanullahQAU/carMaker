// // services/initialization_service.dart
// import 'package:cardmaker/services/remote_config.dart';
// import 'package:cardmaker/services/update_service.dart';
// import 'package:get/get.dart';

// class InitializationService extends GetxService {
//   final RemoteConfigService _remoteConfig = RemoteConfigService();
//   final UpdateManager _updateManager = UpdateManager();

//   bool _isInitialized = false;

//   Future<void> initializeApp() async {
//     if (_isInitialized) return;

//     try {
//       // Initialize remote config
//       await _remoteConfig.initialize();

//       _isInitialized = true;
//     } catch (e) {
//       print('Initialization failed: $e');
//     }
//   }

//   RemoteConfigService get remoteConfig => _remoteConfig;
//   UpdateManager get updateManager => _updateManager;

//   bool get isInitialized => _isInitialized;
// }
