---
name: idea-generator
description: 멀티소스 페인 마이닝 → 병렬 3역할 적대적 평가 → YC 스타일 go/no-go 판정으로 높은 품질의 프로젝트 아이디어를 생성. auto-project-builder Phase 1에서 호출되거나 단독으로 사용 가능.
triggers:
  - idea-generator
  - 아이디어 생성
  - idea generation
  - 아이디어 발굴
---

## 핵심 원칙

> **솔루션이 아닌 고통(Pain)에서 시작한다.**
> 트렌딩 기술이나 "있으면 좋겠다"는 상상이 아니라, 실제 사용자가 지금 겪고 있는 불편을 먼저 발굴한다.
> 아이디어는 그 고통의 증거를 가지고 있을 때만 유효하다.

---

## 입력 파라미터

이 스킬은 아래 변수들을 호출 시 컨텍스트로 받는다. 단독 실행 시에는 사용자에게 질문한다.

| 변수 | 설명 | 기본값 |
|------|------|--------|
| `PLATFORM` | 웹 / 앱 / CLI / auto | auto |
| `SERVICE_CATEGORIES[]` | 생산성, 교육, 헬스 등 | ["diverse"] |
| `TREND_DATA` | Phase 0-B 트렌드 조사 결과 | null |
| `PROJECT_COUNT` | 생성할 아이디어 수 | 5 |
| `TECH_STACK` | 선호 스택 또는 "auto-per-idea" | "auto-per-idea" |
| `OMC_MODE` | "omc" / "ecc" / "none" | "none" |

---

## Phase A: 멀티소스 페인 마이닝

> 목표: 실제 사용자 고통의 **증거**를 수집한다. 아이디어는 이 단계 이후에 나온다.

`SERVICE_CATEGORIES`와 `PLATFORM`을 기반으로 아래 4개 레인을 **병렬**로 실행한다.

### 레인 1 — Reddit 불만 수집

```
WebSearch("site:reddit.com \"I wish there was\" OR \"why is there no\" OR \"wish existed\" {category} {platform} app 2024 2025")
WebSearch("site:reddit.com \"{category}\" app frustrating OR annoying OR broken OR \"doesn't exist\" 2025")
```

수집 목표: 각 카테고리당 **5개 이상의 구체적 불만 인용문** (upvote 수 포함하면 더 좋음)

### 레인 2 — Hacker News 페인 포인트

```
WebSearch("site:news.ycombinator.com \"Ask HN\" {category} tool OR app OR software 2024 2025")
WebSearch("site:news.ycombinator.com \"{category}\" frustrating OR missing OR \"wish there was\" 2024 2025")
```

HN의 "Ask HN: Is there a tool for X?" 스레드는 미충족 수요의 황금 광맥이다.

### 레인 3 — 앱스토어 1점 리뷰 패턴

```
WebSearch("{category} app \"1 star\" OR \"one star\" review complaints 2024 2025")
WebSearch("{top_competitor_in_category} app review \"missing feature\" OR \"wish it had\" OR \"needs\" 2025")
```

경쟁 제품의 1점 리뷰에서 **반복되는 불만**을 찾는다. 이것이 곧 미충족 수요다.

### 레인 4 — GitHub Issues 기능 요청

```
WebSearch("site:github.com {category} issues \"feature request\" OR \"enhancement\" label:enhancement 2024 2025")
WebSearch("github \"{category}\" {platform} \"would be great\" OR \"missing\" OR \"please add\" issues 2024 2025")
```

오픈소스 도구의 미해결 feature request는 유료 솔루션 수요의 신호다.

### 페인 클러스터링

4개 레인 완료 후, 수집된 불만들을 주제별로 클러스터링한다:

```
PAIN_CLUSTERS = [
  {
    "theme": "반복되는 문제 주제",
    "evidence": ["실제 인용문 1", "실제 인용문 2", "실제 인용문 3"],
    "frequency": 높음 / 중간 / 낮음,
    "platform_fit": PLATFORM과의 관련성,
    "sources": ["Reddit", "HN", "App Store", "GitHub"]
  },
  ...
]
```

빈도가 낮더라도 고통 강도가 강한 클러스터는 별도 표시한다.

---

## Phase B: 페인→아이디어 변환

`PAIN_CLUSTERS`를 기반으로 `PROJECT_COUNT × 2`개의 후보 아이디어를 생성한다. (Phase D 필터링을 위해 2배 생성)

**변환 규칙**:
- 각 아이디어는 반드시 **하나 이상의 페인 클러스터 인용문**에 근거를 둔다
- "기술이 있으니 만들자"가 아닌 "이 고통이 있으니 이것으로 해결하자"로 서술한다
- 아이디어 제목 형식: `"{타겟 사용자}가 {고통}을 해결하는 {솔루션 키워드}"`

