import 'package:flutter/material.dart';
import '../../state/facilities_store.dart';

class FacilitiesListScreen extends StatefulWidget {
  const FacilitiesListScreen({Key? key}) : super(key: key);

  @override
  State<FacilitiesListScreen> createState() => _FacilitiesListScreenState();
}

class _FacilitiesListScreenState extends State<FacilitiesListScreen> {
  final store = FacilitiesStore.instance;
  late VoidCallback _listener;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _listener = () => setState(() {});
    store.addListener(_listener);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
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
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
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
              : Column(
                  children: [
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search facility...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    store.setSearchQuery(null);
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        onChanged: (value) {
                          store.setSearchQuery(value);
                          setState(() {});
                        },
                      ),
                    ),
                    // Filter button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showFilterBottomSheet(),
                              icon: const Icon(Icons.filter_list),
                              label: const Text('Filters'),
                            ),
                          ),
                          if (store.selectedRegion != null ||
                              store.selectedZone != null ||
                              store.selectedDistrict != null ||
                              store.selectedFacilityType != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: TextButton(
                                onPressed: () {
                                  store.clearFilters();
                                  setState(() {});
                                },
                                child: const Text('Clear'),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Active filters display
                    if (store.selectedRegion != null ||
                        store.selectedZone != null ||
                        store.selectedDistrict != null ||
                        store.selectedFacilityType != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Wrap(
                          spacing: 8,
                          children: [
                            if (store.selectedRegion != null)
                              Chip(
                                label: Text('Region: ${store.selectedRegion}'),
                                onDeleted: () async {
                                  await store.setRegion(null);
                                  setState(() {});
                                },
                              ),
                            if (store.selectedZone != null)
                              Chip(
                                label: Text('Zone: ${store.selectedZone}'),
                                onDeleted: () async {
                                  await store.setZone(null);
                                  setState(() {});
                                },
                              ),
                            if (store.selectedDistrict != null)
                              Chip(
                                label: Text('District: ${store.selectedDistrict}'),
                                onDeleted: () {
                                  store.setDistrict(null);
                                  setState(() {});
                                },
                              ),
                            if (store.selectedFacilityType != null)
                              Chip(
                                label: Text('Type: ${store.selectedFacilityType}'),
                                onDeleted: () {
                                  store.setFacilityType(null);
                                  setState(() {});
                                },
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    // Results count
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Found ${store.filteredCount} facilities',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Facilities list
                    Expanded(
                      child: store.facilities.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_off,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No facilities found',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: store.facilities.length,
                              itemBuilder: (context, index) {
                                final facility = store.facilities[index];
                                return _buildFacilityTile(facility);
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildFacilityTile(HealthFacility facility) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: () => _showFacilityDetails(facility),
        title: Text(
          facility.facilityName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(facility.district),
            Text(
              '${facility.facilityType} • ${facility.urbanRural}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildFilterSheet(),
      isScrollControlled: true,
    );
  }

  Widget _buildFilterSheet() {
    return StatefulBuilder(
      builder: (context, setState) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filter Facilities',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Region
              _buildFilterDropdown(
                label: 'Region',
                value: store.selectedRegion,
                items: store.regions,
                onChanged: (value) async {
                  await store.setRegion(value);
                  setState(() {});
                },
              ),
              const SizedBox(height: 12),
              // Zone
              _buildFilterDropdown(
                label: 'Zone',
                value: store.selectedZone,
                items: store.zones,
                onChanged: (value) async {
                  await store.setZone(value);
                  setState(() {});
                },
              ),
              const SizedBox(height: 12),
              // District
              _buildFilterDropdown(
                label: 'District',
                value: store.selectedDistrict,
                items: store.districts,
                onChanged: (value) {
                  store.setDistrict(value);
                  setState(() {});
                },
              ),
              const SizedBox(height: 12),
              // Facility Type
              _buildFilterDropdown(
                label: 'Facility Type',
                value: store.selectedFacilityType,
                items: store.getUniqueFacilityTypes(),
                onChanged: (value) {
                  store.setFacilityType(value);
                  setState(() {});
                },
              ),
              const SizedBox(height: 12),
              // Managing Authority
              _buildFilterDropdown(
                label: 'Managed By',
                value: store.selectedManagedBy,
                items: store.getUniqueManagedBy(),
                onChanged: (value) {
                  store.setManagedBy(value);
                  setState(() {});
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        store.clearFilters();
                        setState(() {});
                        Navigator.pop(context);
                      },
                      child: const Text('Clear All'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          items: [
            DropdownMenuItem(
              value: null,
              child: Text('All $label'),
            ),
            ...items.map((item) => DropdownMenuItem(
              value: item,
              child: Text(item),
            )),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _showFacilityDetails(HealthFacility facility) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              facility.facilityName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Region', facility.region),
            _buildDetailRow('Zone', facility.zone),
            _buildDetailRow('District', facility.district),
            _buildDetailRow('Facility Type', facility.facilityType),
            _buildDetailRow('Managing Authority', facility.managingAuthority),
            _buildDetailRow('Urban/Rural', facility.urbanRural),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}

