# Univ Planner

대학생을 위한 학사 통합 관리 앱 — 시간표, 학사일정, 출결, 학점, 과제를 한 곳에서.

## 기능 목록

| 기능 | 설명 |
|------|------|
| 홈 | 오늘 수업, 마감 임박 과제(D-Day), 이번 주 학사일정 한눈에 확인 |
| 시간표 | 요일별 과목 관리, 색상 구분, 강의실·교수명·학점 기록 |
| 학사일정 | 월별 캘린더 + 카테고리별(학사/시험/휴일/기타) 일정 관리 |
| 출결 관리 | 과목별 출석·지각·결석 기록, 지각 3회=결석 1회 자동 환산, 경고 알림 |
| 학점 | GPA 자동 계산(가중 평균), 학기별 필터, 등급 색상 구분 |
| 과제 | 우선순위(낮음/보통/높음), D-Day 배지, 완료/미완료 분류 |

## 기술 스택

| 영역 | 기술 |
|------|------|
| 프레임워크 | Flutter 3.x (Android / iOS) |
| 상태 관리 | flutter_riverpod ^2.5.1 |
| 로컬 저장소 | Hive ^2.2.3 + hive_flutter ^1.1.0 |
| 코드 생성 | hive_generator ^2.0.1 + build_runner ^2.4.9 |
| 날짜 처리 | intl ^0.19.0 |
| 캘린더 UI | table_calendar ^3.1.1 |
| 폰트 | google_fonts ^6.2.1 (Noto Sans KR) |
| 디자인 | Material Design 3 |

## 실행 방법

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

자세한 설정은 [docs/setup.md](docs/setup.md)를 참고하세요.

## 디렉토리 구조

```
lib/
├── main.dart                        # 앱 진입점, Hive 초기화
├── core/
│   ├── constants/app_colors.dart    # 색상 상수
│   ├── theme/app_theme.dart         # 테마 (라이트/다크)
│   └── widgets/                     # 공통 위젯 (AppCard, EmptyState, SectionHeader)
├── domain/
│   ├── entities/                    # Hive Entity 5개 (Course, Task, 등)
│   └── usecases/                    # 비즈니스 로직 3개 (GPA, 출결, 임박과제)
├── data/
│   └── repositories/               # Hive Repository 5개
├── application/
│   └── *_viewmodel.dart             # StateNotifier ViewModel 5개
└── presentation/
    ├── home/                        # 홈 화면
    ├── timetable/                   # 시간표 화면
    ├── calendar/                    # 학사일정 화면
    ├── attendance/                  # 출결 관리 화면
    ├── grade/                       # 학점 관리 화면
    └── task/                        # 과제 관리 화면
```

## Won't 목록

- 서버 동기화 / 클라우드 백업 (로컬 전용)
- 알림 / 푸시 (OS 레벨 퍼미션 불필요 유지)
- 소셜 기능 (개인 학사 관리 앱)
- 웹 플랫폼 지원
