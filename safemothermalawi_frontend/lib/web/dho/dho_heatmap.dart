import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class DhoHeatmap extends StatelessWidget {
  const DhoHeatmap({super.key});

  final List<Map<String, dynamic>> _zones = const [
    {'name': 'Blantyre South', 'risk': 0.85, 'x': 0.50, 'y': 0.60},
    {'name': 'Blantyre North', 'risk': 0.45, 'x': 0.48, 'y': 0.40},
    {'name': 'Blantyre Central', 'risk': 0.70, 'x': 0.52, 'y': 0.50},
    {'name': 'Chilomoni', 'risk': 0.55, 'x': 0.44, 'y': 0.55},
    {'name': 'Ndirande', 'risk': 0.65, 'x': 0.56, 'y': 0.45},
    {'name': 'Limbe', 'risk': 0.40, 'x': 0.60, 'y': 0.62},
  ];

  Color _heatColor(double v) {
    if (v >= 0.7) return AppColors.criticalText;
    if (v >= 0.4) return AppColors.warningText;
    return AppColors.successText;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Heatmaps',
                  style: GoogleFonts.publicSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.headings)),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.infoBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Blantyre District',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.infoText)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Risk distribution across Blantyre zones',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText)),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  height: 480,
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFE8F4FD), Color(0xFFD0E8F5)],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 20,
                          left: 20,
                          child: Text('BLANTYRE DISTRICT',
                              style: GoogleFonts.publicSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondary,
                                  letterSpacing: 2)),
                        ),
                        ..._zones.map((z) {
                          final color = _heatColor(z['risk'] as double);
                          return Positioned(
                            left: (z['x'] as double) * 400 - 35,
                            top: (z['y'] as double) * 440 - 35,
                            child: Tooltip(
                              message:
                                  '${z['name']}: ${((z['risk'] as double) * 100).toStringAsFixed(0)}% risk',
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(
                                      0.15 + (z['risk'] as double) * 0.3),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: color.withOpacity(0.6),
                                      width: 2),
                                ),
                                child: Center(
                                  child: Text(
                                    (z['name'] as String)
                                        .split(' ')
                                        .first
                                        .substring(0, 3),
                                    style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: color),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Risk Scale',
                                    style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.mutedText)),
                                const SizedBox(height: 8),
                                _Legend(color: AppColors.successText, label: 'Low'),
                                const SizedBox(height: 4),
                                _Legend(color: AppColors.warningText, label: 'Medium'),
                                const SizedBox(height: 4),
                                _Legend(color: AppColors.criticalText, label: 'High'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: 240,
                child: Container(
                  padding: const EdgeInsets.all(20),
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
                      Text('Zone Rankings',
                          style: GoogleFonts.publicSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.headings)),
                      const SizedBox(height: 16),
                      ..._zones.map((z) {
                        final color = _heatColor(z['risk'] as double);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(z['name'],
                                      style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: AppColors.onSurface)),
                                  Text(
                                      '${((z['risk'] as double) * 100).toStringAsFixed(0)}%',
                                      style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: color)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: z['risk'] as double,
                                  backgroundColor:
                                      AppColors.surfaceContainerHighest,
                                  color: color,
                                  minHeight: 5,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
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

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.bodyText)),
      ],
    );
  }
}
