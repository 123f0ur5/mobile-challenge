class AssetModel {
  String? gatewayId;
  String? id;
  String? locationId;
  String? name;
  String? parentId;
  String? sensorId;
  String? sensorType;
  String? status;
  List<AssetModel> assetList = [];

  AssetModel({
    this.gatewayId,
    this.id,
    this.locationId,
    this.name,
    this.parentId,
    this.sensorId,
    this.sensorType,
    this.status,
  });

  static fromJson(Map<String, dynamic> json) {
    return AssetModel(
      gatewayId: json['id'] ?? '',
      id: json['id'] ?? '',
      locationId: json['locationId'] ?? '',
      name: json['name'] ?? '',
      parentId: json['parentId'] ?? '',
      sensorId: json['sensorId'] ?? '',
      sensorType: json['sensorType'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
