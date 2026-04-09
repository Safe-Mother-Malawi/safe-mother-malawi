import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class NeonatalHelpScreen extends StatefulWidget {
  const NeonatalHelpScreen({super.key});
  @override
  State<NeonatalHelpScreen> createState() => _NeonatalHelpScreenState();
}

class _NeonatalHelpScreenState extends State<NeonatalHelpScreen> {
  int? _expanded;

  static const _faqs = [
    {'q': 'How is my baby\'s age calculated?', 'a': 'Your baby\'s age in days is calculated from the date of birth you entered during registration. It updates automatically every day.'},
    {'q': 'What are danger signs I should watch for?', 'a': 'Danger signs include fast breathing (>60 breaths/min), blue or pale skin, not feeding for 3+ hours, fever above 38°C, seizures, or a limp unresponsive baby. Seek help immediately if any of these occur.'},
    {'q': 'How does the health check work?', 'a': 'The health check asks 7 questions about your baby\'s condition. Each answer has a weight score. The total score determines whether your baby appears well, needs monitoring, or requires immediate help.'},
    {'q': 'When are vaccines due?', 'a': 'Vaccines follow the Malawi EPI schedule. BCG and OPV-0 are given at birth, then OPV-1, PCV-1, and Pentavalent-1 at 6 weeks. Check the Vaccine Schedule screen for your baby\'s full schedule.'},
    {'q': 'How do I log a feeding session?', 'a': 'Go to the Feeding Tracker from the side menu. Select the feed type (breast, formula, or mixed), enter the volume or duration, and tap "Log Feed".'},
    {'q': 'How do I log a sleep session?', 'a': 'Open the Sleep Tracker from the side menu. Choose day nap or night sleep, set the start and end times, then tap "Log Sleep".'},
    {'q': 'Can I use the app without internet?', 'a': 'Yes. Core features like the baby tracker, feeding log, sleep log, and health information work offline. Data is stored locally on your device.'},
    {'q': 'How do I update my baby\'s information?', 'a': 'Go to Profile from the side menu to view your baby\'s details. Contact support if you need to correct registration information.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mobilePageBg,
      appBar: AppBar(
        backgroundColor: AppColors.navbarBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Help & Support',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Support banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.navbarBg, AppColors.sidebarBgMob],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Need Help?',
                          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Our support team is here for you',
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.mobileNavy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening contact form...'), backgroundColor: AppColors.mobileNavy),
                  ),
                  child: const Text('Contact Us', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quick links
          _SectionLabel('QUICK LINKS'),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(children: [
              _LinkTile(
                icon: Icons.phone_outlined,
                label: 'SafeMother Helpline',
                subtitle: '116 (Free call)',
                color: AppColors.statusRed,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Calling 116...'), backgroundColor: AppColors.statusRed),
                ),
              ),
              const Divider(height: 1, indent: 56),
              _LinkTile(
                icon: Icons.email_outlined,
                label: 'Email Support',
                subtitle: 'support@safemothermalawi.org',
                color: AppColors.mobileNavy,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening email...'), backgroundColor: AppColors.mobileNavy),
                ),
              ),
              const Divider(height: 1, indent: 56),
              _LinkTile(
                icon: Icons.local_hospital_outlined,
                label: 'Nearest Health Centre',
                subtitle: 'Find a clinic near you',
                color: AppColors.statusGreen,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening map...'), backgroundColor: AppColors.statusGreen),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          // Danger signs reminder
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.statusRedBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.statusRed.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_rounded, color: AppColors.statusRed, size: 20),
                    SizedBox(width: 8),
                    Text('Baby Danger Signs — Act Immediately',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.statusRed)),
                  ],
                ),
                const SizedBox(height: 10),
                ...['Fast or difficult breathing', 'Blue, pale, or grey skin', 'Not feeding for 3+ hours',
                    'Fever above 38°C or cold below 36°C', 'Seizures or limpness', 'Deep yellow jaundice']
                    .map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: AppColors.statusRed, fontWeight: FontWeight.bold)),
                      Expanded(child: Text(s, style: const TextStyle(fontSize: 12, color: Color(0xFF7F0000), height: 1.4))),
                    ],
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // FAQs
          _SectionLabel('FREQUENTLY ASKED QUESTIONS'),
          ..._faqs.asMap().entries.map((e) => _FaqTile(
            question: e.value['q']!,
            answer: e.value['a']!,
            expanded: _expanded == e.key,
            onTap: () => setState(() => _expanded = _expanded == e.key ? null : e.key),
          )),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 10),
    child: Text(text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
            color: AppColors.textMuted, letterSpacing: 1.0)),
  );
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _LinkTile({required this.icon, required this.label, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ])),
        const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
      ]),
    ),
  );
}

class _FaqTile extends StatelessWidget {
  final String question, answer;
  final bool expanded;
  final VoidCallback onTap;
  const _FaqTile({required this.question, required this.answer, required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: expanded ? AppColors.mobileLightBg : AppColors.border),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(question,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
            Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: AppColors.mobileNavy),
          ]),
          if (expanded) ...[
            const SizedBox(height: 10),
            Text(answer, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
          ],
        ]),
      ),
    ),
  );
}
