import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://pvydgdervayxjrtkstgp.supabase.co',
    publishableKey: 'sb_publishable_KLzFS5t4kGNWVN9sWuaAjw_87aLe11T',
  );
  runApp(const ProviderScope(child: ActivityApp()));
}
