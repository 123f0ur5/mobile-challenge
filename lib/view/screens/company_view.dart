import 'package:flutter/material.dart';
import 'package:tractian_challenge/model/models/company.dart';
import 'package:tractian_challenge/view/widgets/company_widget.dart';
import 'package:tractian_challenge/view/widgets/loading_widget.dart';
import 'package:tractian_challenge/view_model/company_view_model.dart';

class CompanyView extends StatefulWidget {
  const CompanyView({super.key});

  @override
  State<CompanyView> createState() => _CompanyViewState();
}

class _CompanyViewState extends State<CompanyView> {
  final CompanyViewModel _companyViewModel = CompanyViewModel();

  @override
  void initState() {
    _companyViewModel.fetchCompanies();

    super.initState();
  }

  @override
  void dispose() {
    _companyViewModel.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "TRACTIAN",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF17192D),
      ),
      body: ListenableBuilder(
        listenable: _companyViewModel,
        builder: (context, _) => _companyViewModel.bodyWidget == null
            ? const LoadingWidget(
                message: "Carregando empresas...",
              )
            : _companyViewModel.bodyWidget!,
      ),
    );
  }
}

class CompanyListView extends StatelessWidget {
  final List<CompanyModel> companies;
  final Function(BuildContext context, String companyId) onCompanyTap;

  const CompanyListView({
    super.key,
    required this.companies,
    required this.onCompanyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) => CompanyWidget(
            name: companies[index].name ?? "",
            onTap: () => onCompanyTap(
              context,
              companies[index].id ?? "",
            ),
          ),
          itemCount: companies.length,
        ),
      ],
    );
  }
}
