---
name: auto-project-builder
description: 인간 개입 없이 자율적으로 서비스 아이디어를 기획하고 Next.js+shadcn/ui+SQLite 웹 프로젝트로 완성까지 구현하는 완전 자동화 스킬. --count N 으로 개수, --keywords 로 도메인 힌트 지정 가능.
triggers:
  - auto-project-builder
  - 자율 프로젝트
  - 아이디어 자동 구현
  - autonomous build
  - 서비스 자동 생성
---

## 옵션 파싱 (ARGUMENTS 처리)

스킬 호출 시 ARGUMENTS에서 아래 옵션을 파싱한다. 옵션이 없으면 기본값 사용.

| 옵션 | 단축 | 기본값 | 설명 |
|------|------|--------|------|
| `--count N` | `-n N` | `5` | 생성할 프로젝트 수 (1–10) |
| `--keywords "k1,k2,..."` | `-k "..."` | _(없음)_ | 아이디어 도메인/키워드 힌트 (쉼표 구분) |

**파싱 규칙**:

1. `--count` 또는 `-n` 처리:
   - 다음 토큰이 양의 정수인가?
     - YES: 범위 확인 (1–10), 범위 외면 기본값 5
     - NO (다음 옵션이거나 텍스트이거나 없음): 기본값 5 사용
   - 음수, 소수, 0 → 기본값 5 사용

2. `--keywords` 또는 `-k` 처리:
   - 큰따옴표 `"..."` → 내부 쉼표로 분할 → 배열
   - 작은따옴표 `'...'` → 내부 쉼표로 분할 → 배열
   - 따옴표 없음 → 공백/쉼표로 분할 (다음 `--` 옵션 전까지)
   - 없으면 빈 배열 (완전 자율 선택)

3. 자유 형식 자연어 파싱 (옵션 형식이 아닌 텍스트):
   - **숫자 추출**: `(\d+)개` 또는 독립된 `(\d+)` 패턴 → **첫 번째 숫자만** PROJECT_COUNT로 사용 (다중 숫자 발견 시 이후 숫자 무시)
   - **불용어 제거**: 다음 단어는 키워드에서 제외 — `관련`, `대해`, `으로`, `같은`, `등`, `프로젝트`, `아이디어`, `서비스`, `만들어`, `개`, `개짜리`, `부탁`, `해줘`, `좀`, `해봐`
   - **도메인 키워드 추출**: 불용어 제거 후 남은 명사/형용사 → IDEA_KEYWORDS에 추가
   - 키워드가 숫자 앞에 오거나 뒤에 오더라도 동일하게 처리

   **자연어 파싱 알고리즘** (의사코드):
   ```
   function parseNaturalLanguage(text):
     # 1단계: 숫자 추출 (첫 번째 양의 정수만 사용)
     # 패턴: 앞에 '-' 또는 '.' 없는 순수 양의 정수 + 선택적 '개'
     # 부동소수점(3.5개), 음수(-3개), 소수점 뒤 숫자(3.5) 제외
     number_matches = regex_findall(r'(?<![.\-])(?<!\d)\b(\d+)\b개?', text)
     # number_matches 예: "3개 커머스 4개 게임" → ["3", "4"]
     #                     "3.5개 서비스"      → []  (소수점 앞 숫자 제외)
     #                     "-3개"              → []  (음수 제외)
     if number_matches:
       first_num = int(number_matches[0])   # 다중 숫자 중 첫 번째만
       PROJECT_COUNT = first_num if 1 <= first_num <= 10 else 5
       # 범위 벗어나면 (0, 11+, 소수 등) → 기본값 5
     else:
       PROJECT_COUNT = 5  # 기본값

     # 2단계: 불용어 제거 후 키워드 추출
     STOPWORDS = ["관련", "대해", "으로", "같은", "등", "프로젝트",
                  "아이디어", "서비스", "만들어", "개", "개짜리",
                  "부탁", "해줘", "좀", "해봐", "시작", "해", "줘"]
     words = split(text, delimiters=[' ', ','])  # 공백·쉼표 분할
     words = remove_numbers_and_suffixes(words)  # 순수 숫자, "개", "짜리" 제거
     IDEA_KEYWORDS = [w for w in words if w not in STOPWORDS and len(w) >= 2]

     return PROJECT_COUNT, IDEA_KEYWORDS
   ```

   **자연어 파싱 예시**:
   ```
   "3개 커머스 관련으로"           → PROJECT_COUNT=3, IDEA_KEYWORDS=["커머스"]
   "헬스케어 관련 4개 프로젝트"    → PROJECT_COUNT=4, IDEA_KEYWORDS=["헬스케어"]
   "2개 프로젝트"                  → PROJECT_COUNT=2, IDEA_KEYWORDS=[]
   "3개 커머스 4개 게임"           → PROJECT_COUNT=3(첫 번째), IDEA_KEYWORDS=["커머스","게임"]
   "교육 같은 아이디어 5개 해봐"   → PROJECT_COUNT=5, IDEA_KEYWORDS=["교육"]
   "SaaS 관련해서 부탁해"          → PROJECT_COUNT=5(기본값), IDEA_KEYWORDS=["SaaS"]
   "피트니스, 헬스케어 3개"        → PROJECT_COUNT=3, IDEA_KEYWORDS=["피트니스","헬스케어"]
   "생산성 도구 만들어줘"          → PROJECT_COUNT=5(기본값), IDEA_KEYWORDS=["생산성","도구"]
   ```