```
CANDIDATE_IDEAS = []
for cluster in top PAIN_CLUSTERS (빈도순):
  idea = {
    "slug": "영문-kebab-case",
    "name_ko": "한국어 이름",
    "pain_statement": "구체적 고통 설명 (인용문 근거)",
    "pain_evidence": [인용문 1, 인용문 2, 인용문 3],
    "target_user": "구체적 타겟 (예: '매일 Jira를 쓰는 5인 이하 스타트업 개발팀')",
    "solution": "핵심 해결 방식 (기능 나열 아님)",
    "core_features": ["Must-have 기능 1", "기능 2", "기능 3"],
    "why_now": "왜 지금이 적기인가",
    "tech_stack_candidate": TECH_STACK 또는 페인에 맞는 추정 스택
  }
  CANDIDATE_IDEAS.append(idea)
```

`TECH_STACK = "auto-per-idea"`이면 각 아이디어의 특성에 맞는 스택을 개별 결정한다.

---

## Phase C: 병렬 3역할 적대적 평가

각 후보 아이디어에 대해 **3가지 역할**이 동시에 평가한다.
역할들은 서로 다른 관점을 가지며, 합의가 아닌 긴장(tension)이 목표다.

### OMC_MODE = "omc" 일 때 — Agent 병렬 호출

```
# 3가지 역할을 동시에 실행
Agent(oh-my-claudecode:planner,
  prompt="다음 후보 아이디어 목록에 대해 '제품 기획자' 역할로 평가하라:
          {CANDIDATE_IDEAS}

          각 아이디어에 대해:
          1. 핵심 가치 제안 한 문장으로 정리
          2. 타겟 사용자 페르소나 구체화 (직업, 상황, 빈도)
          3. 킬러 기능 1개 선택 (나머지는 없애도 쓰는 기능)
          4. 경쟁 서비스 3개 나열 + 각각과의 구체적 차이점
          5. 6개월 후 이 서비스가 살아있을 시나리오")

Agent(oh-my-claudecode:architect,
  prompt="다음 후보 아이디어 목록에 대해 '기술 아키텍트' 역할로 평가하라:
          {CANDIDATE_IDEAS}
          선호 스택: {TECH_STACK}  플랫폼: {PLATFORM}

          각 아이디어에 대해:
          1. 선택 스택으로 구현 가능성 (1=불가 / 2=가능하나 복잡 / 3=적합)
          2. 핵심 기술 리스크 (예: 실시간 동기화, AI API 비용, 모바일 성능)
          3. MVP 구현에 필요한 예상 sprint 수 (1–6)
          4. 스케일링 시 발생할 수 있는 기술 부채
          5. 외부 API 의존성 및 리스크")

Agent(oh-my-claudecode:critic,
  prompt="다음 후보 아이디어 목록에 대해 'YC 심사위원' 역할로 혹독하게 평가하라.
          사탕발림 없이, 실패할 이유를 먼저 찾아라:
          {CANDIDATE_IDEAS}

          각 아이디어에 대해 다음을 반드시 답하라:
          1. 이 아이디어가 6개월 안에 실패할 가장 큰 이유 1가지 (있다면)
          2. 이미 잘 하고 있는 경쟁자가 있는가? 있다면 왜 이길 수 있는가?
          3. 수익화 경로가 명확한가? (없으면 명시)
          4. 네트워크 효과 또는 방어 가능한 해자가 있는가?
          5. 창업자(빌더)가 이 문제를 직접 겪어봤을 가능성이 있는가?
          6. 최종 평결: GO / CONDITIONAL / NO-GO  (이유 포함)")
```

### OMC_MODE != "omc" 일 때 — 직접 3역할 수행

아래 순서로 직접 각 역할을 수행하고 결과를 기록한다:

**역할 1 — 제품 기획자**: 각 아이디어의 핵심 가치, 타겟 페르소나, 경쟁 차별점 정의
**역할 2 — 기술 아키텍트**: 구현 가능성 점수(1-3), 기술 리스크, MVP sprint 수 산정
**역할 3 — YC 비평가**: 실패 원인 먼저 탐색, 경쟁자 검토, 수익화 경로, 최종 판정

각 역할 평가 후 `EVALUATIONS[]`에 결과를 누적한다.

---

## Phase D: YC 스타일 최종 판정

### 스코어카드 (합계 15점 만점)

