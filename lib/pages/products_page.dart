import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/shop_providers.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  RangeValues? _draftPriceRange;

  Future<void> _refresh() async {
    ref.invalidate(categoriesProvider);
    ref.invalidate(maximumProductPriceProvider);
    ref.invalidate(paginatedProductsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final maximumPrice = ref.watch(maximumProductPriceProvider);
    final products = ref.watch(paginatedProductsProvider);
    final cart = ref.watch(cartProvider);
    final selectedCategory = ref.watch(categoryFilterProvider);
    final selectedRange = ref.watch(selectedPriceRangeProvider);
    final page = ref.watch(currentProductPageProvider);

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search products',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              ref.read(currentProductPageProvider.notifier).state = 0;
              ref.read(searchProvider.notifier).state = value;
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: categories.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('Categories unavailable: $error'),
              data: (items) => ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('All'),
                      selected: selectedCategory == null,
                      onSelected: (_) {
                        ref.read(currentProductPageProvider.notifier).state = 0;
                        ref.read(categoryFilterProvider.notifier).state = null;
                      },
                    ),
                  ),
                  ...items.map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category.name),
                        selected: selectedCategory == category.id,
                        onSelected: (_) {
                          ref.read(currentProductPageProvider.notifier).state =
                              0;
                          ref.read(categoryFilterProvider.notifier).state =
                              category.id;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          maximumPrice.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text('Price filter unavailable: $error'),
            data: (rawMaximum) {
              final sliderMaximum = rawMaximum > 0 ? rawMaximum : 1.0;
              final committedRange =
                  selectedRange ?? RangeValues(0, sliderMaximum);
              final minimum = committedRange.start
                  .clamp(0.0, sliderMaximum)
                  .toDouble();
              final maximum = committedRange.end
                  .clamp(minimum, sliderMaximum)
                  .toDouble();
              final visibleRange =
                  _draftPriceRange ?? RangeValues(minimum, maximum);

              return Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Filter by price',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              ref
                                      .read(currentProductPageProvider.notifier)
                                      .state =
                                  0;
                              ref
                                      .read(selectedPriceRangeProvider.notifier)
                                      .state =
                                  null;
                              setState(() => _draftPriceRange = null);
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
                            setState(() => _draftPriceRange = value),
                        onChangeEnd: (value) {
                          ref.read(currentProductPageProvider.notifier).state =
                              0;
                          ref.read(selectedPriceRangeProvider.notifier).state =
                              value;
                          setState(() => _draftPriceRange = null);
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
              );
            },
          ),
          const SizedBox(height: 12),
          products.when(
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Text('Could not load products: $error'),
            data: (result) {
              if (result.items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 32, bottom: 16),
                  child: Center(child: Text('No products match your filters.')),
                );
              }
              return Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 280,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: result.items.length,
                    itemBuilder: (context, index) {
                      final product = result.items[index];
                      final inCart = cart.where(
                        (item) => item.product.id == product.id,
                      );
                      final quantity = inCart.isEmpty
                          ? 0
                          : inCart.first.quantity;
                      return _ProductCard(
                        product: product,
                        cartQuantity: quantity,
                      );
                    },
                  ),
                  _PaginationBar(
                    page: page,
                    totalCount: result.totalCount,
                    onPrevious: page == 0
                        ? null
                        : () => ref
                              .read(currentProductPageProvider.notifier)
                              .state--,
                    onNext: (page + 1) * productsPerPage >= result.totalCount
                        ? null
                        : () => ref
                              .read(currentProductPageProvider.notifier)
                              .state++,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  const _ProductCard({required this.product, required this.cartQuantity});

  final ProductModel product;
  final int cartQuantity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final atStockLimit = cartQuantity >= product.stock;
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
                      child: Icon(Icons.shopping_bag_outlined, size: 48),
                    ),
                  )
                : Image.network(
                    product.imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const Center(child: Icon(Icons.broken_image_outlined)),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text('₱${product.price.toStringAsFixed(2)}'),
                Text(
                  '${product.stock} in stock',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: product.stock == 0 || atStockLimit
                        ? null
                        : () => ref.read(cartProvider.notifier).add(product),
                    child: Text(
                      product.stock == 0
                          ? 'Out of stock'
                          : atStockLimit
                          ? 'Stock limit'
                          : 'Add to cart',
                    ),
                  ),
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
    required this.totalCount,
    required this.onPrevious,
    required this.onNext,
  });

  final int page;
  final int totalCount;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final pageCount = (totalCount + productsPerPage - 1) ~/ productsPerPage;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
                : 'Page ${page + 1} of $pageCount ($totalCount products)',
          ),
          IconButton(
            tooltip: 'Next page',
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
