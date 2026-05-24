---
name: auto-project-builder
description: 인터랙티브 설정(플랫폼·기술스택·서비스 유형·개수)을 거쳐 트렌드 조사·경쟁 분석·아이디어 평가를 자율 수행하고, 자동 QA 루프로 실제 동작하는 프로젝트를 완성까지 구현하는 완전 자동화 스킬. 체크포인트 재개, 완료 알림, 날짜별 리포트, overview.html 포함.
triggers:
  - auto-project-builder
  - 자율 프로젝트
  - 아이디어 자동 구현
  - autonomous build
  - 서비스 자동 생성
---

## 핵심 원칙

> **사람의 개입 없이 실제로 동작하는 프로젝트를 완성한다.**
> 빌드 오류, 타입 오류, 린트 오류가 남은 프로젝트는 "완성"이 아니다.
> 사람은 완성된 결과물만 받는다.

---

## Phase -0.5: OMC/ECC 환경 감지

이 단계는 **모든 Phase보다 먼저** 자동으로 실행된다. 사용자에게는 별도로 고지하지 않는다.

### 감지 로직

현재 세션에서 사용 가능한 스킬 목록을 확인한다:

```
if "oh-my-claudecode:" in available_skills:
  OMC_MODE = "omc"
elif "everything-claude-code:" in available_skills:
  OMC_MODE = "ecc"
else:
  OMC_MODE = "none"
```

`OMC_MODE` 값에 따라 이후 모든 Phase에서 **Agent 위임 전략**이 달라진다.
`OMC_MODE = "omc"` 일 때 가장 풍부한 스킬 조합을 활용한다.

---

## Phase -1: 체크포인트 확인 + 인터랙티브 설정

### 0단계 — 이전 실행 체크포인트 확인

스킬 시작 직후 체크포인트 파일을 탐색한다:

```bash
ls .auto-project-builder-checkpoint.json 2>/dev/null
```

파일이 존재하면 내용을 읽어 아래 정보를 추출한다:
- 실행 날짜, 플랫폼, 스택, 총 프로젝트 수
- 완료된 프로젝트 목록
- 남은 프로젝트 목록

그 후 AskUserQuestion 도구로 확인:

```
이전 실행에서 중단된 작업이 있습니다.

실행일: {날짜}  /  플랫폼: {PLATFORM}  /  스택: {TECH_STACK}
완료: {완료 목록}  /  남은 것: {미완료 목록}

이어서 진행할까요, 아니면 새로 시작할까요?

1. 이어서 진행  — 완료된 프로젝트는 건너뛰고 남은 것부터 시작
2. 새로 시작    — 이전 체크포인트 삭제 후 처음부터
```

- **이어서 진행** 선택: 저장된 변수를 복원하고 Phase 2 루프로 바로 진입
- **새로 시작** 선택: 체크포인트 삭제 후 아래 질문 1로 진행

체크포인트 파일이 없으면 질문 1로 바로 진행.

---

### 질문 1 — 플랫폼

```
어떤 플랫폼의 프로젝트를 만들고 싶으신가요?

1. 웹 (Web)          — 브라우저에서 동작하는 웹 앱
2. 앱 (Mobile App)   — iOS / Android 모바일 앱
3. CLI               — 터미널에서 동작하는 커맨드라인 도구
4. 알아서            — 트렌드·서비스 유형 기반으로 자율 선택
5. 자유롭게          — 직접 설명해 주세요
```

**"알아서" 선택 시**: Phase 0-B 트렌드 조사 결과와 SERVICE_CATEGORIES를 바탕으로
가장 적합한 플랫폼을 자율 결정하고 이유와 함께 고지한 뒤 진행한다.
예: `알아서 선택: 웹 — 생산성 SaaS는 브라우저 접근성이 전환율에 직결되므로`

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
5. 알아서 — 아이디어에 가장 적합한 스택 자율 선택
6. 자유롭게 — 직접 입력해 주세요
```

**PLATFORM = 앱:**
```
어떤 기술 스택을 사용할까요?

1. React Native + Expo · SQLite (expo-sqlite)
2. Flutter · Dart · sqflite
3. 알아서 — 아이디어에 가장 적합한 스택 자율 선택
4. 자유롭게 — 직접 입력해 주세요
```

**PLATFORM = CLI:**
```
어떤 기술 스택을 사용할까요?

1. Node.js · TypeScript · Commander.js · SQLite
2. Python · Typer · Click · SQLite
3. Go · Cobra · SQLite
4. Rust · Clap · SQLite
5. 알아서 — 아이디어에 가장 적합한 스택 자율 선택
6. 자유롭게 — 직접 입력해 주세요
```

**PLATFORM = 자유롭게:**
```
사용하고 싶은 기술 스택을 자유롭게 설명해 주세요.
(예: "Electron + React + SQLite", "FastAPI + HTMX + PostgreSQL" 등)
또는 "알아서"라고 입력하면 자율 선택합니다.
```

**"알아서" 선택 시**: 아이디어 생성(Phase 1) 이후 각 아이디어의 특성에 맞게
프로젝트별로 최적 스택을 독립적으로 결정하고 PRD 작성 전 이유와 함께 고지한다.
예: `알아서 선택: Flutter — 크로스플랫폼 네이티브 UI가 이 앱의 핵심 경험에 적합하므로`

→ 선택/입력 결과를 `TECH_STACK`에 저장. "알아서"이면 `TECH_STACK = "auto"`로 저장 후 Phase 2에서 아이디어별 결정.

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
10. 알아서        — 트렌드 조사 기반으로 유망 카테고리 자율 선택
11. 자유롭게      — 직접 설명해 주세요
```

