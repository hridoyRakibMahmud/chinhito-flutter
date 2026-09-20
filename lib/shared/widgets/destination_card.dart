import 'package:flutter/material.dart';

import '../models/destination.dart';
import '../theme/app_theme.dart';

/// Tonal card for a destination summary — no real photos in the schema yet,
/// so the thumbnail is a category-tinted icon placeholder.
class DestinationCard extends StatelessWidget {
  const DestinationCard({super.key, required this.destination, required this.onTap});

  final Destination destination;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.charcoal.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CategoryThumbnail(category: destination.category),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CategoryPill(category: destination.category),
                      const SizedBox(height: 6),
                      Text(
                        destination.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${destination.districtName} · ★ ${destination.rating.toStringAsFixed(1)}',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF8A8A8A)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryThumbnail extends StatelessWidget {
  const _CategoryThumbnail({required this.category});

  final DestinationCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.12),
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
      ),
      child: Icon(categoryIcon(category), color: AppColors.teal, size: 32),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.category});

  final DestinationCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: const Color(0xFFE4EEED), borderRadius: BorderRadius.circular(20)),
      child: Text(
        category.name,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.teal),
      ),
    );
  }
}

IconData categoryIcon(DestinationCategory category) {
  switch (category) {
    case DestinationCategory.beach:
      return Icons.beach_access;
    case DestinationCategory.hill:
      return Icons.terrain;
    case DestinationCategory.forest:
      return Icons.forest;
    case DestinationCategory.historical:
      return Icons.account_balance;
    case DestinationCategory.religious:
      return Icons.mosque;
    case DestinationCategory.waterfall:
      return Icons.water;
    case DestinationCategory.lake:
      return Icons.water_drop;
    case DestinationCategory.island:
      return Icons.landscape;
    case DestinationCategory.archaeological:
      return Icons.temple_hindu;
    case DestinationCategory.other:
      return Icons.place;
  }
}
