import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import 'sidebar.dart';

class TopNavbar extends StatelessWidget implements PreferredSizeWidget {
  final UserRole role;
  final String userName;
  final String pageTitle;

  const TopNavbar({
    super.key,
    required this.role,
    required this.userName,
    required this.pageTitle,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowColor, blurRadius: 12, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(pageTitle,
              style: GoogleFonts.publicSans(
                  fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.headings)),
          const Spacer(),

          // Search
          Container(
            width: 240, height: 38,
            decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(10)),
            child: TextField(
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText),
                prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.mutedText),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Notifications
          _IconBtn(icon: Icons.notifications_none_rounded, badge: '3', onTap: () {}),
          const SizedBox(width: 8),

          // Profile chip — no logout
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryContainer,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userName,
                      style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
                  Text(
                    role == UserRole.admin ? 'System Admin' : 'District Health Officer',
                    style: GoogleFonts.inter(fontSize: 10, color: AppColors.mutedText),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final String? badge;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: AppColors.secondary, size: 22),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surfaceContainerLow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        if (badge != null)
          Positioned(
            top: 4, right: 4,
            child: Container(
              width: 16, height: 16,
              decoration: const BoxDecoration(color: AppColors.criticalText, shape: BoxShape.circle),
              child: Center(
                child: Text(badge!,
                    style: GoogleFonts.inter(
                        fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ),
      ],
    );
  }
}
