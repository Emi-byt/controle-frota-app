import 'package:flutter/material.dart';

/// Identidade visual do Controle de Frota.
abstract final class AppColors {
  // Marca
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1E3A5F);
  static const Color primaryLight = Color(0xFFDBEAFE);

  // Superfícies
  static const Color background = Color(0xFFF3F5F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F3F6);
  static const Color border = Color(0xFFE5E7EB);

  // Textos
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF15803D);
  static const Color successSoft = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFD97706);
  static const Color warningSoft = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerSoft = Color(0xFFFEE2E2);
  static const Color neutralSoft = Color(0xFFE5E7EB);
}
