import 'package:tractian_challenge/model/models/asset.dart';

class LocationModel {
  String? id;
  String? name;
  String? parentId;
  List<LocationModel> childLocations = [];
  List<AssetModel> assetList = [];

  LocationModel({
    required this.id,
    required this.name,
    required this.parentId,
  });

  static fromJson(Map<String, dynamic> data) {
    return LocationModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      parentId: data['parentId'] ?? '',
    );
  }
}
