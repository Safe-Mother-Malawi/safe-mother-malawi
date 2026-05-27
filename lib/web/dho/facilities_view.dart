import 'package:flutter/material.dart';
import '../../state/facilities_store.dart';
import '../../state/user_store.dart';
import '../shared/widgets/facilities_filter_widget.dart';
import '../shared/widgets/facility_card.dart';

class DhoFacilitiesView extends StatefulWidget {
  const DhoFacilitiesView({Key? key}) : super(key: key);

  @override
  State<DhoFacilitiesView> createState() => _DhoFacilitiesViewState();
}

class _DhoFacilitiesViewState extends State<DhoFacilitiesView> {
  final store = FacilitiesStore.instance;
  final userStore = UserStore.instance;
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
      // Auto-filter by DHO's district if available
      final dhoDistrict = userStore.district;
      if (dhoDistrict.isNotEmpty) {
        store.setDistrict(dhoDistrict);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dhoDistrict = userStore.district;
    final isFiltered = store.selectedDistrict != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Facilities'),
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
                        // Info banner
                        if (dhoDistrict.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              border: Border.all(color: Colors.blue[200]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info, color: Colors.blue[700]),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Showing facilities for: $dhoDistrict',
                                    style: TextStyle(color: Colors.blue[900]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        // Summary cards
                        Row(
                          children: [
                            _buildSummaryCard(
                              'Total in District',
                              store.filteredCount.toString(),
                              Colors.green,
                            ),
                            const SizedBox(width: 16),
                            _buildSummaryCard(
                              'All Facilities',
                              store.totalCount.toString(),
                              Colors.blue,
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
                          'Facilities (${store.filteredCount})',
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
                                'No facilities match your filters',
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

