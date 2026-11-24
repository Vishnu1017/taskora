import 'package:flutter/material.dart';

/// Workspace or Project Category Model for grouping tasks.
class TaskCategory {
  final String id;
  final String name;
  final int colorValue;
  final int iconCodePoint;

  const TaskCategory({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.iconCodePoint,
  });

  Color get color => Color(colorValue);
  IconData get icon {
    switch (id) {
      case 'work':
        return Icons.work_rounded;
      case 'personal':
        return Icons.person_rounded;
      case 'health':
        return Icons.favorite_rounded;
      case 'study':
        return Icons.school_rounded;
      case 'finance':
        return Icons.account_balance_wallet_rounded;
      default:
        // ignore: non_const_argument_for_const_parameter
        return IconData(iconCodePoint, fontFamily: 'MaterialIcons');
    }
  }

  static const List<TaskCategory> defaultCategories = [
    TaskCategory(
      id: 'work',
      name: 'Work',
      colorValue: 0xFF6366F1, // Electric Iris
      iconCodePoint: 0xe0ef, // work_rounded
    ),
    TaskCategory(
      id: 'personal',
      name: 'Personal',
      colorValue: 0xFF10B981, // Mint Emerald
      iconCodePoint: 0xe491, // person_rounded
    ),
    TaskCategory(
      id: 'health',
      name: 'Health',
      colorValue: 0xFFFF3366, // Neon Rose
      iconCodePoint: 0xe25a, // favorite_rounded
    ),
    TaskCategory(
      id: 'study',
      name: 'Study',
      colorValue: 0xFFFF9500, // Solar Amber
      iconCodePoint: 0xe559, // school_rounded
    ),
    TaskCategory(
      id: 'finance',
      name: 'Finance',
      colorValue: 0xFF06B6D4, // Bioluminescent Cyan
      iconCodePoint: 0xe040, // account_balance_wallet_rounded
    ),
  ];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'colorValue': colorValue,
    'iconCodePoint': iconCodePoint,
  };

  factory TaskCategory.fromJson(Map<String, dynamic> json) => TaskCategory(
    id: json['id'] as String,
    name: json['name'] as String,
    colorValue: json['colorValue'] as int? ?? 0xFF4F46E5,
    iconCodePoint: json['iconCodePoint'] as int? ?? 0xe0ef,
  );

  TaskCategory copyWith({
    String? id,
    String? name,
    int? colorValue,
    int? iconCodePoint,
  }) => TaskCategory(
    id: id ?? this.id,
    name: name ?? this.name,
    colorValue: colorValue ?? this.colorValue,
    iconCodePoint: iconCodePoint ?? this.iconCodePoint,
  );
}
