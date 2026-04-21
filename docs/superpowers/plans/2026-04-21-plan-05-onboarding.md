# Plan 05: Onboarding (Guided + Observation) — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** New users land in a first-launch mode picker (Guided or Observation), complete the chosen flow, and end up in a working app state — either with an AI-generated plan (Guided) or in free-log mode (Observation) with a later prompt to generate a plan once enough data exists.

**Architecture:** The router reads `users.onboarding_completed_at` and redirects to `/onboarding` if null. Two sub-routes: `/onboarding/guided` runs the 6-question Q&A and calls `generate-plan`; `/onboarding/observe` runs a 3-question Q&A and marks onboarding complete without a plan. A background check on app foreground evaluates the observe-mode threshold (14 days OR 8 sessions) and shows a "Ready for a plan?" bottom sheet.

**Depends on:** Plans 01, 02, 03, 04.

---

## File structure

```
apps/mobile/lib/features/onboarding/
├── data/
│   └── onboarding_repository.dart
├── presentation/
│   ├── onboarding_gate.dart           # router decision
│   ├── mode_picker_screen.dart
│   ├── guided_qa_screen.dart
│   ├── observe_qa_screen.dart
│   ├── generating_plan_screen.dart
│   └── ready_for_plan_sheet.dart
```

---

## Task 1 — Onboarding repository

**Files:**
- Create: `apps/mobile/lib/features/onboarding/data/onboarding_repository.dart`

- [ ] **Step 1:** Implement.

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingRepository {
  OnboardingRepository(this._client);
  final SupabaseClient _client;

  Future<void> setMode({
    required String userId,
    required String mode, // 'guided' | 'observe'
    required String goal,
    String? experienceLevel,
  }) async {
    await _client.from('users').update({
      'onboarding_mode': mode,
      'goal': goal,
      if (experienceLevel != null) 'experience_level': experienceLevel,
    }).eq('id', userId);
  }

  Future<void> markComplete(String userId) async {
    await _client.from('users').update({
      'onboarding_completed_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', userId);
  }

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final data = await _client.from('users').select().eq('id', userId).maybeSingle();
    return data;
  }

  /// Observation mode: counts sessions since the user joined for threshold tracking.
  Future<int> loggedSessionCount(String userId) async {
    final rows = await _client
        .from('sessions')
        .select('id')
        .eq('user_id', userId)
        .eq('status', 'completed');
    return rows.length;
  }

  /// Days since account creation.
  Future<int> daysSinceSignup(String userId) async {
    final profile = await getProfile(userId);
    if (profile == null) return 0;
    final created = DateTime.parse(profile['created_at'] as String);
    return DateTime.now().toUtc().difference(created).inDays;
  }
}
```

- [ ] **Step 2:** Commit.

```bash
git add apps/mobile/lib/features/onboarding
git commit -m "feat(onboarding): repository — set mode, mark complete, threshold checks"
```

---

## Task 2 — Router gate

**Files:**
- Modify: `apps/mobile/lib/core/routing/app_router.dart`

- [ ] **Step 1:** Extend the redirect logic.

Edit `app_router.dart`:

```dart
import '../../features/onboarding/data/onboarding_repository.dart';

