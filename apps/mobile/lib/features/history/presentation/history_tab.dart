import 'package:flutter/material.dart';

import '../../exercises/presentation/widgets/sync_status_pill.dart';
import 'history_screen.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: const [
          Padding(padding: EdgeInsets.all(8), child: SyncStatusPill()),
        ],
      ),
      body: const HistoryScreen(),
    );
  }
}