**"알아서" 선택 시**: Phase 0-B 트렌드 조사 결과(`TREND_DATA.market_gaps`, `TREND_DATA.trending_categories`)를
기반으로 현재 가장 유망한 카테고리를 자율 선택하고 이유와 함께 고지한 뒤 진행한다.
예: `알아서 선택: 개발자 도구 — GitHub Trending에서 AI 코드 도구 수요가 급증 중이므로`

→ 선택 결과(복수 가능)를 `SERVICE_CATEGORIES[]`에 저장.

---

### 질문 4 — 프로젝트 개수

```
총 몇 개의 서비스를 만들까요? (기본값: 5, 최대: 10)

숫자 입력, 또는:
- 알아서 — 선택한 카테고리 수와 트렌드 밀도를 기반으로 자율 결정
```

**"알아서" 선택 시**: `SERVICE_CATEGORIES` 수와 `TREND_DATA.competitive_density`를 기반으로
적정 개수를 결정한다. 카테고리 1개당 2–3개, 최대 10개를 초과하지 않는다.
예: `알아서 선택: 6개 — 카테고리 2개 × 3개씩`

→ 입력값을 `PROJECT_COUNT`에 저장. 빈 입력이면 5. "알아서"이면 위 공식으로 계산.

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

## Phase 0: 환경 조사

Context7 조사와 트렌드 조사를 **병렬로** 실행한다.

### 0-A. Context7 스택 조사 (병렬 레인 1)

`TECH_STACK`에 포함된 라이브러리/프레임워크의 최신 버전과 권장 사용 패턴 조사.

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

조사 결과를 `STACK_VERSIONS`에 저장.

### 0-B. 트렌드 조사 (병렬 레인 2)

**OMC_MODE == "omc"** 일 때 — autoresearch 스킬로 심층 조사:

```
Skill("oh-my-claudecode:autoresearch",
  prompt="{SERVICE_CATEGORIES} 카테고리의 2025-2026 시장 트렌드 조사.
          포함: Product Hunt 인기 서비스, GitHub Trending 저장소,
          시장 갭(아직 해결 안 된 문제), 경쟁 밀도(high/medium/low).
          플랫폼: {PLATFORM}")
```

그 외 모드에서는 WebSearch 또는 Exa로 직접 조사:

```
# Product Hunt 최근 인기 서비스
WebSearch("site:producthunt.com {SERVICE_CATEGORIES} {PLATFORM} app 2025 2026")

# GitHub Trending 조사
WebSearch("github trending {TECH_STACK_KEYWORD} repositories 2025")

# 해당 카테고리 인기 앱/서비스 현황
WebSearch("{SERVICE_CATEGORIES} best apps 2025 market trends")
```

조사 결과를 `TREND_DATA`에 저장:
```json
{
  "trending_categories": ["현재 뜨는 세부 카테고리"],
  "popular_features": ["사용자들이 원하는 기능"],
  "market_gaps": ["아직 해결 안 된 문제"],
  "competitive_density": "high | medium | low"
}
```

두 레인 완료 후 Phase 1로 진행.

---

## 변수 추적 (Variable Flow)

| 변수명 | 초기화 위치 | 타입/범위 |
|--------|------------|-----------|
| `OMC_MODE` | Phase -0.5 | string: "omc" / "ecc" / "none" |
| `PLATFORM` | Phase -1 Q1 | string: 웹/앱/CLI/auto/자유 |
| `TECH_STACK` | Phase -1 Q2 | string: 선택 스택 명칭 또는 "auto" |
| `SERVICE_CATEGORIES[]` | Phase -1 Q3 | string[]; "auto" 이면 트렌드 기반 자율 결정 |
| `PROJECT_COUNT` | Phase -1 Q4 | 정수 1–10, 기본 5; "알아서" 이면 공식 계산 |
| `STACK_VERSIONS` | Phase 0-A | 라이브러리 버전 맵 |
| `TREND_DATA` | Phase 0-B | 트렌드 조사 결과 객체 |
| `IDEAS[]` | Phase 1 | PROJECT_COUNT개 객체 배열 |
| `IDEA_SCORES[]` | Phase 1.3 | {idea, market, originality, feasibility, total}[] |
| `GITHUB_REPOS[]` | Phase 1.5 | {name, description, url}[] |
| `REJECTED_IDEAS[]` | Phase 1.3 + 1.5 | 탈락 아이디어 + 사유 |
| `APPROVED_IDEAS[]` | Phase 1.5 | 최종 승인 아이디어 |
| `REPLACEMENT_ATTEMPTS` | Phase 1.3 + 1.5 | 정수, 최대 PROJECT_COUNT×3 |
| `PROJECT_LOG[]` | Phase 2 | 완료 프로젝트 로그 |
| `QA_ATTEMPTS` | Phase 2-4 | 프로젝트별 QA 재시도 횟수 |
| `RUN_DATE` | Phase 3 시작 | YYYYMMDD 형식 |
| `CHECKPOINT_FILE` | Phase -1 | `.auto-project-builder-checkpoint.json` |

