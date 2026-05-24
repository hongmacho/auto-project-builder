---
name: auto-project-builder
description: 인터랙티브 설정(플랫폼·기술스택·서비스 유형·개수)을 거쳐 자율적으로 서비스 아이디어를 기획하고 프로젝트를 완성까지 구현하는 완전 자동화 스킬. 완료 후 날짜별 리포트와 overview.html을 자동 생성.
triggers:
  - auto-project-builder
  - 자율 프로젝트
  - 아이디어 자동 구현
  - autonomous build
  - 서비스 자동 생성
---

## Phase -1: 인터랙티브 설정

스킬 시작 시 아래 4가지를 순서대로 사용자에게 묻는다.
모든 질문은 **AskUserQuestion 도구**로 제시한다.

---

### 질문 1 — 플랫폼

```
어떤 플랫폼의 프로젝트를 만들고 싶으신가요?

1. 웹 (Web)          — 브라우저에서 동작하는 웹 앱
2. 앱 (Mobile App)   — iOS / Android 모바일 앱
3. CLI               — 터미널에서 동작하는 커맨드라인 도구
4. 자유롭게          — 직접 설명해 주세요
```

→ 선택 결과를 `PLATFORM`에 저장.

---

### 질문 2 — 기술 스택 (PLATFORM에 따라 옵션 자동 생성)

**PLATFORM = 웹:**
```
어떤 기술 스택을 사용할까요?

1. Next.js 14+ · shadcn/ui · Drizzle + SQLite   (추천)
2. Nuxt 3 · Tailwind CSS · PGlite
3. SvelteKit · shadcn-svelte · Drizzle + SQLite
4. Remix · shadcn/ui · Drizzle + SQLite
5. 자유롭게 — 직접 입력해 주세요
```

**PLATFORM = 앱:**
```
어떤 기술 스택을 사용할까요?

1. React Native + Expo · SQLite (expo-sqlite)   (추천)
2. Flutter · Dart · sqflite
3. Swift · SwiftUI (iOS 전용)
4. Kotlin · Jetpack Compose (Android 전용)
5. 자유롭게 — 직접 입력해 주세요
```

**PLATFORM = CLI:**
```
어떤 기술 스택을 사용할까요?

1. Node.js · TypeScript · Commander.js · SQLite  (추천)
2. Python · Typer · Click · SQLite
3. Go · Cobra · SQLite
4. Rust · Clap · SQLite
5. 자유롭게 — 직접 입력해 주세요
```

**PLATFORM = 자유롭게:**
```
사용하고 싶은 기술 스택을 자유롭게 설명해 주세요.
(예: "Electron + React + SQLite", "FastAPI + HTMX + PostgreSQL" 등)
```

→ 선택/입력 결과를 `TECH_STACK`에 저장.

---

### 질문 3 — 서비스 유형

```
어떤 유형의 서비스를 만들고 싶으신가요?
(복수 선택 가능)

1.  생산성        — 할 일 관리, 시간 추적, 노트, 자동화
2.  콘텐츠        — 블로그, 미디어, 뉴스레터, 크리에이터 도구
3.  팀·협업       — 팀 관리, 소통, 프로젝트 추적
4.  커머스        — 쇼핑, 마켓플레이스, 구독
5.  교육          — 학습, 퀴즈, 튜터링, 플래시카드
6.  헬스·라이프   — 건강 추적, 피트니스, 웰빙, 식단
7.  파이낸스      — 예산 관리, 투자, 가계부
8.  개발자 도구   — 유틸리티, API 도구, 코드 분석
9.  커뮤니티      — 소셜, 포럼, 네트워킹
10. 자유롭게      — 직접 설명해 주세요
```

→ 선택 결과(복수 가능)를 `SERVICE_CATEGORIES[]`에 저장.

---

### 질문 4 — 프로젝트 개수

```
총 몇 개의 서비스를 만들까요? (기본값: 5, 최대: 10)
```

→ 입력값을 `PROJECT_COUNT`에 저장. 빈 입력이면 5.

---

### 설정 요약 출력

```
━━━ 설정 요약 ━━━
플랫폼:      {PLATFORM}
기술 스택:   {TECH_STACK}
서비스 유형: {SERVICE_CATEGORIES}
프로젝트 수: {PROJECT_COUNT}개
━━━━━━━━━━━━━━━━━
진행할까요? (yes / 취소)
```

