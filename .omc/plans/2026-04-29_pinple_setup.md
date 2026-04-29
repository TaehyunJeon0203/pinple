# Pinple 셋업 플랜 (2026-04-29)

## 목표
placeholder 상태인 Pinple 앱을 **실기기에서 처음부터 끝까지 동작**하도록 만들고, **첫 의미있는 커밋**까지 완료.

## 전제
- Android 우선, iOS는 폴더만 있는 상태 (빌드는 나중)
- Firebase 무료 Spark 플랜만 사용, Cloud Functions 사용 안 함
- 네이버 클라우드 플랫폼(NCP) 무료 한도 안에서 사용
- Android 패키지: `kr.ac.kongju.pinple` (이미 설정됨)

## 완료 기준 (Acceptance Criteria)
- [ ] 안드로이드 실기기/에뮬레이터에서 `flutter run` 시 흰 화면/크래시 없이 로그인 화면 진입
- [ ] `@smail.kongju.ac.kr` 이메일로 회원가입 → 인증 메일 수신 → 인증 후 지도 진입 가능
- [ ] 캠퍼스 반경 2km 밖에서는 `LocationBlockedScreen` 표시
- [ ] 지도에 네이버 지도가 정상 렌더, 모임 핀 추가/삭제 시 지도에 즉시 반영
- [ ] Firestore Rules가 미인증 유저의 읽기/쓰기를 차단
- [ ] `flutter analyze` 0 errors
- [ ] 발견된 코드 이슈 3개(`map_screen.dart` ref.listen, 닉네임 fallback, signup 트랜잭션) 모두 수정
- [ ] 첫 커밋 완료, 시크릿 파일 git에 안 들어감

---

## Stage 0. 외부 계정/프로젝트 준비 (수동, 사용자 작업)

### 0-1. Firebase 프로젝트 생성
- https://console.firebase.google.com → "프로젝트 추가"
- 프로젝트 이름: `pinple` (또는 원하는 이름)
- Google Analytics: **비활성화 권장** (필요 없고 Spark 단순화)
- 위치: `asia-northeast3` (서울)

### 0-2. Firebase 서비스 활성화
- **Authentication** → "시작하기" → 로그인 방법: 이메일/비밀번호 활성화
- **Cloud Firestore** → "데이터베이스 만들기" → **프로덕션 모드** → 위치: `asia-northeast3`

### 0-3. 네이버 클라우드 플랫폼 (NCP) Maps
- https://www.ncloud.com → 가입 (휴대폰 인증, 결제수단 등록 — 무료 한도 내 0원)
- 콘솔 → **AI·Application Service** → **Maps** → "이용 신청"
- **Application 등록**:
  - 애플리케이션 이름: `Pinple`
  - 서비스: **Mobile Dynamic Map** 체크
  - Android 패키지 이름: `kr.ac.kongju.pinple`
  - iOS Bundle ID: `kr.ac.kongju.pinple` (지금 설정해두면 나중에 편함)
- **Client ID 발급** → 메모해두기

### 0-4. 검증
- Firebase 콘솔에서 프로젝트 ID, Auth 활성, Firestore 빈 DB 확인
- NCP에서 Client ID 복사 가능

---

## Stage 1. Firebase 연동 (자동화 도구 사용)

### 1-1. FlutterFire CLI 설치
```bash
dart pub global activate flutterfire_cli
firebase login   # 처음 한 번만 (firebase-tools 이미 설치 가정)
```
- `firebase-tools` 미설치 시: `npm install -g firebase-tools`

### 1-2. 프로젝트에 Firebase 연결
프로젝트 루트에서:
```bash
flutterfire configure --project=<firebase-project-id>
```
- Android만 선택 (iOS는 일단 패스, 나중에 같은 명령으로 추가)
- 자동 생성/갱신:
  - `lib/firebase_options.dart` (placeholder가 실제 값으로 교체됨)
  - `android/app/google-services.json` 자동 배치
  - `android/build.gradle.kts`, `android/app/build.gradle.kts`에 Google Services 플러그인 자동 추가

