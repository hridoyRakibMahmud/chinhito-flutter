import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/destination.dart';
import 'supabase_provider.dart';

part 'destinations_provider.g.dart';

/// Shared across map_explore (map pins) and destination_detail (single lookup
/// + district progress) — cheap to fetch the whole published set once and
/// derive per-screen views from it rather than adding a fetch-by-slug query.
class DestinationsRepository {
  DestinationsRepository(this._client);

  final SupabaseClient _client;

  Future<List<Destination>> fetchPublished() async {
    final rows = await _client
        .from('destinations')
        .select('*, districts!inner(name, geojson_id, divisions!inner(name))')
        .eq('is_published', true);
    return rows.map(Destination.fromMap).toList();
  }
}

@riverpod
DestinationsRepository destinationsRepository(Ref ref) {
  return DestinationsRepository(ref.watch(supabaseClientProvider));
}

@riverpod
Future<List<Destination>> publishedDestinations(Ref ref) {
  return ref.watch(destinationsRepositoryProvider).fetchPublished();
}
