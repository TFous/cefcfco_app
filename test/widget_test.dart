class HttpErrorEvent {
    final int code;

    final String message;

    HttpErrorEvent(this.code, this.message);
}
class CustomException implements Exception {
    String cause;
    CustomException(this.cause);
}
void main() {
    print('Exception details:\n 123');
}
throwException() {
    throw new CustomException('This is my first custom exception');
}