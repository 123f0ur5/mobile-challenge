import 'package:dartz/dartz.dart' show Either, Right, Left;
import 'package:tractian_challenge/model/constants/api_constants.dart';
import 'package:tractian_challenge/model/errors/failure.dart';
import 'package:tractian_challenge/model/helpers/request_helper.dart';
import 'package:tractian_challenge/model/models/asset.dart';

class AssetRepository {
  Future<Either<Failure, Map>> fetchAssets(String companyId) async {
    Either result = await RequestHelper.makeRequest(ApiConstants.fetchAssets(companyId));

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          return Right({for (var entry in data) entry['id']: AssetModel.fromJson(entry)});
        } catch (_) {
          return const Left(ModelFailure("Houve um erro durante o processamento dos dados."));
        }
      },
    );
  }
}
