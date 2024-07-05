class ApiConstants {
  static const String baseUrl = "https://fake-api.tractian.com";
  static const String fetchCompanies = "$baseUrl/companies";
  static String fetchAssets(String companyId) => "$fetchCompanies/$companyId/assets";
  static String fetchLocations(String companyId) => "$fetchCompanies/$companyId/locations";
}
