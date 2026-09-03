import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/vault_item.dart';
import '../../controllers/home_controller.dart';

class PasswordsTabView extends GetView<HomeController> {
  const PasswordsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black12, width: 1.2),
            ),
            child: const Icon(Icons.person_outline_rounded, color: Colors.black87, size: 22),
          ),
          onPressed: controller.navigateToProfile,
        ),
        centerTitle: true,
        title: const Text(
          'Passwords',
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
            onPressed: controller.navigateToNewRecord,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        final items = controller.vaultService.items;

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline_rounded, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No passwords yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: controller.navigateToNewRecord,
                  child: const Text('Add your first record'),
                ),
              ],
            ),
          );
        }

        // Group by category
        final priorityItems = items.where((i) => i.category.toLowerCase() == 'priority').toList();
        final entertainmentItems = items.where((i) => i.category.toLowerCase() == 'entertainment').toList();
        final workItems = items.where((i) => i.category.toLowerCase() == 'work').toList();
        final otherItems = items.where((i) {
          final c = i.category.toLowerCase();
          return c != 'priority' && c != 'entertainment' && c != 'work';
        }).toList();

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            if (priorityItems.isNotEmpty) ...[
              _buildCategoryHeader('Priority'),
              ...priorityItems.map((item) => _buildPasswordTile(item)),
              const SizedBox(height: 16),
            ],
            if (entertainmentItems.isNotEmpty) ...[
              _buildCategoryHeader('Entertainment'),
              ...entertainmentItems.map((item) => _buildPasswordTile(item)),
              const SizedBox(height: 16),
            ],
            if (workItems.isNotEmpty) ...[
              _buildCategoryHeader('Work'),
              ...workItems.map((item) => _buildPasswordTile(item)),
              const SizedBox(height: 16),
            ],
            if (otherItems.isNotEmpty) ...[
              _buildCategoryHeader('Other'),
              ...otherItems.map((item) => _buildPasswordTile(item)),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 24),
          ],
        );
      }),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildPasswordTile(VaultItem item) {
    return InkWell(
      onTap: () => controller.navigateToDetails(item),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            // Brand Logo / Initial
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.brandColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: item.brandColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                item.iconLetter,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Title & Username
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.username,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Copy Password Button
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black12, width: 1),
                ),
                child: const Icon(
                  Icons.copy_rounded,
                  size: 18,
                  color: Colors.black87,
                ),
              ),
              onPressed: () => controller.vaultService.copyPassword(item.password, title: item.name),
              tooltip: 'Copy password',
            ),
          ],
        ),
      ),
    );
  }
}
