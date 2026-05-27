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
  
  // Cache for async data
  List<String> _facilityTypes = [];
  List<String> _managedBy = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: store.searchQuery ?? '');
    _loadFilterOptions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFilterOptions() async {
    try {
      final types = await store.getAvailableFacilityTypes();
      final authorities = await store.getAvailableManagedBy();
      
      if (mounted) {
        setState(() {
          _facilityTypes = types;
          _managedBy = authorities;
        });
      }
    } catch (e) {
      debugPrint('Error loading filter options: $e');
    }
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
                    _loadFilterOptions();
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
                  await _loadFilterOptions();
                  setState(() {});
                  widget.onFilterChanged();
                },
              ),
              _buildDropdown(
                label: 'Zone',
                value: store.selectedZone,
                items: store.selectedRegion != null ? store.zones : [],
                enabled: store.selectedRegion != null,
                onChanged: (value) async {
                  await store.setZone(value);
                  await _loadFilterOptions();
                  setState(() {});
                  widget.onFilterChanged();
                },
              ),
              _buildDropdown(
                label: 'District',
                value: store.selectedDistrict,
                items: store.selectedZone != null ? store.districts : [],
                enabled: store.selectedZone != null,
                onChanged: (value) {
                  store.setDistrict(value);
                  _loadFilterOptions();
                  setState(() {});
                  widget.onFilterChanged();
                },
              ),
              _buildDropdown(
                label: 'Facility Type',
                value: store.selectedFacilityType,
                items: _facilityTypes,
                onChanged: (value) {
                  store.setFacilityType(value);
                  widget.onFilterChanged();
                },
              ),
              _buildDropdown(
                label: 'Managed By',
                value: store.selectedManagedBy,
                items: _managedBy,
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
    bool enabled = true,
  }) {
    if (!enabled) {
      return SizedBox(
        width: 180,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            filled: true,
            fillColor: Colors.grey[200],
          ),
          child: Text(
            value ?? 'All $label',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

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

