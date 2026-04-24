import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _gap = 16.0;

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
              const SizedBox(height: _gap * 1.5),
              Text(
                'Welcome to Gimma',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: _gap / 2),
              Text(
                'Tell me about your training.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: _gap * 2),
              _ModeCard(
                icon: Icons.flag_outlined,
                title: 'Guided',
                subtitle:
                    'I want a plan to follow. Answer a few questions and start training today.',
                onTap: () => context.push('/onboarding/guided'),
              ),
              const SizedBox(height: _gap),
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
              const SizedBox(width: _gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: _gap / 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
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
