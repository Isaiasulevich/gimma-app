import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app.dart';
import 'config/env.dart';
import 'config/supabase_bootstrap.dart';
import 'core/db/app_database.dart';
import 'features/exercises/data/seed_loader.dart';

Future<void> _runApp() async {
  final db = AppDatabase();
  await loadSeedIfEmpty(db);
  await db.close();
  runApp(const ProviderScope(child: GimmaApp()));
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.load();
  await initSupabase();

  final dsn = dotenv.env['SENTRY_DSN_FLUTTER'];
  if (dsn == null || dsn.isEmpty) {
    await _runApp();
    return;
  }

  await SentryFlutter.init(
    (options) {
      options.dsn = dsn;
      options.tracesSampleRate = 0.2;
    },
    appRunner: _runApp,
  );
}
