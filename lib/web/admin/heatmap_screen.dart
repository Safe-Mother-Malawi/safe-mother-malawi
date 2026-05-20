import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';

class HeatmapScreen extends StatefulWidget {
  const HeatmapScreen({super.key});

  @override
  State<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> {
  String _activeLayer = 'High-Risk Areas';
  bool _loading = true;

  // Fallback static facilities if API has no lat/lon data
  List<Map<String, dynamic>> _facilities = [
    {'name': 'Queen Elizabeth Central\nBlantyre', 'lat': -15.786, 'lon': 35.005, 'risk': 0.85, 'ivr': 0.72, 'clinician': 0.40, 'type': 'Central'},
    {'name': 'Kamuzu Central\nLilongwe', 'lat': -13.977, 'lon': 33.786, 'risk': 0.60, 'ivr': 0.88, 'clinician': 0.75, 'type': 'Central'},
    {'name': 'Mzuzu Central\nMzuzu', 'lat': -11.465, 'lon': 34.020, 'risk': 0.30, 'ivr': 0.45, 'clinician': 0.80, 'type': 'Central'},
    {'name': 'Zomba Central\nZomba', 'lat': -15.386, 'lon': 35.318, 'risk': 0.70, 'ivr': 0.55, 'clinician': 0.50, 'type': 'Central'},
    {'name': 'Mangochi District', 'lat': -14.478, 'lon': 35.265, 'risk': 0.55, 'ivr': 0.40, 'clinician': 0.35, 'type': 'District'},
    {'name': 'Kasungu District', 'lat': -13.014, 'lon': 33.468, 'risk': 0.40, 'ivr': 0.60, 'clinician': 0.65, 'type': 'District'},
    {'name': 'Dedza District', 'lat': -14.368, 'lon': 34.334, 'risk': 0.50, 'ivr': 0.35, 'clinician': 0.55, 'type': 'District'},
    {'name': 'Salima District', 'lat': -13.780, 'lon': 34.459, 'risk': 0.45, 'ivr': 0.50, 'clinician': 0.60, 'type': 'District'},
    {'name': 'Mulanje District', 'lat': -16.032, 'lon': 35.502, 'risk': 0.75, 'ivr': 0.38, 'clinician': 0.42, 'type': 'District'},
    {'name': 'Thyolo District', 'lat': -16.128, 'lon': 35.143, 'risk': 0.68, 'ivr': 0.42, 'clinician': 0.48, 'type': 'District'},
    {'name': 'Chikwawa District', 'lat': -16.033, 'lon': 34.800, 'risk': 0.62, 'ivr': 0.30, 'clinician': 0.38, 'type': 'District'},
    {'name': 'Nsanje District', 'lat': -16.923, 'lon': 35.263, 'risk': 0.78, 'ivr': 0.25, 'clinician': 0.28, 'type': 'District'},
    {'name': 'Ntcheu District', 'lat': -14.820, 'lon': 34.636, 'risk': 0.48, 'ivr': 0.44, 'clinician': 0.58, 'type': 'District'},
    {'name': 'Balaka District', 'lat': -14.987, 'lon': 34.957, 'risk': 0.52, 'ivr': 0.48, 'clinician': 0.52, 'type': 'District'},
    {'name': 'Machinga District', 'lat': -15.200, 'lon': 35.350, 'risk': 0.58, 'ivr': 0.36, 'clinician': 0.44, 'type': 'District'},
    {'name': 'Karonga District', 'lat': -9.933, 'lon': 33.933, 'risk': 0.25, 'ivr': 0.30, 'clinician': 0.72, 'type': 'District'},
    {'name': 'Chitipa District', 'lat': -9.700, 'lon': 33.267, 'risk': 0.20, 'ivr': 0.22, 'clinician': 0.78, 'type': 'District'},
    {'name': 'Rumphi District', 'lat': -11.017, 'lon': 33.867, 'risk': 0.28, 'ivr': 0.32, 'clinician': 0.70, 'type': 'District'},
    {'name': 'Nkhata Bay District', 'lat': -11.600, 'lon': 34.300, 'risk': 0.33, 'ivr': 0.38, 'clinician': 0.65, 'type': 'District'},
    {'name': 'Mzimba District', 'lat': -11.900, 'lon': 33.600, 'risk': 0.35, 'ivr': 0.42, 'clinician': 0.68, 'type': 'District'},
    {'name': 'Dowa District', 'lat': -13.650, 'lon': 33.933, 'risk': 0.42, 'ivr': 0.55, 'clinician': 0.62, 'type': 'District'},
    {'name': 'Nkhotakota District', 'lat': -12.925, 'lon': 34.298, 'risk': 0.38, 'ivr': 0.45, 'clinician': 0.60, 'type': 'District'},
    {'name': 'Ntchisi District', 'lat': -13.383, 'lon': 33.883, 'risk': 0.36, 'ivr': 0.40, 'clinician': 0.63, 'type': 'District'},
    {'name': 'Mchinji District', 'lat': -13.800, 'lon': 32.900, 'risk': 0.44, 'ivr': 0.52, 'clinician': 0.58, 'type': 'District'},
    {'name': 'Chiradzulu District', 'lat': -15.683, 'lon': 35.150, 'risk': 0.72, 'ivr': 0.48, 'clinician': 0.45, 'type': 'District'},
    {'name': 'Phalombe District', 'lat': -15.817, 'lon': 35.650, 'risk': 0.65, 'ivr': 0.35, 'clinician': 0.40, 'type': 'District'},
    {'name': 'Mwanza District', 'lat': -15.617, 'lon': 34.517, 'risk': 0.55, 'ivr': 0.32, 'clinician': 0.48, 'type': 'District'},
    {'name': 'Bwaila Hospital\nLilongwe', 'lat': -13.960, 'lon': 33.780, 'risk': 0.58, 'ivr': 0.82, 'clinician': 0.72, 'type': 'District'},
  ];

  double _layerValue(Map<String, dynamic> d) {
    switch (_activeLayer) {
      case 'IVR Usage': return d['ivr'] as double;
      case 'Low Clinician Activity': return 1.0 - (d['clinician'] as double);
      default: return d['risk'] as double;
    }
  }

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
                  'ivr': ((f['ivrUsage'] ?? 0.5) as num).toDouble(),
                  'clinician': ((f['clinicianActivity'] ?? 0.5) as num).toDouble(),
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

  List<Map<String, dynamic>> get _sorted =>
      [..._facilities]..sort((a, b) => _layerValue(b).compareTo(_layerValue(a)));

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Heatmaps',
              style: TextStyle(fontFamily: 'Public Sans', 
                  fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.headings)),
          const SizedBox(height: 6),
          Text('Health facility hotspots across Malawi — real geographic positions',
              style: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: AppColors.mutedText)),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Real map
              Expanded(
                flex: 3,
                child: Container(
                  height: 580,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 24, offset: Offset(0, 4))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: FlutterMap(
                      options: const MapOptions(
                        initialCenter: LatLng(-13.2543, 34.3015),
                        initialZoom: 6.2,
                        minZoom: 5.5,
                        maxZoom: 12,
                      ),
                      children: [
                        // OpenStreetMap tile layer
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.safemothermalawi.app',
                        ),
                        // Heatspot circles
                        CircleLayer(
                          circles: _facilities.map((f) {
                            final val = _layerValue(f);
                            final color = _heatColor(val);
                            final isCentral = f['type'] == 'Central';
                            return CircleMarker(
                              point: LatLng(f['lat'] as double, f['lon'] as double),
                              radius: isCentral ? 18 : 12,
                              color: color.withOpacity(0.25 + val * 0.3),
                              borderColor: color.withOpacity(0.8),
                              borderStrokeWidth: isCentral ? 2.5 : 1.5,
                            );
                          }).toList(),
                        ),
                        // Facility markers
                        MarkerLayer(
                          markers: _facilities.map((f) {
                            final val = _layerValue(f);
                            final color = _heatColor(val);
                            final isCentral = f['type'] == 'Central';
                            return Marker(
                              point: LatLng(f['lat'] as double, f['lon'] as double),
                              width: 28,
                              height: 28,
                              child: Tooltip(
                                message: '${f['name'].toString().replaceAll('\n', ' ')}\n$_activeLayer: ${(val * 100).toStringAsFixed(0)}%',
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 1.5),
                                    boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6)],
                                  ),
                                  child: Icon(
                                    isCentral ? Icons.local_hospital_rounded : Icons.circle,
                                    color: Colors.white,
                                    size: isCentral ? 14 : 6,
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

              // Controls + rankings
              SizedBox(
                width: 260,
                child: Column(
                  children: [
                    // Layer selector
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 24, offset: Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Map Layer',
                              style: TextStyle(fontFamily: 'Public Sans', 
                                  fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.headings)),
                          const SizedBox(height: 12),
                          ...['High-Risk Areas', 'IVR Usage', 'Low Clinician Activity']
                              .map((layer) => _LayerTile(
                                    label: layer,
                                    selected: _activeLayer == layer,
                                    onTap: () => setState(() => _activeLayer = layer),
                                  )),
                          const SizedBox(height: 12),
                          // Legend
                          _LegendItem(color: AppColors.successText, label: 'Low (0–39%)'),
                          const SizedBox(height: 4),
                          _LegendItem(color: AppColors.warningText, label: 'Medium (40–69%)'),
                          const SizedBox(height: 4),
                          _LegendItem(color: AppColors.criticalText, label: 'High (70–100%)'),
                          const SizedBox(height: 8),
                          Row(children: [
                            const Icon(Icons.local_hospital_rounded, size: 12, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Text('Central Hospital', style: TextStyle(fontFamily: 'Roboto', fontSize: 10, color: AppColors.bodyText)),
                          ]),
                          const SizedBox(height: 3),
                          Row(children: [
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle)),
                            const SizedBox(width: 4),
                            Text('District Hospital', style: TextStyle(fontFamily: 'Roboto', fontSize: 10, color: AppColors.bodyText)),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Top facilities
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 24, offset: Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Top Facilities',
                              style: TextStyle(fontFamily: 'Public Sans', 
                                  fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.headings)),
                          Text('by $_activeLayer',
                              style: TextStyle(fontFamily: 'Roboto', fontSize: 11, color: AppColors.mutedText)),
                          const SizedBox(height: 12),
                          ..._sorted.take(8).map((f) {
                            final val = _layerValue(f);
                            final color = _heatColor(val);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          f['name'].toString().replaceAll('\n', ' '),
                                          style: TextStyle(fontFamily: 'Roboto', fontSize: 11, color: AppColors.onSurface),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text('${(val * 100).toStringAsFixed(0)}%',
                                          style: TextStyle(fontFamily: 'Roboto', 
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
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(fontFamily: 'Roboto', fontSize: 10, color: AppColors.bodyText)),
    ]);
  }
}

class _LayerTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LayerTile({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.infoBg : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.layers_rounded, size: 16, color: selected ? AppColors.primary : AppColors.mutedText),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(fontFamily: 'Roboto', 
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? AppColors.primary : AppColors.bodyText)),
          ],
        ),
      ),
    );
  }
}

