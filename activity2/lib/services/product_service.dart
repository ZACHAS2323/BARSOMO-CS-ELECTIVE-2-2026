import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/catalog.dart';

class ProductService {
  ProductService(this._client);

  final SupabaseClient _client;

  Future<double> maximumPrice() async {
    final row = await _client
        .from('products')
        .select('price')
        .order('price', ascending: false)
        .limit(1)
        .maybeSingle();
    if (row == null) return 1;
    final price = (row['price'] as num).toDouble();
    return price > 0 ? price : 1;
  }

  Future<PaginatedProducts> products({
    required double minimumPrice,
    required double maximumPrice,
    required int page,
  }) async {
    final range = pageRange(page);
    final response = await _client
        .from('products')
        .select('id,name,description,price,image_url')
        .gte('price', minimumPrice)
        .lte('price', maximumPrice)
        .order('name')
        .range(range.start, range.end)
        .count(CountOption.exact);

    return PaginatedProducts(
      items: response.data
          .map<Product>(
            (row) => Product.fromMap(Map<String, dynamic>.from(row)),
          )
          .toList(),
      totalCount: response.count,
    );
  }
}
