import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class RuleBuilder extends StatefulWidget {
  const RuleBuilder({super.key});

  @override
  State<RuleBuilder> createState() => _RuleBuilderState();
}

class _RuleBuilderState extends State<RuleBuilder> {
  final List<Map<String, String>> _rules = [
    {'if': 'Risk Level = High', 'then': 'Assign ANC Visit within 24h', 'status': 'Active'},
    {'if': 'IVR Drop-off > 3 times', 'then': 'Flag for clinician callback', 'status': 'Active'},
    {'if': 'Task Missed > 2 days', 'then': 'Send alert to DHO', 'status': 'Inactive'},
  ];

  String _ifCondition = 'Risk Level';
  String _ifOperator = '=';
  String _ifValue = 'High';
  String _thenAction = 'Assign Task';
  String _thenDetail = '';
  final _thenDetailCtrl = TextEditingController();

  @override
  void dispose() {
    _thenDetailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rule Builder',
              style: GoogleFonts.publicSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.headings)),
          const SizedBox(height: 6),
          Text('Create automated task assignment rules',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText)),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rule builder form
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                          color: AppColors.shadowColor,
                          blurRadius: 24,
                          offset: Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('New Rule',
                          style: GoogleFonts.publicSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.headings)),
                      const SizedBox(height: 20),

                      // IF block
                      _BlockLabel(label: 'IF', color: AppColors.primary),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.infoBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _RuleDrop(
                              value: _ifCondition,
                              items: const [
                                'Risk Level', 'IVR Drop-off', 'Task Missed',
                                'Clinician Inactive', 'Assessment Score'
                              ],
                              onChanged: (v) => setState(() => _ifCondition = v!),
                            ),
                            _RuleDrop(
                              value: _ifOperator,
                              items: const ['=', '>', '<', '>=', '<=', '!='],
                              onChanged: (v) => setState(() => _ifOperator = v!),
                            ),
                            _RuleDrop(
                              value: _ifValue,
                              items: const [
                                'High', 'Medium', 'Low', '1', '2', '3',
                                '24h', '48h', '7 days'
                              ],
                              onChanged: (v) => setState(() => _ifValue = v!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // THEN block
                      _BlockLabel(label: 'THEN', color: AppColors.tertiary),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2F1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _RuleDrop(
                              value: _thenAction,
                              items: const [
                                'Assign Task', 'Send Alert', 'Flag for Review',
                                'Notify DHO', 'Escalate to Admin'
                              ],
                              onChanged: (v) => setState(() => _thenAction = v!),
                            ),
                            SizedBox(
                              width: 220,
                              child: TextField(
                                controller: _thenDetailCtrl,
                                onChanged: (v) => _thenDetail = v,
                                style: GoogleFonts.inter(
                                    fontSize: 13, color: AppColors.onSurface),
                                decoration: InputDecoration(
                                  hintText: 'Describe action detail...',
                                  hintStyle: GoogleFonts.inter(
                                      fontSize: 13, color: AppColors.mutedText),
                                  filled: true,
                                  fillColor: AppColors.surfaceContainerLowest,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Preview
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.preview_rounded,
                                size: 16, color: AppColors.mutedText),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'IF $_ifCondition $_ifOperator $_ifValue → THEN $_thenAction${_thenDetail.isNotEmpty ? ': $_thenDetail' : ''}',
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.bodyText,
                                    fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _rules.add({
                              'if': '$_ifCondition $_ifOperator $_ifValue',
                              'then': '$_thenAction${_thenDetail.isNotEmpty ? ': $_thenDetail' : ''}',
                              'status': 'Active',
                            });
                            _thenDetailCtrl.clear();
                            _thenDetail = '';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_rounded,
                                  color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text('Save Rule',
                                  style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Existing rules
              SizedBox(
                width: 320,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                          color: AppColors.shadowColor,
                          blurRadius: 24,
                          offset: Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Active Rules',
                          style: GoogleFonts.publicSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.headings)),
                      const SizedBox(height: 16),
                      ..._rules.asMap().entries.map((e) => _RuleCard(
                            rule: e.value,
                            onDelete: () =>
                                setState(() => _rules.removeAt(e.key)),
                            onToggle: () => setState(() {
                              _rules[e.key]['status'] =
                                  _rules[e.key]['status'] == 'Active'
                                      ? 'Inactive'
                                      : 'Active';
                            }),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BlockLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _BlockLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: GoogleFonts.publicSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1)),
    );
  }
}

class _RuleDrop extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _RuleDrop(
      {required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
          items: items
              .map((i) => DropdownMenuItem(value: i, child: Text(i)))
              .toList(),
        ),
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  final Map<String, String> rule;
  final VoidCallback onDelete;
  final VoidCallback onToggle;
  const _RuleCard(
      {required this.rule, required this.onDelete, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isActive = rule['status'] == 'Active';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.successText
                      : AppColors.mutedText,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(isActive ? 'Active' : 'Inactive',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? AppColors.successText
                          : AppColors.mutedText)),
              const Spacer(),
              InkWell(
                onTap: onToggle,
                child: Icon(
                  isActive
                      ? Icons.pause_circle_outline_rounded
                      : Icons.play_circle_outline_rounded,
                  size: 18,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onDelete,
                child: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: AppColors.criticalText),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.bodyText),
              children: [
                const TextSpan(
                    text: 'IF ',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
                TextSpan(text: rule['if']),
                const TextSpan(
                    text: '\nTHEN ',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.tertiary)),
                TextSpan(text: rule['then']),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
