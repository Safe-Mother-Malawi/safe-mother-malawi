import 'package:flutter/material.dart';
import '../../state/facilities_store.dart';

class FacilityDetailScreen extends StatelessWidget {
  final HealthFacility facility;

  const FacilityDetailScreen({
    Key? key,
    required this.facility,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facility Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Facility name header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      facility.facilityName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(facility.facilityType),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            facility.facilityType,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: facility.urbanRural == 'Urban'
                                ? Colors.blue[100]
                                : Colors.green[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            facility.urbanRural,
                            style: TextStyle(
                              color: facility.urbanRural == 'Urban'
                                  ? Colors.blue[900]
                                  : Colors.green[900],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Location section
              _buildSection(
                title: 'Location',
                children: [
                  _buildDetailItem('Region', facility.region),
                  _buildDetailItem('Zone', facility.zone),
                  _buildDetailItem('District', facility.district),
                ],
              ),
              const SizedBox(height: 24),
              // Details section
              _buildSection(
                title: 'Details',
                children: [
                  _buildDetailItem('Facility Type', facility.facilityType),
                  _buildDetailItem('Managing Authority', facility.managingAuthority),
                  _buildDetailItem('Urban/Rural', facility.urbanRural),
                ],
              ),
              const SizedBox(height: 24),
              // ID section
              _buildSection(
                title: 'System Information',
                children: [
                  _buildDetailItem('Facility ID', facility.id),
                ],
              ),
              const SizedBox(height: 32),
              // Action buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _copyToClipboard(context),
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy Details'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'hospital':
        return Colors.red;
      case 'health centre':
        return Colors.orange;
      case 'clinic':
        return Colors.blue;
      case 'dispensary':
        return Colors.purple;
      case 'health post':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  void _copyToClipboard(BuildContext context) {
    final details = '''
Facility: ${facility.facilityName}
Type: ${facility.facilityType}
Region: ${facility.region}
Zone: ${facility.zone}
District: ${facility.district}
Managing Authority: ${facility.managingAuthority}
Urban/Rural: ${facility.urbanRural}
ID: ${facility.id}
''';

    // Copy to clipboard (requires flutter/services)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Details copied to clipboard')),
    );
  }
}
