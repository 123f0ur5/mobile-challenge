import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tractian_challenge/model/constants/string_constants.dart';
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

  Map assets = {};
  Map locations = {};

  List<String> mainNodes = [];
  List<String> energySensorsIds = [];
  List<String> criticalSensorsIds = [];
  List<String> energyCriticalSensorsIds = [];

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

  /*  Estrutura dos nodes foi alterada para melhorar o desempenho da aplicação.
      Agora ao criar um asset/location, ele vem com a seguinte estrutura:
      {asset.id : 
        {
          'model': AssetModel ou LocationModel,
          'children': [], //Ids dos filhos daquele node
        }
      }

      Pois definindo uma chave de acesso, não preciso procurar no array o elemento pai
      correspondente do node, apenas passo a chave e tenho o retorno instantâneo.

      Com essa mudança, garanto O(n) na aplicação.
   */

  Future<void> _fetchAssets() async {
    Either<Failure, Map> response = await AssetRepository().fetchAssets(_companyId ?? "");

    response.fold(
      (failure) => bodyWidget = FailureWidget(message: failure.message ?? "", onTap: initData),
      (data) => assets = data,
    );
  }

  Future<void> _fetchLocations() async {
    Either<Failure, Map> response = await LocationRepository().fetchLocations(_companyId ?? "");

    response.fold(
      (failure) => bodyWidget = FailureWidget(message: failure.message ?? "", onTap: initData),
      (data) => locations = data,
    );
  }

  void _processMainNodes() {
    for (MapEntry entry in locations.entries) {
      String? parentId = entry.value['model'].parentId;

      if (parentId != "") {
        locations[parentId]['children'].add(entry.key);

        continue;
      }

      mainNodes.add(entry.key);
    }

    for (MapEntry entry in assets.entries) {
      String? locationId = entry.value['model'].locationId;
      bool energyAsset = entry.value['model'].sensorType == SensorTypes.energy.name;
      bool alertAsset = entry.value['model'].status == SensorStatus.alert.name;

      if (energyAsset) {
        energySensorsIds.add(entry.key);

        if (alertAsset) energyCriticalSensorsIds.add(entry.key);
      }

      if (alertAsset) criticalSensorsIds.add(entry.key);

      if (locationId != "") {
        locations[locationId]['children'].add(entry.key);

        continue;
      }

      String? parentId = entry.value['model'].parentId;

      if (parentId != "") {
        assets[parentId]['children'].add(entry.key);

        continue;
      }

      mainNodes.add(entry.key);
    }

    _setBodyWidget();
  }

  void _setBodyWidget({List<String>? nodes, Map? allNodes}) {
    bodyWidget = AssetsTree(
      mainNodesIds: nodes ?? mainNodes,
      allNodes: allNodes ?? {...assets, ...locations},
      controller: this,
      txtController: searchText,
    );

    notifyListeners();
  }

  Future<void> onNodesSearch() async {
    List<String> mainQueryIds = [];
    Map searchChildrenNodes = {};
    Map queryNodes = {};

    bool isAnyFilterMarked = isAlertFilterActive || isEnergyFilterActive;

    if (searchText.text == "" && !isAnyFilterMarked) {
      _setBodyWidget();

      return;
    }

    if (searchText.text != "" && !isAnyFilterMarked) {
      assets.forEach(
        (key, value) {
          if (value['model'].name.toUpperCase().contains(searchText.text.toUpperCase())) {
            queryNodes.addAll({
              key: {'model': value['model'], 'children': []}
            });
          }
        },
      );

      locations.forEach(
        (key, value) {
          if (value['model'].name.toUpperCase().contains(searchText.text.toUpperCase())) {
            queryNodes.addAll({
              key: {'model': value['model'], 'children': []}
            });
          }
        },
      );
    }

    if (isEnergyFilterActive && isAlertFilterActive) {
      for (String id in energyCriticalSensorsIds) {
        queryNodes.addAll({
          id: {'model': assets[id]['model'] ?? locations[id]['model'], 'children': []}
        });
      }
    } else {
      if (isEnergyFilterActive) {
        for (String id in energySensorsIds) {
          queryNodes.addAll({
            id: {'model': assets[id]['model'] ?? locations[id]['model'], 'children': []}
          });
        }
      }

      if (isAlertFilterActive) {
        for (String id in criticalSensorsIds) {
          queryNodes.addAll({
            id: {'model': assets[id]['model'] ?? locations[id]['model'], 'children': []}
          });
        }
      }
    }

    if (searchText.text != "") {
      queryNodes.removeWhere((k, v) => !v['model'].name.toUpperCase().contains(searchText.text.toUpperCase()));
    }

    queryNodes.forEach(
      (key, value) {
        dynamic node = value['model'];
        String? nodeKey = key;
        String? lastNodeKey = "";
        bool isMainNode = false;

        while (!isMainNode) {
          if (node is LocationModel) {
            if (node.parentId == '') {
              if (!mainQueryIds.contains(nodeKey)) {
                mainQueryIds.add(nodeKey!);
              }

              _updateSearchChildrenNodes(searchChildrenNodes, nodeKey, lastNodeKey, node: node);

              isMainNode = true;

              continue;
            }

            if (node.parentId != '') {
              _updateSearchChildrenNodes(searchChildrenNodes, node.parentId, nodeKey, childrenMaps: locations);

              lastNodeKey = nodeKey;
              nodeKey = node.parentId;
              node = locations[node.parentId]['model'];
            }
          }

          if (node is AssetModel) {
            if (node.parentId == '' && node.locationId == '') {
              if (!mainQueryIds.contains(nodeKey)) {
                mainQueryIds.add(nodeKey!);
              }

              _updateSearchChildrenNodes(searchChildrenNodes, nodeKey, lastNodeKey, node: node);

              isMainNode = true;

              continue;
            }

            if (node.parentId != '') {
              _updateSearchChildrenNodes(searchChildrenNodes, node.parentId, nodeKey, childrenMaps: assets);

              lastNodeKey = nodeKey;

              nodeKey = node.parentId;

              node = assets[node.parentId]['model'];

              continue;
            }

            if (node.locationId != '') {
              _updateSearchChildrenNodes(searchChildrenNodes, node.locationId, nodeKey, childrenMaps: locations);

              lastNodeKey = nodeKey;
              nodeKey = node.locationId;
              node = locations[node.locationId]['model'];

              continue;
            }
          }
        }
      },
    );

    queryNodes.forEach(
      (key, value) => searchChildrenNodes.putIfAbsent(key, () => value),
    );

    _setBodyWidget(nodes: mainQueryIds, allNodes: searchChildrenNodes);
  }

  void _updateSearchChildrenNodes(
    Map searchChildrenNodes,
    String? parentKey,
    String? childrenKey, {
    Map? childrenMaps,
    dynamic node,
  }) {
    searchChildrenNodes.update(
      parentKey,
      (e) {
        if ((childrenKey?.isNotEmpty ?? false) && !e['children'].contains(childrenKey)) {
          e['children'].add(childrenKey);
        }

        return e;
      },
      ifAbsent: () => {
        'model': node ?? childrenMaps?[parentKey]['model'],
        'children': childrenKey == '' ? [] : [childrenKey],
      },
    );
  }

  //     if (isAlertFilterActive) {
  //       for (AssetModel alertNode in alertStatusSensors) {
  //         if (!alertNode.name!.toUpperCase().contains(searchText.text.toUpperCase())) continue;

  //         dynamic node = getNodeTree(alertNode, mainNodesSearch);

  //         if (node != null) {
  //           mainNodesSearch.add(node);
  //         }
  //       }
  //     }
  //   }

  //   bodyWidget = AssetsTree(
  //     mainNodes: mainNodesSearch,
  //     onParentTap: _getChildrenNodes,
  //     onChanged: onNodesSearch,
  //     controller: searchText,
  //   );

  //   notifyListeners();
  // }

  // dynamic getNodeTree(dynamic child, List<dynamic> mainNodes) {
  //   if (child.runtimeType == LocationModel) {
  //     if (child.parentId == "") return child;

  //     for (LocationModel location in locations) {
  //       if (child.parentId == location.id) {
  //         if (!location.childLocations.contains(child)) {
  //           location.childLocations.add(child);
  //         }

  //         if (mainNodes.contains(location)) return;

  //         return getNodeTree(location, mainNodes);
  //       }
  //     }
  //   }

  //   if (child.runtimeType == AssetModel) {
  //     if (child.locationId == "" && child.parentId == "") return child;

  //     if (child.locationId != "") {
  //       for (LocationModel location in locations) {
  //         if (child.locationId == location.id) {
  //           if (!location.assetList.contains(child)) {
  //             location.assetList.add(child);
  //           }

  //           if (mainNodes.contains(location)) return;

  //           return getNodeTree(location, mainNodes);
  //         }
  //       }
  //     }

  //     if (child.parentId != "") {
  //       for (AssetModel asset in assets) {
  //         if (child.parentId == asset.id) {
  //           if (!asset.assetList.contains(child)) {
  //             asset.assetList.add(child);
  //           }

  //           if (mainNodes.contains(asset)) return;

  //           return getNodeTree(asset, mainNodes);
  //         }
  //       }
  //     }
  //   }
  // }
}