---

## Phase 1: 아이디어 생성 (경쟁 분석 포함)

**OMC_MODE = "omc"** 일 때 — `team` 스킬로 planner · architect · autoresearch를 **병렬 실행**한다:
```
Skill("oh-my-claudecode:team", prompt="[ROLE: planner] 아이디어 기획 / [ROLE: architect] 기술 적합성 / [ROLE: autoresearch] 경쟁 분석")
```
→ 세 역할의 결과를 통합하여 IDEAS[] 확정. 자세한 프롬프트는 Agent 위임 전략 섹션 참조.

그 외 모드에서는 아래 알고리즘대로 직접 생성:

`PROJECT_COUNT`개의 서비스 아이디어를 `SERVICE_CATEGORIES`, `PLATFORM`, `TREND_DATA`를 반영하여 자율 생성.

**분배 알고리즘**:

```
CATEGORY_COUNT = len(SERVICE_CATEGORIES)

if CATEGORY_COUNT == 0 or "자유롭게" in SERVICE_CATEGORIES:
  IDEAS = generate(PROJECT_COUNT, domain="diverse", platform=PLATFORM, trend=TREND_DATA)
else:
  IDEAS_PER_CATEGORY = floor(PROJECT_COUNT / CATEGORY_COUNT)
  REMAINING = PROJECT_COUNT % CATEGORY_COUNT
  IDEAS = []
  for category in SERVICE_CATEGORIES:
    IDEAS += generate(IDEAS_PER_CATEGORY, domain=category, platform=PLATFORM, trend=TREND_DATA)
  IDEAS += generate(REMAINING, domain=SERVICE_CATEGORIES[0]+"_derivative", platform=PLATFORM)
```

각 아이디어에 대해 정의:
- 서비스명 (영문 slug + 한국어 이름)
- 타겟 사용자
- 핵심 기능 3가지
- **경쟁 서비스 분석** (Exa/WebSearch로 유사 서비스 검색 → 상위 3개 나열)
- **차별점** — 경쟁 서비스와 구체적으로 다른 점
- **트렌드 연관성** — `TREND_DATA.market_gaps`와의 연결 설명
- 선택 이유 (카테고리·플랫폼 연관성 포함)

경쟁 분석은 아이디어 생성과 **병렬**로 Exa를 사용:
```
WebSearch("{서비스명 키워드} app site:producthunt.com OR site:github.com")
→ 유사 서비스 발견 시 차별점 항목에 구체적으로 반영
→ 유사 서비스가 없으면 "경쟁 공백 영역" 으로 표기 (가산점)
```

---

## Phase 1.3: 아이디어 사전 평가

생성된 모든 아이디어를 빌드 전에 점수화하여 필터링한다.

### 평가 기준 (각 1–3점, 합계 9점 만점)

| 항목 | 1점 | 2점 | 3점 |
|------|-----|-----|-----|
| **시장성** | 경쟁 포화·차별점 없음 | 틈새 시장 있음 | 경쟁 공백·명확한 수요 |
| **독창성** | 명백한 클론 | 개선된 클론 | 새로운 접근 또는 조합 |
| **구현 가능성** | 현재 스택으로 불가 | 가능하나 복잡 | 선택 스택으로 적합 |

### 평가 결과 처리

```
합계 7점 이상  → APPROVED_IDEAS에 추가 (우선 빌드)
합계 5–6점     → APPROVED_IDEAS에 추가 (후순위)
합계 4점 이하  → REJECTED_IDEAS에 추가 (탈락) → 대체 아이디어 생성
```

프로젝트가 `PROJECT_COUNT`개 채워질 때까지 탈락 시 재생성 (최대 `PROJECT_COUNT×3`회).

평가 결과 출력:
```
━━━ 아이디어 평가 결과 ━━━
통과: {A}개 ✅  |  탈락: {R}개 ❌  |  대체 생성: {T}회
─────────────────────────
{서비스명}  시장성 {M}/3 · 독창성 {O}/3 · 구현 {F}/3  =  합계 {T}/9  ✅/❌
...
━━━━━━━━━━━━━━━━━━━━━━━━━
```

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

### ultrawork 자율 오케스트레이션 옵션 (OMC_MODE = "omc")

**Phase 2 전체를 `ultrawork`에게 위임**하면 사람 개입 없이 완전 자율 실행이 가능하다.
ultrawork는 내부적으로 PRD·ROADMAP·구현·QA·README·Push를 스스로 조율한다.

```
Skill("oh-my-claudecode:ultrawork",
  prompt="아래 조건으로 {PROJECT_COUNT}개 프로젝트를 처음부터 끝까지 완성하라.

  완료 기준:
  - tsc/lint/build 오류 없음
  - 80%+ 테스트 커버리지
  - README.md 생성
  - GitHub push 완료

  프로젝트 목록: {APPROVED_IDEAS}
  플랫폼: {PLATFORM}  스택: {TECH_STACK}
  작업 디렉토리: projects/

  각 프로젝트 완료 시 체크포인트 저장:
  .auto-project-builder-checkpoint.json

  단계 순서: PRD → ROADMAP → 구현 → QA 루프(최대 3회) → README → GitHub push
  QA 실패 3회 시 스코프 축소 후 재시도, 그래도 실패 시 SKIP 마킹 후 다음 진행.")
```

