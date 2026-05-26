import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinple/app.dart';
import 'package:pinple/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FlutterNaverMap().init(
    clientId: 'num7515n0d',
    onAuthFailed: (ex) {
      debugPrint('===== NaverMap auth failed =====');
      debugPrint('type: ${ex.runtimeType}');
      debugPrint('message: $ex');
      debugPrint('================================');
    },
  );

  runApp(
    const ProviderScope(
      child: PinpleApp(),
    ),
  );
}
