import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../services/api_service.dart';

class ANCVisitPage extends StatefulWidget {
  final String? prenatalPatientId;
  final String? patientName;

  const ANCVisitPage({super.key, this.prenatalPatientId, this.patientName});

  @override
  State<ANCVisitPage> createState() => _ANCVisitPageState();
}

class _ANCVisitPageState extends State<ANCVisitPage> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  // ─── Maternal Vitals ───
  final _bpCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();
  final _pulseCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();

  // ─── Pregnancy Monitoring ───
  final _gestationalAgeCtrl = TextEditingController();
  final _fundalHeightCtrl = TextEditingController();
  final _fetalHeartRateCtrl = TextEditingController();
  String? _fetalMovement = 'Normal';
  String? _babyPresentation = 'Cephalic';

  // ─── Laboratory Results ───
  final _hbLevelCtrl = TextEditingController();
  String? _hivStatus = 'Negative';
  String? _urineProtein = 'Negative';
  final _bloodSugarCtrl = TextEditingController();
  String? _syphilisTest = 'Negative';

  // ─── Medications & Vaccines ───
  bool _ironTablets = false;
  bool _folicAcid = false;
  bool _spFansidar = false;
  bool _tetanusVaccine = false;

  // ─── Danger Signs ───
  bool _dsBleeding = false;
  bool _dsHeadache = false;
  bool _dsConvulsions = false;
  bool _dsSwollenFeet = false;
  bool _dsFever = false;
  bool _dsReducedMovement = false;

  @override
  void dispose() {
    _bpCtrl.dispose();
    _weightCtrl.dispose();
    _tempCtrl.dispose();
    _pulseCtrl.dispose();
    _heightCtrl.dispose();
    _gestationalAgeCtrl.dispose();
    _fundalHeightCtrl.dispose();
    _fetalHeartRateCtrl.dispose();
    _hbLevelCtrl.dispose();
    _bloodSugarCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.prenatalPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No patient selected for this visit.'), backgroundColor: AppColors.red),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final ancData = {
        'vitals': {
          'bloodPressure': _bpCtrl.text.trim(),
          'weight': _weightCtrl.text.trim(),
          'temperature': _tempCtrl.text.trim(),
          'pulse': _pulseCtrl.text.trim(),
          'height': _heightCtrl.text.trim(),
        },
        'monitoring': {
          'gestationalAge': _gestationalAgeCtrl.text.trim(),
          'fundalHeight': _fundalHeightCtrl.text.trim(),
          'fetalHeartRate': _fetalHeartRateCtrl.text.trim(),
          'fetalMovement': _fetalMovement,
          'babyPresentation': _babyPresentation,
        },
        'laboratory': {
          'hbLevel': _hbLevelCtrl.text.trim(),
          'hivStatus': _hivStatus,
          'urineProtein': _urineProtein,
          'bloodSugar': _bloodSugarCtrl.text.trim(),
          'syphilisTest': _syphilisTest,
        },
        'medications': {
          'ironTablets': _ironTablets,
          'folicAcid': _folicAcid,
          'spFansidar': _spFansidar,
          'tetanusVaccine': _tetanusVaccine,
        },
        'dangerSigns': {
          'bleeding': _dsBleeding,
          'severeHeadache': _dsHeadache,
          'convulsions': _dsConvulsions,
          'swollenFeet': _dsSwollenFeet,
          'fever': _dsFever,
          'reducedFetalMovement': _dsReducedMovement,
        }
      };

      final payload = {
        'title': 'ANC Visit',
        'patientName': widget.patientName ?? 'Unknown Patient',
        'patientContact': 'N/A',
        'type': 'anc',
        'status': 'completed',
        'date': DateTime.now().toIso8601String().split('T')[0],
        'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        'prenatalPatientId': widget.prenatalPatientId,
        'ancData': ancData,
      };

      await ApiService.instance.post('/appointments', payload);
      
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ANC Visit recorded successfully.'), backgroundColor: AppColors.green),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving visit: $e'), backgroundColor: AppColors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.navy),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('New ANC Visit', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 16)),
            if (widget.patientName != null)
              Text('Patient: ${widget.patientName}', style: const TextStyle(color: AppColors.g600, fontSize: 12)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Maternal Vitals', Icons.monitor_heart_outlined),
                  _buildCard(
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildTextField('Blood pressure (mmHg)', _bpCtrl, hint: 'e.g. 120/80', width: 180),
                        _buildTextField('Weight (kg)', _weightCtrl, numeric: true, width: 140),
                        _buildTextField('Temperature (°C)', _tempCtrl, numeric: true, width: 140),
                        _buildTextField('Pulse (bpm)', _pulseCtrl, numeric: true, width: 140),
                        _buildTextField('Height (cm)', _heightCtrl, numeric: true, width: 140),
                      ],
                    ),
                  ),

                  _buildSectionHeader('Pregnancy Monitoring', Icons.pregnant_woman),
                  _buildCard(
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildTextField('Gestational age (weeks)', _gestationalAgeCtrl, numeric: true, width: 200),
                        _buildTextField('Fundal height (cm)', _fundalHeightCtrl, numeric: true, width: 180),
                        _buildTextField('Fetal heart rate (bpm)', _fetalHeartRateCtrl, numeric: true, width: 180),
                        _buildDropdown('Fetal movement', _fetalMovement, ['Normal', 'Reduced', 'Absent'], (v) => setState(() => _fetalMovement = v), width: 180),
                        _buildDropdown('Baby presentation', _babyPresentation, ['Cephalic', 'Breech', 'Transverse', 'Unknown'], (v) => setState(() => _babyPresentation = v), width: 180),
                      ],
                    ),
                  ),

                  _buildSectionHeader('Laboratory Results', Icons.science_outlined),
                  _buildCard(
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildTextField('Hb level (g/dL)', _hbLevelCtrl, numeric: true, width: 160),
                        _buildDropdown('HIV status', _hivStatus, ['Negative', 'Positive', 'Unknown'], (v) => setState(() => _hivStatus = v), width: 160),
                        _buildDropdown('Urine protein', _urineProtein, ['Negative', 'Trace', '+', '++', '+++'], (v) => setState(() => _urineProtein = v), width: 160),
                        _buildTextField('Blood sugar (mg/dL)', _bloodSugarCtrl, numeric: true, width: 180),
                        _buildDropdown('Syphilis test', _syphilisTest, ['Negative', 'Positive', 'Unknown'], (v) => setState(() => _syphilisTest = v), width: 160),
                      ],
                    ),
                  ),

                  _buildSectionHeader('Medications & Vaccines', Icons.medication_outlined),
                  _buildCard(
                    child: Wrap(
                      spacing: 24,
                      runSpacing: 12,
                      children: [
                        _buildCheckbox('Iron tablets', _ironTablets, (v) => setState(() => _ironTablets = v!)),
                        _buildCheckbox('Folic acid', _folicAcid, (v) => setState(() => _folicAcid = v!)),
                        _buildCheckbox('SP/Fansidar', _spFansidar, (v) => setState(() => _spFansidar = v!)),
                        _buildCheckbox('Tetanus vaccine', _tetanusVaccine, (v) => setState(() => _tetanusVaccine = v!)),
                      ],
                    ),
                  ),

                  _buildSectionHeader('Danger Signs', Icons.warning_amber_rounded, color: AppColors.red),
                  _buildCard(
                    child: Wrap(
                      spacing: 24,
                      runSpacing: 12,
                      children: [
                        _buildCheckbox('Bleeding', _dsBleeding, (v) => setState(() => _dsBleeding = v!)),
                        _buildCheckbox('Severe headache', _dsHeadache, (v) => setState(() => _dsHeadache = v!)),
                        _buildCheckbox('Convulsions', _dsConvulsions, (v) => setState(() => _dsConvulsions = v!)),
                        _buildCheckbox('Swollen feet', _dsSwollenFeet, (v) => setState(() => _dsSwollenFeet = v!)),
                        _buildCheckbox('Fever', _dsFever, (v) => setState(() => _dsFever = v!)),
                        _buildCheckbox('Reduced fetal movement', _dsReducedMovement, (v) => setState(() => _dsReducedMovement = v!)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _saving
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Save ANC Visit Record', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {Color color = AppColors.navy}) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.g200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool numeric = false, String? hint, double width = 200}) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.g800)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: numeric ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.g400, fontSize: 13),
              filled: true,
              fillColor: AppColors.bg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.g200)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.navy)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged, {double width = 200}) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.g800)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.g200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.g600),
                items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.navy,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.g800)),
      ],
    );
  }
}

