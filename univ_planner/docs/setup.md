# Univ Planner 환경설정 가이드

5분 안에 개발 환경을 설정하고 앱을 실행하는 방법입니다.

## 1. Flutter 설치

Flutter 3.x 이상이 필요합니다.

```bash
flutter --version  # 설치 확인
```

설치되어 있지 않다면: https://docs.flutter.dev/get-started/install

## 2. 저장소 클론 또는 프로젝트 폴더 이동

```bash
cd univ_planner
```

## 3. 의존성 설치

```bash
flutter pub get
```

## 4. Hive 어댑터 코드 생성

**이 단계를 반드시 실행해야 합니다.** 생략하면 빌드가 실패합니다.

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 5. 앱 실행

```bash
flutter run
```

에뮬레이터가 없다면 Android Studio에서 에뮬레이터를 먼저 실행하거나, 실기기를 USB로 연결하세요.

## 6. 테스트 실행

```bash
flutter test           # 전체 테스트
flutter test test/domain/  # 도메인 단위 테스트만
```

## 7. 코드 분석

```bash
flutter analyze  # 경고 없이 통과해야 합니다
```

## 자주 발생하는 문제

| 문제 | 해결 방법 |
|------|-----------|
| `*.g.dart not found` | `dart run build_runner build` 실행 |
| `HiveError: box not open` | `main.dart`에서 어댑터 등록 확인 |
| `intl` 관련 오류 | `flutter pub get` 다시 실행 |
