import 'package:flutter/material.dart';
import 'package:pinple/core/constants/app_constants.dart';
import 'package:pinple/core/theme/app_theme.dart';

Color categoryColor(String label) {
  switch (label) {
    case '스터디':
      return AppColors.categoryStudy;
    case '운동':
      return AppColors.categoryExercise;
    case '밥약':
      return AppColors.categoryMeal;
    case '취미':
      return AppColors.categoryHobby;
    default:
      return AppColors.categoryOther;
  }
}

IconData categoryIcon(String label) {
  switch (label) {
    case '스터디':
      return Icons.menu_book_rounded;
    case '운동':
      return Icons.sports_basketball_rounded;
    case '밥약':
      return Icons.restaurant_rounded;
    case '취미':
      return Icons.palette_rounded;
    default:
      return Icons.tag_rounded;
  }
}

GroupCategory? categoryFromLabel(String label) {
  for (final c in GroupCategory.values) {
    if (c.label == label) return c;
  }
  return null;
}
