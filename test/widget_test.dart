
import 'dart:convert';

class A{
    int a;
    A(this.a){
        print(a);
    }
}
void main() {
    String a = '{"Status":0}';
    Map parseJsonForString(String jsonString) {
        Map decoded = jsonDecode(jsonString);
        return decoded;
    }
    Map decoded = jsonDecode(a);
    print(decoded is Map);
}