final _onboardingStateProvider = FutureProvider.autoDispose<bool>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return true; // not logged in, don't matter
  final repo = OnboardingRepository(Supabase.instance.client);
  final profile = await repo.getProfile(user.id);
  return profile?['onboarding_completed_at'] != null;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthed = Supabase.instance.client.auth.currentSession != null;
      final loc = state.matchedLocation;

      if (!isAuthed) return loc == '/sign-in' ? null : '/sign-in';

      final onboardingAsync = ref.read(_onboardingStateProvider);
      final onboardingComplete = onboardingAsync.valueOrNull ?? true;

      if (!onboardingComplete && !loc.startsWith('/onboarding')) return '/onboarding';
      if (onboardingComplete && loc.startsWith('/onboarding')) return '/';
      if (loc == '/sign-in') return '/';
      return null;
    },
    refreshListenable:
        GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/sign-in', builder: (_, __) => const SignInScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const ModePickerScreen()),
      GoRoute(path: '/onboarding/guided', builder: (_, __) => const GuidedQaScreen()),
      GoRoute(path: '/onboarding/observe', builder: (_, __) => const ObserveQaScreen()),
      GoRoute(path: '/onboarding/generating', builder: (_, __) => const GeneratingPlanScreen()),
      GoRoute(path: '/today', builder: (_, __) => const TodayScreen()),
      GoRoute(path: '/session/:id', builder: (_, state) => SessionScreen(sessionId: state.pathParameters['id']!)),
      GoRoute(path: '/session/:id/finish', builder: (_, state) => FinishScreen(sessionId: state.pathParameters['id']!)),
      GoRoute(path: '/exercises', builder: (_, __) => const ExerciseListScreen()),
      GoRoute(path: '/exercises/new', builder: (_, __) => const CreateExerciseScreen()),
      GoRoute(path: '/exercises/:id', builder: (_, state) => ExerciseDetailScreen(id: state.pathParameters['id']!)),
    ],
  );
});
```

Add imports for the new onboarding screens.

- [ ] **Step 2:** Commit.

```bash
git add apps/mobile/lib/core/routing/app_router.dart
git commit -m "feat(routing): gate behind onboarding completion"
```

---

## Task 3 — Mode picker screen

**Files:**
- Create: `apps/mobile/lib/features/onboarding/presentation/mode_picker_screen.dart`

- [ ] **Step 1:** Implement.

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ModePickerScreen extends StatelessWidget {
  const ModePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text('Welcome to Gimma',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              const Text('Tell me about your training.'),
              const SizedBox(height: 32),
              _ModeCard(
                icon: Icons.flag_outlined,
                title: 'Guided',
                subtitle:
                    'I want a plan to follow. Answer a few questions and start training today.',
                onTap: () => context.push('/onboarding/guided'),
              ),
              const SizedBox(height: 16),
              _ModeCard(
                icon: Icons.visibility_outlined,
                title: 'Observation',
                subtitle:
                    'Let me train my way for a couple weeks. Then AI proposes a plan based on what it sees.',
                onTap: () => context.push('/onboarding/observe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(subtitle),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2:** Commit.

```bash
git add apps/mobile/lib/features/onboarding/presentation/mode_picker_screen.dart
git commit -m "feat(onboarding): mode picker — Guided vs Observation"
```

---

## Task 4 — Guided Q&A wizard

**Files:**
- Create: `apps/mobile/lib/features/onboarding/presentation/guided_qa_screen.dart`

- [ ] **Step 1:** Implement a simple stepper form.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../plans/data/plan_api.dart';
import '../data/onboarding_repository.dart';

class _Answers {
  String goal = 'muscle';
  String experience = 'intermediate';
  int daysPerWeek = 4;
  int sessionLength = 60;
  String equipment = 'full gym';
  List<String> injuries = [];
  String styleNotes = '';
}

class GuidedQaScreen extends ConsumerStatefulWidget {
  const GuidedQaScreen({super.key});

  @override
  ConsumerState<GuidedQaScreen> createState() => _GuidedQaScreenState();
}

class _GuidedQaScreenState extends ConsumerState<GuidedQaScreen> {
  int _step = 0;
  final _answers = _Answers();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Widget _stepBody() {
    switch (_step) {
      case 0:
        return _RadioGroup(
          title: 'Goal',
          options: const [
            ('muscle', 'Muscle / hypertrophy'),
            ('strength', 'Strength'),
            ('fat_loss', 'Fat loss'),
            ('general', 'General fitness'),
          ],
          selected: _answers.goal,
          onChanged: (v) => setState(() => _answers.goal = v),
        );
      case 1:
        return _RadioGroup(
          title: 'Experience',
          options: const [
            ('beginner', 'Beginner (< 1 year)'),
            ('intermediate', 'Intermediate (1–3 years)'),
            ('advanced', 'Advanced (3+ years)'),
          ],
          selected: _answers.experience,
          onChanged: (v) => setState(() => _answers.experience = v),
        );
      case 2:
        return _IntSlider(
          title: 'Days per week',
          value: _answers.daysPerWeek,
          min: 2,
          max: 6,
          onChanged: (v) => setState(() => _answers.daysPerWeek = v),
        );
      case 3:
        return _IntSlider(
          title: 'Session length (minutes)',
          value: _answers.sessionLength,
          min: 30,
          max: 120,
          step: 15,
          onChanged: (v) => setState(() => _answers.sessionLength = v),
        );
      case 4:
        return _RadioGroup(
          title: 'Equipment',
          options: const [
            ('full gym', 'Full gym'),
            ('home + dumbbells', 'Home gym (dumbbells + bench)'),
            ('bodyweight', 'Bodyweight only'),
          ],
          selected: _answers.equipment,
          onChanged: (v) => setState(() => _answers.equipment = v),
        );
      case 5:
        return _MultiSelect(
          title: 'Injuries / limitations',
          options: const [
            ('knee_pain', 'Knee'),
            ('lower_back_pain', 'Lower back'),
            ('shoulder_pain', 'Shoulder'),
            ('wrist', 'Wrist'),
          ],
          selected: _answers.injuries.toSet(),
          onChanged: (s) => setState(() => _answers.injuries = s.toList()),
        );
      case 6:
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Style notes (optional)',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _notesCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'e.g. "I like high volume, hate cardio"',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => _answers.styleNotes = v,
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _finish() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final repo = OnboardingRepository(Supabase.instance.client);
    await repo.setMode(
      userId: userId,
      mode: 'guided',
      goal: _answers.goal,
      experienceLevel: _answers.experience,
    );
    if (mounted) context.go('/onboarding/generating');
    final api = PlanApi(Supabase.instance.client);
    try {
      await api.generatePlan(
        goal: _answers.goal,
        experienceLevel: _answers.experience,
        daysPerWeek: _answers.daysPerWeek,
        sessionLengthMinutes: _answers.sessionLength,
        equipment: _answers.equipment,
        injuries: _answers.injuries,
        styleNotes: _answers.styleNotes.isEmpty ? null : _answers.styleNotes,
      );
      await repo.markComplete(userId);
      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Plan generation failed: $e')),
        );
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const last = 6;
    return Scaffold(
      appBar: AppBar(
        title: Text('Step ${_step + 1} of ${last + 1}'),
      ),
      body: _stepBody(),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (_step > 0)
                OutlinedButton(
                  onPressed: () => setState(() => _step--),
                  child: const Text('Back'),
                ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  if (_step < last) {
                    setState(() => _step++);
                  } else {
                    _finish();
                  }
                },
                child: Text(_step < last ? 'Next' : 'Generate plan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioGroup extends StatelessWidget {
  const _RadioGroup({required this.title, required this.options, required this.selected, required this.onChanged});
  final String title;
  final List<(String, String)> options;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...options.map((o) => RadioListTile<String>(
              title: Text(o.$2),
              value: o.$1,
              groupValue: selected,
              onChanged: (v) => onChanged(v!),
            )),
      ],
    );
  }
}

class _IntSlider extends StatelessWidget {
  const _IntSlider({required this.title, required this.value, required this.min, required this.max, required this.onChanged, this.step = 1});
  final String title;
  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: $value', style: Theme.of(context).textTheme.titleMedium),
          Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: (max - min) ~/ step,
            onChanged: (v) => onChanged(v.round()),
          ),
        ],
      ),
    );
  }
}

class _MultiSelect extends StatelessWidget {
  const _MultiSelect({required this.title, required this.options, required this.selected, required this.onChanged});
  final String title;
  final List<(String, String)> options;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...options.map((o) => CheckboxListTile(
              title: Text(o.$2),
              value: selected.contains(o.$1),
              onChanged: (v) {
                final next = {...selected};
                if (v == true) next.add(o.$1); else next.remove(o.$1);
                onChanged(next);
              },
            )),
      ],
    );
  }
}
```

