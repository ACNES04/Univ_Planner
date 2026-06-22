# Univ Planner

> 흩어진 학사 정보를 손바닥 위에서 하나로 — 대학생 전용 올인원 학사 관리 앱

[![Flutter](https://img.shields.io/badge/Flutter-3.19+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.3+-0175C2?logo=dart)](https://dart.dev)

---

## 비전

대학생은 매 학기 시간표·학사일정·결석 현황·학점 계산·과제 마감을 서로 다른 도구에서 관리합니다.  
**Univ Planner**는 이 모든 정보를 **하나의 앱**에서 오프라인으로 관리할 수 있도록 합니다.

---

## 주요 기능

| 기능 | 설명 |
|---|---|
| 시간표 | 요일·시간·색상 지정, 과목 등록/조회/삭제 |
| 학사일정 | 달력 기반 일정 등록 (학사/시험/휴일/기타) |
| 결석 계산기 | 총 수업 x 25% 한도 자동 계산, 지각 3회 = 결석 1회 환산 |
| 학점 계산기 | 등급별 환산 x 학점 가중 평균 GPA 자동 계산 |
| 과제 메모 | D-Day 표시, 완료 체크, 마감 임박 과제 홈 화면 강조 |
| 홈 요약 | 오늘 수업 + 임박 과제 + 이번 주 일정 한눈에 |

---

## 기술 스택

| 항목 | 선택 | 근거 |
|---|---|---|
| 플랫폼 | Flutter (Dart) | iOS/Android 동시 지원, 1인 개발 최적 ([ADR-0001](docs/ADR-0001-platform-selection.md)) |
| 아키텍처 | Layered Architecture + MVVM | 관심사 분리, 테스트 용이 |
| 상태관리 | Riverpod 2.x | 컴파일 타임 안전성, Provider 의존성 주입 ([ADR-0002](docs/ADR-0002-state-management.md)) |
| 로컬 저장 | Hive | 서버 없이 오프라인 동작, 빠른 NoSQL 읽기 ([ADR-0003](docs/ADR-0003-local-storage.md)) |
| 캘린더 UI | table_calendar | Flutter 생태계 표준 달력 위젯 |

---

## 아키텍처

```
Presentation  ->  Application  ->  Domain  ->  Data
   (화면)          (ViewModel)      (규칙)      (저장)
```

각 레이어는 아래 방향으로만 의존합니다. 자세한 내용은 [docs/architecture.md](docs/architecture.md)를 참고하세요.

---

## 빠른 시작 (Quick Start)

### 사전 요구 사항

- Flutter SDK 3.19+
- Android Studio (에뮬레이터) 또는 실기기

### 설치 및 실행

```bash
# 1. 저장소 클론
git clone https://github.com/[username]/univ_planner.git
cd univ_planner

# 2. 의존성 설치
flutter pub get

# 3. 앱 실행
flutter run
```

> 이 프로젝트는 **서버 및 API 키가 불필요**합니다. Hive 로컬 저장소만 사용합니다.

전체 환경 설정 가이드는 [docs/setup.md](docs/setup.md)를 참고하세요.

---

## 빌드 및 배포

```bash
# Android APK (디버그)
flutter build apk --debug
# 결과: build/app/outputs/flutter-apk/app-debug.apk

# Android APK (릴리즈)
flutter build apk --release

# iOS (macOS 필요)
flutter build ios --release
```

### GitHub Pages 배포 (발표/문서 사이트)

이 저장소는 `docs/` 폴더를 GitHub Pages로 자동 배포하도록 설정되어 있습니다.

1. GitHub 저장소 설정에서 **Settings -> Pages -> Build and deployment**로 이동
2. **Source**를 **GitHub Actions**로 선택
3. `main` 브랜치에 푸시하면 `.github/workflows/deploy-pages.yml`이 자동 실행

배포 주소:

```text
https://acnes04.github.io/Univ_Planner/
```

---

## 테스트

```bash
# 전체 테스트 실행
flutter test

# 도메인 단위 테스트만 실행
flutter test test/domain/

# 특정 테스트 파일
flutter test test/domain/calculate_gpa_test.dart
flutter test test/domain/calculate_attendance_test.dart
flutter test test/domain/get_upcoming_tasks_test.dart
```

### 테스트 커버리지

| 테스트 파일 | 케이스 수 | 대상 |
|---|---|---|
| `calculate_gpa_test.dart` | 6개 | GPA 가중 평균 계산 (엣지케이스 포함) |
| `calculate_attendance_test.dart` | 6개 | 결석 한도, 지각 환산, 경고 레벨 |
| `get_upcoming_tasks_test.dart` | 3개 | 마감 임박 과제 조회 |
| `widget_test.dart` | 2개 | 통합: 앱 테마/렌더링 스모크 테스트 |

---

## 프로젝트 구조

```
lib/
├── main.dart
├── presentation/    # 화면 (Flutter Widget)
├── application/     # ViewModel (Riverpod Provider)
├── domain/          # 비즈니스 규칙 (순수 Dart)
│   ├── entities/    # 데이터 구조
│   ├── usecases/    # 비즈니스 로직
│   └── repositories/# 인터페이스 (추상 클래스)
└── data/            # 저장소 구현 (Hive)
```

---

## 문서

| 문서 | 설명 |
|---|---|
| [docs/00-vision.md](docs/00-vision.md) | 비전 & 문제 정의 |
| [docs/01-requirements.md](docs/01-requirements.md) | MoSCoW 요구사항 |
| [docs/02-wbs.md](docs/02-wbs.md) | WBS (Work Breakdown Structure) |
| [docs/04-schedule.md](docs/04-schedule.md) | 6주 개발 일정 |
| [docs/architecture.md](docs/architecture.md) | 아키텍처 설계 & Mermaid 다이어그램 |
| [docs/setup.md](docs/setup.md) | 환경 설정 & 빌드 & 테스트 가이드 |
| [docs/ADR-0001-platform-selection.md](docs/ADR-0001-platform-selection.md) | Flutter 선택 근거 |
| [docs/ADR-0002-state-management.md](docs/ADR-0002-state-management.md) | Riverpod 선택 근거 |
| [docs/ADR-0003-local-storage.md](docs/ADR-0003-local-storage.md) | Hive 선택 근거 |
| [AGENTS.md](AGENTS.md) | AI Agent 워크플로우 & 규칙 통합 문서 |

---

## AI 활용 방식

이 프로젝트는 **Claude Code**를 활용한 AI 협업 개발로 진행되었습니다.

- `CLAUDE.md`: Claude Code 전용 아키텍처 규칙 파일 (자동 로드)
- `AGENTS.md`: Agent/Skills/Rules/Commands 통합 워크플로우 문서
- **Plan -> Build -> Verify** 3단계 분리 프롬프트 전략 적용
- 비즈니스 규칙 선 명세 후 구현 방식으로 AI 오해 방지

자세한 AI 활용 기법은 [AGENTS.md](AGENTS.md)를 참고하세요.

---

## 라이선스

MIT License
