import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:tractian_challenge/model/models/asset.dart';
import 'package:tractian_challenge/model/models/location.dart';
import 'package:tractian_challenge/view/widgets/custom_icon_button.dart';
import 'package:tractian_challenge/view/widgets/loading_widget.dart';
import 'package:tractian_challenge/view/widgets/custom_search_bar.dart';
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
  @override
  void initState() {
    Provider.of<AssetsTreeViewModel>(context, listen: false).initData(companyId: widget.companyId);
    super.initState();
  }

  @override
  void dispose() {
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
      body: Consumer<AssetsTreeViewModel>(
        builder: (context, value, _) => value.bodyWidget == null
            ? const LoadingWidget(
                message: "Carregando assets...",
              )
            : value.bodyWidget!,
      ),
    );
  }
}

class AssetsTree extends StatefulWidget {
  final List<dynamic> mainNodes;
  final Function(dynamic parent) onParentTap;
  final VoidCallback onChanged;
  final TextEditingController controller;

  const AssetsTree({
    super.key,
    required this.mainNodes,
    required this.onParentTap,
    required this.onChanged,
    required this.controller,
  });

  @override
  State<AssetsTree> createState() => _AssetsTreeState();
}

class _AssetsTreeState extends State<AssetsTree> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomSearchBar(controller: widget.controller, onChanged: widget.onChanged),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Consumer<AssetsTreeViewModel>(
            builder: (context, value, _) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconButton(
                  text: Text(
                    "Sensor de Energia",
                    style: TextStyle(
                      color: value.isEnergyFilterActive ? Colors.white : const Color(0xFF77818C),
                    ),
                  ),
                  icon: Icon(
                    Icons.bolt,
                    color: value.isEnergyFilterActive ? Colors.white : const Color(0xFF77818C),
                  ),
                  backgroundColor: value.isEnergyFilterActive ? const Color(0xFF2188FF) : Colors.white,
                  borderColor: value.isEnergyFilterActive ? const Color(0xFF2188FF) : const Color(0xFF77818C),
                  onPressed: () {
                    value.isEnergyFilterActive = !value.isEnergyFilterActive;

                    widget.onChanged();
                  },
                ),
                const SizedBox(
                  width: 16,
                ),
                CustomIconButton(
                  text: Text(
                    "Estado crítico",
                    style: TextStyle(
                      color: value.isAlertFilterActive ? Colors.white : const Color(0xFF77818C),
                    ),
                  ),
                  icon: Icon(
                    Icons.error_outline,
                    color: value.isAlertFilterActive ? Colors.white : const Color(0xFF77818C),
                  ),
                  backgroundColor: value.isAlertFilterActive ? const Color(0xFF2188FF) : Colors.white,
                  borderColor: value.isAlertFilterActive ? const Color(0xFF2188FF) : const Color(0xFF77818C),
                  onPressed: () {
                    value.isAlertFilterActive = !value.isAlertFilterActive;

                    widget.onChanged();
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.mainNodes.length,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) => NodeWidget(
                node: widget.mainNodes[index],
                children: _getChildren(widget.mainNodes[index]),
                mainNode: true,
                onParentTap: widget.onParentTap,
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
  final List<dynamic> children;
  final Function(dynamic parent) onParentTap;

  final bool mainNode;
  final double leftPadding;
  const NodeWidget({
    super.key,
    required this.node,
    required this.children,
    required this.onParentTap,
    this.mainNode = false,
    this.leftPadding = 16,
  });

  @override
  State<NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<NodeWidget> {
  @override
  Widget build(BuildContext context) {
    bool hasChildren = widget.children.isNotEmpty;

    return ExpansionTile(
      title: Row(
        children: [
          SvgPicture.asset(
            _getNodeIcon(widget.node),
            width: 20,
            height: 20,
          ),
          const SizedBox(
            width: 8,
          ),
          Text(
            widget.node.name,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
          _getNodeTrailingIcon(widget.node),
        ],
      ),
      shape: const Border(),
      leading: hasChildren ? const Icon(Icons.keyboard_arrow_down) : null,
      trailing: const SizedBox.shrink(),
      tilePadding:
          EdgeInsets.only(left: !hasChildren && !widget.mainNode ? widget.leftPadding + 30 : widget.leftPadding),
      minTileHeight: 40,
      enabled: hasChildren,
      maintainState: true,
      onExpansionChanged: (_) {
        widget.onParentTap(widget.node);
        setState(() {});
      },
      children: [
        for (var child in widget.children)
          NodeWidget(
            node: child,
            children: _getChildren(child),
            leftPadding: widget.leftPadding + 16,
            onParentTap: widget.onParentTap,
          )
      ],
    );
  }
}

List<dynamic> _getChildren(dynamic parent) {
  if (parent.runtimeType == LocationModel) {
    return [...?parent?.assetList, ...?parent?.childLocations];
  } else if (parent.runtimeType == AssetModel) {
    return [...?parent?.assetList];
  }

  return [];
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