4. 파싱 안전망 (모든 예외를 기본값으로 수렴):
   ```
   파싱 실패 의사결정 트리:

   regex 매치 없음?
     → PROJECT_COUNT = 5

   매치됐으나 int() 변환 실패? (이론상 불가하나 방어적 처리)
     → PROJECT_COUNT = 5

   int() 성공했으나 1 <= value <= 10 범위 밖?
     → PROJECT_COUNT = 5

   키워드 추출 후 배열이 비어있음?
     → IDEA_KEYWORDS = []  (오류 아님, 자율 선택으로 진행)

   어떤 단계에서든 예외 발생 시:
     → PROJECT_COUNT = 5, IDEA_KEYWORDS = []
     → 경고 출력: "파싱 예외 발생. 기본값 적용: count=5, keywords=[]"
   ```
   - 파싱 완료 후 항상 출력: `"파싱 결과: count={PROJECT_COUNT}, keywords={IDEA_KEYWORDS}"`

**파싱 예시**:

```
ARGUMENTS: --count 3 --keywords "헬스케어,교육,게임"
→ PROJECT_COUNT=3, IDEA_KEYWORDS=["헬스케어","교육","게임"]

ARGUMENTS: -n 2 -k "productivity tools"
→ PROJECT_COUNT=2, IDEA_KEYWORDS=["productivity tools"]

ARGUMENTS: --count (값 없음) --keywords "SaaS"
→ PROJECT_COUNT=5(기본값), IDEA_KEYWORDS=["SaaS"]

ARGUMENTS: (없음)
→ PROJECT_COUNT=5, IDEA_KEYWORDS=[]
```

---

## 사전 조건

- `gh` CLI 로그인 완료 (`gh auth login`)
- `node` 18+ 설치
- `git` 설정 완료
- Context7 MCP 서버 활성화 (최신 기술 스택 조사용)

## 핵심 제약사항

- **프레임워크**: Next.js 14+ App Router + shadcn/ui
- **데이터베이스**: SQLite (Drizzle ORM or better-sqlite3) — Supabase 마이그레이션 가능한 스키마 설계
- **인증**: NextAuth.js v5 (필요 시)
- **언어**: TypeScript 엄격 모드
- **보고서**: 최종 `project_report.html`을 한국어로 작성
- **자율성**: 사람의 개입 없이 완주

---

## 실행 흐름

### Phase 0: 환경 조사 (Context7 활용)

Context7 MCP 도구로 최신 스택 버전 조사:

```
mcp__context7__resolve-library-id("next.js")
mcp__context7__resolve-library-id("shadcn/ui")
mcp__context7__resolve-library-id("drizzle-orm")
mcp__context7__resolve-library-id("better-sqlite3")
mcp__context7__resolve-library-id("next-auth")
```

조사 결과를 기반으로 각 라이브러리의 최신 버전과 권장 사용 패턴 파악.

---

## 변수 추적 (Variable Flow)

