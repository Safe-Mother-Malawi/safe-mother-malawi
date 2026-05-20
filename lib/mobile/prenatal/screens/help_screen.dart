import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/api_service.dart';
import '../../../theme/app_colors.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});
  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _faqs = const [
    {'q': 'How is my pregnancy week calculated?', 'a': 'Your pregnancy week is automatically calculated from your Last Menstrual Period (LMP) date entered during registration.'},
    {'q': 'Can I use the app without internet?', 'a': 'Yes. Core features like the pregnancy tracker, nutrition tips, and health information are available offline. Data syncs when you reconnect.'},
    {'q': 'How do I update my LMP date?', 'a': 'On the home screen, tap the "Edit" button next to your due date to update your LMP date.'},
    {'q': 'What is the IVR call feature?', 'a': 'The IVR (Interactive Voice Response) feature lets you quickly call hospitals, midwives, or emergency services directly from the app.'},
    {'q': 'How does the health diagnostic work?', 'a': 'The diagnostic asks you a series of questions about your symptoms. Each answer has a weight, and the system calculates a risk score to suggest possible health concerns.'},
    {'q': 'How do I add an appointment?', 'a': 'Go to the Schedule tab and tap "+ New" to add a new appointment with date, time, location, and doctor details.'},
  ];

  int? _expanded;
  bool _isSubmitting = false;

  Future<void> _callHelpline() async {
    const phoneNumber = 'tel:700';
    try {
      if (await canLaunchUrl(Uri.parse(phoneNumber))) {
        await launchUrl(Uri.parse(phoneNumber));
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to make call. Please dial 700 manually.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _sendEmail() async {
    const email = 'safemothermalawi@gmail.com';
    final emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'SafeMother Support Request',
        'body': 'Hello,\n\nI need help with...\n\nThank you',
      },
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unable to open email. Please email $email manually.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _findNearestHealthCentre() async {
    const mapsUrl = 'https://maps.google.com/?q=health+centre+malawi';
    try {
      if (await canLaunchUrl(Uri.parse(mapsUrl))) {
        await launchUrl(Uri.parse(mapsUrl), mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to open maps. Please search manually.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _showContactForm() async {
    final subjectController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Contact Support'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectController,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                decoration: InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  hintText: 'Describe your issue...',
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isSubmitting
                ? null
                : () async {
                    if (subjectController.text.isEmpty || messageController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill in all fields')),
                      );
                      return;
                    }

                    setState(() => _isSubmitting = true);
                    try {
                      await ApiService.instance.submitContactForm(
                        subject: subjectController.text,
                        message: messageController.text,
                      );
                      if (mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Thank you! Your message has been sent to our support team.'),
                            backgroundColor: Color(0xFF4CAF50),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isSubmitting = false);
                      }
                    }
                  },
            child: _isSubmitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mobilePageBg,
      appBar: AppBar(
        backgroundColor: AppColors.navbarBg,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('Help & Support', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Contact support
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.navbarBg, AppColors.sidebarBgMob], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Need Help?', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Our support team is here for you', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.mobileNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  onPressed: _showContactForm,
                  child: const Text('Contact Us', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Quick links
          _SectionLabel('QUICK LINKS'),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
            child: Column(children: [
              _LinkTile(icon: Icons.phone_outlined, label: 'SafeMother Helpline', subtitle: '700', color: AppColors.statusRed, onTap: _callHelpline),
              const Divider(height: 1, indent: 56),
              _LinkTile(icon: Icons.email_outlined, label: 'Email Support', subtitle: 'safemothermalawi@gmail.com', color: AppColors.mobileNavy, onTap: _sendEmail),
              const Divider(height: 1, indent: 56),
              _LinkTile(icon: Icons.local_hospital_outlined, label: 'Nearest Health Centre', subtitle: 'Find a clinic near you', color: AppColors.statusGreen, onTap: _findNearestHealthCentre),
            ]),
          ),
          const SizedBox(height: 20),
          // Pregnancy danger signs reminder
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
                    Text('Pregnancy Danger Signs — Seek Help Immediately',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.statusRed)),
                  ],
                ),
                const SizedBox(height: 10),
                ...['Severe vaginal bleeding', 'Severe abdominal pain', 'Severe headache with vision changes',
                    'Swelling of face, hands, or feet', 'Difficulty breathing', 'Loss of consciousness or seizures',
                    'Severe chest pain', 'Signs of infection (fever, chills)']
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
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _LinkTile({required this.icon, required this.label, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20)),
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
  final String question;
  final String answer;
  final bool expanded;
  final VoidCallback onTap;
  const _FaqTile({required this.question, required this.answer, required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: expanded ? AppColors.mobileLightBg : AppColors.border)),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(question, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
            Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: AppColors.mobileNavy),
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
