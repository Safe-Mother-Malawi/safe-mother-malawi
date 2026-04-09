import 'package:flutter/material.dart';

class AppColors {
  // ── Brand / Primary ──────────────────────────────────────────────────────────
  static const navy  = Color(0xFF0D47A1);
  static const navyD = Color(0xFF0A3880);
  static const navyL = Color(0xFFE3F2FD);

  // Aliases kept for layout compatibility
  static const tealXd = Color(0xFF0D47A1);
  static const tealD  = Color(0xFF0D47A1);
  static const teal   = Color(0xFF1565C0);
  static const tealL  = Color(0xFFE3F2FD);

  // ── Medical Risk Colors ───────────────────────────────────────────────────────
  static const red     = Color(0xFFD32F2F);
  static const redL    = Color(0xFFFFEBEE);
  static const orange  = Color(0xFFE65100);
  static const orangeL = Color(0xFFFBE9E7);
  static const green   = Color(0xFF2E7D32);
  static const greenL  = Color(0xFFE8F5E9);

  // ── Neutrals ─────────────────────────────────────────────────────────────────
  static const g100 = Color(0xFFF5F5F5);
  static const g200 = Color(0xFFEEEEEE);
  static const g400 = Color(0xFFBDBDBD);
  static const g600 = Color(0xFF757575);
  static const g800 = Color(0xFF212121);
  static const bg   = Color(0xFFF4F6FA);

  static const rose  = Color(0xFFAD1457);
  static const roseL = Color(0xFFFCE4EC);
  static const amber  = Color(0xFFE65100);
  static const amberL = Color(0xFFFBE9E7);
  static const stable  = Color(0xFF2E7D32);
  static const stableL = Color(0xFFE8F5E9);

  // ── DHO/Admin Design System Tokens ───────────────────────────────────────────
  // Primary palette
  static const primary          = Color(0xFF003178);
  static const primaryContainer = Color(0xFF0D47A1);
  static const secondary        = Color(0xFF455F87);
  static const tertiary         = Color(0xFF003D36);
  static const accent           = Color(0xFF00897B);

  // Surfaces
  static const pageBg                  = Color(0xFFF0F6FF);
  static const surface                 = Color(0xFFFCF9F8);
  static const surfaceContainerLow     = Color(0xFFF6F3F2);
  static const surfaceContainerLowest  = Color(0xFFFFFFFF);
  static const surfaceContainerHighest = Color(0xFFE5E2E1);

  // Text
  static const onSurface  = Color(0xFF1B1C1C);
  static const headings   = Color(0xFF212121);
  static const bodyText   = Color(0xFF424242);
  static const mutedText  = Color(0xFF757575);

  // Status
  static const successText = Color(0xFF4CAF50);
  static const successBg   = Color(0xFFE8F5E9);
  static const warningText = Color(0xFFFF9800);
  static const warningBg   = Color(0xFFFFF3E0);
  static const criticalText = Color(0xFFF44336);
  static const criticalBg   = Color(0xFFFFEBEE);
  static const infoText    = Color(0xFF1565C0);
  static const infoBg      = Color(0xFFE3F2FD);

  // Shadow
  static const shadowColor = Color(0x0F1A2E4A);

  // Sidebar
  static const sidebarBg     = Color(0xFF455F87);
  static const sidebarActive = Color(0xFF003178);
  static const sidebarText   = Color(0xFFE8EEF7);
  static const sidebarMuted  = Color(0xFFB0BEC5);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryContainer],
  );

  // Outline
  static const outlineVariant = Color(0x26455F87);
}