### 1-3. Android Gradle 확인
- `android/build.gradle.kts`에 `id("com.google.gms.google-services") version "4.4.2" apply false` 추가됐는지 확인
- `android/app/build.gradle.kts`의 `plugins` 블록에 `id("com.google.gms.google-services")` 추가됐는지 확인
- 자동 추가 안 됐으면 수동으로 추가

### 1-4. .gitignore 정책 결정
**선택 1 (추천, 단독 개발)**: `google-services.json` 커밋 — Firebase API 키는 SHA-1 + Firestore Rules로 보호되므로 진짜 시크릿 아님
**선택 2 (협업/오픈소스)**: `.gitignore`에 추가
```
**/android/app/google-services.json
**/ios/Runner/GoogleService-Info.plist
```

### 1-5. Firestore Rules 작성
Firebase 콘솔 → Firestore → "규칙" 탭에 붙여넣기:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() {
      return request.auth != null;
    }
    function isVerified() {
      return isSignedIn() && request.auth.token.email_verified == true;
    }
    function isKongjuEmail() {
      return isSignedIn() &&
        request.auth.token.email.matches('.*@smail\\.kongju\\.ac\\.kr$');
    }
    function isMember() {
      return isSignedIn() && (
        request.auth.token.email_verified == true &&
        request.auth.token.email.matches('.*@smail\\.kongju\\.ac\\.kr$')
      );
    }

    // 유저 본인 정보만 쓰기 가능, 인증된 유저는 모두 읽기 가능
    match /users/{userId} {
      allow read: if isMember();
      allow create: if isSignedIn() && request.auth.uid == userId
                    && isKongjuEmail();
      allow update, delete: if isSignedIn() && request.auth.uid == userId;
    }

    // 모임: 인증된 유저는 읽기, 본인이 만든 모임만 수정/삭제
    match /groups/{groupId} {
      allow read: if isMember();
      allow create: if isMember()
                    && request.resource.data.ownerId == request.auth.uid;
      allow update: if isMember() && (
        // 모임장은 모든 수정 가능
        resource.data.ownerId == request.auth.uid ||
        // 멤버 추가만 (참여 신청 수락 시 다른 유저가 자기 자신을 추가)
        request.resource.data.diff(resource.data).affectedKeys().hasOnly(['memberIds'])
      );
      allow delete: if isMember() && resource.data.ownerId == request.auth.uid;
    }

    // 참여 신청: 본인이 보낸 것 또는 모임장이 받은 것만 접근
    match /join_requests/{requestId} {
      allow read: if isMember() && (
        resource.data.requesterId == request.auth.uid ||
        get(/databases/$(database)/documents/groups/$(resource.data.groupId)).data.ownerId == request.auth.uid
      );
      allow create: if isMember()
                    && request.resource.data.requesterId == request.auth.uid
                    && request.resource.data.status == 'pending';
      allow update: if isMember() && (
        get(/databases/$(database)/documents/groups/$(resource.data.groupId)).data.ownerId == request.auth.uid
      );
      allow delete: if isMember() && (
        resource.data.requesterId == request.auth.uid ||
        get(/databases/$(database)/documents/groups/$(resource.data.groupId)).data.ownerId == request.auth.uid
      );
    }
  }
}
```

### 1-6. Firestore 인덱스
`group_repository.dart`에서 사용하는 쿼리:
- `where('isActive', isEqualTo: true)` — 단일 필드, 인덱스 불필요
- `where('groupId', ...).where('status', ...)` — 복합 인덱스 필요할 수 있음
- `where('memberIds', arrayContains: userId)` — 단일 필드, 자동
→ 첫 실행 시 콘솔 로그에 인덱스 생성 링크가 나오면 클릭만 하면 됨

### 1-7. 검증
- `flutter run` → 로그인 화면 떠야 함 (네이버맵 키 없어도 여기까지는 OK)
- Firestore Rules 시뮬레이터에서 미인증 read 차단 확인

---

## Stage 2. 네이버맵 연동

### 2-1. main.dart 키 교체
`lib/main.dart:17` 의 `'YOUR_NAVER_MAP_CLIENT_ID'` → 실제 NCP Client ID로 교체

### 2-2. Android 권한/설정 확인
`android/app/src/main/AndroidManifest.xml`:
- `<uses-permission android:name="android.permission.INTERNET"/>` (있어야 함)
- `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>`
- `<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>`

### 2-3. minSdk 확인
- `android/app/build.gradle.kts` 의 `minSdk = 24` (현재) — 네이버맵 SDK 요구사항(21+) 충족

### 2-4. 검증
- 에뮬레이터(또는 실기기) 위치를 천안캠퍼스 좌표로 mock
  - Android Studio: Extended Controls → Location → 36.85, 127.1515
- 회원가입 → 인증 → 지도 화면에서 네이버 지도 렌더 확인

---

## Stage 3. 코드 이슈 수정

### 3-1. `map_screen.dart` `ref.listen` 위치 버그
**문제**: `ref.listen`이 `_updateMarkers()` 안에서 호출되는데, 이건 `onMapReady` 콜백에서 트리거됨 → `build` 외부 시점이라 동작 보장 안 됨
**수정**: `build` 메서드 안으로 이동
```dart
@override
Widget build(BuildContext context) {
  ref.listen(activeGroupsProvider, (_, next) {
    next.whenData(_setMarkers);
  });
  // ... 기존 locationCheck.when(...) 그대로
}
```
그리고 `_updateMarkers()` 메서드에서 `ref.listen` 부분 제거, `onMapReady`에서는 `_setMarkers` 호출만 유지.

### 3-2. `group_detail_screen.dart` 닉네임 fallback 버그
**문제**: `currentUser.displayName` 은 Firebase Auth의 `displayName`인데, 이 앱은 `users/{uid}` 문서의 `displayName` 필드에 닉네임 저장 → Auth 쪽은 비어있어서 항상 email로 fallback됨
**수정**: `_showJoinDialog` 안에서 `userDataProvider`로 닉네임 조회
```dart
final userData = await ref.read(authRepositoryProvider).getUserData(currentUser!.uid);
final nickname = userData?['displayName'] ?? currentUser.email ?? '';
```

### 3-3. signup 트랜잭션 보강
**문제**: `auth_repository.dart:30-36` Auth 계정 생성 후 Firestore 문서 생성 사이 실패 시 orphan 유저 발생
**수정**: 실패 시 Auth 유저 삭제 (rollback)
```dart
try {
  await _firestore.collection('users').doc(user.uid).set({...});
  await user.sendEmailVerification();
} catch (e) {
  await user.delete();  // rollback
  rethrow;
}
```

### 3-4. (선택) 추가로 손볼 곳
- `group_repository.dart:34-42` `deleteGroup`도 batch/transaction으로 묶기 — 지금은 모임 삭제 후 join_requests 삭제 중간에 끊어지면 orphan 요청 남음
- `group_create_screen.dart:67` ScaffoldMessenger를 `mounted` 체크 없이 호출 — 현재 동기 코드라 안전하지만 방어적으로 추가

### 3-5. 검증
- `flutter analyze` 0 errors
- 모임 생성 → 다른 계정으로 참여 신청 → 모임장 화면에 신청자 닉네임 정상 표시
- 회원가입 중 네트워크 끊으면 Auth 계정도 안 남음 (수동 테스트)

---

## Stage 4. 실기기 / 에뮬레이터 풀 플로우 테스트

### 시나리오
1. **회원가입** — `test@smail.kongju.ac.kr` / 비번 / 닉네임 → 인증 메일 수신
2. **이메일 인증** — 메일 링크 클릭 → 앱에서 "인증 완료 확인" → `/map` 진입
3. **위치 게이트** — 캠퍼스 좌표(36.85, 127.1515)일 때 지도 진입, 멀리 떨어진 좌표(서울 등)면 차단 화면
4. **모임 생성** — `+모임 만들기` → 폼 채우기 → 지도에서 위치 선택 → 생성
5. **참여 신청** — 다른 계정으로 로그인 → 핀 클릭 → 바텀시트 → 자세히 보기 → 참여 신청
6. **수락/거절** — 모임장 계정에서 신청 카드의 ✓ 클릭 → 멤버에 추가됨
7. **로그아웃** — 마이페이지에서 로그아웃 → `/login`으로 리다이렉트

### 잡힐 만한 이슈
- 위치 권한 첫 요청 시 OS 다이얼로그 동작
- Firestore 인덱스 미생성 시 콘솔 에러 → 링크 클릭으로 해결
- 네이버맵 Client ID 오타 시 회색 빈 지도 → SDK 초기화 로그 확인

---

## Stage 5. 첫 커밋

### 5-1. 정리
```bash
flutter clean
flutter pub get
flutter analyze
```

### 5-2. .gitignore 최종 확인
- `firebase_options.dart` 는 커밋 (실제 API 키 포함되어도 SHA-1 + Rules로 보호)
- `google-services.json` 는 위 1-4 결정에 따름
- `.dart_tool/`, `build/` 들어가있는지 확인 (이미 OK)

### 5-3. iOS 폴더 추가 + 코드 변경 커밋
브랜치는 main으로, 변경사항을 의미 단위로 분리:
- 커밋 1: `Feat: iOS 플랫폼 추가 및 위치 권한 설정`
- 커밋 2: `Feat: Firebase 실제 프로젝트 연동 (flutterfire configure)`
- 커밋 3: `Feat: 네이버맵 Client ID 적용`
- 커밋 4: `Fix: 코드 이슈 3종 수정 (ref.listen 위치, 닉네임 fallback, signup 트랜잭션)`
- 커밋 5: `Chore: Firestore Rules 추가` (Rules 파일을 `firestore.rules`로 저장하면 같이 커밋)

또는 한 번에 묶고 싶으면:
- `Feat: Firebase/네이버맵 실제 연동 및 코드 이슈 수정`

### 5-4. 검증
- `git log --oneline -5` 로 새 커밋 확인
- `git status` clean

---

## Risks & Mitigations

| 리스크 | 영향 | 대응 |
|---|---|---|
| NCP 결제수단 등록 거부감 | 중단 | 무료 한도 안에선 0원, 한도 초과 알림 설정 |
| Firebase 무료 한도 초과 | 동작 중단 | 일일 50K read 모니터링, `groupRepository`의 stream 최적화 (필요시 페이지네이션) |
| 네이버맵 Client ID 발급 지연 | 1-2일 | 그동안 `main_preview.dart` 로 UI 작업 진행 |
| Firestore Rules 너무 빡빡 | 정상 기능 차단 | 시뮬레이터로 각 시나리오 검증, 콘솔 로그로 실패 원인 추적 |
| 인덱스 미생성 | 첫 쿼리 실패 | 에러 메시지의 링크 클릭으로 자동 생성 |
| Auth 이메일 메일이 스팸함으로 | UX | Firebase Auth 설정에서 발신자 도메인 커스터마이징(선택) |

---

## 진행 순서 요약

```
Stage 0 (수동)        — 30분~1시간 (계정 가입 등)
  ↓
Stage 1 (자동 + 수동) — 30분
  ↓
Stage 2 (코드)        — 10분
  ↓
Stage 3 (코드)        — 30분
  ↓
Stage 4 (테스트)      — 30분~1시간
  ↓
Stage 5 (커밋)        — 10분
```

**총 예상 시간**: 2-4시간 (Stage 0의 NCP 가입 심사 시간 변수)

---

## 다음에 할 것 (이 플랜 범위 밖)
- 푸시 알림 (FCM 도입, 무료 플랜 한계 우회 방법 검토)
- 모임 검색/필터 UI
- 모임 만료 자동 처리 (클라이언트 사이드)
- iOS 빌드 (Mac에서)
- Google Play 출시 준비
