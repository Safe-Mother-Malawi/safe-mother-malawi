import 'package:flutter/material.dart';
import '../../../state/facilities_store.dart';

class FacilitiesFilterWidget extends StatefulWidget {
  final VoidCallback onFilterChanged;

  const FacilitiesFilterWidget({
    Key? key,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  State<FacilitiesFilterWidget> createState() => _FacilitiesFilterWidgetState();
}

class _FacilitiesFilterWidgetState extends State<FacilitiesFilterWidget> {
  final store = FacilitiesStore.instance;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: store.searchQuery ?? '');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (store.selectedRegion != null ||
                  store.selectedZone != null ||
                  store.selectedDistrict != null ||
                  store.selectedFacilityType != null ||
                  store.selectedManagedBy != null ||
                  store.searchQuery != null)
                TextButton(
                  onPressed: () {
                    store.clearFilters();
                    _searchController.clear();
                    widget.onFilterChanged();
                  },
                  child: const Text('Clear All'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Search
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search facility name or district...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (value) {
              store.setSearchQuery(value);
              widget.onFilterChanged();
            },
          ),
          const SizedBox(height: 12),
          // Filters row
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildDropdown(
                label: 'Region',
                value: store.selectedRegion,
                items: store.regions,
                onChanged: (value) async {
                  await store.setRegion(value);
                  widget.onFilterChanged();
                },
              ),
              _buildDropdown(
                label: 'Zone',
                value: store.selectedZone,
                items: store.zones,
                onChanged: (value) async {
                  await store.setZone(value);
                  widget.onFilterChanged();
                },
              ),
              _buildDropdown(
                label: 'District',
                value: store.selectedDistrict,
                items: store.districts,
                onChanged: (value) {
                  store.setDistrict(value);
                  widget.onFilterChanged();
                },
              ),
              _buildDropdown(
                label: 'Facility Type',
                value: store.selectedFacilityType,
                items: store.getUniqueFacilityTypes(),
                onChanged: (value) {
                  store.setFacilityType(value);
                  widget.onFilterChanged();
                },
              ),
              _buildDropdown(
                label: 'Managed By',
                value: store.selectedManagedBy,
                items: store.getUniqueManagedBy(),
                onChanged: (value) {
                  store.setManagedBy(value);
                  widget.onFilterChanged();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    );
  }
}
