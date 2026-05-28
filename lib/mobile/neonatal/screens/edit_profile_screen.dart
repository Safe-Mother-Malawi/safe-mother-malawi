import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth/models/user_model.dart';
import '../../auth/services/auth_service.dart';
import '../../../services/api_service.dart';
import '../../../services/offline_api_service.dart';
import '../../../utils/profile_photo_utils.dart';

class NeonatalEditProfileScreen extends StatefulWidget {
  final UserModel user;
  const NeonatalEditProfileScreen({super.key, required this.user});

  @override
  State<NeonatalEditProfileScreen> createState() =>
      _NeonatalEditProfileScreenState();
}

class _NeonatalEditProfileScreenState extends State<NeonatalEditProfileScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _districtController;
  late TextEditingController _facilityController;
  late TextEditingController _babyNameController;
  late TextEditingController _babyDobController;
  late TextEditingController _babyGenderController;
  late TextEditingController _babyBirthWeightController;

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
    _babyNameController = TextEditingController(text: widget.user.babyName);
    _babyDobController = TextEditingController(text: widget.user.babyDob);
    _babyGenderController = TextEditingController(text: widget.user.babyGender);
    _babyBirthWeightController =
        TextEditingController(text: widget.user.babyBirthWeight);
    _photoUrl = widget.user.profilePhotoUrl.isNotEmpty
        ? widget.user.profilePhotoUrl
        : null;
    _loadPhoto();
  }

  Future<void> _loadPhoto() async {
    if (_photoUrl != null && _photoUrl!.isNotEmpty) return;
    try {
      final user = await ApiService.instance.currentUser();
      if (mounted && user != null) {
        final photo = user['profilePhotoUrl'] as String?;
        setState(() => _photoUrl = photo);
      }
    } catch (_) {}
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
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
      final updatedUser = widget.user.copyWith(profilePhotoUrl: url ?? '');
      await AuthService().persistSession(updatedUser);
      if (mounted) setState(() => _photoUrl = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Photo upload failed: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _removePhoto() async {
    setState(() => _uploadingPhoto = true);
    try {
      await ApiService.uploadProfilePhoto(null);
      final updatedUser = widget.user.copyWith(profilePhotoUrl: '');
      await AuthService().persistSession(updatedUser);
      if (mounted) setState(() => _photoUrl = null);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Photo removal failed: $e'),
              backgroundColor: Colors.red),
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
    _babyNameController.dispose();
    _babyDobController.dispose();
    _babyGenderController.dispose();
    _babyBirthWeightController.dispose();
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

    if (_babyNameController.text.isEmpty) {
      setState(() => _errorMessage = "Baby's name is required");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await OfflineApiService().put('/auth/me', {
        'fullName': _fullNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'district': _districtController.text,
        'facilityName': _facilityController.text,
      });

      // Update user in auth service
      final updatedUser = widget.user.copyWith(
        email: _emailController.text,
        fullName: _fullNameController.text,
        phone: _phoneController.text,
        babyName: _babyNameController.text,
        babyDob: _babyDobController.text,
        district: _districtController.text,
        facilityName: _facilityController.text,
        babyGender: _babyGenderController.text,
        babyBirthWeight: _babyBirthWeightController.text,
        profilePhotoUrl: _photoUrl ?? '',
      );
      await AuthService().persistSession(updatedUser);

      if (mounted) {
        final queued = result is Map && result['queued'] == true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(queued
                ? 'Profile update saved locally and will sync when online.'
                : 'Profile updated successfully'),
            backgroundColor: queued ? Colors.orange : Colors.green,
          ),
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
      initialDate: _babyDobController.text.isNotEmpty
          ? DateTime.tryParse(_babyDobController.text) ?? DateTime.now()
          : DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() =>
          _babyDobController.text = picked.toIso8601String().split('T')[0]);
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
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Center(
              child: GestureDetector(
                onTap: _uploadingPhoto ? null : _pickPhoto,
                child: Stack(children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: const Color(0xFFE8EAF6),
                    backgroundImage: buildProfilePhotoProvider(_photoUrl),
                    child: _uploadingPhoto
                        ? const CircularProgressIndicator(
                            strokeWidth: 2, color: Color(0xFF1A237E))
                        : _photoUrl == null
                            ? const Icon(Icons.person,
                                size: 52, color: Color(0xFF9E9E9E))
                            : null,
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                          color: Color(0xFF1A237E), shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt_rounded,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                _photoUrl == null
                    ? 'Tap to upload a photo'
                    : 'Tap photo to change it',
                style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
              ),
            ),
            if (_photoUrl != null) ...[
              const SizedBox(height: 10),
              Center(
                child: TextButton.icon(
                  onPressed: _uploadingPhoto ? null : _removePhoto,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Remove photo'),
                  style:
                      TextButton.styleFrom(foregroundColor: Colors.redAccent),
                ),
              ),
            ],
            const SizedBox(height: 20),
            const Text(
              'Mother Information',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A237E)),
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
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A237E)),
            ),
            const SizedBox(height: 12),
            _buildTextField('District', _districtController, Icons.location_on),
            const SizedBox(height: 12),
            _buildTextField(
                'Health Facility', _facilityController, Icons.local_hospital),
            const SizedBox(height: 20),
            const Text(
              'Baby Information',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A237E)),
            ),
            const SizedBox(height: 12),
            _buildTextField(
                "Baby's Name", _babyNameController, Icons.child_care),
            const SizedBox(height: 12),
            _buildDateField('Date of Birth', _babyDobController, _selectDate),
            const SizedBox(height: 12),
            _buildDropdownField(
                'Gender', _babyGenderController, ['Male', 'Female', 'Other']),
            const SizedBox(height: 12),
            _buildTextField('Birth Weight (kg)', _babyBirthWeightController,
                Icons.monitor_weight),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isLoading ? null : _saveProfile,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white)),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon) {
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

  Widget _buildDateField(
      String label, TextEditingController controller, VoidCallback onTap) {
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

  Widget _buildDropdownField(
      String label, TextEditingController controller, List<String> options) {
    return DropdownButtonFormField<String>(
      value: controller.text.isNotEmpty ? controller.text : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.wc, color: Color(0xFF1A237E)),
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
      items: options
          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => controller.text = value);
        }
      },
    );
  }
}
