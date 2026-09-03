import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/vault_item.dart';
import '../../controllers/home_controller.dart';

class SearchTabView extends GetView<HomeController> {
  const SearchTabView({super.key});

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
          'Search',
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
      body: Column(
        children: [
          // Search Input Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5F7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: controller.searchController,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'search here...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 15,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Colors.black54,
                    size: 22,
                  ),
                  suffixIcon: Obx(() {
                    if (controller.searchQuery.value.isNotEmpty) {
                      return IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18, color: Colors.black54),
                        onPressed: () => controller.searchController.clear(),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Search Results List
          Expanded(
            child: Obx(() {
              final results = controller.searchResults;

              if (results.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 56, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'No passwords found matching "${controller.searchQuery.value}"',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: results.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.black12),
                itemBuilder: (context, index) {
                  final item = results[index];
                  return _buildSearchTile(item);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTile(VaultItem item) {
    return InkWell(
      onTap: () => controller.navigateToDetails(item),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            // Brand Logo
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.brandColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                item.iconLetter,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 14),

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
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.username,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Copy button
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
            ),
          ],
        ),
      ),
    );
  }
}
