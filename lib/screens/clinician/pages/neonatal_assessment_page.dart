import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../services/api_service.dart';

class NeonatalAssessmentPage extends StatefulWidget {
  final String? neonatalPatientId;
  final String? patientName;

  const NeonatalAssessmentPage({super.key, this.neonatalPatientId, this.patientName});

  @override
  State<NeonatalAssessmentPage> createState() => _NeonatalAssessmentPageState();
}

class _NeonatalAssessmentPageState extends State<NeonatalAssessmentPage> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  // ─── Vitals ───
  final _tempCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _respRateCtrl = TextEditingController();
  final _o2SatCtrl = TextEditingController();

  // ─── Danger Signs ───
  bool _dsNotFeeding = false;
  bool _dsConvulsions = false;
  bool _dsFastBreathing = false;
  bool _dsSevereChestIndrawing = false;
  bool _dsFeverOrLowTemp = false;
  bool _dsJaundice = false;
  bool _dsUmbilicalPus = false;

  @override
  void dispose() {
    _tempCtrl.dispose();
    _weightCtrl.dispose();
    _respRateCtrl.dispose();
    _o2SatCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.neonatalPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No patient selected for this visit.'), backgroundColor: AppColors.red),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final symptoms = <String>[];
      if (_dsNotFeeding) symptoms.add('Not feeding well');
      if (_dsConvulsions) symptoms.add('Convulsions');
      if (_dsFastBreathing) symptoms.add('Fast breathing');
      if (_dsSevereChestIndrawing) symptoms.add('Severe chest in-drawing');
      if (_dsFeverOrLowTemp) symptoms.add('Fever or Low temp');
      if (_dsJaundice) symptoms.add('Jaundice');
      if (_dsUmbilicalPus) symptoms.add('Umbilical cord pus/bleeding');

      // Add to risk assessment API via appointment process endpoint
      // We will create a generic 'neonatal' appointment completion
      await ApiService.instance.post('/appointments/complete-visit', {
        'patientId': widget.neonatalPatientId,
        'patientType': 'neonatal',
        'type': 'NEONATAL',
        'notes': 'Neonatal Assessment\nTemp: ${_tempCtrl.text} °C\nWeight: ${_weightCtrl.text} kg\nResp: ${_respRateCtrl.text} /min\nO2: ${_o2SatCtrl.text} %',
        'symptoms': symptoms,
        'bloodPressure': null,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Neonatal Assessment for ${widget.patientName ?? "Baby"} recorded successfully.'),
            backgroundColor: AppColors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save assessment: $e'), backgroundColor: AppColors.red),
        );
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Neonatal Assessment — ${widget.patientName ?? "Baby"}',
            style: const TextStyle(color: AppColors.g800, fontSize: 16, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.g800),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.g200, height: 1),
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.infoBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: const Row(children: [
                      Icon(Icons.child_care, color: AppColors.primary),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Record the baby\'s current vitals and check for any danger signs. This data will be analyzed by the Risk Engine.',
                          style: TextStyle(fontSize: 13, color: AppColors.g800),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 32),

                  _sectionTitle('Vitals'),
                  _buildFormGrid([
                    _buildTextField('Temperature (°C)', _tempCtrl, 'e.g., 36.5', true),
                    _buildTextField('Weight (kg)', _weightCtrl, 'e.g., 3.2', true),
                    _buildTextField('Respiratory Rate (/min)', _respRateCtrl, 'e.g., 40', true),
                    _buildTextField('Oxygen Saturation (%)', _o2SatCtrl, 'e.g., 98', true),
                  ]),
                  
                  const SizedBox(height: 32),
                  _sectionTitle('Danger Signs Checklist'),
                  const Text('Select all that apply:', style: TextStyle(fontSize: 13, color: AppColors.g600)),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.g200),
                    ),
                    child: Column(
                      children: [
                        _buildCheckbox('Not feeding well', _dsNotFeeding, (v) => setState(() => _dsNotFeeding = v!)),
                        _buildCheckbox('Convulsions', _dsConvulsions, (v) => setState(() => _dsConvulsions = v!)),
                        _buildCheckbox('Fast breathing (≥60 breaths/min)', _dsFastBreathing, (v) => setState(() => _dsFastBreathing = v!)),
                        _buildCheckbox('Severe chest in-drawing', _dsSevereChestIndrawing, (v) => setState(() => _dsSevereChestIndrawing = v!)),
                        _buildCheckbox('Fever (≥38°C) or Low temp (<35.5°C)', _dsFeverOrLowTemp, (v) => setState(() => _dsFeverOrLowTemp = v!)),
                        _buildCheckbox('Yellow soles/palms (Jaundice)', _dsJaundice, (v) => setState(() => _dsJaundice = v!)),
                        _buildCheckbox('Umbilical cord pus/bleeding', _dsUmbilicalPus, (v) => setState(() => _dsUmbilicalPus = v!)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel', style: TextStyle(color: AppColors.g600)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _saving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _saving
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Save Assessment', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Helpers ───
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(width: 4, height: 18, color: AppColors.navy, margin: const EdgeInsets.only(right: 12)),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.g800)),
        ],
      ),
    );
  }

  Widget _buildFormGrid(List<Widget> children) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 24,
      mainAxisSpacing: 20,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 3.5,
      children: children,
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, String hint, bool isNumeric) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g800),
            children: const [TextSpan(text: ' *', style: TextStyle(color: AppColors.red))],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.g400, fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.g200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.g200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.navy)),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 24, height: 24,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.g800))),
          ],
        ),
      ),
    );
  }
}

