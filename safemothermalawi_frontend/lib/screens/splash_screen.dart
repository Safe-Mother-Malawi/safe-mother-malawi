import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../web/admin/admin_overview.dart';
import '../web/dho/dho_overview.dart';
import 'clinician/clinician_layout.dart';
import 'login_dialog.dart';

class _SlideData {
  final String imagePath;
  final String headline;
  final String sub;
  const _SlideData({required this.imagePath, required this.headline, required this.sub});
}

const List<_SlideData> _slides = [
  _SlideData(imagePath: 'assets/images/pic1.png', headline: 'Excellence in maternal and neonatal health',  sub: 'Delivering  Safe,high-quality care for mothers and newborns across Malawi'),
  _SlideData(imagePath: 'assets/images/pic2.jpg', headline: 'Smart Clinical Management', sub: 'Digital tools for seamless patient care coordination and data-driven insights'),
  _SlideData(imagePath: 'assets/images/pic3.jpg', headline: 'Dedicated Medical Team',     sub: 'Over 200 specialists committed to your health'),
  _SlideData(imagePath: 'assets/images/pic4.png', headline: 'Always Watching over You', sub: '24/7 real-time monitoring for every patient'),
  _SlideData(imagePath: 'assets/images/pic5.jpg', headline: 'Emergency Response Ready',   sub: 'Rapid response units available around the clock'),
];