ultrawork를 사용하지 않는 경우(기본값)에는 아래 단계별 루프로 직접 진행.

---

루프 시작 시 체크포인트에서 이미 완료된 프로젝트는 건너뛴다:
```
if slug in CHECKPOINT.completed_projects: SKIP → 다음 아이디어
```

---

### 2-1. PRD 작성 (`projects/{slug}/docs/PRD.md`)

**OMC_MODE == "omc"** 일 때:
```
Agent(oh-my-claudecode:planner,
  prompt="다음 아이디어의 PRD를 작성하라: {IDEA}.
          플랫폼: {PLATFORM}, 스택: {TECH_STACK}.
          포함: 타겟 사용자 페르소나, MoSCoW 기능 목록,
          경쟁 서비스 분석 + 차별점, 데이터 모델 초안, 비기능 요구사항.
          출력 경로: projects/{slug}/docs/PRD.md")
```

그 외 모드에서는 직접 작성. 포함 내용:
- 서비스 개요 및 목적
- 타겟 사용자 페르소나
- 핵심 기능 (MoSCoW 우선순위)
- 경쟁 서비스 분석 및 차별점
- 선택된 기술 스택 명세 (`TECH_STACK` 기반)
- 데이터 모델 초안
- 비기능 요구사항

---

### 2-2. ROADMAP 작성 (`projects/{slug}/docs/ROADMAP.md`)

**OMC_MODE == "omc"** 일 때:
```
Agent(oh-my-claudecode:architect,
  prompt="PRD(projects/{slug}/docs/PRD.md) 기반 기술 아키텍처 설계.
          스택: {TECH_STACK}.
          포함: Sprint 계획, DB 스키마, 컴포넌트 구조도, 기술 결정 근거.
          출력 경로: projects/{slug}/docs/ROADMAP.md")
```

그 외 모드에서는 직접 작성. `TECH_STACK`에 맞는 Sprint 계획:

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

---

### 2-3. 구현

**OMC_MODE == "omc"** 일 때 — 아래 순서로 에이전트 위임:

```
# 1. UI 있는 플랫폼(웹/앱): designer가 먼저 UI 가이드 작성
if PLATFORM in ["웹", "앱"]:
  Agent(oh-my-claudecode:designer,
    prompt="PRD + ROADMAP 기반 UI/UX 설계.
            컴포넌트 목록, 색상 팔레트, 레이아웃 초안 제공.
            스택: {TECH_STACK}")

# 2. executor가 Sprint 순서대로 구현
Agent(oh-my-claudecode:executor,
  prompt="ROADMAP의 Sprint 순서대로 {slug} 구현.
          스택: {TECH_STACK}.
          immutable 패턴, Repository 패턴, 명시적 에러 처리 준수.
          완료 기준: 컴파일·린트·빌드 오류 없음, 80%+ 테스트 커버리지.")

# 3. 코드 리뷰 (구현 직후)
Agent(oh-my-claudecode:code-reviewer,
  prompt="projects/{slug}/ 코드 리뷰.
          CRITICAL/HIGH 이슈 발견 시 직접 수정. 수정 파일 목록 보고.")

# 4. 보안 검토 — 인증/외부 API/사용자 입력 처리가 있는 경우
if PRD includes "auth" OR "user input" OR "external API":
  Agent(oh-my-claudecode:security-reviewer,
    prompt="projects/{slug}/ OWASP Top 10 기준 보안 취약점 검토.
            CRITICAL 이슈 즉시 수정.")
```

**OMC_MODE != "omc"** 일 때 — 직접 구현:

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

---

### 2-4. 자동 QA 루프 (핵심)

> 이 단계를 통과하지 못하면 프로젝트는 완성 처리하지 않는다.

**스택별 QA 명령:**

```bash
# 웹 / CLI (TypeScript)
npx tsc --noEmit && npm run lint && npm run build

# 앱 (Expo)
npx expo-doctor && npx tsc --noEmit

# CLI (Python)
python -m mypy . && python -m pytest

# CLI (Go)
go vet ./... && go build ./... && go test ./...

# CLI (Rust)
cargo check && cargo clippy && cargo test
```

**QA 루프 알고리즘:**

```
QA_ATTEMPTS = 0
MAX_QA_ATTEMPTS = 3

while QA_ATTEMPTS < MAX_QA_ATTEMPTS:
  result = run_qa_commands()

  if result.success:
    → QA 통과, Phase 2-5로 진행
    break

  QA_ATTEMPTS += 1
  errors = parse_errors(result.stderr)

  if QA_ATTEMPTS <= 2:
    # OMC_MODE에 따라 오류 수정 에이전트 선택
    if OMC_MODE == "omc":
      → Agent(oh-my-claudecode:debugger,
           prompt="다음 빌드 오류를 근본 원인부터 분석하고 수정하라:
                   {errors}
                   프로젝트: projects/{slug}/  스택: {TECH_STACK}")
    elif OMC_MODE == "ecc":
      → Agent(everything-claude-code:build-error-resolver, errors, context=프로젝트_소스코드)
    else:
      → Task(build-error-resolver, errors, context=프로젝트_소스코드)
    → 수정 후 재시도

  if QA_ATTEMPTS == 3 and not result.success:
    → 스코프 축소: Nice-to-have 기능 제거, Must-have만 남기고 재구현
    → 최종 QA 1회 더 실행
    → 그래도 실패 시 SKIP 마킹 + report_data에 오류 기록

# QA 통과 후 — OMC_MODE == "omc" 이면 verifier로 기능 동작 최종 확인
if QA passed and OMC_MODE == "omc":
  Agent(oh-my-claudecode:verifier,
    prompt="projects/{slug}/ 핵심 기능이 실제로 동작하는지 검증.
            PRD Must-have 기능 체크리스트 기준. 실패 항목은 재현 방법과 함께 보고.")
```

