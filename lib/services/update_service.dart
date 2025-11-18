// // main.dart
// import 'package:flutter/material.dart';
// import 'package:upgrader/upgrader.dart';
// import 'package:firebase_remote_config/firebase_remote_config.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await _setupRemoteConfig();
//   runApp(const MyApp());
// }

// Future<void> _setupRemoteConfig() async {
//   final remoteConfig = FirebaseRemoteConfig.instance;
//   await remoteConfig.setConfigSettings(RemoteConfigSettings(
//     fetchTimeout: const Duration(seconds: 10),
//     minimumFetchInterval: const Duration(hours: 1),
//   ));
//   await remoteConfig.setDefaults({
//     'app_update': {
//       'min_version': '1.0.0',
//       'force_update': false,
//       'store_url': 'https://play.google.com/store/apps/details?id=com.your.app',
//       'new_features': <String>[],
//     }
//   });
//   await remoteConfig.fetchAndActivate();
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final rc = FirebaseRemoteConfig.instance;
//     final json = rc.getString('app_update');
//     final data = Map<String, dynamic>.from(jsonDecode(json));

//     final minVersion = data['min_version'] as String;
//     final forceUpdate = data['force_update'] as bool;
//     final storeUrl = data['store_url'] as String;
//     final features = List<String>.from(data['new_features']);

//     return MaterialApp(
//       home: UpgradeAlert(
//         upgrader: Upgrader(
//           minAppVersion: minVersion,
//           durationUntilAlertAgain: const Duration(hours: 1),
//           debugLogging: false,
//           messages: UpgraderMessages(
//             code: 'en',
//             title: forceUpdate ? 'Update Required' : 'Update Available',
//             message: forceUpdate
//                 ? 'You must update to continue.'
//                 : (features.isEmpty
//                     ? 'A new version is available.'
//                     : 'New features:\n• ${features.join('\n• ')}'),
//             buttonTitleUpdate: 'UPDATE NOW',
//             buttonTitleIgnore: forceUpdate ? null : 'Later',
//           ),
//         ),
//         dialogBuilder: forceUpdate
//             ? (context, upgrader) => WillPopScope(
//                   onWillPop: () async => false,
//                   child: UpgradeDialog(
//                     upgrader: upgrader,
//                     onUpdate: () {
//                       Upgrader().launchURL(storeUrl);
//                       return true;
//                     },
//                   ),
//                 )
//             : null,
//         child: Scaffold(
//           appBar: AppBar(title: const Text('My App')),
//           body: const Center(child: Text('App Running')),
//         ),
//       ),
//     );
//   }
// }
