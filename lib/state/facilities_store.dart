import '../services/api_service.dart';

class HealthFacility {
  final String id;
  final String region;
  final String zone;
  final String district;
  final String facilityName;
  final String facilityType;
  final String managingAuthority;
  final String urbanRural;

  HealthFacility({
    required this.id,
    required this.region,
    required this.zone,
    required this.district,
    required this.facilityName,
    required this.facilityType,
    required this.managingAuthority,
    required this.urbanRural,
  });

  factory HealthFacility.fromJson(Map<String, dynamic> j) {
    return HealthFacility(
      id: j['id']?.toString() ?? '',
      region: j['region']?.toString() ?? '',
      zone: j['zone']?.toString() ?? '',
      district: j['district']?.toString() ?? '',
      facilityName: j['facilityName']?.toString() ?? '',
      facilityType: j['facilityType']?.toString() ?? '',
      managingAuthority: j['managingAuthority']?.toString() ?? '',
      urbanRural: j['urbanRural']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'region': region,
    'zone': zone,
    'district': district,
    'facilityName': facilityName,
    'facilityType': facilityType,
    'managingAuthority': managingAuthority,
    'urbanRural': urbanRural,
  };
}

class FacilitiesStore {
  FacilitiesStore._();
  static final FacilitiesStore instance = FacilitiesStore._();

  final List<HealthFacility> _allFacilities = [];
  final List<HealthFacility> _filteredFacilities = [];
  final List<String> _regions = [];
  final List<String> _zones = [];
  final List<String> _districts = [];
  final List<String> _facilityTypes = [];
  final List<String> _managingAuthorities = [];
  
  // Cache for all zones and districts (extracted from facilities)
  List<String> _allZonesCache = [];
  List<String> _allDistrictsCache = [];

  bool _loaded = false;
  bool _loading = false;
  String? _error;

  // Filters
  String? _selectedRegion;
  String? _selectedZone;
  String? _selectedDistrict;
  String? _selectedFacilityType;
  String? _selectedManagedBy;
  String? _searchQuery;

  // Getters
  List<HealthFacility> get facilities => List.from(_filteredFacilities);
  List<HealthFacility> get allFacilities => List.from(_allFacilities);
  List<String> get regions => List.from(_regions);
  List<String> get zones => List.from(_zones);
  List<String> get districts => List.from(_districts);
  List<String> get facilityTypes => List.from(_facilityTypes);
  List<String> get managingAuthorities => List.from(_managingAuthorities);
  bool get loaded => _loaded;
  bool get loading => _loading;
  String? get error => _error;

  String? get selectedRegion => _selectedRegion;
  String? get selectedZone => _selectedZone;
  String? get selectedDistrict => _selectedDistrict;
  String? get selectedFacilityType => _selectedFacilityType;
  String? get selectedManagedBy => _selectedManagedBy;
  String? get searchQuery => _searchQuery;

  int get totalCount => _allFacilities.length;
  int get filteredCount => _filteredFacilities.length;

  /// Load all facilities and regions
  Future<void> load() async {
    if (_loaded) return;
    _loading = true;
    _error = null;
    _notify();

    try {
      // Load regions
      final regionsData = await ApiService.getRegions();
      _regions.clear();
      _regions.addAll(regionsData);

      // Load facility types
      final typesData = await ApiService.getFacilityTypes();
      _facilityTypes.clear();
      _facilityTypes.addAll(typesData);

      // Load managing authorities
      final authoritiesData = await ApiService.getManagingAuthorities();
      _managingAuthorities.clear();
      _managingAuthorities.addAll(authoritiesData);

      // Load all facilities (with high limit to get all records)
      final facilitiesData = await ApiService.getHealthFacilities() as List<dynamic>;
      _allFacilities.clear();
      _allFacilities.addAll(
        facilitiesData.cast<Map<String, dynamic>>().map(HealthFacility.fromJson),
      );

      // Extract all unique zones and districts from facilities
      final allZones = <String>{};
      final allDistricts = <String>{};
      for (final facility in _allFacilities) {
        allZones.add(facility.zone);
        allDistricts.add(facility.district);
      }
      
      // Store them for reference (not filtered by region/zone yet)
      _allZonesCache = allZones.toList()..sort();
      _allDistrictsCache = allDistricts.toList()..sort();

      _loaded = true;
      _applyFilters();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      _notify();
    }
  }