- [ ] **Step 2:** Commit.

```bash
git add apps/mobile/lib/features/onboarding/presentation/guided_qa_screen.dart
git commit -m "feat(onboarding): guided Q&A wizard → generate-plan"
```

---

## Task 5 — Generating plan placeholder screen

**Files:**
- Create: `apps/mobile/lib/features/onboarding/presentation/generating_plan_screen.dart`

- [ ] **Step 1:** Implement.

```dart
import 'package:flutter/material.dart';

class GeneratingPlanScreen extends StatelessWidget {
  const GeneratingPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 24),
              Text('Building your plan…',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'This takes a few seconds — your coach is reading your training history.',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2:** Commit.

```bash
git add apps/mobile/lib/features/onboarding/presentation/generating_plan_screen.dart
git commit -m "feat(onboarding): generating-plan loading screen"
```

---

## Task 6 — Observation Q&A screen

**Files:**
- Create: `apps/mobile/lib/features/onboarding/presentation/observe_qa_screen.dart`

- [ ] **Step 1:** Implement (simpler form).

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/onboarding_repository.dart';

class ObserveQaScreen extends ConsumerStatefulWidget {
  const ObserveQaScreen({super.key});

  @override
  ConsumerState<ObserveQaScreen> createState() => _ObserveQaScreenState();
}

class _ObserveQaScreenState extends ConsumerState<ObserveQaScreen> {
  String _goal = 'muscle';
  int _daysPerWeek = 4;
  String _equipment = 'full gym';

  Future<void> _finish() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final repo = OnboardingRepository(Supabase.instance.client);
    await repo.setMode(userId: userId, mode: 'observe', goal: _goal);
    await repo.markComplete(userId);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Observation mode')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Log your training for ~2 weeks. Once I\'ve seen enough, I\'ll propose a plan that respects what you\'ve been doing.',
          ),
          const SizedBox(height: 24),
          const Text('Goal', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: _goal,
            items: const [
              DropdownMenuItem(value: 'muscle', child: Text('Muscle')),
              DropdownMenuItem(value: 'strength', child: Text('Strength')),
              DropdownMenuItem(value: 'fat_loss', child: Text('Fat loss')),
              DropdownMenuItem(value: 'general', child: Text('General')),
            ],
            onChanged: (v) => setState(() => _goal = v!),
          ),
          const SizedBox(height: 16),
          const Text('Training days / week', style: TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: _daysPerWeek.toDouble(),
            min: 2, max: 6, divisions: 4,
            label: '$_daysPerWeek',
            onChanged: (v) => setState(() => _daysPerWeek = v.round()),
          ),
          const SizedBox(height: 16),
          const Text('Equipment', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: _equipment,
            items: const [
              DropdownMenuItem(value: 'full gym', child: Text('Full gym')),
              DropdownMenuItem(value: 'home + dumbbells', child: Text('Home + dumbbells')),
              DropdownMenuItem(value: 'bodyweight', child: Text('Bodyweight')),
            ],
            onChanged: (v) => setState(() => _equipment = v!),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _finish,
            child: const Text('Start free-logging'),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2:** Commit.

```bash
git add apps/mobile/lib/features/onboarding/presentation/observe_qa_screen.dart
git commit -m "feat(onboarding): observation-mode Q&A"
```

---

## Task 7 — Observation-mode home & "Ready for a plan?" prompt

**Files:**
- Modify: `apps/mobile/lib/features/home/presentation/home_screen.dart`
- Create: `apps/mobile/lib/features/onboarding/presentation/ready_for_plan_sheet.dart`

- [ ] **Step 1:** In `home_screen.dart`, if the user is in observation mode and the threshold is met, show a bottom sheet on mount.

```dart
// (inside HomeScreen.build — pseudocode to add)
final profileAsync = ref.watch(userProfileProvider);
profileAsync.whenData((p) async {
  if (p == null) return;
  if (p['onboarding_mode'] == 'observe' && p['has_active_plan'] != true) {
    final repo = OnboardingRepository(Supabase.instance.client);
    final days = await repo.daysSinceSignup(p['id'] as String);
    final sessions = await repo.loggedSessionCount(p['id'] as String);
    if (days >= 14 || sessions >= 8) {
      if (context.mounted) {
        showModalBottomSheet(
          context: context,
          builder: (_) => const ReadyForPlanSheet(),
        );
      }
    }
  }
});
```

(Refactor the exact wiring — use a `userProfileProvider` that fetches the users row and joins whether an active plan exists. Skipping full code here to keep this task focused.)

- [ ] **Step 2:** Implement the sheet.

Write `apps/mobile/lib/features/onboarding/presentation/ready_for_plan_sheet.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReadyForPlanSheet extends StatelessWidget {
  const ReadyForPlanSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Ready for a plan?',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'I\'ve seen enough of how you train. Want me to propose a plan that respects your pattern?',
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.push('/onboarding/guided?from=observe'),
              child: const Text('Yes — generate plan'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Not yet'),
            ),
          ],
        ),
      ),
    );
  }
}
```

Note: reuse the Guided Q&A flow for generation (the `?from=observe` query can be consumed if needed later).

- [ ] **Step 3:** Commit.

```bash
git add apps/mobile/lib/features/onboarding/presentation/ready_for_plan_sheet.dart \
        apps/mobile/lib/features/home/presentation/home_screen.dart
