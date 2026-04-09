import 'package:flutter/material.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/models/user_model.dart';
import '../models/neonatal_data.dart';

class NeonatalProfileScreen extends StatefulWidget {
  const NeonatalProfileScreen({super.key});
  @override
  State<NeonatalProfileScreen> createState() => _NeonatalProfileScreenState();
}

class _NeonatalProfileScreenState extends State<NeonatalProfileScreen> {
  UserModel? _user;
  NeonatalData? _data;

  @override
  void initState() {
    super.initState();
    AuthService().getCurrentUser().then((u) {
      if (u == null) return;
      final dob = u.babyDob.isNotEmpty
          ? DateTime.tryParse(u.babyDob) ?? DateTime.now()
          : DateTime.now();
      setState(() {
        _user = u;
        _data = NeonatalData(
          babyDob: dob,
          babyName: u.babyName.isNotEmpty ? u.babyName : 'Baby',
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final u = _user;
    final d = _data;
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00695C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Profile',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00695C), Color(0xFF00ACC1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.3),
                        child: const Icon(Icons.person,
                            size: 48, color: Colors.white),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt,
                              size: 16, color: Color(0xFF00695C)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(u?.fullName ?? 'Loading...',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(u?.phone ?? '',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('👶 Neonatal',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionLabel('Mother Information'),
                  _InfoCard(items: [
                    _InfoRow(
                        icon: Icons.person_outline,
                        label: 'Full Name',
                        value: u?.fullName ?? '—'),
                    _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: u?.phone ?? '—'),
                    _InfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: u?.email.contains('@safemothermalawi') == true
                            ? '—'
                            : (u?.email ?? '—')),
                    _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'District',
                        value: u?.district ?? '—'),
                    _InfoRow(
                        icon: Icons.local_hospital_outlined,
                        label: 'Health Centre',
                        value: u?.healthCentre ?? '—'),
                  ]),
                  const SizedBox(height: 16),
                  const _SectionLabel('Baby Information'),
                  _InfoCard(items: [
                    _InfoRow(
                        icon: Icons.child_care,
                        label: "Baby's Name",
                        value: u?.babyName.isNotEmpty == true
                            ? u!.babyName
                            : '—'),
                    _InfoRow(
                        icon: Icons.cake_outlined,
                        label: 'Date of Birth',
                        value: u?.babyDob.isNotEmpty == true
                            ? _fmtDate(u!.babyDob)
                            : '—'),
                    _InfoRow(
                        icon: Icons.wc_outlined,
                        label: 'Gender',
                        value: u?.babyGender.isNotEmpty == true
                            ? u!.babyGender
                            : '—'),
                    _InfoRow(
                        icon: Icons.monitor_weight_outlined,
                        label: 'Birth Weight',
                        value: u?.babyBirthWeight.isNotEmpty == true
                            ? '${u!.babyBirthWeight} kg'
                            : '—'),
                    if (d != null)
                      _InfoRow(
                          icon: Icons.today_outlined,
                          label: 'Age',
                          value: '${d.ageInDays} days · ${d.stageLabel}'),
                  ]),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      const m = [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'
      ];
      return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF9E9E9E),
                letterSpacing: 0.8)),
      );
}

class _InfoCard extends StatelessWidget {
  final List<_InfoRow> items;
  const _InfoCard({required this.items});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          children: items.asMap().entries.map((e) => Column(children: [
                e.value,
                if (e.key < items.length - 1)
                  const Divider(height: 1, indent: 56),
              ])).toList(),
        ),
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Icon(icon, size: 20, color: const Color(0xFF00897B)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF9E9E9E))),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF212121),
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ]),
      );
}
