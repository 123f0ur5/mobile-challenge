import 'package:dartz/dartz.dart' show Either, Right, Left;
import 'package:tractian_challenge/model/constants/api_constants.dart';
import 'package:tractian_challenge/model/errors/failure.dart';
import 'package:tractian_challenge/model/helpers/request_helper.dart';
import 'package:tractian_challenge/model/models/location.dart';

class LocationRepository {
  Future<Either<Failure, Map>> fetchLocations(String companyId) async {
    Either result = await RequestHelper.makeRequest(ApiConstants.fetchLocations(companyId));

    return result.fold(
      (error) => Left(error),
      (data) {
        try {
          return Right({for (var entry in data) entry['id']: LocationModel.fromJson(entry)});
        } catch (_) {
          return const Left(ModelFailure("Houve um erro durante o processamento dos dados."));
        }
      },
    );
  }
}
