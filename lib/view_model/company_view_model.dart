import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/material.dart';
import 'package:tractian_challenge/model/errors/failure.dart';
import 'package:tractian_challenge/model/models/company.dart';
import 'package:tractian_challenge/model/repositories/company_repository.dart';
import 'package:tractian_challenge/routes.dart';
import 'package:tractian_challenge/view/screens/company_view.dart';
import 'package:tractian_challenge/view/widgets/failure_widget.dart';

class CompanyViewModel extends ChangeNotifier {
  Widget? bodyWidget;

  void fetchCompanies() async {
    Either<Failure, List<CompanyModel>> response = await CompanyRepository().fetchCompanies();

    response.fold(
      (failure) => bodyWidget = FailureWidget(message: failure.message ?? "", onTap: fetchCompanies),
      (data) => bodyWidget = CompanyListView(companies: data, onCompanyTap: onCompanyTap),
    );

    notifyListeners();
  }

  void onCompanyTap(BuildContext context, String companyId) {
    Navigator.push(
      context,
      AppRoutes.assetsTreeView(companyId),
    );
  }
}
