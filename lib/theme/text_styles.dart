//SAMPLE CODE

import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    fontFamily: 'Roboto',
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
    fontFamily: 'Roboto',
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
    fontFamily: 'Roboto',
  );
}