| 항목 | 배점 | 기준 |
|------|------|------|
| **페인 강도** | 1–3 | 1=추측, 2=간접 증거, 3=직접 인용 5개 이상 |
| **시장 규모** | 1–3 | 1=틈새 소수, 2=수천~수만, 3=수십만 이상 |
| **독창성** | 1–3 | 1=명백한 클론, 2=개선된 클론, 3=새로운 조합·접근 |
| **구현 가능성** | 1–3 | 1=스택 불일치, 2=가능하나 리스크 큼, 3=스택 최적 |
| **치명적 결함 감점** | -3–0 | 결함 없음=0, 1개=-1, 2개=-2, 3개 이상=-3 |

```
total_score = pain_strength + market_size + originality + feasibility + flaw_penalty
```

### 판정 기준

```
total_score ≥ 11  → GO ✅       (즉시 빌드 추천)
total_score 8–10  → CONDITIONAL ⚠️  (지적된 결함 수정 후 진행)
total_score ≤ 7   → NO-GO ❌    (아이디어 폐기, 대체 생성)
```

### 최종 IDEAS[] 구성

```
# GO + CONDITIONAL 아이디어를 점수 내림차순으로 정렬
# PROJECT_COUNT개만 선택 (부족하면 새 후보 생성)
IDEAS = sorted(
  [idea for idea in CANDIDATE_IDEAS if verdict in ["GO", "CONDITIONAL"]],
  key=lambda x: x.score.total,
  reverse=True
)[:PROJECT_COUNT]

# 부족분 자동 보충 (최대 PROJECT_COUNT × 3회 시도)
while len(IDEAS) < PROJECT_COUNT and attempts < PROJECT_COUNT * 3:
  new_candidates = generate_from_remaining_pain_clusters()
  # Phase C → Phase D 재실행
  attempts += 1
```

---

## 출력 형식

스킬 종료 시 `IDEAS[]`를 아래 구조로 출력한다. auto-project-builder는 이 출력을 Phase 1.3 이후 단계에서 바로 사용한다.

```json
{
  "ideas": [
    {
      "slug": "project-slug",
      "name_ko": "한국어 이름",
      "pain_statement": "구체적 고통 설명",
      "pain_evidence": [
        "Reddit: '나는 매일 이 문제를 겪는다...' (250 upvotes)",
        "HN: 'Ask HN: Is there a tool for...' (82 comments)",
        "App Store: '★☆ 이 기능만 있으면 완벽한데...' (반복 10건 이상)"
      ],
      "target_user": "구체적 타겟 사용자",
      "solution": "핵심 해결 방식",
      "core_features": ["킬러 기능", "보조 기능 1", "보조 기능 2"],
      "why_now": "지금 만들어야 하는 이유",
      "competitors": ["경쟁 서비스 A", "경쟁 서비스 B"],
      "differentiator": "경쟁과 구체적으로 다른 점",
      "tech_stack": "선택된 스택 (이유 포함)",
      "score": {
        "pain_strength": 3,
        "market_size": 2,
        "originality": 3,
        "feasibility": 3,
        "flaw_penalty": -1,
        "total": 10
      },
      "fatal_flaws": ["수익화 경로 불명확 — 프리미엄 전환율 낮을 수 있음"],
      "flaw_mitigations": ["초기엔 SaaS 구독 대신 one-time 요금으로 시작"],
      "verdict": "CONDITIONAL",
      "idea_rationale": "왜 이 아이디어인가 (트렌드·카테고리 연결 설명)"
    }
  ],
  "pain_mining_summary": {
    "total_evidence_collected": 42,
    "top_pain_themes": ["테마 1", "테마 2", "테마 3"],
    "sources_used": ["Reddit", "HN", "App Store", "GitHub Issues"]
  },
  "generation_stats": {
    "candidates_generated": 10,
    "go": 3,
    "conditional": 4,
    "no_go": 3,
    "final_count": 5
  }
}
```

---

## 결과 출력 (사용자용)

```
━━━ 아이디어 발굴 완료 ━━━
페인 마이닝: {N}개 증거 수집  |  후보: {C}개 생성  |  최종: {F}개 선정

┌─ {서비스명} ({slug})  점수: {total}/15  {verdict}
│  고통: "{pain_quote}"
│  타겟: {target_user}
│  차별점: {differentiator}
│  스택: {tech_stack}
│  치명적 결함: {fatal_flaws or "없음"}
└──────────────────────────────────────

[다음 아이디어...]
━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 단독 실행 모드

`/idea-generator`로 직접 호출 시, 아래 질문을 먼저 한다:

```
1. 어떤 플랫폼? (웹 / 앱 / CLI / 알아서)
2. 어떤 카테고리? (생산성 / 교육 / 헬스 / 개발자 도구 / 알아서 등)
3. 몇 개 생성? (기본: 3)
4. 선호 스택? (없으면 "알아서")
```

입력 후 Phase A → B → C → D 순으로 실행하고 IDEAS[]를 출력한다.
아이디어만 필요하고 빌드는 필요 없을 때 이 모드를 사용한다.
