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
    var a = "03:31:57.117000";
    var b = a.split(":");

    print(b[0].length);
    
    var d1 = DateTime.parse('2018-10-10 03:31:58.117000');
    var d2 = DateTime.parse('2018-10-10 03:31:57.117000');
    var timeStamp1 =  "4:31:59.117000";



    print(d1.millisecondsSinceEpoch - d2.millisecondsSinceEpoch);
    print('Exception details:\n 123');
}
throwException() {
    throw new CustomException('This is my first custom exception');
}