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

A Claude Code skill that runs a fully autonomous pipeline: interactive setup → trend research → idea scoring → competitive analysis → GitHub dedup → build → auto QA loop → README generation → GitHub push → report. No human intervention after the initial 4 questions.

---

## How It Works

```
/auto-project-builder
        │
        ▼
┌─────────────────────────────────────────────────────────┐
│  Phase -1  체크포인트 확인 + 인터랙티브 설정 (4 questions) │
└──────────────────────────┬──────────────────────────────┘
                           │
        ┌──────────────────┴──────────────────┐
        ▼                                     ▼
┌───────────────┐                   ┌──────────────────┐
│ Phase 0-A     │                   │ Phase 0-B        │
│ Context7      │  (parallel)       │ Trend Research   │
│ Stack Docs    │                   │ Product Hunt /   │
│               │                   │ GitHub Trending  │
└───────┬───────┘                   └────────┬─────────┘
        └──────────────┬────────────────────┘
                       ▼
        ┌──────────────────────────────┐
        │  Phase 1  Idea Generation    │
        │  + Competitive Analysis      │
        │  (Exa search per idea)       │
        └──────────────┬───────────────┘
                       ▼
        ┌──────────────────────────────┐
        │  Phase 1.3  Idea Scoring     │
        │  시장성 · 독창성 · 구현가능성  │
        │  /9점  →  미달 시 자동 재생성  │
        └──────────────┬───────────────┘
                       ▼
        ┌──────────────────────────────┐
        │  Phase 1.5  GitHub Dedup     │
        │  내 레포와 중복 검토           │
        └──────────────┬───────────────┘
                       ▼
        ┌──────────────────────────────────────────────────┐
        │  Phase 2  Build Loop  (프로젝트 수만큼 반복)        │
        │                                                  │
        │  2-1  PRD 작성                                    │
        │  2-2  ROADMAP + Sprint 계획                       │
        │  2-3  구현                                        │
        │  2-4  ★ 자동 QA 루프 (tsc / lint / build)         │
        │       └─ 실패 시 build-error-resolver 최대 3회     │
        │  2-5  README 자동 생성                             │
        │  2-6  GitHub push                                │
        │  2-7  macOS 완료 알림                              │
        │  2-8  체크포인트 저장                               │
        └──────────────┬───────────────────────────────────┘
                       ▼
        ┌──────────────────────────────┐
        │  Phase 3  Reports            │
        │  YYYYMMDD_report.html        │
        │  overview.html (누적 갱신)    │
        └──────────────────────────────┘
```

---

## Installation

```bash
mkdir -p ~/.claude/skills/auto-project-builder
curl -o ~/.claude/skills/auto-project-builder/SKILL.md \
  https://raw.githubusercontent.com/hongmacho/auto-project-builder/main/skills/auto-project-builder/SKILL.md
```

Claude Code를 재시작하면 `/skills` 목록에 `auto-project-builder`가 나타납니다.

---

## Usage

```
/auto-project-builder
```

### 시작 시 묻는 4가지 질문

| # | 질문 | 선택지 |
|---|------|--------|
| 1 | 플랫폼 | 웹 / 앱 / CLI / 자유롭게 |
| 2 | 기술 스택 | 플랫폼에 따라 자동 생성 |
| 3 | 서비스 유형 | 생산성 / 콘텐츠 / 커머스 / 교육 등 10가지 (복수 선택) |
| 4 | 프로젝트 수 | 기본값 5, 최대 10 |

이후 사람의 개입 없이 끝까지 실행됩니다.

---

## Features

### 체크포인트 재개
실행 중 중단되더라도 `.auto-project-builder-checkpoint.json`에 진행 상태가 저장됩니다. 다음 실행 시 완료된 프로젝트는 건너뛰고 남은 것부터 이어서 진행합니다.

### 트렌드 기반 아이디어 생성
Context7 스택 조사와 병렬로 Product Hunt / GitHub Trending을 검색합니다. 요즘 시장에서 뜨는 카테고리와 아직 해결 안 된 문제(market gap)를 아이디어에 반영합니다.

### 아이디어 사전 평가
생성된 아이디어를 빌드 전에 3가지 기준으로 점수화합니다.

