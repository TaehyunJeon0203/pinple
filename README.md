# Pinple

공주대학교 천안캠퍼스 학생 전용 소모임 앱. 지도 위에서 주변 소모임을 찾고, 직접 모임을 만들고, 참여를 신청할 수 있습니다.

## 주요 기능

- **위치 인증**: 천안캠퍼스 반경 2km 이내에서만 앱 사용 가능
- **이메일 인증**: `@smail.kongju.ac.kr` 도메인 이메일로만 가입 가능
- **지도 기반 소모임 탐색**: 네이버 지도 위에 소모임 핀 표시, 리스트 뷰(거리순 정렬) 전환
- **소모임 CRUD**: 지도에서 위치를 핀으로 지정해 소모임 생성/수정/삭제
- **참여 신청**: 소모임 참여 신청 및 수락/거절

## 기술 스택

| 영역 | 기술 |
|---|---|
| 프레임워크 | Flutter |
| 상태 관리 | Riverpod |
| 라우팅 | go_router |
| 지도 | flutter_naver_map |
| 위치 | geolocator, permission_handler |
| 백엔드 | Firebase (Auth, Firestore) — Spark(무료) 플랜 |
| 폰트 | google_fonts (Noto Sans KR) |

## 프로젝트 구조

```
lib/
├── app.dart                     # 앱 진입점(라우터/테마 설정)
├── main.dart
├── firebase_options.dart
├── core/
│   ├── constants/                # 앱/캠퍼스 상수
│   ├── theme/                    # 디자인 시스템 (토스 스타일)
│   ├── utils/                    # 거리 계산, 유효성 검사 등
│   └── widgets/                  # 공용 위젯
└── features/
    ├── auth/                     # 로그인/회원가입/이메일 인증
    ├── location_gate/            # 캠퍼스 반경 위치 게이트
    ├── map/                      # 지도, 소모임 CRUD, 참여 신청
    ├── profile/                  # 마이페이지
    └── shell/                    # 드로어, 위치 게이트 셸(ShellRoute)
```

Feature-first 구조로, 각 feature는 `data`(리포지토리) / `domain`(모델) / `presentation`(화면) / `providers`(Riverpod)로 구성됩니다.

## 시작하기

```bash
flutter pub get
flutter run
```

Firebase(Android `google-services.json`)와 네이버 지도 Client ID 설정이 필요합니다. 관련 값은 `.gitignore`에 포함되어 있어 각자 재발급/재생성해야 합니다.

## 개발 환경

- Flutter SDK `^3.11.4`
- Firebase 프로젝트: 별도 등록 필요 (Auth, Firestore 사용, Spark 플랜 기준)
- 네이버 클라우드 플랫폼(NCP) Maps Application 등록 필요
