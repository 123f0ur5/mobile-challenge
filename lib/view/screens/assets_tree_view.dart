import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tractian_challenge/model/models/asset.dart';
import 'package:tractian_challenge/model/models/location.dart';
import 'package:tractian_challenge/view/widgets/custom_icon_button.dart';
import 'package:tractian_challenge/view/widgets/loading_widget.dart';
import 'package:tractian_challenge/view/widgets/custom_search_bar.dart';
import 'package:tractian_challenge/view/widgets/not_found.dart';
import 'package:tractian_challenge/view_model/assets_tree_view_model.dart';

class AssetsTreeView extends StatefulWidget {
  final String companyId;

  const AssetsTreeView({
    super.key,
    required this.companyId,
  });

  @override
  State<AssetsTreeView> createState() => _AssetsTreeViewState();
}

class _AssetsTreeViewState extends State<AssetsTreeView> {
  final AssetsTreeViewModel _assetsTreeViewModel = AssetsTreeViewModel();

  @override
  void initState() {
    _assetsTreeViewModel.initData(companyId: widget.companyId);
    super.initState();
  }

  @override
  void dispose() {
    _assetsTreeViewModel.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            size: 24,
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Assets",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF17192D),
      ),
      body: ListenableBuilder(
        listenable: _assetsTreeViewModel,
        builder: (context, _) => _assetsTreeViewModel.bodyWidget == null
            ? const LoadingWidget(
                message: "Carregando assets...",
              )
            : _assetsTreeViewModel.bodyWidget!,
      ),
    );
  }
}

class AssetsTree extends StatefulWidget {
  final List<String> mainNodesIds;
  final Map allNodes;
  final AssetsTreeViewModel controller;
  final TextEditingController txtController;

  const AssetsTree({
    super.key,
    required this.mainNodesIds,
    required this.allNodes,
    required this.controller,
    required this.txtController,
  });

  @override
  State<AssetsTree> createState() => _AssetsTreeState();
}

class _AssetsTreeState extends State<AssetsTree> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomSearchBar(
          controller: widget.txtController,
          onChanged: widget.controller.onNodesSearch,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListenableBuilder(
            listenable: widget.controller,
            builder: (context, _) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconButton(
                  text: "Sensor de Energia",
                  icon: Icons.bolt,
                  isActive: widget.controller.isEnergyFilterActive,
                  onPressed: () {
                    widget.controller.isEnergyFilterActive = !widget.controller.isEnergyFilterActive;
                    widget.controller.onNodesSearch();

                    setState(() {});
                  },
                ),
                const SizedBox(
                  width: 16,
                ),
                CustomIconButton(
                  text: "Estado crítico",
                  icon: Icons.error_outline,
                  isActive: widget.controller.isAlertFilterActive,
                  onPressed: () async {
                    widget.controller.isAlertFilterActive = !widget.controller.isAlertFilterActive;
                    await widget.controller.onNodesSearch();

                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        widget.mainNodesIds.isEmpty
            ? const NotFound(message: "Nenhum item encontrado")
            : Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.mainNodesIds.length,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) => NodeWidget(
                      node: widget.allNodes[widget.mainNodesIds[index]],
                      allNodes: widget.allNodes,
                      controller: widget.controller,
                      mainNode: true,
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}

class NodeWidget extends StatefulWidget {
  final dynamic node;
  final Map allNodes;
  final AssetsTreeViewModel controller;
  final bool mainNode;
  final double leftPadding;

  const NodeWidget({
    super.key,
    required this.node,
    required this.allNodes,
    required this.controller,
    this.mainNode = false,
    this.leftPadding = 16,
  });

  @override
  State<NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<NodeWidget> {
  bool isActive = false;

  @override
  Widget build(BuildContext context) {
    bool hasChildren = widget.node['children']?.isNotEmpty ?? false;

    return ExpansionTile(
      title: Row(
        children: [
          SvgPicture.asset(
            _getNodeIcon(widget.node['model']),
            width: 20,
            height: 20,
          ),
          const SizedBox(
            width: 8,
          ),
          Text(
            widget.node['model'].name,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
          _getNodeTrailingIcon(widget.node['model']),
        ],
      ),
      shape: const Border(),
      leading: hasChildren ? const Icon(Icons.keyboard_arrow_down) : null,
      trailing: const SizedBox.shrink(),
      tilePadding: EdgeInsets.only(
        left: !hasChildren && !widget.mainNode ? widget.leftPadding + 30 : widget.leftPadding,
      ),
      minTileHeight: 40,
      enabled: hasChildren,
      maintainState: true,
      onExpansionChanged: (expanded) {
        setState(() {
          isActive = expanded;
        });
      },
      children: [
        if (isActive)
          ListView.builder(
            itemCount: widget.node['children'].length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => NodeWidget(
              node: widget.allNodes[widget.node['children'][index]],
              allNodes: widget.allNodes,
              controller: widget.controller,
              leftPadding: widget.leftPadding + 16,
            ),
          ),
      ],
    );
  }
}

String _getNodeIcon(dynamic node) {
  if (node.runtimeType == LocationModel) return "assets/svgs/location.svg";

  if (node.sensorType != "") return "assets/svgs/codepen.svg";

  if (node.sensorId == "") return "assets/svgs/box.svg";

  return "";
}

Widget _getNodeTrailingIcon(dynamic node) {
  if (node.runtimeType == AssetModel) {
    return Row(
      children: [
        if (node.sensorType == "energy")
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Icon(
              Icons.bolt,
              size: 18,
              color: Color(0xFF52C41A),
            ),
          ),
        if (node.sensorType == "vibration")
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Icon(
              Icons.vibration,
              size: 18,
              color: Color(0xFF52C41A),
            ),
          ),
        if (node.status == "alert")
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: CircleAvatar(
              backgroundColor: Color(0xFFED3833),
              radius: 3.5,
            ),
          )
      ],
    );
  }

  return const SizedBox.shrink();
}
