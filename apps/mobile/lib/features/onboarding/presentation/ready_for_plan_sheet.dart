import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _gap = 16.0;

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
            Text(
              'Ready for a plan?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: _gap / 2),
            Text(
              'I\'ve seen enough of how you train. Want me to propose a plan that respects your pattern?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: _gap * 1.5),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.push('/onboarding/guided');
              },
              child: const Text('Yes — generate plan'),
            ),
            const SizedBox(height: _gap / 2),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Not yet'),
            ),
          ],
        ),
      ),
    );
  }
}
