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

  // ignore: deprecated_member_use
  await NaverMapSdk.instance.initialize(
    clientId: 'YOUR_NAVER_MAP_CLIENT_ID',
  );

  runApp(
    const ProviderScope(
      child: PinpleApp(),
    ),
  );
}
