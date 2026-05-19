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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440, maxHeight: 560),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF003178), Color(0xFF0D47A1)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: Row(children: [
                  const Icon(Icons.notifications_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Notifications',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ListenableBuilder(
                      listenable: NotificationStore.instance,
                      builder: (_, __) {
                        final u = NotificationStore.instance.unreadCount;
                        return Text(u > 0 ? '$u unread' : 'All caught up',
                            style: const TextStyle(color: Colors.white60, fontSize: 11));
                      },
                    ),
                  ])),
                  TextButton(
                    onPressed: () => NotificationStore.instance.markAllRead(),
                    child: const Text('Mark all read',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 18),
                    onPressed: () => NotificationStore.instance.reload(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                ]),
              ),
              Expanded(child: _NotificationList()),
            ]),
          ),
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
      return Center(child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: const Color(0xFFEEF2FF), shape: BoxShape.circle),
            child: const Icon(Icons.notifications_none_rounded, size: 32, color: Color(0xFF003178)),
          ),
          const SizedBox(height: 16),
          const Text('All caught up!',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF212121))),
          const SizedBox(height: 4),
          const Text('No new notifications.',
              style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
        ]),
      ));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 68),
      itemBuilder: (_, i) {
        final n = items[i];
        final color = n.type == NotifType.alert
            ? const Color(0xFFC62828)
            : n.type == NotifType.appointment
                ? const Color(0xFF003178)
                : const Color(0xFF2E7D32);
        final bgColor = n.type == NotifType.alert
            ? const Color(0xFFFFEBEE)
            : n.type == NotifType.appointment
                ? const Color(0xFFE3F2FD)
                : const Color(0xFFE8F5E9);
        final icon = n.type == NotifType.alert
            ? Icons.warning_amber_rounded
            : n.type == NotifType.appointment
                ? Icons.calendar_today_rounded
                : Icons.info_outline_rounded;

        return Dismissible(
          key: ValueKey(n.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: const Color(0xFFFFEBEE),
            child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFC62828), size: 20),
          ),
          onDismissed: (_) => NotificationStore.instance.delete(n.id),
          child: InkWell(
            onTap: () => NotificationStore.instance.markRead(n.id),
            child: Container(
              color: n.read ? Colors.transparent : color.withValues(alpha: 0.04),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(n.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: n.read ? FontWeight.w500 : FontWeight.w700,
                          color: const Color(0xFF212121),
                        ))),
                    Text(n.timeAgo,
                        style: const TextStyle(fontSize: 10, color: Color(0xFFBDBDBD))),
                  ]),
                  const SizedBox(height: 3),
                  Text(n.body,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF757575), height: 1.4),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ])),
                if (!n.read) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 8, height: 8, margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                ],
              ]),
            ),
          ),
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
