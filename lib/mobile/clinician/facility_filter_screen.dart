import 'package:flutter/material.dart';
import '../../state/facilities_store.dart';

class FacilityFilterScreen extends StatefulWidget {
  const FacilityFilterScreen({Key? key}) : super(key: key);

  @override
  State<FacilityFilterScreen> createState() => _FacilityFilterScreenState();
}

class _FacilityFilterScreenState extends State<FacilityFilterScreen> {
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
        title: const Text('Filter Facilities'),
        elevation: 0,
      ),
      body: store.loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Region
                    _buildFilterSection(
                      title: 'Region',
                      value: store.selectedRegion,
                      items: store.regions,
                      onChanged: (value) async {
                        await store.setRegion(value);
                      },
                    ),
                    const SizedBox(height: 24),
                    // Zone
                    _buildFilterSection(
                      title: 'Zone',
                      value: store.selectedZone,
                      items: store.zones,
                      onChanged: (value) async {
                        await store.setZone(value);
                      },
                    ),
                    const SizedBox(height: 24),
                    // District
                    _buildFilterSection(
                      title: 'District',
                      value: store.selectedDistrict,
                      items: store.districts,
                      onChanged: (value) {
                        store.setDistrict(value);
                      },
                    ),
                    const SizedBox(height: 24),
                    // Facility Type
                    _buildFilterSection(
                      title: 'Facility Type',
                      value: store.selectedFacilityType,
                      items: store.getUniqueFacilityTypes(),
                      onChanged: (value) {
                        store.setFacilityType(value);
                      },
                    ),
                    const SizedBox(height: 24),
                    // Managing Authority
                    _buildFilterSection(
                      title: 'Managed By',
                      value: store.selectedManagedBy,
                      items: store.getUniqueManagedBy(),
                      onChanged: (value) {
                        store.setManagedBy(value);
                      },
                    ),
                    const SizedBox(height: 32),
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              store.clearFilters();
                              setState(() {});
                            },
                            child: const Text('Clear All'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Apply Filters'),
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

  Widget _buildFilterSection({
    required String title,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
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
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            hintText: 'Select $title',
          ),
          items: [
            DropdownMenuItem(
              value: null,
              child: Text('All $title'),
            ),
            ...items.map((item) => DropdownMenuItem(
              value: item,
              child: Text(item),
            )),
          ],
          onChanged: (newValue) {
            onChanged(newValue);
            setState(() {});
          },
        ),
      ],
    );
  }
}
