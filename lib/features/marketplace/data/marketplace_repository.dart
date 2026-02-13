import 'dart:async';
import 'package:eduquest/features/marketplace/domain/marketplace_item.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/cache_policy.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MarketplaceRepository {
  final _local = LocalJsonCache();
  static final Map<String, List<MarketplaceItem>> _mem = {};

  Future<List<MarketplaceItem>> search({
    String? query,
    String? type,
    int limit = 40,
  }) async {
    final q = (query ?? '').trim();
    final key = 'market:$q:${type ?? 'all'}:$limit';
    final mem = _mem[key];
    if (mem != null) {
      if (Env.hasSupabase &&
          !await _local.isFresh(key, CachePolicy.marketplaceSearch)) {
        unawaited(_refresh(key: key, q: q, type: type, limit: limit));
      }
      return mem;
    }
    final local = await _fromLocal(key);
    if (local.isNotEmpty) {
      _mem[key] = local;
      if (Env.hasSupabase &&
          !await _local.isFresh(key, CachePolicy.marketplaceSearch)) {
        unawaited(_refresh(key: key, q: q, type: type, limit: limit));
      }
      return local;
    }
    if (!Env.hasSupabase) return const [];
    final fresh = await _refresh(key: key, q: q, type: type, limit: limit);
    return fresh ?? local;
  }

  Future<List<MarketplaceItem>?> _refresh({
    required String key,
    required String q,
    required String? type,
    required int limit,
  }) async {
    try {
      final rows = await Supabase.instance.client.rpc(
        'search_marketplace_items',
        params: {
          'p_query': q.isEmpty ? null : q,
          'p_item_type': type,
          'p_limit': limit,
        },
      );
      final out = (rows as List)
          .map(
            (e) => MarketplaceItem(
              id: '${e['id']}',
              title: '${e['title']}',
              type: '${e['item_type']}',
              priceLabel: e['price_label']?.toString(),
              url: '${e['external_checkout_url']}',
            ),
          )
          .toList();
      await _local.writeList(
        key,
        out
            .map(
              (e) => {
                'id': e.id,
                'title': e.title,
                'type': e.type,
                'priceLabel': e.priceLabel,
                'url': e.url,
              },
            )
            .toList(),
      );
      _mem[key] = out;
      return out;
    } catch (_) {
      return null;
    }
  }

  Future<List<MarketplaceItem>> _fromLocal(String key) async {
    final rows = await _local.readList(key);
    if (rows == null) return const [];
    return rows
        .map(
          (e) => MarketplaceItem(
            id: '${e['id']}',
            title: '${e['title']}',
            type: '${e['type']}',
            priceLabel: e['priceLabel']?.toString(),
            url: '${e['url']}',
          ),
        )
        .toList();
  }
}