| 변수명 | 초기화 위치 | 사용처 | 타입/범위 |
|--------|------------|--------|-----------|
| `PROJECT_COUNT` | 옵션 파싱 | Phase 1 루프 크기, Phase 3 보고서 | 정수 1–10, 기본 5 |
| `IDEA_KEYWORDS` | 옵션 파싱 | Phase 1 분배 알고리즘 | 문자열 배열, 기본 [] |
| `KEYWORD_COUNT` | Phase 1 시작 | Phase 1 분배 계산 | `len(IDEA_KEYWORDS)` |
| `IDEAS_PER_KEYWORD` | Phase 1 시작 | Phase 1 루프 크기 | `floor(PROJECT_COUNT / KEYWORD_COUNT)` |
| `REMAINING_IDEAS` | Phase 1 시작 | Phase 1 나머지 채우기 | `PROJECT_COUNT % KEYWORD_COUNT` |
| `IDEAS[]` | Phase 1 생성 | Phase 1.5 검토 입력, Phase 2 루프 | PROJECT_COUNT개 객체 배열 |
| `GITHUB_REPOS[]` | Phase 1.5 시작 | Phase 1.5 중복 검토 | `{name, description, url}` 객체 배열 |
| `REJECTED_IDEAS[]` | Phase 1.5 반복 | Phase 3 보고서 섹션 2 | 탈락 아이디어 + 사유 배열 |
| `REPLACEMENT_ATTEMPTS` | Phase 1.5 반복 | 무한루프 방지 | 정수, 최대 `PROJECT_COUNT * 3` |
| `PROJECT_LOG[]` | Phase 2 반복 | Phase 3 보고서 생성 | 완료된 프로젝트 로그 배열 |

---

### Phase 1: 아이디어 생성

**`PROJECT_COUNT`개의 서비스 아이디어**를 자율 생성.

**`IDEA_KEYWORDS` 분배 알고리즘**:

```
KEYWORD_COUNT = len(IDEA_KEYWORDS)

if KEYWORD_COUNT == 0:
  # 완전 자율 선택: PROJECT_COUNT개 다양한 도메인에서 생성
  IDEAS = generate(PROJECT_COUNT, domain="diverse")
else:
  IDEAS_PER_KEYWORD = floor(PROJECT_COUNT / KEYWORD_COUNT)
  REMAINING_IDEAS = PROJECT_COUNT % KEYWORD_COUNT
  IDEAS = []
  for keyword in IDEA_KEYWORDS:
    IDEAS += generate(IDEAS_PER_KEYWORD, domain=keyword)
  # 나머지는 첫 번째 키워드의 파생 도메인에서 채움
  IDEAS += generate(REMAINING_IDEAS, domain=IDEA_KEYWORDS[0] + "_derivative")
```

예시: `PROJECT_COUNT=5, IDEA_KEYWORDS=["헬스케어","교육"]`
→ 헬스케어 2개 + 교육 2개 + 헬스케어 파생 1개 = 5개

**선택 기준**:

1. **실용성**: 실제 사용자 문제를 해결
2. **구현 가능성**: 1-2일 내 MVP 구현 가능
3. **다양성**: 키워드가 없을 경우 서로 다른 도메인 (생산성, 커뮤니티, 분석, 교육, 라이프스타일 등)
4. **기술 활용도**: SQLite + Next.js 특성을 잘 활용

각 아이디어에 대해 다음을 정의:
- 서비스명 (영문 slug + 한국어 이름)
- 타겟 사용자
- 핵심 기능 3가지
- 차별점
- 선택 이유 (키워드 연관성 포함)

---

### Phase 1.5: GitHub 중복 검토

Phase 1에서 생성된 `IDEAS[]`를 **내 GitHub 저장소와 대조**하여 이미 유사한 프로젝트가 존재하는 아이디어를 걸러낸다.

#### 1.5-1. 기존 GitHub 저장소 목록 수집

```bash
gh repo list --limit 200 --json name,description,url
```

결과를 `GITHUB_REPOS[]`에 저장. `gh` 오류 시 빈 배열로 계속 진행하고 보고서에 기록.

#### 1.5-2. 유사도 판정 알고리즘

각 `idea`에 대해 `GITHUB_REPOS[]`를 순회하며 아래 기준으로 **유사 판정**:

