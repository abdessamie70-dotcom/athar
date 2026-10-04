# Product Specification (SPEC.md): Athar (أثر باقٍ)

> **Vision Statement:**
> "وَالْآخِرَةُ خَيْرٌ وَأَبْقَىٰ" — A mindful productivity and spiritual legacy application designed to shift users' daily focus from transient consumption to lasting, continuous impact (صدقة جارية، علم يُنتفع به، أثر صالح).

---

## 1. Project Overview & Guiding Principles

* **Application Name:** Athar (أثر باقٍ)
* **Target Audience:** Users seeking meaningful time management, spiritual habit building, and lasting charitable/educational contributions.
* **Core Philosophy:**
  * **Zero Social Clutter:** No public vanity metrics, followers, or competitive leaderboards.
  * **Mindful & Minimalist UI:** Calming aesthetics, subdued colors, and zero high-stress push notifications.
  * **Privacy & Security First:** Highly sensitive notes and legacy capsules must be encrypted before storage.
  * **Offline Resilience:** Critical logging features must operate offline and sync smoothly when connected.

---

## 2. Technical Stack & Dependencies

* **Client Framework:** Flutter (Dart 3.x, Null Safety enforced)
* **Backend Platform:** Firebase (Cloud Firestore, Firebase Authentication)
* **Architecture Pattern:** Repository Pattern with BLoC or Provider for state management.
* **Core Dependencies (`pubspec.yaml` reference):**
  * `firebase_core`, `cloud_firestore`, `firebase_auth`
  * `encrypt` (for local client-side AES encryption of capsules)
  * `fl_chart` (for lightweight perspective/time allocation visuals)
  * `intl` (for date formatting and multi-language support)

---

## 3. Core Features & Functional Requirements (MVP)

### 3.1. Legacy Action Tracker (`actions_log`)
* Enable logging of lasting deeds under three primary categories:
  * `continuous_knowledge` (علم نافع)
  * `ongoing_charity` (صدقة جارية)
  * `good_deed` (عمل صالح)
* Each entry records:
  * Title, duration in minutes, timestamp, and optional private notes.
* Writing a log must trigger an atomic/batch increment of the user's daily lasting minutes in `daily_metrics`.

### 3.2. Perspective & Time Awareness Metric (`daily_metrics`)
* Allows logging of transient/consumption time (`transientTimeMinutes`) to establish contrast against lasting time (`lastingTimeMinutes`).
* Computes real-time lasting investment ratio:
  $$\text{Ratio} = \frac{\text{Lasting Time}}{\text{Lasting Time} + \text{Transient Time}} \times 100$$
* Compares total daily lasting minutes against user's configurable daily target (`dailyTargetMinutes`).

### 3.3. Initiatives & Impact Library (`initiatives_library`)
* Curated catalog of low-barrier, high-impact ideas (e.g., documenting technical documentation, sponsoring enduring public utilities, donating books).
* Filterable by category (`knowledge`, `sadaqah`, `service`) and estimated resource requirement (`zero_cost`, `low_cost`, `high_cost`).
* Read-only collection for general users.

### 3.4. Secure Legacy Capsule (`legacy_capsule`)
* Encrypted vault for reflections, spiritual wills, and personal advice meant for posterity.
* Requires symmetric client-side encryption (AES-256) using a user-derived passphrase before syncing to Firestore.

---

## 4. Firestore Data Model & Schema