사용자가 yes가 아닌 경우 Phase -1 처음으로 돌아간다.

---

## Phase 0: 환경 조사 (Context7 활용)

`TECH_STACK`에 포함된 라이브러리/프레임워크의 최신 버전과 권장 사용 패턴을 Context7로 조사한다.

```
# 공통
mcp__context7__resolve-library-id("drizzle-orm")

# 웹 — Next.js 선택 시
mcp__context7__resolve-library-id("next.js")
mcp__context7__resolve-library-id("shadcn/ui")
mcp__context7__resolve-library-id("better-sqlite3")
mcp__context7__resolve-library-id("next-auth")

# 앱 — React Native 선택 시
mcp__context7__resolve-library-id("react-native")
mcp__context7__resolve-library-id("expo")

# CLI — Node.js 선택 시
mcp__context7__resolve-library-id("commander")
mcp__context7__resolve-library-id("inquirer")

# ... 선택 스택에 맞게 동적으로 조사
```

조사 결과를 `STACK_VERSIONS`에 저장 후 Phase 1로 진행.

---

## 변수 추적 (Variable Flow)

| 변수명 | 초기화 위치 | 타입/범위 |
|--------|------------|-----------|
| `PLATFORM` | Phase -1 Q1 | string: 웹/앱/CLI/자유 |
| `TECH_STACK` | Phase -1 Q2 | string: 선택 스택 명칭 |
| `SERVICE_CATEGORIES[]` | Phase -1 Q3 | string[] |
| `PROJECT_COUNT` | Phase -1 Q4 | 정수 1–10, 기본 5 |
| `STACK_VERSIONS` | Phase 0 | 라이브러리 버전 맵 |
| `IDEA_KEYWORDS` | Phase -1 파생 | SERVICE_CATEGORIES에서 추출 |
| `IDEAS[]` | Phase 1 | PROJECT_COUNT개 객체 배열 |
| `GITHUB_REPOS[]` | Phase 1.5 | {name, description, url}[] |
| `REJECTED_IDEAS[]` | Phase 1.5 | 탈락 아이디어 + 사유 |
| `APPROVED_IDEAS[]` | Phase 1.5 | 최종 승인 아이디어 |
| `REPLACEMENT_ATTEMPTS` | Phase 1.5 | 정수, 최대 PROJECT_COUNT×3 |
| `PROJECT_LOG[]` | Phase 2 | 완료 프로젝트 로그 |
| `RUN_DATE` | Phase 3 시작 | YYYYMMDD 형식 |

---

## Phase 1: 아이디어 생성

`PROJECT_COUNT`개의 서비스 아이디어를 `SERVICE_CATEGORIES`와 `PLATFORM`을 반영하여 자율 생성.

**분배 알고리즘**:

```
CATEGORY_COUNT = len(SERVICE_CATEGORIES)

if CATEGORY_COUNT == 0 or "자유롭게" in SERVICE_CATEGORIES:
  IDEAS = generate(PROJECT_COUNT, domain="diverse", platform=PLATFORM)
else:
  IDEAS_PER_CATEGORY = floor(PROJECT_COUNT / CATEGORY_COUNT)
  REMAINING = PROJECT_COUNT % CATEGORY_COUNT
  IDEAS = []
  for category in SERVICE_CATEGORIES:
    IDEAS += generate(IDEAS_PER_CATEGORY, domain=category, platform=PLATFORM)
  IDEAS += generate(REMAINING, domain=SERVICE_CATEGORIES[0]+"_derivative", platform=PLATFORM)
```

각 아이디어에 대해 정의:
- 서비스명 (영문 slug + 한국어 이름)
- 타겟 사용자
- 핵심 기능 3가지
- 차별점
- 선택 이유 (카테고리·플랫폼 연관성 포함)

---

## Phase 1.5: GitHub 중복 검토

```bash
gh repo list --limit 200 --json name,description,url
```

유사도 판정 후 탈락/승인 분류. 대체 아이디어 생성 루프 실행 (최대 PROJECT_COUNT×3회).

