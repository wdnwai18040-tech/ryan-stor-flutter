class NoInternetException implements Exception {
  final String message;

  NoInternetException([
    this.message = 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الاتصال والمحاولة مرة أخرى.',
  ]);

  @override
  String toString() {
    return message;
  }
}