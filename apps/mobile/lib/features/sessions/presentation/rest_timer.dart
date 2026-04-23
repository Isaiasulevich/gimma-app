import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

const _gap = 12.0;

class RestTimer extends StatefulWidget {
  const RestTimer({
    required this.durationSeconds,
    required this.onFinished,
    super.key,
  });

  final int durationSeconds;
  final VoidCallback onFinished;

  @override
  State<RestTimer> createState() => _RestTimerState();
}

class _RestTimerState extends State<RestTimer> {
  late int _remaining;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _remaining = widget.durationSeconds;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= 0) {
        _ticker?.cancel();
        unawaited(_notifyEnd());
        widget.onFinished();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  Future<void> _notifyEnd() async {
    final hasVib = await Vibration.hasVibrator();
    if (hasVib) {
      await Vibration.vibrate(duration: 500);
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String get _display {
    final m = (_remaining ~/ 60).toString();
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _display,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: _gap / 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () => setState(() => _remaining += 30),
              child: const Text('+30s'),
            ),
            const SizedBox(width: _gap),
            OutlinedButton(
              onPressed: () {
                _ticker?.cancel();
                widget.onFinished();
              },
              child: const Text('Skip rest'),
            ),
          ],
        ),
      ],
    );
  }
}
