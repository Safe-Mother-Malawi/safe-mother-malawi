import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../screens/splash_screen.dart';
import 'sidebar.dart';
import 'widgets/notification_panel.dart';

void _doLogout(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Row(children: [
        Icon(Icons.logout_rounded, color: Color(0xFF0D47A1), size: 20),
        SizedBox(width: 8),
        Text('Log Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ]),
      content: const Text('Are you sure you want to log out?',
          style: TextStyle(fontSize: 13, color: Colors.black54)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.black45)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const SplashScreen()),
              (_) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D47A1),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: const Text('Log Out'),
        ),
      ],
    ),
  );
}

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
          const NotificationBell(),
          const SizedBox(width: 8),

          // Profile chip — logout UI only, no action (auth pending)
          PopupMenuButton<String>(
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: AppColors.surfaceContainerLowest,
            onSelected: (value) {
              if (value == 'logout') _doLogout(context);
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName,
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.headings)),
                    Text(
                      role == UserRole.admin ? 'System Admin' : 'District Health Officer',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.mutedText),
                    ),
                  ],
                ),
              ),
            ],
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primaryContainer,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName,
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
                    Text(
                      role == UserRole.admin ? 'System Admin' : 'District Health Officer',
                      style: GoogleFonts.inter(fontSize: 10, color: AppColors.mutedText),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// _IconBtn kept for potential reuse elsewhere
// ignore: unused_element
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