결과 출력:
```
━━━ GitHub 중복 검토 결과 ━━━
총 검토: {N}개 | 승인: {A}개 ✅ | 탈락: {R}개 ❌ | 대체 시도: {T}회
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Phase 2: 각 프로젝트 실행 루프

`APPROVED_IDEAS[]`를 순회하며 각 프로젝트를 `TECH_STACK` 기준으로 구현.

### 2-1. PRD 작성 (`projects/{slug}/docs/PRD.md`)

포함 내용:
- 서비스 개요 및 목적
- 타겟 사용자 페르소나
- 핵심 기능 (MoSCoW 우선순위)
- 선택된 기술 스택 명세 (`TECH_STACK` 기반)
- 데이터 모델 초안
- 비기능 요구사항

### 2-2. ROADMAP 작성 (`projects/{slug}/docs/ROADMAP.md`)

`TECH_STACK`에 맞는 Sprint 계획:

**웹 (Next.js):**
- Sprint 0: 프로젝트 셋업 (Next.js 초기화, 의존성 설치)
- Sprint 1: DB 스키마 (Drizzle + SQLite)
- Sprint 2: 핵심 기능 구현
- Sprint 3: UI/UX (shadcn/ui)
- Sprint 4: 인증 (NextAuth — 필요 시)
- Sprint 5: 테스트 + 마무리
- Sprint 6: GitHub push

**앱 (React Native/Expo):**
- Sprint 0: Expo 초기화, 의존성
- Sprint 1: 네비게이션 구조 + SQLite 스키마
- Sprint 2: 핵심 기능 구현
- Sprint 3: UI 컴포넌트
- Sprint 4: 테스트 + 마무리
- Sprint 5: GitHub push

**CLI (Node.js):**
- Sprint 0: 프로젝트 셋업, Commander.js
- Sprint 1: SQLite 스키마 + DB 초기화
- Sprint 2: 핵심 커맨드 구현
- Sprint 3: 출력 포맷·UX
- Sprint 4: 테스트 + 마무리
- Sprint 5: GitHub push + npm publish 준비

**자유 스택:** 위를 참고해 적합한 Sprint 계획 자율 수립.

### 2-3. 구현

Sprint 완료 체크리스트:
```
[ ] 컴파일/타입 오류 없음
[ ] 린트 오류 없음
[ ] 핵심 기능 동작 확인
[ ] 테스트 존재 (80%+ 커버리지 목표)
```

**구현 원칙**:
- Immutable 패턴
- Repository 패턴 (DB 접근 추상화)
- 명시적 에러 처리
- 컴포넌트/함수 200줄 이하

### 2-4. GitHub 저장소 생성 및 Push

```bash
gh repo create {slug} --public --description "{서비스 설명}"
git init && git add . && git commit -m "feat: initial implementation of {서비스명}"
git remote add origin https://github.com/{owner}/{slug}.git
git push -u origin main
```

### 2-5. 진행 로그 기록 (`report_data/{slug}_log.json`)

```json
{
  "project": "slug",
  "platform": "PLATFORM",
  "tech_stack": "TECH_STACK",
  "category": "SERVICE_CATEGORY",
  "idea_rationale": "선택 이유",
  "tech_decisions": ["결정사항과 이유"],
  "challenges": ["겪은 문제들"],
  "solutions": ["해결 방법"],
  "github_url": "https://github.com/...",
  "completed_at": "ISO 날짜"
}
```

---

## Phase 3: 보고서 생성

모든 프로젝트 완료 후 두 파일을 생성/업데이트.

### 3-1. 날짜별 리포트: `{RUN_DATE}_report.html`

`RUN_DATE` = 실행 시작 날짜 (YYYYMMDD, 예: `20260524_report.html`)

**보고서 구성** (한국어):

#### 섹션 1: 실행 요약 대시보드
- 실행 날짜, 플랫폼, 기술 스택, 서비스 유형, 총 프로젝트 수
- 완료/스킵 현황, Context7 조사 결과 요약

#### 섹션 2: 아이디어 선정 배경
- 후보·탈락 아이디어 목록 (탈락 사유 포함)
- GitHub 중복 검토 결과 (일치 레포 URL, 대체 생성 과정)
- 최종 선정 기준 점수 (실용성·구현가능성·다양성·기술활용도)

#### 섹션 3: 프로젝트별 상세 보고 (PROJECT_COUNT개)

각 프로젝트 카드:
```
┌─ 프로젝트 N: {서비스명}  [{PLATFORM} / {TECH_STACK}]
│  ├─ 아이디어 의사결정 배경
│  ├─ 기술적 결정사항 (스택 선택 근거 포함)
│  ├─ Sprint 진행 타임라인
│  ├─ 에이전트 팀 소통 내역
│  └─ 결과: GitHub URL, 빌드 상태, 구현 범위
└─
```

#### 섹션 4: 전체 회고
- 공통 기술 도전, 잘 된 점/아쉬운 점, 다음 실행 개선점

---

### 3-2. overview.html 갱신

`overview.html`이 없으면 새로 생성, 있으면 기존 내용에 이번 실행 결과를 **추가**.

**구조**:

```html
<!-- overview.html 레이아웃 -->
헤더: "Project Overview — 전체 프로젝트 현황"

