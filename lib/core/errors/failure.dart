class Failure {
  final String code;
  final String message;

  const Failure(this.code, this.message);

  @override
  String toString() => 'Failure(code: $code, message: $message)';
}