```
function isSimilar(idea, repo):
  # 1) 슬러그 직접 일치
  if normalize(idea.slug) == normalize(repo.name):
    return true, "슬러그 동일"

  # 2) 슬러그 부분 포함
  if normalize(repo.name) in normalize(idea.slug) or
     normalize(idea.slug) in normalize(repo.name):
    return true, "슬러그 부분 일치"

  # 3) 핵심 키워드 겹침 (도메인 수준)
  idea_tokens  = tokenize(idea.slug + " " + idea.name_ko + " " + idea.features)
  repo_tokens  = tokenize(repo.name + " " + (repo.description or ""))
  overlap = len(idea_tokens ∩ repo_tokens)
  if overlap >= 2:
    return true, f"핵심 키워드 {overlap}개 겹침: {idea_tokens ∩ repo_tokens}"

  return false, ""

# tokenize: 소문자 변환 → 하이픈/공백/언더스코어로 분할 → 불용어 제거
# 불용어: "app", "web", "site", "tool", "my", "the", "a", "서비스", "앱", "관리"
```

**판정 결과**:
- `SIMILAR` → `REJECTED_IDEAS[]`에 추가 (아이디어 + 일치한 레포 URL + 사유 기록) → 대체 아이디어 생성
- `NOT_SIMILAR` → `IDEAS[]`에 유지

#### 1.5-3. 대체 아이디어 생성 루프

```
REPLACEMENT_ATTEMPTS = 0
MAX_ATTEMPTS = PROJECT_COUNT * 3   # 무한루프 방지

while len(APPROVED_IDEAS) < PROJECT_COUNT:
  if REPLACEMENT_ATTEMPTS >= MAX_ATTEMPTS:
    # 경고 출력 후 남은 자리를 부족한 채로 계속 (Phase 2에서 SKIP 처리)
    print("⚠️ 최대 대체 시도 횟수 초과. 승인된 아이디어만으로 진행.")
    break

  # 새 아이디어 생성 (이미 생성된 아이디어·탈락 아이디어와 다른 도메인)
  new_idea = generate(1,
    domain="diverse",
    exclude_domains=[i.domain for i in IDEAS] + [i.domain for i in REJECTED_IDEAS]
  )
  REPLACEMENT_ATTEMPTS += 1

  if not isSimilar(new_idea, any repo in GITHUB_REPOS):
    APPROVED_IDEAS.append(new_idea)
  else:
    REJECTED_IDEAS.append(new_idea + 사유)
```

#### 1.5-4. 결과 출력

검토 완료 후 항상 출력:

```
━━━ GitHub 중복 검토 결과 ━━━
총 검토: {검토한 아이디어 수}개
승인:   {len(APPROVED_IDEAS)}개  ✅
탈락:   {len(REJECTED_IDEAS)}개  ❌
대체 시도: {REPLACEMENT_ATTEMPTS}회

탈락 목록:
  - {아이디어명} → 유사 레포: {repo.url} ({사유})
  ...

최종 승인 아이디어:
  1. {slug} — {name_ko}
  ...
━━━━━━━━━━━━━━━━━━━━━━━━━━
```

`IDEAS[]`를 `APPROVED_IDEAS[]`로 교체 후 Phase 2로 진행.

---

### Phase 2: 각 프로젝트 실행 루프

아이디어별로 아래 서브 흐름을 순서대로 실행:

#### 2-1. PRD 작성

파일: `projects/{slug}/docs/PRD.md`

포함 내용:
- 서비스 개요 및 목적
- 타겟 사용자 페르소나
- 핵심 기능 목록 (MoSCoW 우선순위)
- 기술 스택 명세
- 데이터 모델 초안
- 비기능 요구사항 (성능, 보안)

#### 2-2. ROADMAP 작성

파일: `projects/{slug}/docs/ROADMAP.md`

- Sprint 0: 프로젝트 셋업 (Next.js 초기화, 의존성 설치)
- Sprint 1: 데이터 모델 + DB 셋업 (Drizzle schema + SQLite)
- Sprint 2: 핵심 기능 구현
- Sprint 3: UI/UX (shadcn/ui 컴포넌트)
- Sprint 4: 인증 (NextAuth — 필요 시)
- Sprint 5: 테스트 + 마무리
- Sprint 6: GitHub push

