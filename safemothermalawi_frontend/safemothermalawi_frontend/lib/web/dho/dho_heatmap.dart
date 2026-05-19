import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../state/user_store.dart';

class DhoHeatmap extends StatefulWidget {
  const DhoHeatmap({super.key});
  @override
  State<DhoHeatmap> createState() => _DhoHeatmapState();
}

class _DhoHeatmapState extends State<DhoHeatmap> {
  // Fallback static facilities for Blantyre area
  List<Map<String, dynamic>> _facilities = const [
    {'name': 'Queen Elizabeth Central Hospital', 'lat': -15.786, 'lon': 35.005, 'risk': 0.85, 'type': 'Central'},
    {'name': 'Mwaiwathu Private Hospital', 'lat': -15.795, 'lon': 35.010, 'risk': 0.60, 'type': 'Private'},
    {'name': 'Chiradzulu District Hospital', 'lat': -15.683, 'lon': 35.150, 'risk': 0.72, 'type': 'District'},
    {'name': 'Thyolo District Hospital', 'lat': -16.128, 'lon': 35.143, 'risk': 0.68, 'type': 'District'},
    {'name': 'Chikwawa District Hospital', 'lat': -16.033, 'lon': 34.800, 'risk': 0.62, 'type': 'District'},
    {'name': 'Mwanza District Hospital', 'lat': -15.617, 'lon': 34.517, 'risk': 0.55, 'type': 'District'},
    {'name': 'Ndirande Health Centre', 'lat': -15.770, 'lon': 35.040, 'risk': 0.78, 'type': 'Health Centre'},
    {'name': 'Chilomoni Health Centre', 'lat': -15.810, 'lon': 34.970, 'risk': 0.65, 'type': 'Health Centre'},
    {'name': 'Limbe Health Centre', 'lat': -15.830, 'lon': 35.050, 'risk': 0.50, 'type': 'Health Centre'},
    {'name': 'Bangwe Health Centre', 'lat': -15.820, 'lon': 34.990, 'risk': 0.70, 'type': 'Health Centre'},
    {'name': 'Zingwangwa Health Centre', 'lat': -15.800, 'lon': 35.020, 'risk': 0.58, 'type': 'Health Centre'},
    {'name': "St. Joseph's Hospital Limbe", 'lat': -15.835, 'lon': 35.055, 'risk': 0.42, 'type': 'Private'},
  ];

  bool _loading = true;

  String get _district => UserStore.instance.district;

  @override
  void initState() {
    super.initState();
    _loadFacilities();
  }

  Future<void> _loadFacilities() async {
    try {
      final data = await ApiService.getHealthFacilities();
      if (data.isNotEmpty) {
        final mapped = data
            .where((f) => f['latitude'] != null && f['longitude'] != null)
            .map<Map<String, dynamic>>((f) => {
                  'name': (f['name'] ?? '—').toString(),
                  'lat': (f['latitude'] as num).toDouble(),
                  'lon': (f['longitude'] as num).toDouble(),
                  'risk': ((f['riskScore'] ?? 0.5) as num).toDouble(),
                  'type': (f['type'] ?? 'District').toString(),
                })
            .toList();
        if (mapped.isNotEmpty) {
          if (mounted) setState(() { _facilities = mapped; _loading = false; });
          return;
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Color _heatColor(double v) {
    if (v >= 0.7) return AppColors.criticalText;
    if (v >= 0.4) return AppColors.warningText;
    return AppColors.successText;
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [..._facilities]..sort((a, b) => (b['risk'] as double).compareTo(a['risk'] as double));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Heatmaps',
                  style: GoogleFonts.publicSans(
                      fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.headings)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.infoBg, borderRadius: BorderRadius.circular(20)),
                child: Text(_district.isNotEmpty ? _district : 'District',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.infoText)),
              ),
              const Spacer(),
              if (_loading)
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              else
                const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 6),
          Text('Risk hotspots at actual health facility locations${_district.isNotEmpty ? ' — $_district District' : ''}',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedText)),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  height: 520,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 24, offset: Offset(0, 4))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: FlutterMap(
                      options: const MapOptions(
                        initialCenter: LatLng(-15.85, 34.95),
                        initialZoom: 9.5,
                        minZoom: 8,
                        maxZoom: 14,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.safemothermalawi.app',
                        ),
                        CircleLayer(
                          circles: _facilities.map((f) {
                            final val = f['risk'] as double;
                            final color = _heatColor(val);
                            final isCentral = f['type'] == 'Central';
                            return CircleMarker(
                              point: LatLng(f['lat'] as double, f['lon'] as double),
                              radius: isCentral ? 22 : (f['type'] == 'District' ? 16 : 12),
                              color: color.withValues(alpha: 0.2 + val * 0.3),
                              borderColor: color.withValues(alpha: 0.8),
                              borderStrokeWidth: isCentral ? 2.5 : 1.5,
                            );
                          }).toList(),
                        ),
                        MarkerLayer(
                          markers: _facilities.map((f) {
                            final val = f['risk'] as double;
                            final color = _heatColor(val);
                            final isCentral = f['type'] == 'Central';
                            return Marker(
                              point: LatLng(f['lat'] as double, f['lon'] as double),
                              width: 30,
                              height: 30,
                              child: Tooltip(
                                message: '${f['name']}\nRisk: ${(val * 100).toStringAsFixed(0)}%\nType: ${f['type']}',
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 1.5),
                                    boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 6)],
                                  ),
                                  child: Icon(
                                    isCentral ? Icons.local_hospital_rounded : Icons.circle,
                                    color: Colors.white,
                                    size: isCentral ? 15 : 6,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
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
                    boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 24, offset: Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Facility Rankings',
                          style: GoogleFonts.publicSans(
                              fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.headings)),
                      Text('by risk level',
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.mutedText)),
                      const SizedBox(height: 14),
                      ...sorted.map((f) {
                        final val = f['risk'] as double;
                        final color = _heatColor(val);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(f['name'] as String,
                                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurface),
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  Text('${(val * 100).toStringAsFixed(0)}%',
                                      style: GoogleFonts.inter(
                                          fontSize: 11, fontWeight: FontWeight.w600, color: color)),
                                ],
                              ),
                              const SizedBox(height: 3),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: val,
                                  backgroundColor: AppColors.surfaceContainerHighest,
                                  color: color,
                                  minHeight: 4,
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