  /// Load zones for a region
  Future<void> loadZones(String region) async {
    try {
      final zonesData = await ApiService.getZones(region);
      _zones.clear();
      _zones.addAll(zonesData);
      _notify();
    } catch (e) {
      _error = e.toString();
      _notify();
    }
  }

  /// Load districts for a zone
  Future<void> loadDistricts(String zone) async {
    try {
      final districtsData = await ApiService.getDistricts(zone);
      _districts.clear();
      _districts.addAll(districtsData);
      _notify();
    } catch (e) {
      _error = e.toString();
      _notify();
    }
  }

  /// Set region filter and load zones
  Future<void> setRegion(String? region) async {
    _selectedRegion = region;
    _selectedZone = null;
    _selectedDistrict = null;
    _zones.clear();
    _districts.clear();

    if (region != null) {
      // Filter zones for this region from all facilities
      final zonesForRegion = <String>{};
      for (final facility in _allFacilities) {
        if (facility.region == region) {
          zonesForRegion.add(facility.zone);
        }
      }
      _zones.addAll(zonesForRegion.toList()..sort());
    }
    _applyFilters();
  }

  /// Set zone filter and load districts
  Future<void> setZone(String? zone) async {
    _selectedZone = zone;
    _selectedDistrict = null;
    _districts.clear();

    if (zone != null) {
      // Filter districts for this zone from all facilities
      final districtsForZone = <String>{};
      for (final facility in _allFacilities) {
        if (facility.zone == zone) {
          districtsForZone.add(facility.district);
        }
      }
      _districts.addAll(districtsForZone.toList()..sort());
    }
    _applyFilters();
  }

  /// Set district filter
  void setDistrict(String? district) {
    _selectedDistrict = district;
    _applyFilters();
  }

  /// Set facility type filter
  void setFacilityType(String? type) {
    _selectedFacilityType = type;
    _applyFilters();
  }

  /// Set managing authority filter
  void setManagedBy(String? authority) {
    _selectedManagedBy = authority;
    _applyFilters();
  }

  /// Set search query
  void setSearchQuery(String? query) {
    _searchQuery = query?.isEmpty ?? true ? null : query;
    _applyFilters();
  }

  /// Clear all filters
  void clearFilters() {
    _selectedRegion = null;
    _selectedZone = null;
    _selectedDistrict = null;
    _selectedFacilityType = null;
    _selectedManagedBy = null;
    _searchQuery = null;
    _zones.clear();
    _districts.clear();
    _applyFilters();
  }

  /// Apply all active filters
  void _applyFilters() {
    _filteredFacilities.clear();

    var results = _allFacilities;

    if (_selectedRegion != null) {
      results = results.where((f) => f.region == _selectedRegion).toList();
    }

    if (_selectedZone != null) {
      results = results.where((f) => f.zone == _selectedZone).toList();
    }

    if (_selectedDistrict != null) {
      results = results.where((f) => f.district == _selectedDistrict).toList();
    }

    if (_selectedFacilityType != null) {
      results = results.where((f) => f.facilityType == _selectedFacilityType).toList();
    }

    if (_selectedManagedBy != null) {
      results = results.where((f) => f.managingAuthority == _selectedManagedBy).toList();
    }

    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      final query = _searchQuery!.toLowerCase();
      results = results.where((f) =>
        f.facilityName.toLowerCase().contains(query) ||
        f.district.toLowerCase().contains(query)
      ).toList();
    }

    _filteredFacilities.addAll(results);
    _notify();
  }

