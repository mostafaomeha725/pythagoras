import 'package:flutter/material.dart';

class ProfileOption {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDestructive;

  const ProfileOption({
    required this.title,
    this.subtitle,
    required this.icon,
    this.onTap,
    this.isDestructive = false,
  });
}
