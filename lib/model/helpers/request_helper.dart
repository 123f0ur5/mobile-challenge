import 'dart:io';

import 'package:dartz/dartz.dart' show Either, Right, Left;
import 'package:dio/dio.dart';
import 'package:tractian_challenge/model/errors/failure.dart';

class RequestHelper {
  static Future<Either<Failure, dynamic>> makeRequest<T>(String endpoint) async {
    try {
      Response response = await Dio()
          .get(
            endpoint,
          )
          .timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode == 200) {
        return Right(response.data);
      } else {
        return const Left(RequestFailure("Ocorreu um erro durante a request."));
      }
    } on SocketException {
      return const Left(ConnectionFailure("Não foi possível se conectar a rede."));
    } catch (e) {
      return Left(NotImplementedFailure("Erro não implementado. $e"));
    }
  }
}
