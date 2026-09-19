import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/supabase_provider.dart';

/// Placeholder — wired to real Supabase data + geo_drilldown in step 2.
class MapExploreScreen extends ConsumerWidget {
  const MapExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSignedIn = ref.watch(isSignedInProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('চিহ্নিত'),
        actions: [
          IconButton(
            icon: Icon(isSignedIn ? Icons.person : Icons.login),
            onPressed: () => context.push(isSignedIn ? '/profile' : '/sign-in'),
          ),
        ],
      ),
      body: const Center(child: Text('Map explore — coming in step 2')),
    );
  }
}
