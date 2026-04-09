import 'package:flutter/material.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  static const _contacts = [
    {'name': 'SafeMother Helpline',      'number': '116',             'icon': Icons.support_agent,           'color': 0xFFD81B60},
    {'name': 'Kamuzu Central Hospital',  'number': '+265 1 524 222',  'icon': Icons.local_hospital,          'color': 0xFF00695C},
    {'name': 'Queen Elizabeth Hospital', 'number': '+265 1 874 333',  'icon': Icons.local_hospital,          'color': 0xFF00695C},
    {'name': 'Neonatal Nurse Helpline',  'number': '+265 888 000 222','icon': Icons.child_care,              'color': 0xFF00897B},
    {'name': 'Ambulance Services',       'number': '998',             'icon': Icons.airport_shuttle,         'color': 0xFFE65100},
    {'name': 'Ministry of Health',       'number': '+265 1 789 400',  'icon': Icons.health_and_safety,       'color': 0xFF1565C0},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00695C),
        elevation: 0,
        title: const Text('Call',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Need Help Now?',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
                        Text(
                          'If your baby shows danger signs, call 998 or go to the nearest health centre immediately.',
                          style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.phone_in_talk, color: Colors.white54, size: 48),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Healthcare Contacts',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121))),
            const SizedBox(height: 14),
            ..._contacts.map((c) => _ContactCard(
                  name: c['name'] as String,
                  number: c['number'] as String,
                  icon: c['icon'] as IconData,
                  color: Color(c['color'] as int),
                )),
            const SizedBox(height: 24),
            const Text('IVR Menu Guide',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121))),
            const SizedBox(height: 12),
            const _IvrMenuCard(),
          ],
        ),
      ),
    );
  }
}

// ─── Contact Card ─────────────────────────────────────────────────────────────

class _ContactCard extends StatelessWidget {
  final String name, number;
  final IconData icon;
  final Color color;
  const _ContactCard({
    required this.name,
    required this.number,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF212121))),
                const SizedBox(height: 3),
                Text(number,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF757575))),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Calling $number...'),
                  backgroundColor: color),
            ),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: const Icon(Icons.phone, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── IVR Menu Card ────────────────────────────────────────────────────────────

class _IvrMenuCard extends StatelessWidget {
  const _IvrMenuCard();

  static const _steps = [
    {'key': 'Press 1', 'value': 'Well-baby appointment booking'},
    {'key': 'Press 2', 'value': 'Emergency assistance'},
    {'key': 'Press 3', 'value': 'Vaccine schedule inquiry'},
    {'key': 'Press 4', 'value': 'Speak to a neonatal nurse'},
    {'key': 'Press 0', 'value': 'Repeat menu'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFB2DFDB)),
      ),
      child: Column(
        children: _steps
            .map((s) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00695C),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(s['key']!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 12),
                      Text(s['value']!,
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF424242))),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}
