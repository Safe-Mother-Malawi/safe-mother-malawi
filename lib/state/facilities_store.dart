import 'package:flutter/foundation.dart';

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

  bool _loaded = false;
  bool _loading = false;
  String? _error;

  String? _selectedRegion;
  String? _selectedZone;
  String? _selectedDistrict;
  String? _selectedFacilityType;
  String? _selectedManagedBy;
  String? _selectedUrbanRural;
  String? _searchQuery;

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
  String? get selectedUrbanRural => _selectedUrbanRural;
  String? get searchQuery => _searchQuery;

  int get totalCount => _allFacilities.length;
  int get filteredCount => _filteredFacilities.length;

  Future<void> load() async {
    if (_loaded && _allFacilities.isNotEmpty) return;
    _loading = true;
    _error = null;
    _notify();

    try {
      final regionsData = await ApiService.getRegions();
      _regions
        ..clear()
        ..addAll(_uniqueSorted(regionsData));
      debugPrint('Loaded ${_regions.length} regions');

      final typesData = await ApiService.getFacilityTypes();
      _facilityTypes
        ..clear()
        ..addAll(_uniqueSorted(typesData));
      debugPrint('Loaded ${_facilityTypes.length} facility types');

      final authoritiesData = await ApiService.getManagingAuthorities();
      _managingAuthorities
        ..clear()
        ..addAll(_uniqueSorted(authoritiesData));
      debugPrint('Loaded ${_managingAuthorities.length} managing authorities');

      final facilitiesData = await ApiService.getHealthFacilities();
      _allFacilities
        ..clear()
        ..addAll(facilitiesData
            .whereType<Map<String, dynamic>>()
            .map(HealthFacility.fromJson));
      debugPrint('Loaded ${_allFacilities.length} facilities');

      _loaded = true;
      _applyFilters();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading facilities: $e');
    } finally {
      _loading = false;
      _notify();
    }
  }

  Future<void> loadZones(String region) async {
    try {
      final zonesData = await ApiService.getZones(region);
      _zones
        ..clear()
        ..addAll(_uniqueSorted(zonesData));
      _notify();
    } catch (e) {
      _error = e.toString();
      _notify();
    }
  }

  Future<void> loadDistricts(String zone) async {
    try {
      final districtsData = await ApiService.getDistricts(zone, _selectedRegion);
      _districts
        ..clear()
        ..addAll(_uniqueSorted(districtsData));
      _notify();
    } catch (e) {
      _error = e.toString();
      _notify();
    }
  }

  Future<void> setRegion(String? region) async {
    _selectedRegion = _emptyToNull(region);
    _selectedZone = null;
    _selectedDistrict = null;
    _zones.clear();
    _districts.clear();

    if (_selectedRegion != null) {
      try {
        final zonesData = await ApiService.getZones(_selectedRegion!);
        _zones.addAll(_uniqueSorted(zonesData));
      } catch (_) {
        _zones.addAll(_uniqueSorted(_allFacilities
            .where((f) => f.region == _selectedRegion)
            .map((f) => f.zone)));
      }
    }

    _clearUnavailableAttributeFilters();
    _applyFilters();
  }

  Future<void> setZone(String? zone) async {
    _selectedZone = _emptyToNull(zone);
    _selectedDistrict = null;
    _districts.clear();

    if (_selectedZone != null) {
      try {
        final districtsData =
            await ApiService.getDistricts(_selectedZone!, _selectedRegion);
        _districts.addAll(_uniqueSorted(districtsData));
      } catch (_) {
        _districts.addAll(_uniqueSorted(_geographyFilteredFacilities()
            .where((f) => f.zone == _selectedZone)
            .map((f) => f.district)));
      }
    }

    _clearUnavailableAttributeFilters();
    _applyFilters();
  }

  void setDistrict(String? district) {
    _selectedDistrict = _emptyToNull(district);
    _clearUnavailableAttributeFilters();
    _applyFilters();
  }

  void setFacilityType(String? type) {
    _selectedFacilityType = _emptyToNull(type);
    _applyFilters();
  }

  void setManagedBy(String? authority) {
    _selectedManagedBy = _emptyToNull(authority);
    _applyFilters();
  }

  void setUrbanRural(String? value) {
    _selectedUrbanRural = _emptyToNull(value);
    _applyFilters();
  }

  void setSearchQuery(String? query) {
    _searchQuery = _emptyToNull(query);
    _applyFilters();
  }

  void clearFilters() {
    _selectedRegion = null;
    _selectedZone = null;
    _selectedDistrict = null;
    _selectedFacilityType = null;
    _selectedManagedBy = null;
    _selectedUrbanRural = null;
    _searchQuery = null;
    _zones.clear();
    _districts.clear();
    _applyFilters();
  }

  Future<List<String>> getAvailableFacilityTypes() async {
    return _uniqueSorted(
      _geographyFilteredFacilities().map((f) => f.facilityType),
    );
  }

  Future<List<String>> getAvailableManagedBy() async {
    return _uniqueSorted(
      _geographyFilteredFacilities().map((f) => f.managingAuthority),
    );
  }

  Future<List<String>> getAvailableUrbanRural() async {
    return _uniqueSorted(
      _geographyFilteredFacilities().map((f) => f.urbanRural),
    );
  }

  List<String> getUniqueFacilityTypes() {
    return _uniqueSorted(_allFacilities.map((f) => f.facilityType));
  }

  List<String> getUniqueManagedBy() {
    return _uniqueSorted(_allFacilities.map((f) => f.managingAuthority));
  }

  HealthFacility? getFacilityByName(String name) {
    try {
      return _allFacilities.firstWhere((f) => f.facilityName == name);
    } catch (_) {
      return null;
    }
  }

  Future<void> reload() async {
    _loaded = false;
    _allFacilities.clear();
    _filteredFacilities.clear();
    _regions.clear();
    _zones.clear();
    _districts.clear();
    clearFilters();
    await load();
  }

  Future<void> addFacility(Map<String, dynamic> data) async {
    await ApiService.createFacility(data);
    await reload();
  }

  Future<void> editFacility(String id, Map<String, dynamic> data) async {
    await ApiService.updateHealthFacility(id, data);
    await reload();
  }

  Future<void> deleteFacility(String id) async {
    await ApiService.deleteHealthFacility(id);
    await reload();
  }

  void _applyFilters() {
    Iterable<HealthFacility> results = _allFacilities;

    if (_selectedRegion != null) {
      results = results.where((f) => f.region == _selectedRegion);
    }
    if (_selectedZone != null) {
      results = results.where((f) => f.zone == _selectedZone);
    }
    if (_selectedDistrict != null) {
      results = results.where((f) => f.district == _selectedDistrict);
    }
    if (_selectedFacilityType != null) {
      results = results.where((f) => f.facilityType == _selectedFacilityType);
    }
    if (_selectedManagedBy != null) {
      results = results.where((f) => f.managingAuthority == _selectedManagedBy);
    }
    if (_selectedUrbanRural != null) {
      results = results.where((f) => f.urbanRural == _selectedUrbanRural);
    }
    if (_searchQuery != null) {
      final query = _searchQuery!.toLowerCase();
      results = results.where(
        (f) =>
            f.facilityName.toLowerCase().contains(query) ||
            f.district.toLowerCase().contains(query) ||
            f.zone.toLowerCase().contains(query) ||
            f.region.toLowerCase().contains(query),
      );
    }

    _filteredFacilities
      ..clear()
      ..addAll(results);
    _notify();
  }

  List<HealthFacility> _geographyFilteredFacilities() {
    Iterable<HealthFacility> facilities = _allFacilities;
    if (_selectedRegion != null) {
      facilities = facilities.where((f) => f.region == _selectedRegion);
    }
    if (_selectedZone != null) {
      facilities = facilities.where((f) => f.zone == _selectedZone);
    }
    if (_selectedDistrict != null) {
      facilities = facilities.where((f) => f.district == _selectedDistrict);
    }
    return facilities.toList();
  }

  void _clearUnavailableAttributeFilters() {
    final scoped = _geographyFilteredFacilities();
    final types = _uniqueSorted(scoped.map((f) => f.facilityType));
    final authorities = _uniqueSorted(scoped.map((f) => f.managingAuthority));
    final urbanRural = _uniqueSorted(scoped.map((f) => f.urbanRural));

    if (_selectedFacilityType != null &&
        !types.contains(_selectedFacilityType)) {
      _selectedFacilityType = null;
    }
    if (_selectedManagedBy != null && !authorities.contains(_selectedManagedBy)) {
      _selectedManagedBy = null;
    }
    if (_selectedUrbanRural != null &&
        !urbanRural.contains(_selectedUrbanRural)) {
      _selectedUrbanRural = null;
    }
  }

  List<String> _uniqueSorted(Iterable<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  String? _emptyToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  final List<void Function()> _listeners = [];
  void addListener(void Function() l) => _listeners.add(l);
  void removeListener(void Function() l) => _listeners.remove(l);

  void _notify() {
    for (final l in List<void Function()>.from(_listeners)) {
      l();
    }
  }
}
