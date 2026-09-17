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
  final bool isFavorite;

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
    this.isFavorite = false,
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
    bool? isFavorite,
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
      isFavorite: isFavorite ?? this.isFavorite,
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
      'isFavorite': isFavorite,
      'brandColor': brandColor.value,
      'iconLetter': iconLetter,
    };
  }

  factory VaultItem.fromMap(Map<String, dynamic> map, String id) {
    return VaultItem(
      id: id,
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      category: map['category'] ?? 'Other',
      link: map['link'] ?? '',
      autofill: map['autofill'] ?? false,
      securityStatus: SecurityStatus.values.firstWhere(
        (e) => e.name == map['securityStatus'],
        orElse: () => SecurityStatus.weak,
      ),
      brandColor: Color(map['brandColor'] ?? 0xFF555555),
      iconLetter: map['iconLetter'] ?? 'A',
      isFavorite: map['isFavorite'] ?? false,
    );
  }
}
