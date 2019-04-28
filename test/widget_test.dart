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

    var a = new HttpErrorEvent(1, '2');
    var b = new HttpErrorEvent(1, '2');



}
void main() {

    var c=[1,2,3,4,5,6,7,8,9,0];
    int a= 2;
    var d = c.sublist(8,22);
    print(d);
}
