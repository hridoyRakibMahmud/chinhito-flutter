import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:chinhito/main.dart';
import 'package:chinhito/shared/providers/supabase_provider.dart';

void main() {
  testWidgets('App boots to the map explore screen', (tester) async {
    // A directly-constructed client never touches Supabase.initialize's
    // session-recovery/auto-refresh machinery, so the widget tree builds
    // with zero network activity — no host needed at all.
    // autoRefreshToken: false — GoTrueClient otherwise starts a periodic Timer
    // on construction that outlives the widget tree and fails the test binding's
    // pending-timer check.
    final client = SupabaseClient(
      'http://127.0.0.1',
      'test-anon-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [supabaseClientProvider.overrideWithValue(client)],
        child: const ChinhitoApp(),
      ),
    );
    await tester.pump();

    expect(find.text('চিহ্নিত'), findsOneWidget);
  });
}
