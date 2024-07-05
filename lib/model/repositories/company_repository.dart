import 'package:dartz/dartz.dart' show Either, Right, Left;
import 'package:flutter/material.dart';
import 'package:tractian_challenge/model/constants/api_constants.dart';
import 'package:tractian_challenge/model/errors/failure.dart';
import 'package:tractian_challenge/model/helpers/request_helper.dart';
import 'package:tractian_challenge/model/models/company.dart';

class CompanyRepository extends ChangeNotifier {
  Future<Either<Failure, List<CompanyModel>>> fetchCompanies() async {
    Either result = await RequestHelper.makeRequest(ApiConstants.fetchCompanies);

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          return Right(List<CompanyModel>.from(data.map((e) => CompanyModel.fromJson(e))));
        } catch (_) {
          return const Left(ModelFailure("Houve um erro durante o processamento dos dados."));
        }
      },
    );
  }
}
