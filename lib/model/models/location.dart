class LocationModel {
  String? name;
  String? parentId;

  LocationModel({
    required this.name,
    required this.parentId,
  });

  static fromJson(Map<String, dynamic> data) {
    return {
      'model': LocationModel(
        name: data['name'] ?? '',
        parentId: data['parentId'] ?? '',
      ),
      "children": [],
    };
  }
}
