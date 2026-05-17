import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../state/notification_store.dart';
import '../../screens/clinician/pages/profile_page.dart';
import 'sidebar.dart';

class TopNavbar extends StatefulWidget implements PreferredSizeWidget {
  final UserRole role;
  final String userName;
  final String pageTitle;

  const TopNavbar({super.key, required this.role, required this.userName, required this.pageTitle});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  State<TopNavbar> createState() => _TopNavbarState();
}

class _TopNavbarState extends State<TopNavbar> {
  @override
  void initState() {
    super.initState();
    NotificationStore.instance.addListener(_onNotif);
    NotificationStore.instance.load();
  }

  @override
  void dispose() {
    NotificationStore.instance.removeListener(_onNotif);
    super.dispose();
  }

  void _onNotif() => setState(() {});

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF0D47A1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(children: [
                const Icon(Icons.notifications_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                const Expanded(child: Text('Notifications',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                TextButton(
                  onPressed: () => NotificationStore.instance.markAllRead(),
                  child: const Text('Mark all read', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ),
              ]),
            ),
            Expanded(child: _NotificationList()),
          ]),
        ),
      ),
    );
  }

  void _showProfile() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: MyProfilePage(onClose: () => Navigator.pop(context)),
          ),
        ),
      ),
    );
  }

  String get _roleLabel {
    switch (widget.role) {
      case UserRole.admin: return 'System Admin';
      case UserRole.dho:   return 'District Health Officer';
      case UserRole.clinician: return 'Clinician';
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = NotificationStore.instance.unreadCount;

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
        boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 12, offset: Offset(0, 2))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(children: [
        Text(widget.pageTitle,
            style: GoogleFonts.publicSans(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.headings)),
        const Spacer(),

        // Notifications bell
        _IconBtn(
          icon: Icons.notifications_none_rounded,
          badge: unread > 0 ? '$unread' : null,
          onTap: _showNotifications,
        ),
        const SizedBox(width: 12),

        // Profile chip — clicking opens profile dialog (no logout here)
        GestureDetector(
          onTap: _showProfile,
          child: Row(children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryContainer,
              child: Text(
                widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.userName,
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
              Text(_roleLabel,
                  style: GoogleFonts.inter(fontSize: 10, color: AppColors.mutedText)),
            ]),
            const SizedBox(width: 4),
          ]),
        ),
      ]),
    );
  }
}

// ── Notification list ─────────────────────────────────────────────────────────

class _NotificationList extends StatefulWidget {
  @override
  State<_NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<_NotificationList> {
  @override
  void initState() {
    super.initState();
    NotificationStore.instance.addListener(_rebuild);
  }

  @override
  void dispose() {
    NotificationStore.instance.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final items = NotificationStore.instance.all;
    if (items.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('No notifications.', style: TextStyle(color: Colors.black45)),
      ));
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) {
        final n = items[i];
        final color = n.type == NotifType.alert ? Colors.red
            : n.type == NotifType.appointment ? const Color(0xFF0D47A1) : Colors.green;
        final icon  = n.type == NotifType.alert ? Icons.warning_amber_rounded
            : n.type == NotifType.appointment ? Icons.calendar_today_rounded : Icons.info_outline_rounded;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color, size: 18),
          ),
          title: Text(n.title,
              style: TextStyle(fontSize: 13, fontWeight: n.read ? FontWeight.normal : FontWeight.bold)),
          subtitle: Text(n.body,
              style: const TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: n.read
              ? null
              : Container(width: 8, height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          onTap: () => NotificationStore.instance.markRead(n.id),
        );
      },
    );
  }
}

// ── Icon button with badge ────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final String? badge;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(clipBehavior: Clip.none, children: [
      IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: AppColors.secondary, size: 22),
        style: IconButton.styleFrom(
          backgroundColor: AppColors.surfaceContainerLow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      if (badge != null)
        Positioned(top: 4, right: 4, child: Container(
          width: 16, height: 16,
          decoration: const BoxDecoration(color: AppColors.criticalText, shape: BoxShape.circle),
          child: Center(child: Text(badge!,
              style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white))),
        )),
    ]);
  }
}
