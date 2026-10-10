import 'package:flutter/material.dart';

/// Wraps [child] in [RefreshIndicator] so pull-to-refresh works even when
/// the content doesn't naturally scroll (a loading/empty/error state, or a
/// fixed layout with a `Spacer`) — `SliverFillRemaining` gives it bounded
/// height so `Spacer`/`Expanded` inside still work, while
/// `AlwaysScrollableScrollPhysics` lets the pull gesture register even when
/// there's nothing to actually scroll.
class RefreshableScroll extends StatelessWidget {
  const RefreshableScroll({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [SliverFillRemaining(hasScrollBody: false, child: child)],
      ),
    );
  }
}
