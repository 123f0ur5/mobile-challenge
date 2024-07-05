import 'package:flutter/material.dart';
import 'package:tractian_challenge/utils/fade_transition_util.dart';
import 'package:tractian_challenge/view/screens/assets_tree_view.dart';
import 'package:tractian_challenge/view/screens/company_view.dart';

class AppRoutes {
  static homeView() => RouteUtils.fadeTransitionRoute(
        const CompanyView(),
        settings: const RouteSettings(name: "/"),
      );

  static assetsTreeView(String companyId) => RouteUtils.fadeTransitionRoute(
        AssetsTreeView(companyId: companyId),
        settings: const RouteSettings(name: "/assetsTreeView"),
      );
}
