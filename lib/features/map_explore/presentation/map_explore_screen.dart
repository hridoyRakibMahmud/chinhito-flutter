import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geo_drilldown/geo_drilldown.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/destinations_provider.dart';
import '../../../shared/theme/app_theme.dart';

const _levels = [
  MapLevelConfig(
    levelId: 'division',
    source: AssetGeoJsonSource('assets/geo/bd_divisions.geojson'),
    idProperty: 'adm1_pcode',
    nameProperty: 'adm1_name',
  ),
  MapLevelConfig(
    levelId: 'district',
    source: AssetGeoJsonSource('assets/geo/bd_districts.geojson'),
    idProperty: 'adm2_pcode',
    nameProperty: 'adm2_name',
    parentIdProperty: 'adm1_pcode',
  ),
];

/// Created once and reused for the widget's lifetime so its per-hue-family
/// color cache stays consistent across rebuilds (see package docs).
final _colorScheme = HierarchicalColorScheme();

class MapExploreScreen extends ConsumerWidget {
  const MapExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destinationsAsync = ref.watch(publishedDestinationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('চিহ্নিত')),
      body: destinationsAsync.when(
        data: (destinations) => DrillDownMap(
          style: MapStyle(
            regionColorBuilder: _colorScheme.call,
            backgroundColor: AppColors.offWhite,
            regionBorderColor: AppColors.charcoal,
            pointColor: AppColors.terracotta,
          ),
          levels: _levels,
          pointsConfig: MapPointsConfig(
            source: RawGeoJsonSource(
              destinations.map((d) => d.toMapPoint()).toList(),
            ),
          ),
          onPointTap: (point) => context.push('/destinations/${point.data['slug']}'),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Failed to load destinations:\n$error', textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}
