import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/providers/supabase_provider.dart';

part 'visited_places_repository.g.dart';

class VisitedPlacesRepository {
  VisitedPlacesRepository(this._client);

  final SupabaseClient _client;

  Future<Set<String>> fetchVisitedDestinationIds(String userId) async {
    final rows = await _client
        .from('visited_places')
        .select('destination_id')
        .eq('user_id', userId);
    return rows.map((row) => row['destination_id'] as String).toSet();
  }

  Future<void> markVisited(String userId, String destinationId) {
    return _client.from('visited_places').insert({
      'user_id': userId,
      'destination_id': destinationId,
    });
  }

  Future<void> unmarkVisited(String userId, String destinationId) {
    return _client
        .from('visited_places')
        .delete()
        .eq('user_id', userId)
        .eq('destination_id', destinationId);
  }
}

@riverpod
VisitedPlacesRepository visitedPlacesRepository(Ref ref) {
  return VisitedPlacesRepository(ref.watch(supabaseClientProvider));
}

@riverpod
Future<Set<String>> visitedDestinationIds(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const {};
  return ref.watch(visitedPlacesRepositoryProvider).fetchVisitedDestinationIds(user.id);
}
