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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateFacilityDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Facility'),
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
                                onEdit: () => _showEditFacilityDialog(facility),
                                onDelete: () => _showDeleteConfirmation(facility),
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
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditFacilityDialog(facility);
            },
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showDeleteConfirmation(facility);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
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

  void _showCreateFacilityDialog() {
    final _formKey = GlobalKey<FormState>();
    String _name = '';
    String? _region;
    String? _zone;
    String? _district;
    String? _type;
    String? _authority;
    String _urbanRural = 'Rural';
    
    // Local state for zones and districts in this dialog
    List<String> _dialogZones = [];
    List<String> _dialogDistricts = [];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Add New Facility'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Facility Name'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                    onSaved: (v) => _name = v!,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Region'),
                    value: _region,
                    items: store.regions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    validator: (v) => v == null ? 'Required' : null,
                    onChanged: (v) {
                      setState(() {
                        _region = v;
                        _zone = null;
                        _district = null;
                        _dialogZones = [];
                        _dialogDistricts = [];
                        
                        // Extract zones for this region from all facilities
                        if (v != null) {
                          final zonesForRegion = <String>{};
                          for (final facility in store.allFacilities) {
                            if (facility.region == v) {
                              zonesForRegion.add(facility.zone);
                            }
                          }
                          _dialogZones = zonesForRegion.toList()..sort();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Zone'),
                    value: _zone,
                    items: _dialogZones.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    validator: (v) => v == null ? 'Required' : null,
                    onChanged: (v) {
                      setState(() {
                        _zone = v;
                        _district = null;
                        _dialogDistricts = [];
                        
                        // Extract districts for this zone from all facilities
                        if (v != null) {
                          final districtsForZone = <String>{};
                          for (final facility in store.allFacilities) {
                            if (facility.zone == v) {
                              districtsForZone.add(facility.district);
                            }
                          }
                          _dialogDistricts = districtsForZone.toList()..sort();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'District'),
                    value: _district,
                    items: _dialogDistricts.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    validator: (v) => v == null ? 'Required' : null,
                    onChanged: (v) => setState(() => _district = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Facility Type'),
                    value: _type,
                    items: store.facilityTypes
                        .where((e) => e.toUpperCase() != 'CLINIC' && e.toUpperCase() != 'GOVERNMENT')
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    validator: (v) => v == null ? 'Required' : null,
                    onChanged: (v) => setState(() => _type = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Managing Authority'),
                    value: _authority,
                    items: store.managingAuthorities
                        .where((e) => e != 'GOVERNMENT' && e != 'CLINIC')
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    validator: (v) => v == null ? 'Required' : null,
                    onChanged: (v) => setState(() => _authority = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Urban/Rural'),
                    value: _urbanRural,
                    items: ['Urban', 'Rural'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _urbanRural = v!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  Navigator.pop(ctx);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Creating facility...')),
                  );
                  
                  try {
                    await store.addFacility({
                      'facilityName': _name,
                      'region': _region,
                      'zone': _zone,
                      'district': _district,
                      'facilityType': _type,
                      'managingAuthority': _authority,
                      'urbanRural': _urbanRural,
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Facility created successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to create facility: $e')),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditFacilityDialog(HealthFacility facility) {
    final _formKey = GlobalKey<FormState>();
    String _name = facility.facilityName;
    String? _region = facility.region;
    String? _zone = facility.zone;
    String? _district = facility.district;
    String? _type = facility.facilityType;
    String? _authority = facility.managingAuthority;
    String _urbanRural = facility.urbanRural;
    
    // Local state for zones and districts in this dialog
    List<String> _dialogZones = [];
    List<String> _dialogDistricts = [];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          // Initialize zones and districts on first build
          if (_dialogZones.isEmpty && _region != null) {
            final zonesForRegion = <String>{};
            for (final f in store.allFacilities) {
              if (f.region == _region) {
                zonesForRegion.add(f.zone);
              }
            }
            _dialogZones = zonesForRegion.toList()..sort();
          }
          
          if (_dialogDistricts.isEmpty && _zone != null) {
            final districtsForZone = <String>{};
            for (final f in store.allFacilities) {
              if (f.zone == _zone) {
                districtsForZone.add(f.district);
              }
            }
            _dialogDistricts = districtsForZone.toList()..sort();
          }
          
          return AlertDialog(
            title: const Text('Edit Facility'),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: _name,
                      decoration: const InputDecoration(labelText: 'Facility Name'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                      onSaved: (v) => _name = v!,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Region'),
                      value: _region,
                      items: store.regions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      validator: (v) => v == null ? 'Required' : null,
                      onChanged: (v) {
                        setState(() {
                          _region = v;
                          _zone = null;
                          _district = null;
                          _dialogZones = [];
                          _dialogDistricts = [];
                          
                          if (v != null) {
                            final zonesForRegion = <String>{};
                            for (final f in store.allFacilities) {
                              if (f.region == v) {
                                zonesForRegion.add(f.zone);
                              }
                            }
                            _dialogZones = zonesForRegion.toList()..sort();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Zone'),
                      value: _zone,
                      items: _dialogZones.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      validator: (v) => v == null ? 'Required' : null,
                      onChanged: (v) {
                        setState(() {
                          _zone = v;
                          _district = null;
                          _dialogDistricts = [];
                          
                          if (v != null) {
                            final districtsForZone = <String>{};
                            for (final f in store.allFacilities) {
                              if (f.zone == v) {
                                districtsForZone.add(f.district);
                              }
                            }
                            _dialogDistricts = districtsForZone.toList()..sort();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'District'),
                      value: _district,
                      items: _dialogDistricts.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      validator: (v) => v == null ? 'Required' : null,
                      onChanged: (v) => setState(() => _district = v),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Facility Type'),
                      value: _type,
                      items: store.facilityTypes
                          .where((e) => e.toUpperCase() != 'CLINIC' && e.toUpperCase() != 'GOVERNMENT')
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      validator: (v) => v == null ? 'Required' : null,
                      onChanged: (v) => setState(() => _type = v),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Managing Authority'),
                      value: _authority,
                      items: store.managingAuthorities
                          .where((e) => e != 'GOVERNMENT' && e != 'CLINIC')
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      validator: (v) => v == null ? 'Required' : null,
                      onChanged: (v) => setState(() => _authority = v),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Urban/Rural'),
                      value: _urbanRural,
                      items: ['Urban', 'Rural'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _urbanRural = v!),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Navigator.pop(ctx);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Updating facility...')),
                    );
                    
                    try {
                      await store.editFacility(facility.id, {
                        'facilityName': _name,
                        'region': _region,
                        'zone': _zone,
                        'district': _district,
                        'facilityType': _type,
                        'managingAuthority': _authority,
                        'urbanRural': _urbanRural,
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Facility updated successfully')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update facility: $e')),
                      );
                    }
                  }
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(HealthFacility facility) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Facility'),
        content: Text('Are you sure you want to delete "${facility.facilityName}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Deleting facility...')),
              );
              
              try {
                await store.deleteFacility(facility.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Facility deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete facility: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

