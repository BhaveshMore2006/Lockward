import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/vault_item.dart';
import '../../../data/services/vault_service.dart';

class PasswordDetailsView extends StatefulWidget {
  const PasswordDetailsView({super.key});

  @override
  State<PasswordDetailsView> createState() => _PasswordDetailsViewState();
}

class _PasswordDetailsViewState extends State<PasswordDetailsView> {
  final VaultService vaultService = Get.find<VaultService>();
  late VaultItem item;
  bool isPasswordVisible = false;
  late bool autofill;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is VaultItem) {
      item = args;
    } else {
      // Fallback
      item = vaultService.items.isNotEmpty
          ? vaultService.items.first
          : VaultItem(
              id: '0',
              name: 'Adobe',
              username: 'work.steve@gmail.com',
              password: 'Czb6n1WFh8Qvia#M',
              category: 'Priority',
              link: 'adobe.com',
              autofill: true,
              securityStatus: SecurityStatus.safe,
              brandColor: const Color(0xFFED2224),
              iconLetter: 'A',
            );
    }
    autofill = item.autofill;
  }

  void _deleteRecord() {
    Get.defaultDialog(
      title: 'Delete Password',
      middleText: 'Are you sure you want to delete ${item.name} from your vault?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        vaultService.deleteItem(item.id);
        Get.back(); // close dialog
        Get.back(); // go back to previous screen
        Get.snackbar('Deleted', '${item.name} removed from vault',
            snackPosition: SnackPosition.BOTTOM);
      },
    );
  }

  void _showChangePasswordDialog() {
    final newPassController = TextEditingController(text: item.password);
    Get.defaultDialog(
      title: 'Change Password',
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: TextField(
          controller: newPassController,
          decoration: const InputDecoration(
            labelText: 'New Password',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      textConfirm: 'Update',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF0057FF),
      onConfirm: () {
        final newPass = newPassController.text.trim();
        if (newPass.isNotEmpty) {
          final updated = item.copyWith(password: newPass);
          vaultService.updateItem(updated);
          setState(() {
            item = updated;
          });
          Get.back();
          Get.snackbar('Updated', 'Password updated successfully!',
              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 100,
        leading: TextButton.icon(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87, size: 20),
          label: const Text(
            'back',
            style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 24),
            onPressed: _deleteRecord,
            tooltip: 'Delete password',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          const SizedBox(height: 10),
          // Large Brand Card
          Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: item.brandColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: item.brandColor.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    item.iconLetter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.username,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // Details & Settings Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Details & settings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54),
            ],
          ),
          const SizedBox(height: 16),

          // Details Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            child: Column(
              children: [
                // Link
                _buildDetailRow(
                  label: 'Link',
                  valueWidget: Text(
                    item.link,
                    style: const TextStyle(
                      color: Color(0xFF0057FF),
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const Divider(height: 24, color: Colors.black12),

                // User ID
                _buildDetailRow(
                  label: 'User id',
                  valueWidget: Text(
                    item.username,
                    style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                  ),
                ),
                const Divider(height: 24, color: Colors.black12),

                // Password with reveal eye
                _buildDetailRow(
                  label: 'Password',
                  valueWidget: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isPasswordVisible ? item.password : '••••••••••••',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                        child: Icon(
                          isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 24, color: Colors.black12),

                // Autofill
                _buildDetailRow(
                  label: 'Autofill',
                  valueWidget: Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: autofill,
                      onChanged: (val) {
                        setState(() => autofill = val);
                        final updated = item.copyWith(autofill: val);
                        vaultService.updateItem(updated);
                      },
                      activeColor: const Color(0xFF0057FF),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Action Buttons: Copy Password & Change Password
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => vaultService.copyPassword(item.password, title: item.name),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.black26),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Copy password',
                    style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: OutlinedButton(
                  onPressed: _showChangePasswordDialog,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.black26),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Change password',
                    style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({required String label, required Widget valueWidget}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        valueWidget,
      ],
    );
  }
}
