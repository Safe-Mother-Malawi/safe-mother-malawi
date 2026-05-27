import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../auth/services/auth_service.dart';

class PostnatalHomeScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;
  const PostnatalHomeScreen({super.key, this.onOpenDrawer});

  @override
  State<PostnatalHomeScreen> createState() => _PostnatalHomeScreenState();
}

class _PostnatalHomeScreenState extends State<PostnatalHomeScreen> {
  String _userName = 'Mother';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await AuthService().getCurrentUser();
      if (user != null) {
        setState(() {
          _userName = user.fullName.split(' ').first;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      print('Error loading user: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                color: AppColors.primary,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onOpenDrawer,
                      child: const Icon(Icons.menu, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back, $_userName!',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Postnatal Care',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.infoBg),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Postnatal Care Overview',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF212121),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'This section helps you track your baby\'s health and development during the critical first month after birth. Regular neonatal follow-ups are essential for early detection of any health issues.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF757575),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quick Links
                    const Text(
                      'QUICK LINKS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF9E9E9E),
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Neonatal Visits Card
                    _QuickLinkCard(
                      icon: Icons.medical_services_outlined,
                      title: 'Neonatal Follow-Up',
                      description: 'Track baby\'s health visits and immunizations',
                      color: AppColors.primary,
                      onTap: () {
                        // Navigate to neonatal visits tab
                        // This will be handled by the parent dashboard
                      },
                    ),

                    const SizedBox(height: 12),

                    // Feeding Tips Card
                    _QuickLinkCard(
                      icon: Icons.restaurant_outlined,
                      title: 'Feeding & Nutrition',
                      description: 'Breastfeeding tips and nutrition guidance',
                      color: Colors.orange,
                      onTap: () {
                        // TODO: Navigate to feeding tips
                      },
                    ),

                    const SizedBox(height: 12),

                    // Mother\'s Health Card
                    _QuickLinkCard(
                      icon: Icons.favorite_outline,
                      title: 'Mother\'s Health',
                      description: 'Postpartum recovery and wellness tracking',
                      color: Colors.red,
                      onTap: () {
                        // TODO: Navigate to mother's health
                      },
                    ),

                    const SizedBox(height: 24),

                    // Important Information
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning_rounded, color: Colors.amber.shade700, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                'Important Reminders',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber.shade900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '• Attend all scheduled neonatal follow-up visits\n'
                            '• Ensure baby receives all recommended immunizations\n'
                            '• Practice exclusive breastfeeding for first 6 months\n'
                            '• Seek immediate care if baby shows danger signs\n'
                            '• Monitor your own postpartum recovery',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber.shade900,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickLinkCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _QuickLinkCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}
