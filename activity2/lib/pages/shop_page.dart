import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/catalog.dart';
import '../providers/activity_providers.dart';

class ShopPage extends ConsumerStatefulWidget {
  const ShopPage({super.key});

  @override
  ConsumerState<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends ConsumerState<ShopPage> {
  RangeValues? _draftRange;

  Future<void> _refresh() async {
    ref.invalidate(maximumPriceProvider);
    ref.invalidate(paginatedProductsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final maximumPrice = ref.watch(maximumPriceProvider);
    final products = ref.watch(paginatedProductsProvider);
    final selectedRange = ref.watch(selectedPriceRangeProvider);
    final page = ref.watch(currentPageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ShopHub'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: maximumPrice.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _LoadError(
          message: 'Could not load product prices: $error',
          onRetry: _refresh,
        ),
        data: (rawMaximum) {
          final sliderMaximum = rawMaximum > 0 ? rawMaximum : 1.0;
          final committedRange = selectedRange ?? RangeValues(0, sliderMaximum);
          final clampedStart = committedRange.start
              .clamp(0, sliderMaximum)
              .toDouble();
          final clampedEnd = committedRange.end
              .clamp(clampedStart, sliderMaximum)
              .toDouble();
          final visibleRange =
              _draftRange ?? RangeValues(clampedStart, clampedEnd);
          return Column(
            children: [
              Card(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Filter by price',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() => _draftRange = null);
                              ref
                                      .read(selectedPriceRangeProvider.notifier)
                                      .state =
                                  null;
                              ref.read(currentPageProvider.notifier).state = 0;
                            },
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                      RangeSlider(
                        min: 0,
                        max: sliderMaximum,
                        divisions: 20,
                        labels: RangeLabels(
                          '₱${visibleRange.start.toStringAsFixed(0)}',
                          '₱${visibleRange.end.toStringAsFixed(0)}',
                        ),
                        values: visibleRange,
                        onChanged: (value) =>
                            setState(() => _draftRange = value),
                        onChangeEnd: (value) {
                          ref.read(selectedPriceRangeProvider.notifier).state =
                              value;
                          ref.read(currentPageProvider.notifier).state = 0;
                          setState(() => _draftRange = null);
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('₱${visibleRange.start.toStringAsFixed(2)}'),
                          Text('₱${visibleRange.end.toStringAsFixed(2)}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: products.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => _LoadError(
                    message: 'Could not load products: $error',
                    onRetry: () => ref.invalidate(paginatedProductsProvider),
                  ),
                  data: (result) {
                    if (result.items.isEmpty) {
                      return const Center(
                        child: Text('No products in this price range.'),
                      );
                    }
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth >= 1000
                            ? 4
                            : constraints.maxWidth >= 650
                            ? 3
                            : 2;
                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                mainAxisExtent: 270,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: result.items.length,
                          itemBuilder: (context, index) =>
                              _ProductCard(product: result.items[index]),
                        );
                      },
                    );
                  },
                ),
              ),
              products.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const SizedBox(height: 4),
                data: (result) => _PaginationBar(
                  page: page,
                  pageCount: (result.totalCount / productsPerPage).ceil().clamp(
                    1,
                    1 << 31,
                  ),
                  totalCount: result.totalCount,
                  onPrevious: page == 0
                      ? null
                      : () => ref.read(currentPageProvider.notifier).state--,
                  onNext: (page + 1) * productsPerPage >= result.totalCount
                      ? null
                      : () => ref.read(currentPageProvider.notifier).state++,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: product.imageUrl == null
                ? const ColoredBox(
                    color: Color(0xFFEDE7F6),
                    child: Center(
                      child: Icon(Icons.checkroom_outlined, size: 52),
                    ),
                  )
                : Image.network(
                    product.imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const ColoredBox(
                      color: Color(0xFFEDE7F6),
                      child: Center(
                        child: Icon(Icons.broken_image_outlined, size: 40),
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '₱${product.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (product.description.isNotEmpty)
                  Text(
                    product.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.page,
    required this.pageCount,
    required this.totalCount,
    required this.onPrevious,
    required this.onNext,
  });

  final int page;
  final int pageCount;
  final int totalCount;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: 'Previous page',
              onPressed: onPrevious,
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              totalCount == 0
                  ? 'No products'
                  : 'Page ${page + 1} of $pageCount  •  $totalCount products',
            ),
            IconButton(
              tooltip: 'Next page',
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
