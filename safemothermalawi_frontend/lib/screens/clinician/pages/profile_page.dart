import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../../../theme/app_colors.dart';

class MyProfilePage extends StatefulWidget {
  final VoidCallback? onClose;
  const MyProfilePage({super.key, this.onClose});
  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  bool _editing = false;
  Uint8List? _photoBytes;

  final _nameCtrl       = TextEditingController(text: 'Dr. Rachel Phiri');
  final _emailCtrl      = TextEditingController(text: 'rachel.phiri@safemothermalawi.org');
  final _phoneCtrl      = TextEditingController(text: '+265 991 000 111');
  final _roleCtrl       = TextEditingController(text: 'Clinician');
  final _facilityCtrl   = TextEditingController(text: 'Zomba Central Health Centre');
  final _districtCtrl   = TextEditingController(text: 'Zomba');
  final _licenceCtrl    = TextEditingController(text: 'MCL-2019-04821');
  final _qualCtrl       = TextEditingController(text: 'MBChB, MMed (Obs & Gynae)');
  final _experienceCtrl = TextEditingController(text: '7 years');

  @override
  void dispose() {
    for (final c in [_nameCtrl, _emailCtrl, _phoneCtrl, _roleCtrl,
        _facilityCtrl, _districtCtrl, _licenceCtrl, _qualCtrl, _experienceCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _photoBytes = bytes);
  }

  void _save() {
    setState(() => _editing = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(children: [
        Icon(Icons.check, color: Colors.white, size: 16),
        SizedBox(width: 8),
        Text('Profile updated successfully.'),
      ]),
      backgroundColor: const Color(0xFF1A3A5C),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Scrollable content
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // ── Close button row ───────────────────────────────────────────
              if (widget.onClose != null)
                Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                          color: AppColors.navy, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.close, size: 18, color: Colors.white),
                    ),
                  ),
                ),
              if (widget.onClose != null) const SizedBox(height: 12),
              // ── Hero card ──────────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  // Avatar
                  GestureDetector(
                    onTap: _editing ? _pickPhoto : null,
                    child: Stack(children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white.withOpacity(0.15),
                        backgroundImage: _photoBytes != null
                            ? MemoryImage(_photoBytes!) : null,
                        child: _photoBytes == null
                            ? const Text('RP', style: TextStyle(fontSize: 22,
                                fontWeight: FontWeight.bold, color: Colors.white))
                            : null,
                      ),
                      if (_editing)
                        Positioned(bottom: 0, right: 0,
                          child: Container(
                            width: 22, height: 22,
                            decoration: const BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt,
                                color: AppColors.navy, size: 13),
                          ),
                        ),
                    ]),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(_nameCtrl.text,
                        style: const TextStyle(color: Colors.white, fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 3),
                    Text(_roleCtrl.text,
                        style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 3),
                    Text(_facilityCtrl.text,
                        style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: AppColors.greenL, borderRadius: BorderRadius.circular(16)),
                    child: const Text('Active',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                            color: AppColors.green)),
                  ),
                ]),
              ),
              const SizedBox(height: 16),

              // ── Personal Information ───────────────────────────────────────
              _sectionHeader('Personal Information'),
              _field('Full Name', _nameCtrl, Icons.person_outline),
              _field('Email Address', _emailCtrl, Icons.email_outlined),
              _field('Phone Number', _phoneCtrl, Icons.phone_outlined),
              const SizedBox(height: 12),

              // ── Work Details ───────────────────────────────────────────────
              _sectionHeader('Work Details'),
              _field('Role', _roleCtrl, Icons.badge_outlined),
              _field('Health Facility', _facilityCtrl, Icons.local_hospital_outlined),
              _field('District', _districtCtrl, Icons.location_on_outlined),
              const SizedBox(height: 12),

              // ── Professional Details ───────────────────────────────────────
              _sectionHeader('Professional Details'),
              _field('Licence Number', _licenceCtrl, Icons.verified_outlined),
              _field('Qualifications', _qualCtrl, Icons.school_outlined),
              _field('Years of Experience', _experienceCtrl, Icons.timeline_outlined),
              const SizedBox(height: 80), // space for sticky bar
            ]),
        ),
      ),

      // ── Sticky bottom bar ──────────────────────────────────────────────────
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppColors.g200)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
              blurRadius: 8, offset: const Offset(0, -2))],
        ),
        child: Row(children: [
          if (_editing) ...[
            OutlinedButton(
              onPressed: () => setState(() => _editing = false),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.g600,
                side: const BorderSide(color: AppColors.g200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save, size: 16),
                label: const Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ),
          ] else
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _editing = true),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ),
        ]),
      ),
    ]);
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Container(width: 3, height: 14, color: AppColors.navy,
            margin: const EdgeInsets.only(right: 8)),
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
            color: AppColors.g800)),
      ]),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon) {
    if (!_editing) {
      return Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: AppColors.bg,
            borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          Icon(icon, size: 15, color: AppColors.navy),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.g600)),
          const Spacer(),
          Text(ctrl.text, style: const TextStyle(fontSize: 12,
              fontWeight: FontWeight.w600, color: AppColors.g800)),
        ]),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12, color: AppColors.g600),
          prefixIcon: Icon(icon, size: 16, color: AppColors.navy),
          filled: true, fillColor: AppColors.bg,
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.g200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.g200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.navy, width: 1.5)),
        ),
      ),
    );
  }
}
