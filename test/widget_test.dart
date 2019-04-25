import 'dart:math';

class HttpErrorEvent {
    final int code;

    final String message;
    double getVariance(c,ma,int n){
        double num = c-ma;
        return num*num;
    }
    double getmd(List list,int length){

        double addAll=0; // 累加总数，用于计算平均数
        double allVariance=0;  // 累加差值，用于计算md

        list.asMap().forEach((index,num){
            addAll+=num;
            double ma = addAll/(index+1);
            double a = getVariance(num,ma,length);
            allVariance+=a;
        });
        return sqrt(allVariance/length);
    }


    HttpErrorEvent(this.code, this.message);
}
class CustomException implements Exception {
    String cause;
    CustomException(this.cause);
}
void main() {
    var d1 = DateTime.parse('2018-10-10 03:31:58');
    var d2 = DateTime.parse('2018-10-10 03:31:59');
    var timeStamp1 =  "4:31:59.117000";


    var list = [21,22,33,44,32,52,67,77,88,15];


    var aa = new HttpErrorEvent(1,'2');
    double b = aa.getmd(list, 10);
    print(b);

}
throwException() {
    throw new CustomException('This is my first custom exception');
}