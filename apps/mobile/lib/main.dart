import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'config/env.dart';
import 'config/supabase_bootstrap.dart';
import 'core/db/app_database.dart';
import 'features/exercises/data/seed_loader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.load();
  await initSupabase();

  final db = AppDatabase();
  await loadSeedIfEmpty(db);
  await db.close();

  runApp(const ProviderScope(child: GimmaApp()));
}
