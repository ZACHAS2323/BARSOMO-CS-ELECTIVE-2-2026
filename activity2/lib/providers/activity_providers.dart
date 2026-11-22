import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/catalog.dart';
import '../services/product_service.dart';

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

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService(Supabase.instance.client);
});

final maximumPriceProvider = FutureProvider<double>((ref) {
  return ref.watch(productServiceProvider).maximumPrice();
});

final selectedPriceRangeProvider = StateProvider<RangeValues?>((ref) => null);
final currentPageProvider = StateProvider<int>((ref) => 0);

final paginatedProductsProvider = FutureProvider<PaginatedProducts>((
  ref,
) async {
  final rawMaximum = await ref.watch(maximumPriceProvider.future);
  final sliderMaximum = rawMaximum > 0 ? rawMaximum : 1.0;
  final selectedRange = ref.watch(selectedPriceRangeProvider);
  final range = selectedRange ?? RangeValues(0, sliderMaximum);
  final minimum = range.start.clamp(0.0, sliderMaximum).toDouble();
  final maximum = range.end.clamp(minimum, sliderMaximum).toDouble();
  final page = ref.watch(currentPageProvider);

  return ref
      .watch(productServiceProvider)
      .products(minimumPrice: minimum, maximumPrice: maximum, page: page);
});
