class AssetModel {
  String? gatewayId;
  String? locationId;
  String? name;
  String? parentId;
  String? sensorId;
  String? sensorType;
  String? status;

  AssetModel({
    this.gatewayId,
    this.locationId,
    this.name,
    this.parentId,
    this.sensorId,
    this.sensorType,
    this.status,
  });

  static fromJson(Map<String, dynamic> json) {
    return {
      "model": AssetModel(
        gatewayId: json['gatewayId'] ?? '',
        locationId: json['locationId'] ?? '',
        name: json['name'] ?? '',
        parentId: json['parentId'] ?? '',
        sensorId: json['sensorId'] ?? '',
        sensorType: json['sensorType'] ?? '',
        status: json['status'] ?? '',
      ),
      "children": [],
    };
  }
}
