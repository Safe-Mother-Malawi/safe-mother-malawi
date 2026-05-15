/// Fallback health facilities data for when API calls fail
/// This ensures users can always complete registration even if backend is unavailable

class FallbackFacilities {
  static const Map<String, List<Map<String, String>>> facilitiesByDistrict = {
    'Balaka': [
      {'facilityName': 'Balaka District Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Balaka Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Utale Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Phimbi Health Centre', 'facilityType': 'Health Centre'},
    ],
    'Blantyre': [
      {'facilityName': 'Queen Elizabeth Central Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Blantyre Adventist Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Mlambe Mission Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Bangwe Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Chilomoni Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Limbe Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Ndirande Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'South Lunzu Health Centre', 'facilityType': 'Health Centre'},
    ],
    'Chikwawa': [
      {'facilityName': 'Chikwawa District Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Chikwawa Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Ngabu Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Nchalo Health Centre', 'facilityType': 'Health Centre'},
    ],
    'Chiradzulu': [
      {'facilityName': 'Chiradzulu District Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Chiradzulu Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Blantyre Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Kadewere Health Centre', 'facilityType': 'Health Centre'},
    ],
    'Chitipa': [
      {'facilityName': 'Chitipa District Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Chitipa Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Kaporo Health Centre', 'facilityType': 'Health Centre'},
    ],
    'Dedza': [
      {'facilityName': 'Dedza District Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Dedza Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Lobi Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Mtakataka Health Centre', 'facilityType': 'Health Centre'},
    ],
    'Dowa': [
      {'facilityName': 'Dowa District Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Madisi Mission Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Mponela Rural Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Bowe Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Chakhaza Health Centre', 'facilityType': 'Health Centre'},
    ],
    'Karonga': [
      {'facilityName': 'Karonga District Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Karonga Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Chilumba Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Iponga Health Centre', 'facilityType': 'Health Centre'},
    ],
    'Kasungu': [
      {'facilityName': 'Kasungu District Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Nkhamenya Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Kaluluma Rural Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Bua Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Chamwabvi Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Chulu Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Kamboni Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Kapelula Health Centre', 'facilityType': 'Health Centre'},
    ],
    'Likoma': [
      {'facilityName': 'Likoma District Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Likoma Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Chizumulu Health Centre', 'facilityType': 'Health Centre'},
    ],
    'Lilongwe': [
      {'facilityName': 'Kamuzu Central Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Bwaila Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Area 18 Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Area 25 Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Kawale Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Chitedze Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Lumbadzi Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Nkhoma Mission Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'St. Gabriel Mission Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Mitundu Community Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Dzenza Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Chikowa Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Chileka Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Chimbalanga Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Chiunjiza Health Centre', 'facilityType': 'Health Centre'},
    ],
    'Machinga': [
      {'facilityName': 'Machinga District Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Machinga Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Liwonde Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Ntaja Health Centre', 'facilityType': 'Health Centre'},
    ],
    'Mangochi': [
      {'facilityName': 'Mangochi District Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Mangochi Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Monkey Bay Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Namwera Health Centre', 'facilityType': 'Health Centre'},
    ],
    'Mchinji': [
      {'facilityName': 'Mchinji District Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Mchinji Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Kapiri Health Centre', 'facilityType': 'Health Centre'},
    ],
    'Mulanje': [
      {'facilityName': 'Mulanje District Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Mulanje Mission Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Mulanje Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Chitakale Health Centre', 'facilityType': 'Health Centre'},
    ],
    'Mwanza': [
      {'facilityName': 'Mwanza District Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Mwanza Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Neno Health Centre', 'facilityType': 'Health Centre'},
    ],
    'Mzimba': [
      {'facilityName': 'Mzimba District Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Mzuzu Central Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Mzimba Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Embangweni Mission Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Ekwendeni Mission Hospital', 'facilityType': 'Hospital'},
    ],
    'Neno': [
      {'facilityName': 'Neno District Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Neno Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Ligowe Health Centre', 'facilityType': 'Health Centre'},
    ],
    'Nkhata Bay': [
      {'facilityName': 'Nkhata Bay District Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Nkhata Bay Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Chintheche Health Centre', 'facilityType': 'Health Centre'},
    ],
    'Nkhotakota': [
      {'facilityName': 'Nkhotakota District Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Dwambazi Rural Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Nkhotakota Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Benga Health Centre', 'facilityType': 'Health Centre'},
    ],
    'Nsanje': [
      {'facilityName': 'Nsanje District Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Nsanje Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Bangula Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Fatima Health Centre', 'facilityType': 'Health Centre'},
    ],
    'Ntcheu': [
      {'facilityName': 'Ntcheu District Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Ntcheu Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Bilira Health Centre', 'facilityType': 'Health Centre'},
    ],
    'Ntchisi': [
      {'facilityName': 'Ntchisi District Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Ntchisi Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Malomo Health Centre', 'facilityType': 'Health Centre'},
    ],
    'Phalombe': [
      {'facilityName': 'Phalombe District Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Phalombe Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Migowi Health Centre', 'facilityType': 'Health Centre'},
    ],
    'Rumphi': [
      {'facilityName': 'Rumphi District Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Rumphi Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Nyika Health Centre', 'facilityType': 'Health Centre'},
    ],
    'Salima': [
      {'facilityName': 'Salima District Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Salima Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Chipoka Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Lifuwu Health Centre', 'facilityType': 'Health Centre'},
    ],
    'Thyolo': [
      {'facilityName': 'Thyolo District Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Thyolo Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Bvumbwe Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Makwasa Health Centre', 'facilityType': 'Health Centre'},
    ],
    'Zomba': [
      {'facilityName': 'Zomba Central Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Zomba Mental Hospital', 'facilityType': 'Hospital'},
      {'facilityName': 'Zomba Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Matawale Health Centre', 'facilityType': 'Health Centre'},
      {'facilityName': 'Domasi Health Centre', 'facilityType': 'Health Centre'},
    ],
  };

  /// Get facilities for a district, with fallback data
  static List<Map<String, dynamic>> getFacilitiesForDistrict(String district) {
    final facilities = facilitiesByDistrict[district] ?? [];
    
    // Convert to the format expected by the app
    return facilities.map((f) => {
      'facilityName': f['facilityName']!,
      'facilityType': f['facilityType']!,
      'district': district,
      'managingAuthority': 'Government', // Default value
      'urbanRural': 'Urban', // Default value
    }).toList();
  }

  /// Get all available districts
  static List<String> getAvailableDistricts() {
    return facilitiesByDistrict.keys.toList()..sort();
  }
}