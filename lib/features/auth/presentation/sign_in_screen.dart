import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/supabase_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../application/auth_controller.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key, this.reason});

  /// Context-specific copy for why sign-in was requested (e.g. from a
  /// "mark visited" or "post" action). Falls back to a generic message.
  final String? reason;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerState = ref.watch(authControllerProvider);
    final isLoading = controllerState.isLoading;

    ref.listen(isSignedInProvider, (previous, next) {
      if (next && context.mounted && context.canPop()) context.pop();
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.explore, size: 72, color: AppColors.teal),
                const SizedBox(height: 16),
                Text('চিহ্নিত', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  reason ?? 'Sign in to mark places visited and share your journey.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                if (controllerState.hasError)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Sign-in failed. Please try again.',
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => ref
                            .read(authControllerProvider.notifier)
                            .signInWithGoogle(),
                    icon: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.g_mobiledata, size: 24),
                    label: const Text('Continue with Google'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
