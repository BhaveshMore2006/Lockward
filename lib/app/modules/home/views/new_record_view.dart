import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/vault_item.dart';
import '../../../data/services/vault_service.dart';

class NewRecordView extends StatefulWidget {
  const NewRecordView({super.key});

  @override
  State<NewRecordView> createState() => _NewRecordViewState();
}

class _NewRecordViewState extends State<NewRecordView> {
  final VaultService vaultService = Get.find<VaultService>();

  final TextEditingController nameController = TextEditingController(text: 'Apple');
  final TextEditingController userIdController = TextEditingController(text: 'steve1902@gmail.com');
  final TextEditingController passwordController = TextEditingController();

  double passwordLength = 12;
  bool useNumbers = true;
  bool useSymbols = true;
  bool useLowercase = true;
  bool useUppercase = true;
  String selectedCategory = 'Priority';

  @override
  void initState() {
    super.initState();
    _regeneratePassword();
  }

  @override
  void dispose() {
    nameController.dispose();
    userIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _regeneratePassword() {
    final newPass = VaultService.generatePassword(
      length: passwordLength.round(),
      useNumbers: useNumbers,
      useSymbols: useSymbols,
      useLowercase: useLowercase,
      useUppercase: useUppercase,
    );
    setState(() {
      passwordController.text = newPass;
    });
  }

  void _saveRecord() {
    final name = nameController.text.trim();
    final userId = userIdController.text.trim();
    final pass = passwordController.text.trim();

    if (name.isEmpty || userId.isEmpty || pass.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final newItem = VaultItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      username: userId,
      password: pass,
      category: selectedCategory,
      link: '${name.toLowerCase().replaceAll(' ', '')}.com',
      autofill: true,
      securityStatus: pass.length > 10 ? SecurityStatus.safe : SecurityStatus.weak,
      brandColor: _pickColor(name),
      iconLetter: name.isNotEmpty ? name.substring(0, name.length > 2 ? 2 : 1) : 'A',
    );

    vaultService.addItem(newItem);
    Get.back();
    Get.snackbar('Success', '$name saved to your vault!',
        snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
  }

  Color _pickColor(String name) {
    final colors = [
      const Color(0xFF0057FF),
      const Color(0xFFED2224),
      const Color(0xFF1DB954),
      const Color(0xFFF24E1E),
      const Color(0xFF171A21),
      const Color(0xFF555555),
    ];
    return colors[name.length % colors.length];
  }

  @override
  Widget build(BuildContext context) {
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
          'New record',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          // Name Field
          _buildInputField(
            controller: nameController,
            label: 'Name',
            hint: 'e.g. Apple, Google, Twitter',
          ),
          const SizedBox(height: 16),

          // User ID Field
          _buildInputField(
            controller: userIdController,
            label: 'User id',
            hint: 'e.g. steve1902@gmail.com',
          ),
          const SizedBox(height: 16),

          // Category Selector
          Row(
            children: [
              const Text(
                'Category:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: selectedCategory,
                underline: const SizedBox.shrink(),
                items: ['Priority', 'Entertainment', 'Work', 'Other'].map((String val) {
                  return DropdownMenuItem<String>(
                    value: val,
                    child: Text(val, style: const TextStyle(fontWeight: FontWeight.w500)),
                  );
                }).toList(),
                onChanged: (newVal) {
                  if (newVal != null) {
                    setState(() => selectedCategory = newVal);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Password Section Header
          const Center(
            child: Text(
              'Password',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Password display box with refresh button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F5F7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: passwordController,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0057FF), size: 22),
                  onPressed: _regeneratePassword,
                  tooltip: 'Generate new password',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Length slider
          Row(
            children: [
              const Text(
                'Length',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
              const SizedBox(width: 16),
              Text(
                '${passwordLength.round()}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
              ),
              Expanded(
                child: Slider(
                  value: passwordLength,
                  min: 6,
                  max: 32,
                  activeColor: const Color(0xFF0057FF),
                  inactiveColor: Colors.black12,
                  onChanged: (val) {
                    setState(() => passwordLength = val);
                    _regeneratePassword();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Checkbox grid
          Row(
            children: [
              Expanded(
                child: _buildCheckbox(
                  label: 'Numbers',
                  value: useNumbers,
                  onChanged: (v) {
                    setState(() => useNumbers = v ?? true);
                    _regeneratePassword();
                  },
                ),
              ),
              Expanded(
                child: _buildCheckbox(
                  label: 'Symbols',
                  value: useSymbols,
                  onChanged: (v) {
                    setState(() => useSymbols = v ?? true);
                    _regeneratePassword();
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _buildCheckbox(
                  label: 'Lowercase',
                  value: useLowercase,
                  onChanged: (v) {
                    setState(() => useLowercase = v ?? true);
                    _regeneratePassword();
                  },
                ),
              ),
              Expanded(
                child: _buildCheckbox(
                  label: 'Uppercase',
                  value: useUppercase,
                  onChanged: (v) {
                    setState(() => useUppercase = v ?? true);
                    _regeneratePassword();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Buttons: Regenerate & Save Password
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _regeneratePassword,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.black26),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Regenerate', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveRecord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0057FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Save password', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // OR divider
          Row(
            children: [
              const Expanded(child: Divider(color: Colors.black12)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('OR', style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500)),
              ),
              const Expanded(child: Divider(color: Colors.black12)),
            ],
          ),
          const SizedBox(height: 20),

          // Add manually button
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  passwordController.clear();
                });
                Get.snackbar('Manual Input', 'You can now type your custom password directly into the field.',
                    snackPosition: SnackPosition.BOTTOM);
              },
              child: const Text(
                'Add manually',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, child) {
            final hasText = value.text.isNotEmpty;
            return TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0057FF), width: 1.5),
                ),
                suffixIcon: hasText
                    ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20)
                    : null,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCheckbox({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF0057FF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
      ],
    );
  }
}