  /// Get unique facility types from filtered facilities (based on region/zone/district)
  Future<List<String>> getAvailableFacilityTypes() async {
    try {
      if (_selectedDistrict != null) {
        final types = await ApiService.getFacilityTypesByDistrict(_selectedDistrict!);
        return types.where((t) => t.toUpperCase() != 'CLINIC' && t.toUpperCase() != 'GOVERNMENT').toList();
      } else if (_selectedZone != null) {
        final types = await ApiService.getFacilityTypesByZone(_selectedZone!);
        return types.where((t) => t.toUpperCase() != 'CLINIC' && t.toUpperCase() != 'GOVERNMENT').toList();
      } else if (_selectedRegion != null) {
        final types = await ApiService.getFacilityTypesByRegion(_selectedRegion!);
        return types.where((t) => t.toUpperCase() != 'CLINIC' && t.toUpperCase() != 'GOVERNMENT').toList();
      } else {
        final types = await ApiService.getFacilityTypes();
        return types.where((t) => t.toUpperCase() != 'CLINIC' && t.toUpperCase() != 'GOVERNMENT').toList();
      }
    } catch (e) {
      // Fallback to local filtering
      var facilities = _allFacilities;
      
      if (_selectedRegion != null) {
        facilities = facilities.where((f) => f.region == _selectedRegion).toList();
      }
      
      if (_selectedZone != null) {
        facilities = facilities.where((f) => f.zone == _selectedZone).toList();
      }
      
      if (_selectedDistrict != null) {
        facilities = facilities.where((f) => f.district == _selectedDistrict).toList();
      }
      
      final types = <String>{};
      for (final f in facilities) {
        types.add(f.facilityType);
      }
      return types.toList()
        ..sort()
        ..removeWhere((t) => t.toUpperCase() == 'CLINIC' || t.toUpperCase() == 'GOVERNMENT');
    }
  }

  /// Get unique managing authorities from filtered facilities (based on region/zone/district)
  Future<List<String>> getAvailableManagedBy() async {
    try {
      if (_selectedDistrict != null) {
        return await ApiService.getManagingAuthoritiesByDistrict(_selectedDistrict!);
      } else if (_selectedZone != null) {
        return await ApiService.getManagingAuthoritiesByZone(_selectedZone!);
      } else if (_selectedRegion != null) {
        return await ApiService.getManagingAuthoritiesByRegion(_selectedRegion!);
      } else {
        return await ApiService.getManagingAuthorities();
      }
    } catch (e) {
      // Fallback to local filtering
      var facilities = _allFacilities;
      
      if (_selectedRegion != null) {
        facilities = facilities.where((f) => f.region == _selectedRegion).toList();
      }
      
      if (_selectedZone != null) {
        facilities = facilities.where((f) => f.zone == _selectedZone).toList();
      }
      
      if (_selectedDistrict != null) {
        facilities = facilities.where((f) => f.district == _selectedDistrict).toList();
      }
      
      final authorities = <String>{};
      for (final f in facilities) {
        authorities.add(f.managingAuthority);
      }
      return authorities.toList()..sort();
    }
  }

  /// Get unique facility types from all facilities (legacy method)
  List<String> getUniqueFacilityTypes() {
    final types = <String>{};
    for (final f in _allFacilities) {
      types.add(f.facilityType);
    }
    return types.toList()..sort();
  }

  /// Get unique managing authorities from all facilities (legacy method)
  List<String> getUniqueManagedBy() {
    final authorities = <String>{};
    for (final f in _allFacilities) {
      authorities.add(f.managingAuthority);
    }
    return authorities.toList()..sort();
  }

  /// Get facility by name
  HealthFacility? getFacilityByName(String name) {
    try {
      return _allFacilities.firstWhere((f) => f.facilityName == name);
    } catch (_) {
      return null;
    }
  }

  /// Reload data
  void reload() {
    _loaded = false;
    load();
  }

  /// Create a new facility
  Future<void> addFacility(Map<String, dynamic> data) async {
    await ApiService.createFacility(data);
    reload();
  }

  /// Edit an existing facility
  Future<void> editFacility(String id, Map<String, dynamic> data) async {
    await ApiService.updateHealthFacility(id, data);
    reload();
  }

  /// Delete a facility
  Future<void> deleteFacility(String id) async {
    await ApiService.deleteHealthFacility(id);
    reload();
  }

  final List<void Function()> _listeners = [];
  void addListener(void Function() l) => _listeners.add(l);
  void removeListener(void Function() l) => _listeners.remove(l);
  void _notify() {
    for (final l in _listeners) {
      l();
    }
  }
}

