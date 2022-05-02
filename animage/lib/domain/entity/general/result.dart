class Result<State> {
  const Result._();
}

class Success<Data> extends Result<Data> {
  final Data data;

  const Success({required this.data}) : super._();
}

class Failure<Data> extends Result<Data> {
  final String message;
  Error? error;

  Failure({required this.message, this.error}) : super._();
}
