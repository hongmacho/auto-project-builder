# auto-project-builder

[![GitHub Stars](https://img.shields.io/github/stars/hongmacho/auto-project-builder?style=flat-square)](https://github.com/hongmacho/auto-project-builder/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/hongmacho/auto-project-builder?style=flat-square)](https://github.com/hongmacho/auto-project-builder/network/members)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Skill-blueviolet?style=flat-square)](https://claude.ai/claude-code)
[![Next.js](https://img.shields.io/badge/Next.js-14+-black?style=flat-square&logo=next.js)](https://nextjs.org)
[![TypeScript](https://img.shields.io/badge/TypeScript-strict-blue?style=flat-square&logo=typescript)](https://www.typescriptlang.org)
[![SQLite](https://img.shields.io/badge/SQLite-Drizzle_ORM-003B57?style=flat-square&logo=sqlite)](https://orm.drizzle.team)

> **사람의 개입 없이 실제로 동작하는 프로젝트를 완성한다.**
> 빌드 오류, 타입 오류, 린트 오류가 남은 프로젝트는 "완성"이 아니다.

인터랙티브 설정 → 트렌드 조사 → 아이디어 평가 → 경쟁 분석 → GitHub 중복 검토 → 구현 → 자동 QA 루프 → README 생성 → GitHub 푸시 → 리포트 생성 → 고도화 가이드 생성까지, 최대 5가지 질문 이후 사람의 개입 없이 전체 파이프라인을 자율 실행하는 Claude Code 스킬입니다.

[English →](README.md)

---

## 동작 방식

```
/auto-project-builder
        │
        ▼
┌─────────────────────────────────────────────────────────┐
│  Phase -0.5  OMC / ECC 환경 감지 (자동, 무음)            │
│  → OMC_MODE = "omc" / "ecc" / "none"                    │
└──────────────────────────┬──────────────────────────────┘
                           │
        ▼
┌─────────────────────────────────────────────────────────┐
│  Phase -1  체크포인트 확인 + 인터랙티브 설정 (최대 5문)   │
│  Q1 플랫폼 → Q1.5 아이디어 유무 → Q2 기술스택            │
│  → Q3 서비스유형* → Q4 프로젝트수*  (* Q1.5=직접입력 시 스킵)│
└──────────────────────────┬──────────────────────────────┘
                           │
        ┌──────────────────┴──────────────────┐
        ▼                                     ▼
┌───────────────┐                   ┌──────────────────┐
│ Phase 0-A     │                   │ Phase 0-B        │
│ Context7      │  (병렬 실행)       │ 트렌드 조사       │
│ 스택 문서 조사 │                   │ Product Hunt /   │
│               │                   │ GitHub Trending  │
└───────┬───────┘                   └────────┬─────────┘
        └──────────────┬────────────────────┘
                       ▼
        ┌──────────────────────────────────────────────────┐
        │  Phase 1  아이디어 생성                           │
        │  + 경쟁 분석 (Exa — 아이디어별 유사 서비스)        │
        │  · 자동 경로: 트렌드·카테고리 기반 아이디어 생성    │
        │  · 직접 입력 경로: 사용자 아이디어 그대로 사용      │
        │  · 기술스택=없음 → 이 단계에서 아이디어별 자동 결정 │
        └──────────────┬───────────────────────────────────┘
                       ▼
        ┌──────────────────────────────┐
        │  Phase 1.3  아이디어 평가     │
        │  시장성 · 독창성 · 구현가능성  │
        │  /9점  →  미달 시 자동 재생성  │
        │  (사용자 아이디어인 경우 스킵)  │
        └──────────────┬───────────────┘
                       ▼
        ┌──────────────────────────────┐
        │  Phase 1.5  GitHub 중복 검토  │
        │  이미 만든 레포와 중복 제거    │
        └──────────────┬───────────────┘
                       ▼
        ┌──────────────────────────────────────────────────┐
        │  Phase 2  빌드 루프  (프로젝트 수만큼 반복)        │
        │                                                  │
        │  2-1  PRD 작성                                    │
        │  2-2  ROADMAP + Sprint 계획                       │
        │  2-3  구현                                        │
        │  2-4  ★ 자동 QA 루프 (tsc / lint / build)         │
        │       └─ 실패 시 build-error-resolver 최대 3회     │
        │  2-5  README 자동 생성                             │
        │  2-6  GitHub 푸시                                 │
        │  2-7  macOS 완료 알림                              │
        │  2-8  체크포인트 저장                               │
        │  2-9  고도화 가이드 생성 (5개 카테고리)              │
        │  2-10 user-suggest.html 갱신                      │
        └──────────────┬───────────────────────────────────┘
                       ▼
        ┌──────────────────────────────────────┐
        │  Phase 3  리포트 생성                 │
        │  YYYYMMDD_report.html                │
        │  overview.html       (누적 갱신)      │
        │  user-suggest.html   (누적 갱신)      │
        └──────────────────────────────────────┘
```

---

## 설치

```bash
mkdir -p ~/.claude/skills/auto-project-builder
curl -o ~/.claude/skills/auto-project-builder/SKILL.md \
  https://raw.githubusercontent.com/hongmacho/auto-project-builder/main/skills/auto-project-builder/SKILL.md
```

Claude Code를 재시작하면 `/skills` 목록에 `auto-project-builder`가 나타납니다.

---

## 사용법

```
/auto-project-builder
```

시작 시 최대 5가지 질문에 답하면 이후 전체 파이프라인이 자율 실행됩니다.

| # | 질문 | 선택지 |
|---|------|--------|
| 1 | 플랫폼 | 웹 / 앱 / CLI / **알아서** / 자유롭게 |
| 1.5 | 아이디어가 있으신가요? | **알아서** (Claude가 트렌드 기반 생성) / 직접 입력 |
| 2 | 선호하는 기술 스택 | 플랫폼별 추천 옵션 + **없음** (아이디어별 자동 결정) / 자유 입력 |
| 3 | 서비스 유형 _\*_ | 생산성 / 콘텐츠 / 커머스 / 교육 등 (복수 선택) + **알아서** |
| 4 | 프로젝트 수 _\*_ | 1–10 / **알아서** (= `floor(카테고리 수 × 2–3)`, 최대 10) |

_\* Q1.5에서 아이디어를 직접 입력하면 Q3·Q4는 자동으로 건너뜁니다 (`PROJECT_COUNT = 1` 로 자동 설정)._

**알아서** / **없음**을 선택하면 Claude가 트렌드 데이터를 기반으로 자율적으로 결정합니다. 선택된 값과 그 이유는 항상 진행 전에 공지됩니다.

---

## 주요 기능

### 체크포인트 재개
프로젝트 1개가 완료될 때마다 `.auto-project-builder-checkpoint.json`에 진행 상태가 저장됩니다. 실행 중 중단되더라도 다음 실행 시 완료된 프로젝트는 건너뛰고 남은 것부터 이어서 진행합니다. 전체 완료 시 파일이 자동 삭제됩니다.

### 트렌드 기반 아이디어 생성
Context7 스택 문서 조사와 병렬로 Product Hunt / GitHub Trending을 검색합니다. 요즘 시장에서 뜨는 카테고리와 아직 해결 안 된 문제(market gap)를 파악하여 아이디어 생성에 반영합니다.

### 아이디어 사전 평가
생성된 아이디어를 빌드 전에 3가지 기준으로 점수화합니다.

| 항목 | 1점 | 2점 | 3점 |
|------|-----|-----|-----|
| 시장성 | 경쟁 포화·차별점 없음 | 틈새 시장 존재 | 경쟁 공백·명확한 수요 |
| 독창성 | 명백한 클론 | 개선된 클론 | 새로운 접근 또는 조합 |
| 구현 가능성 | 선택 스택으로 불가 | 가능하나 복잡 | 선택 스택에 최적 |

합계 5점 미만이면 자동으로 새 아이디어를 재생성합니다.

### 경쟁 분석
각 아이디어마다 Exa로 유사 서비스를 검색합니다. 경쟁 서비스가 발견되면 차별점을 구체적으로 명시하고, 경쟁 공백 영역이면 가산점을 부여합니다.

### GitHub 중복 검토
`gh repo list`로 이미 만든 레포와 유사한 아이디어를 걸러내고 자동으로 대체 아이디어를 생성합니다.

### 자동 QA 루프 (핵심)
구현 완료 후 스택별 검증 명령을 실행합니다.

| 스택 | QA 명령 |
|------|---------|
| TypeScript (웹 / CLI) | `tsc --noEmit && lint && build` |
| Expo (앱) | `expo-doctor && tsc --noEmit` |
| Python | `mypy && pytest` |
| Go | `vet && build && test` |
| Rust | `check && clippy && test` |

실패 시 오류를 `build-error-resolver` 에이전트에 넘겨 자동 수정합니다. 최대 3회 시도 후에도 실패하면 Nice-to-have 기능을 제거하고 Must-have만 재구현합니다. 그래도 실패하면 해당 프로젝트는 SKIP 처리하고 다음으로 넘어갑니다.

### README 자동 생성
QA를 통과한 프로젝트마다 기능 목록, 기술 스택 표, 설치 방법, 실행 명령이 포함된 `README.md`를 자동 생성합니다.

### 완료 알림
프로젝트 1개 완료마다 macOS 알림을 발송합니다. 오래 걸리는 작업 중 자리를 비워도 됩니다.

### 아이디어별 기술 스택 자동 결정
기술 스택 질문에서 **없음**을 선택하면 설정 시점에 스택을 고정하지 않습니다. 대신 Phase 1 기획 단계에서 각 아이디어의 요구사항과 최신 트렌드를 분석하여 아이디어별 최적 스택을 결정합니다. 덕분에 한 번의 실행에서 Next.js, SvelteKit, Remix 등 서로 다른 스택의 프로젝트를 동시에 생성할 수 있습니다.

### 고도화 가이드 (`user-suggest.html`)
프로젝트가 완료될 때마다 5개 카테고리의 고도화 전략을 생성하고 `user-suggest.html`에 추가합니다. 이 파일은 모든 실행에 걸쳐 누적됩니다.

| 카테고리 | 내용 |
|----------|------|
| 빠른 개선 (Quick Wins) | 하루 이내에 배포 가능한 소규모 개선 사항 |
| 기능 고도화 | 다음 스프린트에 추가할 중간 규모 기능 |
| 기술 개선 | 성능·보안·아키텍처 업그레이드 방향 |
| 성장 전략 | 사용자 확보, SEO, 바이럴 루프, 파트너십 |
| 수익화 아이디어 | 프로젝트 유형에 맞는 수익 모델 제안 |

원시 데이터는 `report_data/{slug}_suggestions.json`에도 저장됩니다.

---

## OMC 통합 (oh-my-claudecode)

[oh-my-claudecode](https://github.com/oh-my-claudecode) 환경에서 실행하면, 스킬이 시작 시 자동으로 환경을 감지(Phase -0.5)하고 각 Phase를 전문 에이전트 오케스트레이션으로 업그레이드합니다.

### 자동 환경 감지

| 감지 결과 | `OMC_MODE` | 에이전트 전략 |
|----------|-----------|--------------|
| `oh-my-claudecode:*` 스킬 존재 | `"omc"` | 풀 OMC 오케스트레이션 |
| `everything-claude-code:*` 스킬 존재 | `"ecc"` | ECC 에이전트 Suite |
| 없음 | `"none"` | 내장 에이전트 |

### Phase 1: `team` 스킬로 병렬 기획

`OMC_MODE = "omc"` 일 때, 아이디어 생성 단계에서 `team` 스킬이 세 역할을 동시에 실행합니다:

| 역할 | 담당 |
|------|------|
| `planner` | 타겟 사용자·핵심 기능·차별점 포함 아이디어 생성 |
| `architect` | 아이디어별 기술 적합성 평가 및 구현 리스크 산정 |
| `autoresearch` | 카테고리별 경쟁 서비스 3개 조사, 시장 갭 도출 |

### Phase 2: `ultrawork`로 완전 자율 오케스트레이션

Phase 2 전체(PRD → ROADMAP → 구현 → QA → README → Push)를 `ultrawork`에 위임하면 사람 개입 없이 자율 실행됩니다:

```
Skill("oh-my-claudecode:ultrawork",
  prompt="{N}개 프로젝트를 처음부터 끝까지 완성하라.
  PLATFORM / TECH_STACK / PRD 경로: projects/{slug}/docs/PRD.md
  완료 기준: 빌드 오류 0 + 커버리지 80%+ + README + GitHub push")
```

### 구현 후 `ralph` 품질 반복 개선 루프

구현 완료 후 `ralph`를 적용하면 PRD 기반 acceptance criteria가 모두 통과할 때까지 자동으로 반복합니다.

**자동 적용 조건:**
- QA 2회 이상 실패
- 아이디어 점수 ≤ 6/9
- 코드 리뷰 HIGH 이슈 3개 이상

**ralph가 보장하는 기준:**
1. 테스트 커버리지 80% 이상
2. `tsc / lint / build` 오류 0개
3. 모든 에러 경계에서 명시적 에러 처리
4. 함수 / 컴포넌트 200줄 이하
5. PRD Must-have 기능 전부 동작 확인

모든 완료 프로젝트에 선택적으로 적용하여 전체 품질을 균일하게 높일 수도 있습니다.

---

## 지원 기술 스택

### 웹 (Web)
| 선택지 | 스택 |
|--------|------|
| ① 추천 | Next.js 14+ App Router · shadcn/ui · Drizzle ORM · SQLite |
| ② | Nuxt 3 · Tailwind CSS · PGlite |
| ③ | SvelteKit · shadcn-svelte · Drizzle ORM · SQLite |
| ④ | Remix · shadcn/ui · Drizzle ORM · SQLite |
| ⑤ | 자유 입력 |

### 앱 (Mobile App)
| 선택지 | 스택 |
|--------|------|
| ① 추천 | React Native + Expo · expo-sqlite |
| ② | Flutter 3 · Dart · sqflite |
| ③ | 알아서 (아이디어별 트렌드 데이터 기반 자동 결정) |
| ④ | 자유 입력 |

### CLI
| 선택지 | 스택 |
|--------|------|
| ① 추천 | Node.js · TypeScript · Commander.js · SQLite |
| ② | Python 3.12 · Typer / Click · SQLite |
| ③ | Go 1.22 · Cobra · SQLite |
| ④ | Rust · Clap · ratatui · SQLite |
| ⑤ | 자유 입력 |

---

## 출력 파일

```
{작업 디렉토리}/
├── projects/
│   └── {slug}/
│       ├── docs/
│       │   ├── PRD.md
│       │   └── ROADMAP.md
│       ├── README.md              ← 자동 생성
│       └── ... (소스 코드)
├── report_data/
│   ├── {slug}_log.json
│   └── {slug}_suggestions.json   ← 프로젝트별 고도화 가이드 데이터
├── .auto-project-builder-checkpoint.json  ← 실행 중 존재, 완료 시 자동 삭제
├── YYYYMMDD_report.html           ← 실행별 보고서 (한국어)
├── overview.html                  ← 전체 누적 카탈로그
└── user-suggest.html              ← 누적 고도화 가이드, 실행마다 갱신
```

### `YYYYMMDD_report.html`
실행마다 날짜가 붙은 보고서가 새로 생성됩니다. 포함 내용:
- 실행 요약 대시보드 (트렌드 조사 결과, QA 통계)
- 아이디어 평가 점수 분포 + 탈락 사유
- 프로젝트별 상세 카드 (경쟁 분석, QA 시도 횟수, 수정된 오류 목록)
- 전체 회고

### `overview.html`
실행할 때마다 누적 갱신됩니다. 포함 내용:
- 실행 이력 타임라인 (각 report.html 링크)
- 플랫폼 / 유형 / 점수 필터가 있는 전체 프로젝트 카탈로그
- 통계 대시보드 (총 프로젝트 수, 스택 분포, 평균 QA 재시도 횟수, 평균 아이디어 점수)

### `user-suggest.html`
프로젝트 완료마다 갱신됩니다. 포함 내용:
- 프로젝트별 카드 (빠른 개선, 기능 고도화, 기술 개선, 성장 전략, 수익화 아이디어)
- 제안별 우선순위·예상 공수 레이블
- 프로젝트 / 카테고리 / 우선순위 필터

---

## 사전 요구 사항

- `gh` CLI 로그인 완료 (`gh auth login`)
- Node.js 18+ (웹 / CLI 프로젝트용)
- Git 설정 완료
- Context7 MCP 서버 활성화 (최신 스택 문서 조사용)

---

## 폴백 전략

오류 발생 시 4단계 폴백이 자동으로 실행됩니다.

```
1차  build-error-resolver 에이전트 위임 (자동 수정)
2차  build-error-resolver 재시도 (스코프 축소 힌트 포함)
3차  Nice-to-have 제거 → Must-have만 재구현 → 최종 QA 1회
4차  SKIP 마킹 + 오류 상세 기록 → 다음 프로젝트로 진행
```

GitHub 푸시 실패 시 지수 백오프(5s → 10s → 20s)로 최대 3회 재시도합니다.

---

## 라이선스

MIT
