import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_colors.dart';
import '../models/pregnancy_data.dart';
import '../../auth/services/auth_service.dart';

class EducationScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;
  const EducationScreen({super.key, this.onOpenDrawer});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  PregnancyData? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await AuthService().getCurrentUser();
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    
    PregnancyData? data;
    if (user.lmpDate.isNotEmpty) {
      data = PregnancyData(lmp: DateTime.tryParse(user.lmpDate) ?? DateTime.now());
    } else if (user.totalPregnancyWeeks > 0) {
      data = PregnancyData.fromTotalWeeks(user.totalPregnancyWeeks);
    } else {
      data = PregnancyData.fromTotalWeeks(20);
    }
    
    if (mounted) {
      setState(() {
        _data = data;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.pageBg,
        body: Center(child: CircularProgressIndicator(color: AppColors.mobileNavy)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: AppColors.mobileNavy,
        elevation: 0,
        leading: widget.onOpenDrawer != null 
            ? IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: widget.onOpenDrawer)
            : null,
        title: Text('Health Education', style: GoogleFonts.publicSans(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: _data == null
          ? Center(child: Text('No data available', style: TextStyle(color: Colors.grey)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.mobileNavy.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.mobileNavy.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: AppColors.mobileNavy, size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Week ${_data!.currentWeek} Topics', 
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.mobileNavy)),
                              const SizedBox(height: 4),
                              Text('Personalized education based on your current pregnancy stage.',
                                style: GoogleFonts.inter(fontSize: 13, color: Colors.black54)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTopicCard(
                    icon: Icons.restaurant,
                    color: Colors.green,
                    title: 'Nutrition',
                    content: _data!.nutritionTip,
                  ),
                  _buildTopicCard(
                    icon: Icons.warning_amber_rounded,
                    color: Colors.red,
                    title: 'Danger Signs',
                    content: _data!.dangerSignsTip,
                  ),
                  _buildTopicCard(
                    icon: Icons.child_care,
                    color: Colors.blue,
                    title: 'Breastfeeding',
                    content: _data!.breastfeedingTip,
                  ),
                  _buildTopicCard(
                    icon: Icons.local_hospital,
                    color: Colors.purple,
                    title: 'Birth Preparedness',
                    content: _data!.birthPrepTip,
                  ),
                  _buildTopicCard(
                    icon: Icons.clean_hands,
                    color: Colors.teal,
                    title: 'Hygiene',
                    content: _data!.hygieneTip,
                  ),
                  _buildTopicCard(
                    icon: Icons.family_restroom,
                    color: Colors.orange,
                    title: 'Family Planning',
                    content: _data!.familyPlanningTip,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildTopicCard({
    required IconData icon,
    required Color color,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