#### 2-3. 구현

ROADMAP 순서대로 구현. 각 Sprint 완료 후 체크:

```
Sprint 완료 체크리스트:
[ ] TypeScript 컴파일 오류 없음 (tsc --noEmit)
[ ] ESLint 오류 없음
[ ] 핵심 기능 동작 확인
[ ] 테스트 존재 (80%+ 커버리지 목표)
```

**구현 원칙**:
- Immutable 패턴 (객체 직접 변경 금지)
- Repository 패턴 (DB 접근 추상화)
- 에러 처리 명시적으로
- 컴포넌트 200줄 이하

**SQLite → Supabase 마이그레이션 대비**:
- Drizzle ORM 사용으로 DB 추상화
- 환경변수로 DB URL 분리: `DATABASE_URL`
- 스키마를 Supabase PostgreSQL 호환으로 설계

#### 2-4. GitHub 저장소 생성 및 Push

```bash
# 저장소 생성
gh repo create {slug} --public --description "{서비스 설명}"

# 초기 커밋 및 push
git init
git add .
git commit -m "feat: initial implementation of {서비스명}"
git remote add origin https://github.com/{owner}/{slug}.git
git push -u origin main
```

#### 2-5. 진행 로그 기록

`report_data/{slug}_log.json`에 기록:
```json
{
  "project": "slug",
  "idea_rationale": "왜 이 아이디어를 선택했는지",
  "tech_decisions": ["결정사항과 이유"],
  "team_communications": ["에이전트간 주요 소통 내용"],
  "challenges": ["겪은 문제들"],
  "solutions": ["해결 방법"],
  "github_url": "https://github.com/...",
  "completed_at": "ISO 날짜"
}
```

---

### Phase 3: 최종 보고서 생성

모든 `PROJECT_COUNT`개 프로젝트 완료 후 `project_report.html` 생성.

**보고서 구성** (한국어, 파일명: `project_report.html`):

#### 섹션 1: 전체 요약 대시보드
- 실행 날짜, 총 프로젝트 수, 완료/스킵 현황
- 사용된 키워드 옵션 및 파싱 결과
- 기술 스택 요약 (Context7 조사 결과)

#### 섹션 2: 아이디어 선정 배경 (전체)
- 후보 아이디어 목록과 탈락 이유
- 최종 선정 기준 (실용성·구현가능성·다양성·기술활용도 점수)
- IDEA_KEYWORDS가 있었다면 키워드-아이디어 매핑 과정
- **GitHub 중복 검토 결과**: 탈락된 아이디어 목록, 일치한 기존 레포 URL, 대체 아이디어 생성 과정

#### 섹션 3: 프로젝트별 상세 보고 (PROJECT_COUNT개)

각 프로젝트 카드에 포함:
```
┌─ 프로젝트 N: {서비스명}
│  ├─ 아이디어 의사결정 배경
│  │    왜 이 아이디어를 선택했는가? 어떤 문제를 해결하는가?
│  │    유사 서비스와의 차별점, 타겟 사용자 선정 이유
│  │
│  ├─ 기술적 결정사항
│  │    DB 스키마 설계 근거, 컴포넌트 구조 선택 이유
│  │    NextAuth 사용 여부 결정, 성능 트레이드오프
│  │
│  ├─ 진행 타임라인 (Sprint별)
│  │    Sprint 0~6 각각 시작/완료 시각, 주요 작업
│  │    실패한 시도와 해결 방법 (폴백 발동 여부)
│  │
│  ├─ 에이전트 팀 소통 내역
│  │    어떤 에이전트에게 어떤 작업을 위임했는지
│  │    에이전트 응답에서 중요한 결정으로 이어진 내용
│  │
│  └─ 결과
│       GitHub URL (또는 실패 이유), 빌드 상태, 구현 범위
└─
```

#### 섹션 4: 전체 회고
- 공통적으로 겪은 기술적 도전
- 가장 잘 된 점 / 아쉬운 점
- 다음 실행 시 개선할 점

**보고서 스타일**: 현대적인 HTML+CSS (Tailwind CDN 사용), 다크/라이트 모드 지원, 프로젝트 카드형 레이아웃, 인쇄 가능.

---

## Agent 위임 전략

독립 작업은 병렬 실행:

