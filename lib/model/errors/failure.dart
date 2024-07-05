abstract class Failure {
  final String? message;

  const Failure(this.message);
}

class RequestFailure extends Failure {
  const RequestFailure(String super.message);
}

class ConnectionFailure extends Failure {
  const ConnectionFailure(String super.message);
}

class ModelFailure extends Failure {
  const ModelFailure(String super.message);
}

class NotImplementedFailure extends Failure {
  const NotImplementedFailure(String super.message);
}
