// lib/app/ui/theme/app_text_styles.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontSize: 72.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );

  static const TextStyle headline6 = TextStyle(
    fontSize: 36.0,
    fontStyle: FontStyle.italic,
    color: AppColors.textColor,
  );

  static const TextStyle bodyText2 = TextStyle(
    fontSize: 14.0,
    fontFamily: 'Hind',
    color: AppColors.textColor,
  );

  // 다크 모드용 스타일
  static const TextStyle darkHeadline1 = TextStyle(
    fontSize: 72.0,
    fontWeight: FontWeight.bold,
    color: AppColors.darkTextColor,
  );

  static const TextStyle darkHeadline6 = TextStyle(
    fontSize: 36.0,
    fontStyle: FontStyle.italic,
    color: AppColors.darkTextColor,
  );

  static const TextStyle darkBodyText2 = TextStyle(
    fontSize: 14.0,
    fontFamily: 'Hind',
    color: AppColors.darkTextColor,
  );
}
