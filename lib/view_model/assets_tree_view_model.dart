import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tractian_challenge/model/errors/failure.dart';
import 'package:tractian_challenge/model/models/asset.dart';
import 'package:tractian_challenge/model/models/location.dart';
import 'package:tractian_challenge/model/repositories/asset_repository.dart';
import 'package:tractian_challenge/model/repositories/location_repository.dart';
import 'package:tractian_challenge/view/screens/assets_tree_view.dart';
import 'package:tractian_challenge/view/widgets/failure_widget.dart';

class AssetsTreeViewModel extends ChangeNotifier {
  Widget? bodyWidget;

  String? _companyId;

  List<AssetModel> _assets = [];
  List<LocationModel> _locations = [];

  bool isEnergyFilterActive = false;
  bool isAlertFilterActive = false;

  TextEditingController searchText = TextEditingController();

  void initData({String? companyId}) async {
    _companyId = companyId;
    bodyWidget = null;

    await _fetchAssets();
    await _fetchLocations();

    _processMainNodes();
  }

  Future<void> _fetchAssets() async {
    Either<Failure, List<AssetModel>> response = await AssetRepository().fetchAssets(_companyId ?? "");

    response.fold(
      (failure) => bodyWidget = FailureWidget(message: failure.message ?? "", onTap: initData),
      (data) => _assets = data,
    );
  }

  Future<void> _fetchLocations() async {
    Either<Failure, List<LocationModel>> response = await LocationRepository().fetchLocations(_companyId ?? "");

    response.fold(
      (failure) => bodyWidget = FailureWidget(message: failure.message ?? "", onTap: initData),
      (data) => _locations = data,
    );
  }

  void _processMainNodes() {
    List<dynamic> mainNodesProcess = [];
    isAlertFilterActive = false;
    isEnergyFilterActive = false;
    searchText.text = "";

    for (var location in _locations) {
      if (location.parentId == "") {
        for (var loc in _locations) {
          if (loc.parentId == location.id) {
            location.childLocations.add(loc);
          }
        }
        mainNodesProcess.add(location);
      }
    }

    for (var asset in _assets) {
      if (asset.parentId == "" && asset.locationId == "") {
        for (var ass in _assets) {
          if (ass.parentId == ass.id) {
            asset.assetList.add(ass);
          }
        }

        mainNodesProcess.add(asset);
      }
    }

    for (var node in mainNodesProcess) {
      if (node.runtimeType == LocationModel) {
        for (LocationModel location in _locations) {
          if (location.parentId == node.id) {
            if (node.childLocations.contains(location)) continue;
            node.childLocations.add(location);
          }
        }
      }

      for (AssetModel asset in _assets) {
        if (asset.locationId == node.id) {
          node.assetList.add(asset);
        }
      }
    }

    _setBodyWidget(mainNodesProcess);
  }

  void _setBodyWidget(List<dynamic> mainNodes) {
    bodyWidget = AssetsTree(
      mainNodes: mainNodes,
      onParentTap: _getChildrenNodes,
      onChanged: onNodesSearch,
      controller: searchText,
    );
    notifyListeners();
  }

  void _getChildrenNodes(dynamic parent) {
    if (searchText.text != "" || isAlertFilterActive || isEnergyFilterActive) return;

    if (parent.runtimeType == LocationModel) {
      for (LocationModel location in parent.childLocations) {
        for (LocationModel loc in _locations) {
          if (location.id == loc.parentId && !location.childLocations.contains(loc)) {
            location.childLocations.add(loc);
          }
        }
        for (AssetModel ass in _assets) {
          if (location.id == ass.locationId && !location.assetList.contains(ass)) {
            location.assetList.add(ass);
          }
        }
      }
    }

    for (AssetModel asset in parent.assetList) {
      for (AssetModel ass in _assets) {
        if (asset.id == ass.parentId && !asset.assetList.contains(ass)) {
          asset.assetList.add(ass);
        }
      }
    }
  }

  void onNodesSearch() async {
    _assets = [];
    _locations = [];

    await _fetchAssets();
    await _fetchLocations();

    bool isAnyFilterMarked = isAlertFilterActive || isEnergyFilterActive;

    if (searchText.text == "" && !isAnyFilterMarked) {
      initData();
      return;
    }

    List<dynamic> mainNodesSearch = [];

    List<AssetModel> energySensors = [];
    List<AssetModel> alertStatusSensors = [];

    for (AssetModel asset in _assets) {
      if (asset.sensorType == "energy") {
        energySensors.add(asset);
      }

      if (asset.status == "alert") {
        alertStatusSensors.add(asset);
      }
    }

    if (searchText.text != "" && !isEnergyFilterActive && !isAlertFilterActive) {
      for (dynamic currNode in [..._locations, ..._assets]) {
        if (currNode.name.toUpperCase().contains(searchText.text.toUpperCase())) {
          dynamic node = getNodeTree(currNode, mainNodesSearch);

          if (node != null && !mainNodesSearch.contains(node)) {
            mainNodesSearch.add(node);
          }
        }
      }
    } else if (isEnergyFilterActive && isAlertFilterActive) {
      for (AssetModel asset in [...energySensors, ...alertStatusSensors]) {
        if (asset.sensorType == "energy" && asset.status == "alert" && asset.name!.contains(searchText.text)) {
          dynamic node = getNodeTree(asset, mainNodesSearch);

          if (node != null) {
            mainNodesSearch.add(node);
          }
        }
      }
    } else {
      if (isEnergyFilterActive) {
        for (AssetModel energyNode in energySensors) {
          if (!energyNode.name!.toUpperCase().contains(searchText.text.toUpperCase())) continue;

          dynamic node = getNodeTree(energyNode, mainNodesSearch);

          if (node != null) {
            mainNodesSearch.add(node);
          }
        }
      }

      if (isAlertFilterActive) {
        for (AssetModel alertNode in alertStatusSensors) {
          if (!alertNode.name!.toUpperCase().contains(searchText.text.toUpperCase())) continue;

          dynamic node = getNodeTree(alertNode, mainNodesSearch);

          if (node != null) {
            mainNodesSearch.add(node);
          }
        }
      }
    }

    bodyWidget = AssetsTree(
      mainNodes: mainNodesSearch,
      onParentTap: _getChildrenNodes,
      onChanged: onNodesSearch,
      controller: searchText,
    );

    notifyListeners();
  }

  dynamic getNodeTree(dynamic child, List<dynamic> mainNodes) {
    if (child.runtimeType == LocationModel) {
      if (child.parentId == "") return child;

      for (LocationModel location in _locations) {
        if (child.parentId == location.id) {
          if (!location.childLocations.contains(child)) {
            location.childLocations.add(child);
          }

          if (mainNodes.contains(location)) return;

          return getNodeTree(location, mainNodes);
        }
      }
    }

    if (child.runtimeType == AssetModel) {
      if (child.locationId == "" && child.parentId == "") return child;

      if (child.locationId != "") {
        for (LocationModel location in _locations) {
          if (child.locationId == location.id) {
            if (!location.assetList.contains(child)) {
              location.assetList.add(child);
            }

            if (mainNodes.contains(location)) return;

            return getNodeTree(location, mainNodes);
          }
        }
      }

      if (child.parentId != "") {
        for (AssetModel asset in _assets) {
          if (child.parentId == asset.id) {
            if (!asset.assetList.contains(child)) {
              asset.assetList.add(child);
            }

            if (mainNodes.contains(asset)) return;

            return getNodeTree(asset, mainNodes);
          }
        }
      }
    }
  }
}
