import 'package:flutter/material.dart';

class IvrScreen extends StatelessWidget {
  const IvrScreen({super.key});

  static const _contacts = [
    {'name': 'Emergency Hotline', 'number': '116', 'icon': Icons.emergency, 'color': 0xFFD32F2F},
    {'name': 'Kamuzu Central Hospital', 'number': '+265 1 524 222', 'icon': Icons.local_hospital, 'color': 0xFF1A237E},
    {'name': 'Queen Elizabeth Hospital', 'number': '+265 1 874 333', 'icon': Icons.local_hospital, 'color': 0xFF1A237E},
    {'name': 'Midwife Helpline', 'number': '+265 888 000 111', 'icon': Icons.support_agent, 'color': 0xFF00695C},
    {'name': 'Ambulance Services', 'number': '998', 'icon': Icons.airport_shuttle, 'color': 0xFFE65100},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        title: const Text('IVR — Quick Call', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        Text('Need Help Now?', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
                        Text('Tap any contact below to call immediately', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.phone_in_talk, color: Colors.white54, size: 48),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Healthcare Contacts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF212121))),
            const SizedBox(height: 14),
            ..._contacts.map((c) => _ContactCard(
              name: c['name'] as String,
              number: c['number'] as String,
              icon: c['icon'] as IconData,
              color: Color(c['color'] as int),
            )),
            const SizedBox(height: 24),
            const Text('IVR Menu Guide', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF212121))),
            const SizedBox(height: 12),
            _IvrMenuCard(),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final String name;
  final String number;
  final IconData icon;
  final Color color;

  const _ContactCard({required this.name, required this.number, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF212121))),
                const SizedBox(height: 3),
                Text(number, style: const TextStyle(fontSize: 13, color: Color(0xFF757575))),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling $number...'), backgroundColor: color),
              );
            },
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

class _IvrMenuCard extends StatelessWidget {
  final _steps = const [
    {'key': 'Press 1', 'value': 'Appointment booking'},
    {'key': 'Press 2', 'value': 'Emergency assistance'},
    {'key': 'Press 3', 'value': 'Lab results inquiry'},
    {'key': 'Press 4', 'value': 'Speak to a midwife'},
    {'key': 'Press 0', 'value': 'Repeat menu'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3E8FF)),
      ),
      child: Column(
        children: _steps.map((s) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(s['key']!, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 12),
              Text(s['value']!, style: const TextStyle(fontSize: 13, color: Color(0xFF424242))),
            ],
          ),
        )).toList(),
      ),
    );
  }
}