QA 결과 출력:
```
━━━ QA 결과: {서비스명} ━━━
시도: {QA_ATTEMPTS}회  |  결과: ✅ 통과 / ❌ SKIP
오류 타입: {오류 분류}
수정 내역: {수정된 파일 목록}
━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### 2-5. README 자동 생성 (`projects/{slug}/README.md`)

QA 통과 후 즉시 생성.

**OMC_MODE == "omc"** 일 때:
```
Agent(oh-my-claudecode:writer,
  prompt="projects/{slug}/ README.md 작성.
          PRD + 실제 구현 내용 기반. 영문, 간결하고 기술적인 톤.
          포함: 서비스 소개, 기능 목록, 기술 스택 표, 설치/실행 방법.")
```

그 외 모드에서는 아래 템플릿을 직접 생성.

포함 내용:

```markdown
# {서비스명} — {한국어 이름}

> {한 줄 설명}

## Features
- {핵심 기능 1}
- {핵심 기능 2}
- {핵심 기능 3}

## Tech Stack
| Layer | Technology |
|-------|-----------|
| {레이어} | {기술} |

## Getting Started

### Prerequisites
{스택별 필수 환경 — Node 버전, Python 버전 등}

### Installation
```bash
{설치 명령}
```

### Usage
```bash
{실행 명령}
```

## Screenshots
> _스크린샷 추가 예정_

## License
MIT
```

스택과 실제 구현된 기능 목록을 기반으로 내용을 동적으로 생성.

---

### 2-6. GitHub 저장소 생성 및 Push

**OMC_MODE == "omc"** 일 때:
```
Agent(oh-my-claudecode:git-master,
  prompt="projects/{slug}/ 을 새 GitHub 저장소 {slug}에 push.
          커밋 메시지: 'feat: initial implementation of {서비스명}'.
          저장소 설명: '{서비스 한 줄 설명}'.
          public 저장소. push 성공 후 URL 반환.")
```

그 외 모드에서는 아래 명령을 직접 실행:

```bash
gh repo create {slug} --public --description "{서비스 설명}"
git init && git add . && git commit -m "feat: initial implementation of {서비스명}"
git remote add origin https://github.com/{owner}/{slug}.git
git push -u origin main
```

Push 실패 시 최대 3회 재시도 (지수 백오프: 5s → 10s → 20s).

---

### 2-7. 완료 알림

프로젝트 1개 완료 시 macOS 알림 발송:

```bash
osascript -e 'display notification "{서비스명} 빌드 완료 ({현재번호}/{PROJECT_COUNT})" with title "auto-project-builder" sound name "Glass"'
```

Linux/WSL 환경이면 알림을 생략하고 터미널에만 출력.

```
✅ [{현재번호}/{PROJECT_COUNT}] {서비스명} 완료 — {GitHub URL}
```

---

### 2-8. 체크포인트 저장

매 프로젝트 완료 후 즉시 체크포인트 업데이트:

```json
{
  "run_date": "YYYYMMDD",
  "platform": "PLATFORM",
  "tech_stack": "TECH_STACK",
  "service_categories": [],
  "project_count": 5,
  "approved_ideas": [...],
  "completed_projects": ["slug-1", "slug-2"],
  "remaining_projects": ["slug-3", "slug-4", "slug-5"],
  "last_updated": "ISO 날짜"
}
```

```bash
# 저장
echo '{...}' > .auto-project-builder-checkpoint.json
```

전체 완료 시 체크포인트 파일 삭제:
```bash
rm .auto-project-builder-checkpoint.json
```

---

### 2-9. 진행 로그 기록 (`report_data/{slug}_log.json`)

```json
{
  "project": "slug",
  "platform": "PLATFORM",
  "tech_stack": "TECH_STACK",
  "category": "SERVICE_CATEGORY",
  "idea_score": { "market": 3, "originality": 2, "feasibility": 3, "total": 8 },
  "competitors": ["경쟁 서비스 1", "경쟁 서비스 2"],
  "differentiator": "차별점 설명",
  "idea_rationale": "선택 이유",
  "tech_decisions": ["결정사항과 이유"],
  "qa_attempts": 1,
  "qa_errors_fixed": ["수정된 오류 목록"],
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
- 완료/스킵/QA 재시도 현황
- 트렌드 조사 요약 (`TREND_DATA`)

#### 섹션 2: 아이디어 선정 배경
- 트렌드 조사 결과 요약 (시장 갭, 인기 기능)
- 평가 점수별 아이디어 분포 (통과/탈락 사유 포함)
- GitHub 중복 검토 결과
- 최종 선정 순위 (점수 기준)

#### 섹션 3: 프로젝트별 상세 보고 (PROJECT_COUNT개)

각 프로젝트 카드:
```
┌─ 프로젝트 N: {서비스명}  [{PLATFORM} / {TECH_STACK}]
│  ├─ 아이디어 평가: 시장성 {M}/3 · 독창성 {O}/3 · 구현 {F}/3
│  ├─ 경쟁 서비스 분석 + 차별점
│  ├─ 기술적 결정사항 (스택 선택 근거 포함)
│  ├─ Sprint 진행 타임라인
│  ├─ QA 결과: {시도 횟수}회, 수정된 오류 목록
│  └─ 결과: GitHub URL, 빌드 상태, 구현 범위
└─
```

#### 섹션 4: 전체 회고
- QA 공통 오류 패턴 (어떤 오류가 자주 발생했는지)
- 잘 된 점 / 아쉬운 점
- 다음 실행 개선점

---

### 3-2. overview.html 갱신

`overview.html`이 없으면 새로 생성, 있으면 기존 내용에 이번 실행 결과를 **추가**.

**구조**:

```html
<!-- overview.html 레이아웃 -->
헤더: "Project Overview — 전체 프로젝트 현황"

[실행 이력 타임라인]
  ├─ 2026-05-24  |  웹 / Next.js  |  5개  |  QA 통과율 100%  →  링크
  └─ ...

[전체 프로젝트 카탈로그]
  플랫폼별 / 유형별 / 점수별 필터 UI
  각 프로젝트 카드:
    - 서비스명, 플랫폼, 스택, 카테고리, 아이디어 평가 점수
    - GitHub URL 링크
    - 실행 날짜, QA 시도 횟수

[통계 대시보드]
  - 총 프로젝트 수
  - 플랫폼 분포 차트
  - 카테고리 분포 차트
  - 기술 스택 사용 빈도
  - 평균 QA 재시도 횟수
  - 평균 아이디어 점수
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

`OMC_MODE` 값에 따라 아래 전략 중 하나를 선택한다.

---

### OMC_MODE = "none" (기본 내장 에이전트)

```
# PRD + 환경 설정 병렬
Task(executor/sonnet, "PRD 작성") || Task(executor/haiku, "프로젝트 초기화")

# 구현 후 리뷰
Task(executor/sonnet, "핵심 기능 구현") → Task(code-reviewer/sonnet, "코드 리뷰")

# QA 루프 — 오류 수정
Task(build-error-resolver/sonnet, "빌드 오류 수정", errors=QA_ERRORS)

# 복잡한 아키텍처
Task(architect/opus, "DB 스키마 설계 검토")
```

---

### OMC_MODE = "omc" (oh-my-claudecode 최적화)

OMC가 감지되면 아래 스킬 조합을 사용한다. 각 스킬은 `Skill` 도구로 호출하거나 서브에이전트로 위임한다.

#### Phase 0-B: 트렌드 조사

```
# 시장 조사 + 심층 리서치 병렬
Skill("oh-my-claudecode:autoresearch",
  prompt="SERVICE_CATEGORIES 관련 2025-2026 트렌드, 시장 갭, 인기 기능 조사")
```

#### Phase 1: 아이디어 기획 — team으로 병렬 멀티에이전트 실행

`team` 스킬로 planner · architect · autoresearch를 **동시에** 실행한다.
단일 에이전트 순차 실행 대비 기획 시간을 대폭 단축하고 관점을 다양화한다.

```
Skill("oh-my-claudecode:team",
  prompt="아이디어 기획 팀 구성. 아래 3개 역할을 병렬로 실행하라.

  [ROLE: planner]
  TREND_DATA 기반으로 {PROJECT_COUNT}개 아이디어 기획.
  각 아이디어에 타겟 사용자, 핵심 기능 3개, 차별점 포함.
  플랫폼: {PLATFORM}, 카테고리: {SERVICE_CATEGORIES}

  [ROLE: architect]
  planner 결과를 받아 아이디어별 {TECH_STACK} 기술 적합성 평가.
  구현 가능성(feasibility) 점수 산정 근거와 리스크 제공.

  [ROLE: autoresearch]
  {SERVICE_CATEGORIES} 각 카테고리의 경쟁 서비스 3개씩 조사.
  시장 갭과 차별화 기회를 planner 결과에 보강.")

# team 결과를 통합하여 IDEAS[] 최종 확정
→ planner 아이디어 + architect 적합성 점수 + autoresearch 시장 분석 병합
→ Phase 1.3 아이디어 평가로 진행
```

#### Phase 2 전체: ultrawork 자율 오케스트레이션 (선택 옵션)

team 기획 결과를 바탕으로 **Phase 2 전체를 사람 개입 없이 완전 자율 실행**하고 싶을 때 사용한다.
ultrawork는 내부적으로 PRD·ROADMAP·구현·QA·README·Push를 스스로 조율하므로, Phase 2-1 ~ 2-6 루프를 수동으로 진행할 필요가 없다.

```
Skill("oh-my-claudecode:ultrawork",
  prompt="{PROJECT_COUNT}개 프로젝트를 아래 사양으로 처음부터 끝까지 완성하라.

  프로젝트 목록 (각 항목: slug | 서비스명 | 한 줄 설명):
  {APPROVED_IDEAS}

  공통 사양:
  - PLATFORM: {PLATFORM}
  - TECH_STACK: {TECH_STACK}
  - PRD 출력 경로: projects/{slug}/docs/PRD.md
  - ROADMAP 출력 경로: projects/{slug}/docs/ROADMAP.md

  완료 기준 (모든 항목 충족 필수):
  1. tsc --noEmit / lint / build 오류 0개
  2. 테스트 커버리지 80% 이상
  3. README.md 생성 완료
  4. GitHub 저장소 push 완료 (URL 반환)
  5. PRD Must-have 기능 전부 동작 확인

  단계 순서: PRD → ROADMAP → 구현 → QA → README → Push
  각 프로젝트는 독립적으로 병렬 실행 가능하면 병렬로 처리하라.")
```

ultrawork를 사용하지 않는 경우(기본값)에는 아래 Phase 2-1 ~ 2-6 단계별 루프로 직접 진행.

---

#### Phase 2-1: PRD 작성

```
Agent(oh-my-claudecode:planner,
  prompt="다음 아이디어의 PRD를 작성하라: {IDEA}.
          플랫폼: {PLATFORM}, 스택: {TECH_STACK}.
          포함: 페르소나, MoSCoW 기능 목록, 데이터 모델 초안, 비기능 요구사항.
          출력 경로: projects/{slug}/docs/PRD.md")
```

#### Phase 2-2: ROADMAP + 아키텍처 설계

```
Agent(oh-my-claudecode:architect,
  prompt="PRD(projects/{slug}/docs/PRD.md) 기반으로 기술 아키텍처 설계.
          스택: {TECH_STACK}.
          Sprint 계획, DB 스키마, 컴포넌트 구조도 포함.
          출력 경로: projects/{slug}/docs/ROADMAP.md")
```

#### Phase 2-3: 구현

```
# 웹/앱 — UI 있는 플랫폼: designer가 먼저 UI 가이드 작성
if PLATFORM in ["웹", "앱"]:
  Agent(oh-my-claudecode:designer,
    prompt="PRD + ROADMAP 기반 UI/UX 설계.
            컴포넌트 목록, 색상 팔레트, 레이아웃 초안 제공.
            스택: {TECH_STACK}")

# 구현 — executor가 실제 코드 작성
Agent(oh-my-claudecode:executor,
  prompt="ROADMAP의 Sprint 순서대로 {slug} 구현.
          스택: {TECH_STACK}.
          immutable 패턴, Repository 패턴, 명시적 에러 처리 준수.
          완료 기준: tsc/lint/build 오류 없음.")

# 구현 직후 코드 리뷰 (병렬 가능)
Agent(oh-my-claudecode:code-reviewer,
  prompt="projects/{slug}/ 코드 리뷰.
          CRITICAL/HIGH 이슈만 보고. 수정 사항 직접 적용.")

# 보안 검토 — 인증·외부 API·사용자 입력 처리 코드가 있는 경우
if PRD includes "auth" OR "user input" OR "external API":
  Agent(oh-my-claudecode:security-reviewer,
    prompt="projects/{slug}/ 보안 취약점 검토 (OWASP Top 10 기준).
            CRITICAL 이슈 발견 시 즉시 수정.")
```

#### Phase 2-4: QA 루프

```
QA_ATTEMPTS = 0
MAX_QA_ATTEMPTS = 3

while QA_ATTEMPTS < MAX_QA_ATTEMPTS:
  result = run_qa_commands()
  if result.success: break

  QA_ATTEMPTS += 1

  if QA_ATTEMPTS <= 2:
    # debugger — 근본 원인 분석 + 수정
    Agent(oh-my-claudecode:debugger,
      prompt="다음 빌드 오류를 근본 원인부터 분석하고 수정하라:
              {QA_ERRORS}
              프로젝트: projects/{slug}/
              스택: {TECH_STACK}
              수정 후 QA 명령 재실행 결과도 보고.")

  if QA_ATTEMPTS == 3 and not result.success:
    # 스코프 축소 후 최종 시도
    → Nice-to-have 기능 제거 후 executor로 재구현
    → QA 1회 더 실행

# QA 통과 후 — verifier로 기능 동작 최종 확인
Agent(oh-my-claudecode:verifier,
  prompt="projects/{slug}/ 핵심 기능이 실제로 동작하는지 검증.
          PRD의 Must-have 기능 체크리스트 기준.
          실패 항목 있으면 구체적 재현 방법과 함께 보고.")
```

#### Phase 2-5: README + 문서 생성

```
Agent(oh-my-claudecode:writer,
  prompt="projects/{slug}/ README.md 작성.
          PRD + 실제 구현 내용 기반.
          포함: 서비스 소개, 기능 목록, 기술 스택 표, 설치/실행 방법.
          언어: 영문, 톤: 간결하고 기술적.")
```

#### Phase 2-6: GitHub Push

```
Agent(oh-my-claudecode:git-master,
  prompt="projects/{slug}/ 을 새 GitHub 저장소 {slug}에 push.
          커밋 메시지: 'feat: initial implementation of {서비스명}'.
          저장소 설명: '{서비스 한 줄 설명}'.
          push 후 URL 반환.")
```

#### 품질 반복 개선 — ralph 루프

ralph는 PRD 기반의 검증 루프를 돌려 **모든 acceptance criteria가 통과할 때까지** 자동으로 반복한다.

**자동 적용 조건** (아래 중 하나 이상):
- `QA_ATTEMPTS >= 2` (빌드 오류가 많았던 프로젝트)
- `IDEA_SCORE.total <= 6` (저점 아이디어)
- 코드 리뷰에서 HIGH 이상 이슈가 3개 이상 발견된 경우

**선택적 적용**: 모든 완료 프로젝트에 ralph를 돌려 전체 품질을 균일하게 높일 수 있다.

```
Skill("oh-my-claudecode:ralph",
  prompt="projects/{slug}/ 의 품질을 아래 acceptance criteria 기준으로 완성하라.

  Acceptance Criteria:
  1. 테스트 커버리지 80% 이상 (jest/pytest/go test 기준)
  2. tsc --noEmit / lint / build 오류 0개
  3. 모든 에러 경계에서 명시적 에러 처리 존재
  4. 함수/컴포넌트 200줄 이하 준수
  5. PRD Must-have 기능 전부 동작 확인

  작업 우선순위:
  1. 누락된 테스트 추가 (커버리지 목표 달성)
  2. 에러 처리 보완 (silent failure 제거)
  3. 코드 가독성 개선 (함수 분리, 네이밍)
  4. 빌드/타입 오류 수정

  제약: 기존 기능 동작 유지. 스코프 확장 금지.")
```

ralph는 위 criteria가 모두 통과할 때까지 자동으로 반복 실행한다. 통과 후 자동 종료.

---

### OMC_MODE = "ecc" (everything-claude-code 최적화)

`oh-my-claudecode`는 없고 `everything-claude-code` 스킬만 있을 때 사용.

```
# 기획
Agent(everything-claude-code:planner, "아이디어 기획 + PRD 초안")
Agent(everything-claude-code:architect, "기술 아키텍처 + ROADMAP")

# 트렌드 조사
Agent(everything-claude-code:market-research, "SERVICE_CATEGORIES 시장 조사")

# 구현
Agent(everything-claude-code:feature-dev, "핵심 기능 구현 (TDD 포함)")

# 리뷰
Agent(everything-claude-code:code-review, "코드 품질 검토")
Agent(everything-claude-code:security-review, "보안 취약점 검토")

# 문서
Agent(everything-claude-code:docs, "README + 기술 문서 생성")

# QA
Agent(everything-claude-code:verify, "기능 검증")

# 스택별 빌드 오류
Agent(everything-claude-code:build-error-resolver, errors=QA_ERRORS)
```

---

## 폴백 전략

```
오류 발생
  ├─ 1차: build-error-resolver 에이전트 위임 (최대 5분)
  ├─ 2차: build-error-resolver 재시도 (스코프 축소 힌트 포함)
  ├─ 3차: 스코프 축소 (Nice-to-have 제거 후 재구현 + QA 1회)
  └─ 4차: SKIP 마킹 + report_data에 오류 상세 기록 후 다음으로 진행
```

GitHub push 실패 시 최대 3회 재시도 (지수 백오프 5s→10s→20s).

---

## 파일 구조

```
{작업 디렉토리}/
├── projects/
│   └── {slug}/
│       ├── docs/
│       │   ├── PRD.md
│       │   └── ROADMAP.md
│       ├── README.md                ← 자동 생성
│       └── ... (소스 코드)
├── report_data/
│   └── {slug}_log.json
├── .auto-project-builder-checkpoint.json  ← 실행 중 존재, 완료 시 삭제
├── {YYYYMMDD}_report.html           ← 이번 실행 보고서
└── overview.html                    ← 전체 누적 현황
```

---

## 실행 예시

```
# 기본 실행 (인터랙티브 설정 시작)
/auto-project-builder

# 인터랙티브 대화 예시:
> 이전 체크포인트 발견 → "새로 시작" 선택
> 어떤 플랫폼? → 웹
> 기술 스택?   → Next.js 14+ · shadcn/ui · SQLite
> 서비스 유형? → 생산성, 교육
> 몇 개?       → 3
→ Phase 0: Context7 + 트렌드 조사 병렬 실행
→ Phase 1: 아이디어 3개 생성 + 경쟁 분석
→ Phase 1.3: 점수화 (탈락 시 재생성)
→ Phase 1.5: GitHub 중복 검토
→ Phase 2×3: 빌드 → QA 루프 → README → Push → 알림 → 체크포인트

# 자연어로도 가능 (인터랙티브 질문 건너뛰고 파싱)
"CLI 프로젝트 2개 개발자 도구로 만들어줘"
"웹앱 5개 커머스 관련으로 자율 빌드"
```

## 주의사항

- SQLite DB 파일 `.gitignore` 추가 (`*.db`, `*.sqlite`)
- `.env.local` `.gitignore` 추가, `.env.example` 커밋
- `overview.html`은 누적 파일 — 삭제하지 않도록 주의
- `{RUN_DATE}_report.html`은 실행마다 새로 생성 (덮어쓰지 않음)
- `.auto-project-builder-checkpoint.json`은 실행 중에만 존재 — 완료 시 자동 삭제
