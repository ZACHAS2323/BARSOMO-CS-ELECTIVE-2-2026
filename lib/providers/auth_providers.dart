import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sessionProvider = StreamProvider<Session?>((ref) {
  final auth = Supabase.instance.client.auth;
  return Stream<Session?>.multi((controller) {
    controller.add(auth.currentSession);
    final subscription = auth.onAuthStateChange
        .map((event) => event.session)
        .listen(controller.add, onError: controller.addError);
    controller.onCancel = () async => subscription.cancel();
  });
});
