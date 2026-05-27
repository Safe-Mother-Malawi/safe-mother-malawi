import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../../auth/models/user_model.dart';
import '../../../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _districtController;
  late TextEditingController _facilityController;
  late TextEditingController _lmpDateController;
  late TextEditingController _babyNameController;

  bool _isLoading = false;
  bool _uploadingPhoto = false;
  String? _errorMessage;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
    _districtController = TextEditingController(text: widget.user.district);
    _facilityController = TextEditingController(text: widget.user.facilityName);
    _lmpDateController = TextEditingController(text: widget.user.lmpDate);
    _babyNameController = TextEditingController(text: widget.user.babyName);
    // Load existing photo from backend
    _loadPhoto();
  }

  Future<void> _loadPhoto() async {
    try {
      final user = await ApiService.instance.currentUser();
      if (mounted && user != null) {
        setState(() => _photoUrl = user['profilePhotoUrl'] as String?);
      }
    } catch (_) {}
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512, maxHeight: 512,
      imageQuality: 80,
    );
    if (picked == null || !mounted) return;

    setState(() => _uploadingPhoto = true);
    try {
      final bytes = await picked.readAsBytes();
      final ext = picked.name.split('.').last.toLowerCase();
      final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
      final base64Str = 'data:$mime;base64,${base64Encode(bytes)}';
      final url = await ApiService.uploadProfilePhoto(base64Str);
      if (mounted) setState(() => _photoUrl = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Photo upload failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _districtController.dispose();
    _facilityController.dispose();
    _lmpDateController.dispose();
    _babyNameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_fullNameController.text.isEmpty) {
      setState(() => _errorMessage = 'Full name is required');
      return;
    }

    if (_phoneController.text.isEmpty) {
      setState(() => _errorMessage = 'Phone number is required');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ApiService.instance.patch('/auth/me', {
        'fullName': _fullNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'district': _districtController.text,
        'facilityName': _facilityController.text,
      });

      // Update user in auth service
      final updatedUser = UserModel(
        email: _emailController.text,
        password: '',
        role: widget.user.role,
        fullName: _fullNameController.text,
        phone: _phoneController.text,
        lmpDate: _lmpDateController.text,
        babyName: _babyNameController.text,
        babyDob: widget.user.babyDob,
        age: widget.user.age,
        nationality: widget.user.nationality,
        district: _districtController.text,
        facilityName: _facilityController.text,
        pregnancyMonths: widget.user.pregnancyMonths,
        pregnancyWeeks: widget.user.pregnancyWeeks,
        expectedDeliveryDate: widget.user.expectedDeliveryDate,
        babyGender: widget.user.babyGender,
        babyBirthWeight: widget.user.babyBirthWeight,
        securityQuestion: widget.user.securityQuestion,
        securityAnswer: widget.user.securityAnswer,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context, updatedUser);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error updating profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lmpDateController.text.isNotEmpty
          ? DateTime.tryParse(_lmpDateController.text) ?? DateTime.now()
          : DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _lmpDateController.text = picked.toIso8601String().split('T')[0]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo picker
            Center(
              child: GestureDetector(
                onTap: _uploadingPhoto ? null : _pickPhoto,
                child: Stack(children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: const Color(0xFFE8EAF6),
                    backgroundImage: _photoUrl != null && _photoUrl!.startsWith('data:')
                        ? MemoryImage(base64Decode(_photoUrl!.split(',').last))
                        : null,
                    child: _uploadingPhoto
                        ? const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A237E))
                        : _photoUrl == null
                            ? const Icon(Icons.person, size: 52, color: Color(0xFF9E9E9E))
                            : null,
                  ),
                  Positioned(
                    bottom: 2, right: 2,
                    child: Container(
                      width: 30, height: 30,
                      decoration: const BoxDecoration(color: Color(0xFF1A237E), shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 6),
            const Center(child: Text('Tap to change photo',
                style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)))),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red[700], fontSize: 14),
                ),
              ),
            if (_errorMessage != null) const SizedBox(height: 16),
            const Text(
              'Personal Information',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A237E)),
            ),
            const SizedBox(height: 12),
            _buildTextField('Full Name', _fullNameController, Icons.person),
            const SizedBox(height: 12),
            _buildTextField('Email', _emailController, Icons.email),
            const SizedBox(height: 12),
            _buildTextField('Phone', _phoneController, Icons.phone),
            const SizedBox(height: 20),
            const Text(
              'Location Information',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A237E)),
            ),
            const SizedBox(height: 12),
            _buildTextField('District', _districtController, Icons.location_on),
            const SizedBox(height: 12),
            _buildTextField('Health Facility', _facilityController, Icons.local_hospital),
            const SizedBox(height: 20),
            const Text(
              'Pregnancy Information',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A237E)),
            ),
            const SizedBox(height: 12),
            _buildDateField('LMP Date', _lmpDateController, _selectDate),
            const SizedBox(height: 12),
            _buildTextField('Baby Name', _babyNameController, Icons.child_care),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isLoading ? null : _saveProfile,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1A237E)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE3E8FF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
        ),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, VoidCallback onTap) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF1A237E)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE3E8FF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
        ),
      ),
    );
  }
}