### `users/{userId}`
```typescript
interface UserDoc {
  userId: string;
  name: string;
  email: string;
  dailyTargetMinutes: number; // default: 30
  createdAt: Timestamp;
  preferences: {
    darkMode: boolean;
    reminderTime?: string;
  };
actions_log/{actionId}
}
interface ActionLogDoc {
  actionId: string;
  userId: string; // indexed
  title: string;
  category: 'continuous_knowledge' | 'ongoing_charity' | 'good_deed';
  durationMinutes: number;
  notes?: string;
  isPrivate: boolean;
  dateLogged: Timestamp;
}
daily_metrics/{userId_YYYY-MM-DD}
interface DailyMetricDoc {
  metricId: string; // Composite key: ${userId}_${YYYY-MM-DD}
  userId: string;
  date: string; // YYYY-MM-DD
  transientTimeMinutes: number;
  lastingTimeMinutes: number;
  completedTarget: boolean;
}
initiatives_library/{initiativeId}
interface InitiativeDoc {
  initiativeId: string;
  category: string;
  title: string;
  description: string;
  estimatedCost: 'zero_cost' | 'low_cost' | 'high_cost';
  tags: string[];
}
legacy_capsule/{capsuleId}
interface LegacyCapsuleDoc {
  capsuleId: string;
  userId: string; // indexed
  title: string;
  contentEncrypted: string;
  type: 'advice' | 'will' | 'reflection';
  updatedAt: Timestamp;
}
5. Security & Access Control Guidelines
User Isolation: users, actions_log, daily_metrics, and legacy_capsule documents must only be read and written by the authenticated owner (request.auth.uid == resource.data.userId).

Public Read-Only Collections: initiatives_library is read-only for authenticated users; modifications are restricted to admin access.

Payload Sanitization: Validation rules must reject actions with zero or negative durations.

6. Development & Implementation Roadmap
Phase 1: Foundation (Data Layer)

Set up Flutter base project structure (lib/models, lib/repositories, lib/bloc, lib/views).

Implement Data Models with robust fromJson and toJson methods.

Implement Firestore collections wrapper with typed converters.

Phase 2: Core Repositories & Unit Logic

Implement ActionLogRepository with atomic batch updates to daily_metrics.

Add AES encryption helper service for legacy_capsule.

Phase 3: UI & Experience (Presentation Layer)

Minimalist Dashboard: Daily progress ring, today's ratio, and quick-add FAB.

Log Sheet: Intuitive modal bottom sheet to record deeds under 10 seconds.

Perspective Chart: Clean two-bar or donut comparison of transient vs. lasting time.

Phase 4: Offline Persistence & Polish

Enable Firestore local cache persistence.

Final testing and zero-latency UI interactions.
## 7. Antigravity Agent Guidelines & Code Constraints

1. **State Management & Separation of Concerns:**
   - UI Widgets must be strictly decoupled from business logic and Firestore calls.
   - Use `flutter_bloc` or lightweight `ChangeNotifier` providers; never call `FirebaseFirestore.instance` directly inside a Widget's `build()` method.

2. **Null-Safety & Error Handling:**
   - Enforce strict null-safety across all models and repositories.
   - All async repository calls must be wrapped in `try-catch` blocks returning functional `Result<T, Exception>` or throwing domain-specific exceptions.
   - No silent failures; display unobtrusive UI feedback (e.g., custom SnackBar) when network/sync errors occur.

3. **Performance & Optimization:**
   - Always use `const` constructors wherever possible to minimize unnecessary widget rebuilds.
   - Ensure list views (`ListView.builder`) use pagination or limits (`limit(20)`) to conserve Firestore read quotas.
   - Keep build methods lean; extract complex UI sections into smaller, private standalone widgets.

4. **Styling & Theming:**
   - Define a centralized theme in `lib/theme/app_theme.dart`.
   - Adhere to the calm spiritual aesthetic: use soft earth tones, warm neutrals, and subdued primary colors (e.g., slate green, muted gold, soft cream).
   - Avoid aggressive alert reds or high-saturation neon colors.
## 8. Seed / Mock Data (`initiatives_library`)

Create a setup script or initial local asset `assets/data/seed_initiatives.json` containing starting ideas:

```json
[
  {
    "initiativeId": "init_01",
    "category": "knowledge",
    "title": "توثيق حل تقني مفتوح المصدر",
    "description": "كتابة شرح مبسط أو مقال تقني يحل مشكلة واجهتك أثناء العمل ونشره مجاناً لينتفع به غيرك.",
    "estimatedCost": "zero_cost",
    "tags": ["تقنية", "علم_نافع", "برمجة"]
  },
  {
    "initiativeId": "init_02",
    "category": "sadaqah",
    "title": "سقيا ماء أو صيانة مبرد مسجد",
    "description": "توفير عبوات ماء نظيفة أو فحص وصيانة دورية لبراد مياه في مكان عام أو مسجد بالحي.",
    "estimatedCost": "low_cost",
    "tags": ["خدمة_مجتمعية", "صدقة_جارية", "ميداني"]
  },
  {
    "initiativeId": "init_03",
    "category": "service",
    "title": "وقف كتاب أو مصحف للمطالعة العامة",
    "description": "إهداء نسخة مصحف برسم واضح أو كتاب علمي نافع لمكتبة عامة أو زاوية قراءة.",
    "estimatedCost": "low_cost",
    "tags": ["تعليم", "وقف", "كتب"]
  }
]