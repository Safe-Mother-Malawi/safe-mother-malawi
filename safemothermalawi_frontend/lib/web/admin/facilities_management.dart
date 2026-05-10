import 'package:flutter/material.dart';
import '../../state/facilities_store.dart';
import '../shared/widgets/facilities_filter_widget.dart';
import '../shared/widgets/facility_card.dart';

class FacilitiesManagementScreen extends StatefulWidget {
  const FacilitiesManagementScreen({Key? key}) : super(key: key);

  @override
  State<FacilitiesManagementScreen> createState() => _FacilitiesManagementScreenState();
}

class _FacilitiesManagementScreenState extends State<FacilitiesManagementScreen> {
  final store = FacilitiesStore.instance;
  late VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _listener = () => setState(() {});
    store.addListener(_listener);
    _loadData();
  }

  @override
  void dispose() {
    store.removeListener(_listener);
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!store.loaded) {
      await store.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Facilities Management'),
        elevation: 0,
      ),
      body: store.loading
          ? const Center(child: CircularProgressIndicator())
          : store.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${store.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          store.reload();
                          _loadData();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary cards
                        Row(
                          children: [
                            _buildSummaryCard(
                              'Total Facilities',
                              store.totalCount.toString(),
                              Colors.blue,
                            ),
                            const SizedBox(width: 16),
                            _buildSummaryCard(
                              'Filtered Results',
                              store.filteredCount.toString(),
                              Colors.green,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Filters
                        FacilitiesFilterWidget(
                          onFilterChanged: () => setState(() {}),
                        ),
                        const SizedBox(height: 24),
                        // Results
                        Text(
                          'Results (${store.filteredCount})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (store.facilities.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Text(
                                store.searchQuery != null || store.selectedDistrict != null
                                    ? 'No facilities match your filters'
                                    : 'No facilities found',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: store.facilities.length,
                            itemBuilder: (context, index) {
                              final facility = store.facilities[index];
                              return FacilityCard(
                                facility: facility,
                                onTap: () => _showFacilityDetails(facility),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color) {
    return Expanded(
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFacilityDetails(HealthFacility facility) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(facility.facilityName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Region', facility.region),
              _buildDetailRow('Zone', facility.zone),
              _buildDetailRow('District', facility.district),
              _buildDetailRow('Facility Type', facility.facilityType),
              _buildDetailRow('Managing Authority', facility.managingAuthority),
              _buildDetailRow('Urban/Rural', facility.urbanRural),
              _buildDetailRow('ID', facility.id),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
