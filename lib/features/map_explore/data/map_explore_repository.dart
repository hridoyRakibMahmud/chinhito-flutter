import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/models/destination.dart';
import '../../../shared/providers/supabase_provider.dart';

part 'map_explore_repository.g.dart';

class MapExploreRepository {
  MapExploreRepository(this._client);

  final SupabaseClient _client;

  /// Published destinations, each carrying its enclosing district's
  /// `geojson_id` so the map can slot it under the right district polygon.
  Future<List<Destination>> fetchPublishedDestinations() async {
    final rows = await _client
        .from('destinations')
        .select('*, districts!inner(geojson_id)')
        .eq('is_published', true);
    return rows.map(Destination.fromMap).toList();
  }
}

@riverpod
MapExploreRepository mapExploreRepository(Ref ref) {
  return MapExploreRepository(ref.watch(supabaseClientProvider));
}

@riverpod
Future<List<Destination>> publishedDestinations(Ref ref) {
  return ref.watch(mapExploreRepositoryProvider).fetchPublishedDestinations();
}
