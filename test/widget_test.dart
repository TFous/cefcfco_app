
import 'dart:convert';

class A{
    int a;
    A(this.a){
        print(a);
    }
}
void main() {
    final Map<String,String> tabs= {
        "行业":"industry",
        "沪深A股":"all",
        "沪市A股":"sh",
        "深市A股":"sz",
        "创业板":"gem",
        "中小板":"sme"
    };
    var now = new DateTime.now();
    print(now.toString().split(' ')[0]);
}
