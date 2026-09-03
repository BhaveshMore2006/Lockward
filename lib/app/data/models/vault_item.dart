import 'package:flutter/material.dart';

enum SecurityStatus { safe, weak, risk }

class VaultItem {
  final String id;
  final String name;
  final String username;
  final String password;
  final String category; // 'Priority', 'Entertainment', 'Work', 'Other'
  final String link;
  final bool autofill;
  final SecurityStatus securityStatus;
  final Color brandColor;
  final String iconLetter;
  final IconData? iconData;

  VaultItem({
    required this.id,
    required this.name,
    required this.username,
    required this.password,
    required this.category,
    required this.link,
    this.autofill = true,
    required this.securityStatus,
    required this.brandColor,
    required this.iconLetter,
    this.iconData,
  });

  VaultItem copyWith({
    String? id,
    String? name,
    String? username,
    String? password,
    String? category,
    String? link,
    bool? autofill,
    SecurityStatus? securityStatus,
    Color? brandColor,
    String? iconLetter,
    IconData? iconData,
  }) {
    return VaultItem(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      password: password ?? this.password,
      category: category ?? this.category,
      link: link ?? this.link,
      autofill: autofill ?? this.autofill,
      securityStatus: securityStatus ?? this.securityStatus,
      brandColor: brandColor ?? this.brandColor,
      iconLetter: iconLetter ?? this.iconLetter,
      iconData: iconData ?? this.iconData,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'password': password,
      'category': category,
      'link': link,
      'autofill': autofill,
      'securityStatus': securityStatus.name,
    };
  }
}
