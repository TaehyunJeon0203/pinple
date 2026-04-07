// TODO: flutterfire configure 명령어로 이 파일을 자동 생성하세요
// 아래는 빌드 에러 방지용 placeholder입니다.
// 실행 방법: flutterfire configure

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('이 플랫폼은 지원하지 않습니다');
    }
  }

  // TODO: Firebase Console에서 가져온 실제 값으로 교체하세요
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
  );
}
