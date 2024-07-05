class CompanyModel {
  String? id;
  String? name;

  CompanyModel({
    this.id,
    this.name,
  });

  static fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