const _navy  = Color(0xFF0D47A1);
const _blue  = Color(0xFF1565C0);
const _light = Color(0xFFE3F2FD);
const _green = Color(0xFF00897B);
const _bg    = Color(0xFFF0F6FF);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  final _scrollController = ScrollController();
  final _pageController   = PageController();
  int    _currentPage = 0;
  String _hoveredNav  = '';

  final _heroKey     = GlobalKey();
  final _aboutKey    = GlobalKey();
  final _servicesKey = GlobalKey();
  final _newsKey     = GlobalKey();
  final _contactKey  = GlobalKey();

  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;
  Timer? _slideTimer;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
    _slideTimer = Timer.periodic(const Duration(milliseconds: 2800), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % _slides.length;
      _pageController.animateToPage(next,
          duration: const Duration(milliseconds: 700), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _slideTimer?.cancel();
    _scrollController.dispose();
    _pageController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx,
        duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
  }

  Future<void> _onLogin() async {
    final role = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const LoginDialog(),
    );
    if (role == null || !mounted) return;
    if (role == 'clinician') {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ClinicianDashboard()));
    } else if (role == 'admin') {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminOverview()));
    } else if (role == 'dho') {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DhoOverview()));
    }
  }

  Widget _fullScreen({required GlobalKey sectionKey, required Widget child}) {
    final h = MediaQuery.of(context).size.height;
    return ConstrainedBox(
        key: sectionKey, constraints: BoxConstraints(minHeight: h), child: child);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(children: [
        _buildNavbar(),
        Expanded(
          child: Listener(
            onPointerSignal: (event) {
              if (event is PointerScrollEvent) {
                final newOffset = (_scrollController.offset + event.scrollDelta.dy)
                    .clamp(0.0, _scrollController.position.maxScrollExtent);
                _scrollController.jumpTo(newOffset);
              }
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              child: Column(children: [
                _buildHero(),
                _buildAbout(),
                _buildServices(),
                _buildNews(),
                _buildContact(),
                _buildFooter(),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildNavbar() {
    return Container(
      height: 64, color: _navy,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
          child: const Icon(Icons.local_hospital, color: _navy, size: 24),
        ),
        const SizedBox(width: 10),
        const Text('Safe Mother Malawi',
            style: TextStyle(color: Colors.white, fontSize: 18,
                fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const Spacer(),
        _navLink('Home',     _heroKey),
        _navLink('About',    _aboutKey),
        _navLink('Services', _servicesKey),
        _navLink('News',     _newsKey),
        _navLink('Contact',  _contactKey),
      ]),
    );
  }

  Widget _navLink(String label, GlobalKey key) {
    final hovered = _hoveredNav == label;
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredNav = label),
      onExit:  (_) => setState(() => _hoveredNav = ''),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _scrollTo(key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: hovered ? Colors.white.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: hovered ? Colors.white.withOpacity(0.4) : Colors.transparent),
          ),
          child: Text(label,
              style: TextStyle(
                  color: hovered ? Colors.white : Colors.white70,
                  fontSize: 14,
                  fontWeight: hovered ? FontWeight.w600 : FontWeight.normal,
                  letterSpacing: 0.5)),
        ),
      ),
    );
  }

  Widget _buildHero() {
    final screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      key: _heroKey,
      height: screenHeight - 64,
      child: Stack(fit: StackFit.expand, children: [
        PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (i) => setState(() => _currentPage = i),
          itemCount: _slides.length,
          itemBuilder: (_, i) => Image.asset(_slides[i].imagePath,
              fit: BoxFit.cover, width: double.infinity, height: double.infinity),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft, end: Alignment.centerRight,
              colors: [Color(0xEE000000), Color(0x55000000), Color(0x22000000)],
            ),
          ),
        ),
        FadeTransition(
          opacity: _fadeAnim,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(4)),
                  child: const Text("MALAWI'S LEADING MATERNAL HOSPITAL",
                      style: TextStyle(color: Colors.white, fontSize: 11, letterSpacing: 1.5)),
                ),
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(_slides[_currentPage].headline, key: ValueKey('h$_currentPage'),
                      style: const TextStyle(color: Colors.white, fontSize: 42,
                          fontWeight: FontWeight.bold, height: 1.2)),
                ),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(_slides[_currentPage].sub, key: ValueKey('s$_currentPage'),
                      style: const TextStyle(color: Colors.white70, fontSize: 16)),
                ),
                const SizedBox(height: 36),
                Row(children: [
                  ElevatedButton.icon(
                    onPressed: _onLogin,
                    icon: const Icon(Icons.login),
                    label: const Text('Login to Dashboard', style: TextStyle(fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _navy, foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () => _scrollTo(_aboutKey),
                    icon: const Icon(Icons.info_outline, color: Colors.white),
                    label: const Text('Learn More',
                        style: TextStyle(color: Colors.white, fontSize: 15)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white54),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 24, left: 0, right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_slides.length, (i) {
              final active = i == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 24 : 8, height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: active ? const Color(0xFF42A5F5) : Colors.white.withOpacity(0.35),
                ),
              );
            }),
          ),
        ),
      ]),
    );
  }

  Widget _buildAbout() {
    return _fullScreen(
      sectionKey: _aboutKey,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 72),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(
            width: 260, height: 260,
            decoration: BoxDecoration(color: _light, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.local_hospital, size: 120, color: _navy),
          ),
          const SizedBox(width: 64),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center, children: [
              _sectionTag('ABOUT US'),
              const SizedBox(height: 12),
              const Text('Committed to Maternal Health in Malawi',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,
                      color: Color(0xFF0A1628), height: 1.3)),
              const SizedBox(height: 20),
              const Text(
                'Safe Mother Malawi is a leading maternal and child health hospital dedicated to reducing maternal mortality across Malawi. Founded in 2010, we have served over 50,000 mothers and newborns with compassionate, evidence-based care.\n\nOur multidisciplinary team of obstetricians, midwives, neonatologists, and nurses work together to ensure every mother and child receives the highest standard of care.',
                style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.8),
              ),
              const SizedBox(height: 28),
              Row(children: [
                _aboutStat('50,000+', 'Mothers Served'),
                const SizedBox(width: 40),
                _aboutStat('200+', 'Medical Staff'),
                const SizedBox(width: 40),
                _aboutStat('15+', 'Years of Service'),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _aboutStat(String value, String label) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _navy)),
      Text(label, style: const TextStyle(fontSize: 13, color: Colors.black45)),
    ]);
  }

  Widget _buildServices() {
    final services = [
      (Icons.pregnant_woman,   'Maternity Care',     'Comprehensive prenatal, delivery and neonatal care for mothers.'),
      (Icons.child_care,       'Neonatal Unit',      'Specialised care for premature and critically ill newborns.'),
      (Icons.monitor_heart,    'Patient Monitoring', '24/7 vital signs monitoring with modern ICU equipment.'),
      (Icons.medical_services, 'Surgical Services',  'Emergency and elective obstetric surgeries by expert surgeons.'),
      (Icons.vaccines,         'Immunisation',       'Full vaccination programmes for mothers and children.'),
      (Icons.psychology,       'Mental Health',      'Neonatal depression support and counselling services.'),
    ];
    return _fullScreen(
      sectionKey: _servicesKey,
      child: Container(
        color: _bg,
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 72),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          _sectionTag('OUR SERVICES'),
          const SizedBox(height: 12),
          const Text('What We Offer',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF0A1628))),
          const SizedBox(height: 48),
          Wrap(spacing: 24, runSpacing: 24,
              children: services.map((s) => _serviceCard(s.$1, s.$2, s.$3)).toList()),
        ]),
      ),
    );
  }

  Widget _serviceCard(IconData icon, String title, String desc) {
    return Container(
      width: 280, padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(color: _light, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: _navy, size: 28),
        ),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A1628))),
        const SizedBox(height: 8),
        Text(desc, style: const TextStyle(fontSize: 13, color: Colors.black45, height: 1.6)),
      ]),
    );
  }

  Widget _buildNews() {
    final news = [
      (Icons.newspaper,          'New Neonatal ICU Wing Opens',   'Safe Mother Malawi proudly opens its expanded neonatal intensive care unit with 20 new incubators.',      'March 2026'),
      (Icons.campaign,           'Free Maternal Health Camp',     'Join us for a free maternal health screening camp open to all expectant mothers across Lilongwe.',       'February 2026'),
      (Icons.science,            'Research Partnership with WHO', 'We have signed a landmark research agreement with WHO to study maternal mortality reduction strategies.', 'January 2026'),
      (Icons.volunteer_activism, 'Community Outreach Programme',  'Our mobile health units reached over 3,000 women in rural Malawi this quarter.',                         'December 2025'),
    ];
    return _fullScreen(
      sectionKey: _newsKey,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 72),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          _sectionTag('LATEST NEWS'),
          const SizedBox(height: 12),
          const Text('News & Announcements',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF0A1628))),
          const SizedBox(height: 48),
          Wrap(spacing: 24, runSpacing: 24,
              children: news.map((n) => _newsCard(n.$1, n.$2, n.$3, n.$4)).toList()),
        ]),
      ),
    );
  }

  Widget _newsCard(IconData icon, String title, String body, String date) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: _bg, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: 120,
          decoration: BoxDecoration(color: _blue,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
          child: Center(child: Icon(icon, size: 56, color: Colors.white.withOpacity(0.7))),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(date, style: const TextStyle(fontSize: 11, color: _green,
                fontWeight: FontWeight.w600, letterSpacing: 1)),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                color: Color(0xFF0A1628))),
            const SizedBox(height: 8),
            Text(body, style: const TextStyle(fontSize: 13, color: Colors.black45, height: 1.6)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Text('Read more', style: TextStyle(color: _navy, fontSize: 13)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 14, color: _navy),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildContact() {
    return _fullScreen(
      sectionKey: _contactKey,
      child: Container(
        color: _bg,
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 72),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          _sectionTag('CONTACT US'),
          const SizedBox(height: 12),
          const Text('Get in Touch',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF0A1628))),
          const SizedBox(height: 48),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(children: [
                _contactInfo(Icons.location_on,  'Address',       'Area 18, Lilongwe, Malawi'),
                const SizedBox(height: 16),
                _contactInfo(Icons.phone,         'Phone',         '+265 1 234 567'),
                const SizedBox(height: 16),
                _contactInfo(Icons.email,         'Email',         'info@safemothermalawi.org'),
                const SizedBox(height: 16),
                _contactInfo(Icons.access_time,   'Working Hours', 'Mon–Fri: 8am–6pm  |  Emergency: 24/7'),
              ]),
            ),
            const SizedBox(width: 48),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16)],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Send us a Message',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                          color: Color(0xFF0A1628))),
                  const SizedBox(height: 24),
                  _formField('Full Name', Icons.person),
                  const SizedBox(height: 16),
                  _formField('Email Address', Icons.email),
                  const SizedBox(height: 16),
                  _formField('Subject', Icons.subject),
                  const SizedBox(height: 16),
                  TextFormField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Your message...',
                      hintStyle: const TextStyle(color: Colors.black38),
                      filled: true, fillColor: _bg,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.send),
                      label: const Text('Send Message', style: TextStyle(fontSize: 15)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _navy, foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _contactInfo(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: _light, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: _navy, size: 22),
        ),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black45, letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
              color: Color(0xFF0A1628))),
        ]),
      ]),
    );
  }

  Widget _formField(String hint, IconData icon) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38),
        prefixIcon: Icon(icon, color: _navy, size: 20),
        filled: true, fillColor: _bg,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      color: _navy,
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
      child: const Row(children: [
        Text('© 2026 Safe Mother Malawi. All rights reserved.',
            style: TextStyle(color: Colors.white54, fontSize: 13)),
        Spacer(),
        Text('Ministry of Health · Malawi',
            style: TextStyle(color: Colors.white38, fontSize: 12)),
      ]),
    );
  }

  Widget _sectionTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: _light, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: const TextStyle(color: _navy, fontSize: 11,
              fontWeight: FontWeight.bold, letterSpacing: 1.5)),
    );
  }
}
