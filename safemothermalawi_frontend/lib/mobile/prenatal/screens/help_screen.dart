import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE91E8C),
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
              gradient: const LinearGradient(colors: [Color(0xFFE91E8C), Color(0xFFFF80AB)], begin: Alignment.topLeft, end: Alignment.bottomRight),
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
                      Text('Contact our support team anytime', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFE91E8C), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  onPressed: () {},
                  child: const Text('Contact Us', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Quick links
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 10),
            child: Text('QUICK LINKS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF9E9E9E), letterSpacing: 1.0)),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
            child: Column(children: [
              _LinkTile(icon: Icons.phone_outlined, label: 'Call Support', subtitle: '+265 800 000 111', color: const Color(0xFF1565C0), onTap: () {}),
              const Divider(height: 1, indent: 56),
              _LinkTile(icon: Icons.email_outlined, label: 'Email Us', subtitle: 'support@safemothermalawi.org', color: const Color(0xFFE91E8C), onTap: () {}),
              const Divider(height: 1, indent: 56),
              _LinkTile(icon: Icons.chat_bubble_outline, label: 'Live Chat', subtitle: 'Available 8AM – 5PM', color: const Color(0xFF00695C), onTap: () {}),
            ]),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 10),
            child: Text('FREQUENTLY ASKED QUESTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF9E9E9E), letterSpacing: 1.0)),
          ),
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
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF212121))),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
        ])),
        const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF9E9E9E)),
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
      border: Border.all(color: expanded ? const Color(0xFFFFCDD2) : const Color(0xFFF0F0F0))),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(question, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF212121)))),
            Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: const Color(0xFFE91E8C)),
          ]),
          if (expanded) ...[
            const SizedBox(height: 10),
            Text(answer, style: const TextStyle(fontSize: 12, color: Color(0xFF757575), height: 1.5)),
          ],
        ]),
      ),
    ),
  );
}
