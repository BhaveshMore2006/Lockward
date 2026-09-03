import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../controllers/profile_page_controller.dart';

class ProfilePageView extends GetView<ProfilePageController> {
  const ProfilePageView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final user = authService.currentUser.value;
    final userName = user?.displayName ?? 'Steve Smith';
    final userEmailOrPhone = user?.email ?? '8758066XXX';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Colors.black, size: 30),
            onPressed: () => Get.toNamed(Routes.NEW_RECORD),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          const SizedBox(height: 10),
          // User Avatar & Info
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF10B981), width: 2.5),
                  ),
                  child: const CircleAvatar(
                    radius: 36,
                    backgroundColor: Color(0xFFF3E8FF),
                    child: Text(
                      '👨‍💼',
                      style: TextStyle(fontSize: 36),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmailOrPhone,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    Get.snackbar('Profile', 'Profile editing coming soon',
                        snackPosition: SnackPosition.BOTTOM);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    minimumSize: const Size(0, 32),
                    side: const BorderSide(color: Colors.black12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text(
                    'Edit profile',
                    style: TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // Options List
          _buildActionTile(
            title: 'Switch account',
            trailingWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Steve's team",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black45, size: 18),
              ],
            ),
            onTap: () {},
          ),
          const Divider(height: 24, color: Colors.black12),

          _buildActionTile(
            title: 'Security',
            trailingWidget: const Icon(Icons.chevron_right_rounded, color: Colors.black26, size: 24),
            onTap: () {},
          ),
          const Divider(height: 24, color: Colors.black12),

          _buildActionTile(
            title: 'Trusted devices',
            trailingWidget: const Icon(Icons.chevron_right_rounded, color: Colors.black26, size: 24),
            onTap: () {},
          ),
          const Divider(height: 24, color: Colors.black12),

          _buildActionTile(
            title: 'Backup',
            trailingWidget: const Icon(Icons.chevron_right_rounded, color: Colors.black26, size: 24),
            onTap: () {},
          ),
          const Divider(height: 24, color: Colors.black12),

          const SizedBox(height: 48),

          // Logout Button
          Center(
            child: SizedBox(
              width: 140,
              child: OutlinedButton(
                onPressed: () async {
                  await authService.logout();
                  Get.offAllNamed(Routes.LOGIN);
                  Get.snackbar('Logged out', 'You have been logged out safely',
                      snackPosition: SnackPosition.BOTTOM);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text(
                  'logout',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required Widget trailingWidget,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            trailingWidget,
          ],
        ),
      ),
    );
  }
}
