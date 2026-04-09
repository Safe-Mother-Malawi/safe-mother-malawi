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

  // ── Medical Risk Colors (ONLY these three for risk/status) ───────────────────
  static const red     = Color(0xFFD32F2F); // High risk
  static const redL    = Color(0xFFFFEBEE);

  static const orange  = Color(0xFFE65100); // Medium risk
  static const orangeL = Color(0xFFFBE9E7);

  static const green   = Color(0xFF2E7D32); // Low risk / Stable
  static const greenL  = Color(0xFFE8F5E9);

  // ── Neutrals ─────────────────────────────────────────────────────────────────
  static const g100 = Color(0xFFF5F5F5);
  static const g200 = Color(0xFFEEEEEE);
  static const g400 = Color(0xFFBDBDBD);
  static const g600 = Color(0xFF757575);
  static const g800 = Color(0xFF212121);

  static const bg   = Color(0xFFF4F6FA);

  // ── Kept only for non-risk UI (calendar neonatal accent, rose badge) ─────────
  static const rose  = Color(0xFFAD1457);
  static const roseL = Color(0xFFFCE4EC);

  // amber/amberL removed — use orange for any warning/medium state
  static const amber  = Color(0xFFE65100); // alias → same as orange
  static const amberL = Color(0xFFFBE9E7);

  // stable → green (same as low risk)
  static const stable  = Color(0xFF2E7D32);
  static const stableL = Color(0xFFE8F5E9);
}