```
# PRD 작성과 환경 설정은 병렬 가능
Task(executor/sonnet, "PRD 작성") + Task(executor/haiku, "프로젝트 초기화")

# 구현 중 리뷰는 별도 패스
Task(executor/sonnet, "핵심 기능 구현") → Task(code-reviewer/sonnet, "코드 리뷰")

# 복잡한 아키텍처 결정
Task(architect/opus, "DB 스키마 설계 검토")
```

## 검증 단계

각 프로젝트 완료 전 필수 확인:

```bash
# TypeScript 검사
npx tsc --noEmit

# 빌드 성공 여부
npm run build

# 린트
npm run lint
```

## 보고서 품질 기준

- [ ] `PROJECT_COUNT`개 프로젝트 모두 GitHub에 push 완료
- [ ] 각 프로젝트의 PRD.md, ROADMAP.md 존재
- [ ] TypeScript 빌드 오류 없음
- [ ] 최종 project_report.html이 한국어로 작성
- [ ] 아이디어 선택 근거가 명확히 기술됨
- [ ] GitHub 중복 검토 결과 (탈락 아이디어, 유사 레포 URL, 대체 생성 과정) 포함
- [ ] 팀간 소통 내용 포함
- [ ] 기술적 결정사항과 이유 문서화

## 폴백 전략

### 구현 오류 의사결정 플로우

```
오류 발생
  │
  ├─ 오류 타입 판단
  │     ├─ TypeScript 타입 오류 / 컴파일 에러
  │     │     → 1차: build-error-resolver 에이전트 위임 (최대 5분)
  │     │           성공 → 계속 진행
  │     │           실패 → 2차로 이동
  │     │
  │     ├─ 런타임 로직 오류 / 기능 미작동
  │     │     → 1차: executor 에이전트에 디버깅 위임 (최대 5분)
  │     │           성공 → 계속 진행
  │     │           실패 → 2차로 이동
  │     │
  │     └─ 아키텍처/설계 수준 문제 (3회 누적 실패)
  │           → architect 에이전트에 재설계 위임
  │                 재설계 후 1회 재구현 시도
  │                 여전히 실패 → 3차로 이동
  │
  ├─ 2차: 스코프 축소
  │     - 해당 Sprint의 선택적 기능(Nice-to-have) 제거
  │     - 필수 기능(Must-have)만 재구현 시도
  │     성공 → 계속 진행 (제거된 기능은 TODO 마킹)
  │     실패 → 3차로 이동
  │
  └─ 3차: SKIP 처리
        - 해당 기능 `SKIP` 마킹
        - report_data에 "구현 보류" + 실패 이유 기록
        - 다음 Sprint 또는 다음 프로젝트로 진행
```

**Sprint당 최대 재시도**: 3회 (1차 + 2차 + 3차), 초과 시 자동 SKIP

**GitHub push 실패**:
- 인증 실패 → `gh auth status` 확인 후 재시도 (1회)
- 네트워크 실패 → 최대 3회 재시도 (지수 백오프: 5s, 10s, 20s)
- 3회 후에도 실패 → 로컬 완성본 유지 + 보고서에 URL 불가 기록

## 실행 예시

```
# 기본 (5개, 자율 선택)
/auto-project-builder

# 개수만 지정
/auto-project-builder --count 3
/auto-project-builder -n 2

# 키워드만 지정 (개수는 기본 5개)
/auto-project-builder --keywords "헬스케어,피트니스"
/auto-project-builder -k "productivity,SaaS"

# 개수 + 키워드 함께
/auto-project-builder --count 3 --keywords "교육,학습"
/auto-project-builder -n 2 -k "커머스"

# 자연어로도 동작
"자율 프로젝트 3개 커머스 관련으로 만들어봐"
"autonomous build 2 projects about productivity"
"헬스케어 아이디어 4개로 자율 프로젝트 시작해"
```

## 주의사항

- 각 프로젝트 디렉토리: `projects/{slug}/`
- 공유 보고서 데이터: `report_data/`
- 최종 보고서: `project_report.html` (루트)
- SQLite DB 파일은 `.gitignore`에 추가 (`*.db`, `*.sqlite`)
- `.env.local` 은 `.gitignore`에 추가, `.env.example` 은 커밋