git commit -m "feat(onboarding): ready-for-plan prompt for observation mode"
```

---

## Task 8 — Mode-switching escape hatches

**Files:**
- Modify: `apps/mobile/lib/features/home/presentation/home_screen.dart`

- [ ] **Step 1:** Add a "Free train today" button (Guided mode) and "Generate plan now" button (Observation mode) to the home screen (conditionally rendered based on mode).

```dart
if (p['onboarding_mode'] == 'guided')
  TextButton(
    onPressed: () async {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final sessionId = await ref.read(sessionRepositoryProvider).startSession(
            userId: userId,
            planDayId: 'free-log', // or null — adjust schema allows nullable
            exerciseIds: const [], // empty — user will add mid-session in v1.5
          );
      if (context.mounted) context.push('/session/$sessionId');
    },
    child: const Text('Free train today'),
  ),
if (p['onboarding_mode'] == 'observe' && p['has_active_plan'] != true)
  FilledButton(
    onPressed: () => context.push('/onboarding/guided?from=observe'),
    child: const Text('Generate plan now'),
  ),
```

Note: `SessionRepository.startSession` currently requires `planDayId`; make it nullable:

```dart
Future<String> startSession({
  required String userId,
  String? planDayId,
  required List<String> exerciseIds,
}) async { /* ... */ }
```

And use `Value(planDayId)` instead of `Value(planDayId!)` in the insert.

- [ ] **Step 2:** Commit.

```bash
git add apps/mobile/lib/features/home apps/mobile/lib/features/sessions/data/session_repository.dart
git commit -m "feat(onboarding): mode-switching escape hatches on home"
```

---

## Plan 5 Definition of Done

- [ ] New user is routed to `/onboarding` on first launch
- [ ] Mode picker renders both options
- [ ] Guided flow submits and lands on a populated home screen with an active plan
- [ ] Observation flow marks onboarding complete and lands on free-log home
- [ ] After 14 days or 8 sessions (Observation), the "Ready for a plan?" sheet appears
- [ ] Both mode-switch escape-hatch buttons are visible when appropriate
- [ ] `onboarding_completed_at` is populated after either flow finishes

---

## Deferred

- **Query-param-driven pre-fill for observation-to-guided** (using previously observed patterns as Q&A defaults) — v1.5 polish.
- **Skipping generation if it fails** — currently errors return to mode picker; a retry UI is v1.5.
- **Editing onboarding answers later** — out of v1.