| 항목 | 1점 | 2점 | 3점 |
|------|-----|-----|-----|
| 시장성 | 경쟁 포화 | 틈새 시장 | 경쟁 공백 |
| 독창성 | 명백한 클론 | 개선된 클론 | 새로운 접근 |
| 구현 가능성 | 스택 불일치 | 가능하나 복잡 | 스택에 최적 |

합계 5점 미만이면 자동으로 새 아이디어를 재생성합니다.

### 경쟁 분석
각 아이디어마다 Exa로 유사 서비스를 검색합니다. 경쟁 서비스가 발견되면 차별점을 명시하고, 경쟁 공백 영역이면 가산점을 부여합니다.

### GitHub 중복 검토
`gh repo list`로 이미 만든 레포와 유사한 아이디어를 탈락시키고 대체 아이디어를 생성합니다.

### 자동 QA 루프 (핵심)
구현 완료 후 스택별 검증 명령을 실행합니다.

| 스택 | QA 명령 |
|------|---------|
| TypeScript (웹/CLI) | `tsc --noEmit && lint && build` |
| Expo (앱) | `expo-doctor && tsc --noEmit` |
| Python | `mypy && pytest` |
| Go | `vet && build && test` |
| Rust | `check && clippy && test` |

실패 시 `build-error-resolver` 에이전트에 오류를 넘겨 자동 수정합니다. 최대 3회 시도 후에도 실패하면 Nice-to-have 기능을 제거하고 Must-have만 재구현합니다. 그래도 실패하면 해당 프로젝트는 SKIP 처리하고 다음으로 넘어갑니다.

### README 자동 생성
QA를 통과한 프로젝트마다 기능 목록, 설치 방법, 실행 명령이 포함된 `README.md`를 자동 생성합니다.

### 완료 알림
프로젝트 1개 완료마다 macOS 알림을 발송합니다. 오래 걸리는 작업 중 자리를 비워도 됩니다.

---

## Supported Tech Stacks

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
| ③ | SwiftUI (iOS) · CoreData |
| ④ | Jetpack Compose (Android) · Room |
| ⑤ | 자유 입력 |

### CLI
| 선택지 | 스택 |
|--------|------|
| ① 추천 | Node.js · TypeScript · Commander.js · SQLite |
| ② | Python 3.12 · Typer / Click · SQLite |
| ③ | Go 1.22 · Cobra · SQLite |
| ④ | Rust · Clap · ratatui · SQLite |
| ⑤ | 자유 입력 |

---

## Output

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
│   └── {slug}_log.json
├── .auto-project-builder-checkpoint.json  ← 실행 중 존재, 완료 시 자동 삭제
├── YYYYMMDD_report.html           ← 실행별 보고서 (한국어)
└── overview.html                  ← 전체 누적 카탈로그
```

### `YYYYMMDD_report.html`
실행마다 날짜가 붙은 보고서가 새로 생성됩니다. 포함 내용:
- 실행 요약 대시보드 (트렌드 조사 결과 포함)
- 아이디어 평가 점수 분포 + 탈락 사유
- 프로젝트별 상세 카드 (경쟁 분석, QA 시도 횟수, 수정된 오류 목록)
- 전체 회고

### `overview.html`
실행할 때마다 누적 갱신됩니다. 포함 내용:
- 실행 이력 타임라인 (각 report.html 링크)
- 플랫폼 / 유형 / 점수 필터가 있는 전체 프로젝트 카탈로그
- 통계 대시보드 (총 프로젝트 수, 스택 분포, 평균 QA 재시도 횟수, 평균 아이디어 점수)

---

## Prerequisites

- `gh` CLI 로그인 완료 (`gh auth login`)
- Node.js 18+ (웹/CLI 프로젝트용)
- Git 설정 완료
- Context7 MCP 서버 활성화 (최신 스택 문서 조사용)

---

## Fallback Strategy

문제 발생 시 4단계 폴백을 자동으로 실행합니다:

```
1차  build-error-resolver 에이전트 위임 (자동 수정)
2차  build-error-resolver 재시도 (스코프 축소 힌트 포함)
3차  Nice-to-have 제거 → Must-have만 재구현 → QA 1회
4차  SKIP 마킹 + 오류 상세 기록 후 다음 프로젝트로 진행
```

GitHub push 실패 시 지수 백오프(5s → 10s → 20s)로 최대 3회 재시도합니다.

---

## License

MIT
