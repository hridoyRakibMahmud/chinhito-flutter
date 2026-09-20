import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _BottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData(this.icon, this.activeIcon, this.label);
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

const _navItems = [
  _NavItemData(Icons.explore_outlined, Icons.explore, 'Explore'),
  _NavItemData(Icons.forum_outlined, Icons.forum, 'Feed'),
  _NavItemData(Icons.check_circle_outline, Icons.check_circle, 'Visited'),
  _NavItemData(Icons.person_outline, Icons.person, 'Profile'),
];

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        border: Border(top: BorderSide(color: AppColors.charcoal.withValues(alpha: 0.06))),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < _navItems.length; i++)
                _NavItem(
                  data: _navItems[i],
                  selected: currentIndex == i,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.data, required this.selected, required this.onTap});

  final _NavItemData data;
  final bool selected;
  final VoidCallback onTap;

  static const _inactiveColor = Color(0xFF8A8A8A);
  static const _activeBg = Color(0xFFE4EEED);

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.teal : _inactiveColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? _activeBg : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(selected ? data.activeIcon : data.icon, size: 22, color: color),
            ),
            const SizedBox(height: 4),
            Text(data.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}
