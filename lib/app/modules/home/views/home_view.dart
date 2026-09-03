import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'tabs/passwords_tab_view.dart';
import 'tabs/analysis_tab_view.dart';
import 'tabs/search_tab_view.dart';
import 'tabs/settings_tab_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    const tabs = [
      PasswordsTabView(),
      AnalysisTabView(),
      SearchTabView(),
      SettingsTabView(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(
        () => IndexedStack(
          index: controller.currentTabIndex.value,
          children: tabs,
        ),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.black.withValues(alpha: 0.08), width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomNavItem(
                    index: 0,
                    label: 'HOME',
                    activeIcon: Icons.home_rounded,
                    inactiveIcon: Icons.home_outlined,
                  ),
                  _buildBottomNavItem(
                    index: 1,
                    label: 'ANALYSIS',
                    activeIcon: Icons.donut_large_rounded,
                    inactiveIcon: Icons.donut_large_outlined,
                  ),
                  _buildBottomNavItem(
                    index: 2,
                    label: 'SEARCH',
                    activeIcon: Icons.search_rounded,
                    inactiveIcon: Icons.search_outlined,
                  ),
                  _buildBottomNavItem(
                    index: 3,
                    label: 'SETTING',
                    activeIcon: Icons.settings_rounded,
                    inactiveIcon: Icons.settings_outlined,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required int index,
    required String label,
    required IconData activeIcon,
    required IconData inactiveIcon,
  }) {
    final isSelected = controller.currentTabIndex.value == index;
    final color = isSelected ? Colors.black87 : Colors.black38;

    return InkWell(
      onTap: () => controller.changeTab(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
