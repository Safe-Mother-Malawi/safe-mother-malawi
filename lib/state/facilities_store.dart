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
  List<String> get regions => List.from(_regions);
  List<String> get zones => List.from(_zones);
  List<String> get districts => List.from(_districts);
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

      // Load all facilities
      final facilitiesData = await ApiService.getHealthFacilities() as List<dynamic>;
      _allFacilities.clear();
      _allFacilities.addAll(
        facilitiesData.cast<Map<String, dynamic>>().map(HealthFacility.fromJson),
      );

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
      await loadZones(region);
    }
    _applyFilters();
  }

  /// Set zone filter and load districts
  Future<void> setZone(String? zone) async {
    _selectedZone = zone;
    _selectedDistrict = null;
    _districts.clear();

    if (zone != null) {
      await loadDistricts(zone);
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

  /// Get unique facility types from all facilities
  List<String> getUniqueFacilityTypes() {
    final types = <String>{};
    for (final f in _allFacilities) {
      types.add(f.facilityType);
    }
    return types.toList()..sort();
  }

  /// Get unique managing authorities from all facilities
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

  final List<void Function()> _listeners = [];
  void addListener(void Function() l) => _listeners.add(l);
  void removeListener(void Function() l) => _listeners.remove(l);
  void _notify() {
    for (final l in _listeners) {
      l();
    }
  }
}
