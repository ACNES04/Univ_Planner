# CLAUDE.md — 이 파일은 Claude Code가 항상 읽는 규칙 파일입니다.

## 프로젝트 개요
- 앱명: Univ Planner
- 목적: 시간표·학사일정·결석·학점·과제를 하나로 관리하는 대학생 전용 앱
- 플랫폼: Flutter (Android + iOS)

## 아키텍처 규칙 (반드시 준수)
- 4계층 Layered Architecture + MVVM 패턴
- 계층: presentation → application → domain → data
- 의존성은 항상 아래 방향만 허용 (presentation이 data를 직접 참조 금지)
- 새 화면: lib/presentation/[기능명]/[기능명]_screen.dart
- 새 ViewModel: lib/application/[기능명]_viewmodel.dart
- 새 Entity: lib/domain/entities/[이름].dart
- 새 UseCase: lib/domain/usecases/[동작명].dart
- 새 Repository 구현: lib/data/repositories/hive_[이름]_repository.dart

## 기술 스택 (변경 금지)
- 상태관리: flutter_riverpod ^2.5.1
- 로컬 저장소: hive ^2.2.3 + hive_flutter ^1.1.0
- 코드 생성: hive_generator ^2.0.1 + build_runner ^2.4.9
- 날짜 처리: intl ^0.19.0
- 캘린더 UI: table_calendar ^3.1.1
- 폰트: google_fonts ^6.2.1

## 디자인 규칙
- Material Design 3 사용 (useMaterial3: true)
- 색상: ColorScheme.fromSeed(seedColor: Color(0xFF4F46E5)) — 인디고
- 폰트: GoogleFonts.notoSansKr() 를 기본 폰트로 설정
- 모든 화면에 일관된 padding: EdgeInsets.all(16) 또는 EdgeInsets.symmetric(horizontal: 20, vertical: 16)
- 카드: elevation 0, border 사용 (BoxDecoration with border)
- 버튼: FilledButton (primary action), OutlinedButton (secondary)
- 아이콘: Icons (Material Icons만 사용, 이모지 사용 금지)

## 코드 규칙
- 모든 코드에 한국어 주석 작성
- 파일 상단에 // [레이어명] - [역할 한 줄 설명] 주석 작성
- const 생성자 사용 가능한 모든 곳에 사용
- Hive Adapter는 build_runner로 자동 생성 (수동 작성 금지)
- 각 Entity 파일에 @HiveType, @HiveField 어노테이션 필수
