import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/destinations_provider.dart';
import '../application/feed_controller.dart';

class ComposeScreen extends ConsumerStatefulWidget {
  const ComposeScreen({super.key});

  @override
  ConsumerState<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends ConsumerState<ComposeScreen> {
  final _controller = TextEditingController();
  String? _destinationId;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final destinationsAsync = ref.watch(publishedDestinationsProvider);
    final posting = ref.watch(feedControllerProvider).isLoading;
    final canPost = _controller.text.trim().isNotEmpty && !posting;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('New post'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: FilledButton(
                onPressed: canPost ? _submit : null,
                child: posting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Post'),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              maxLines: 6,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Share your experience — what did you see, what should other travelers know?',
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'TAG A PLACE (OPTIONAL)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF6b6b6b)),
            ),
            const SizedBox(height: 8),
            destinationsAsync.when(
              data: (destinations) => DropdownButtonFormField<String?>(
                initialValue: _destinationId,
                items: [
                  const DropdownMenuItem(value: null, child: Text('No place tag')),
                  ...destinations.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))),
                ],
                onChanged: (value) => setState(() => _destinationId = value),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (error, stackTrace) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    await ref.read(feedControllerProvider.notifier).createPost(body: text, destinationId: _destinationId);
    if (mounted) context.pop();
  }
}