[실행 이력 타임라인]
  ├─ 2026-05-24  |  웹 / Next.js  |  5개 프로젝트  →  {RUN_DATE}_report.html 링크
  ├─ 2026-05-25  |  CLI / Node.js |  3개 프로젝트  →  ...
  └─ ...

[전체 프로젝트 카탈로그]
  플랫폼별 / 유형별 필터 UI
  각 프로젝트 카드:
    - 서비스명, 플랫폼, 스택, 카테고리
    - GitHub URL 링크
    - 실행 날짜

[통계 대시보드]
  - 총 프로젝트 수, 플랫폼 분포 차트, 카테고리 분포 차트
  - 기술 스택 사용 빈도
```

**업데이트 알고리즘**:
1. `overview.html` 파일 읽기 (없으면 빈 템플릿 생성)
2. 현재 실행의 `PROJECT_LOG[]` 데이터를 JSON으로 직렬화
3. HTML 내 `<!-- DATA_INJECT -->` 마커 위치에 새 데이터 삽입
4. 통계 수치 재계산 후 업데이트
5. `{RUN_DATE}_report.html`로의 링크 타임라인에 추가

**스타일**: 현대적 HTML+CSS (Tailwind CDN), 다크/라이트 모드 지원, 카드형 레이아웃, 인쇄 가능.

---

## Agent 위임 전략

```
# PRD + 환경 설정 병렬
Task(executor/sonnet, "PRD 작성") || Task(executor/haiku, "프로젝트 초기화")

# 구현 후 리뷰
Task(executor/sonnet, "핵심 기능 구현") → Task(code-reviewer/sonnet, "코드 리뷰")

# 복잡한 아키텍처
Task(architect/opus, "DB 스키마 설계 검토")
```

---

## 검증 단계

각 프로젝트 완료 전:

```bash
# 웹 / CLI (TypeScript)
npx tsc --noEmit && npm run build && npm run lint

# 앱 (Expo)
npx expo-doctor && npx tsc --noEmit

# CLI (Python)
python -m pytest && python -m mypy .

# CLI (Go)
go build ./... && go vet ./... && go test ./...
```

---

## 폴백 전략

```
오류 발생
  ├─ 1차: 전문 에이전트 위임 (build-error-resolver / executor, 최대 5분)
  ├─ 2차: 스코프 축소 (Nice-to-have 제거, Must-have만 재구현)
  └─ 3차: SKIP 마킹 + report_data에 기록 후 다음으로 진행
```

Sprint당 최대 재시도 3회. GitHub push 실패 시 최대 3회 재시도 (지수 백오프 5s→10s→20s).

---

## 파일 구조

```
{작업 디렉토리}/
├── projects/
│   └── {slug}/
│       ├── docs/
│       │   ├── PRD.md
│       │   └── ROADMAP.md
│       └── ... (소스 코드)
├── report_data/
│   └── {slug}_log.json
├── {YYYYMMDD}_report.html   ← 이번 실행 보고서
└── overview.html            ← 전체 누적 현황
```

---

## 실행 예시

```
# 기본 실행 (인터랙티브 설정 시작)
/auto-project-builder

# 인터랙티브 대화 예시:
> 어떤 플랫폼? → 웹
> 기술 스택?   → Next.js 14+ · shadcn/ui · SQLite
> 서비스 유형? → 생산성, 교육
> 몇 개?       → 3

# 자연어로도 가능 (인터랙티브 질문 건너뛰고 파싱)
"CLI 프로젝트 2개 개발자 도구로 만들어줘"
"웹앱 5개 커머스 관련으로 자율 빌드"
```

## 주의사항

- SQLite DB 파일 `.gitignore` 추가 (`*.db`, `*.sqlite`)
- `.env.local` `.gitignore` 추가, `.env.example` 커밋
- `overview.html`은 누적 파일 — 삭제하지 않도록 주의
- `{RUN_DATE}_report.html`은 실행마다 새로 생성 (덮어쓰지 않음)
