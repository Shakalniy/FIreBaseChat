import 'dart:math';

class Crypto {

  List<int> firstPrimesList = <int>[2, 3, 5, 7, 11, 13, 17, 19, 23, 29,
                                    31, 37, 41, 43, 47, 53, 59, 61, 67,
                                    71, 73, 79, 83, 89, 97, 101, 103,
                                    107, 109, 113, 127, 131, 137, 139,
                                    149, 151, 157, 163, 167, 173, 179,
                                    181, 191, 193, 197, 199, 211, 223,
                                    227, 229, 233, 239, 241, 251, 257,
                                    263, 269, 271, 277, 281, 283, 293,
                                    307, 311, 313, 317, 331, 337, 347, 349];

  final BigInt maxBig = BigInt.from(999999999);
  final n = 8;

  BigInt nextInt(BigInt max) {
    int digits = max.toString().length;
    var out = BigInt.from(0);
    do {
      var str = "";
      for (int i = 0; i < digits; i++) {
        str += Random().nextInt(10).toString();
      }
      out = BigInt.parse(str);
    } while (out > max);
    return out;
  }

  bool ferma (BigInt x) {
    if(x == BigInt.two) {
      return true;
    }
    for(int i = 0; i < 100; i++){
      BigInt a = (nextInt(maxBig) % (x - BigInt.two)) + BigInt.two;
      if (gcd(a, x) != BigInt.one) {
        return false;
      }
      if(pows(a, x - BigInt.one, x) != BigInt.one) {
        return false;
      }
    }
    return true;
  }

  BigInt gcd(BigInt a, BigInt b) {
    if (b == BigInt.zero) {
      return a;
    }
    return gcd(b, a % b);
  }

  BigInt mul(BigInt a, BigInt b, BigInt m) {
    if(b == BigInt.one) {
      return a;
    }
    if(b % BigInt.two == BigInt.zero) {
      BigInt t = mul(a, BigInt.from(b / BigInt.two), m);
      return (BigInt.two * t) % m;
    }
    return (mul(a, b - BigInt.one, m) + a) % m;
  }

  BigInt pows(BigInt a, BigInt b, BigInt m) {
    if(b == BigInt.zero) {
      return BigInt.one;
    }
    if (b % BigInt.two == BigInt.zero) {
      BigInt t = pows(a, BigInt.from(b / BigInt.two), m);
      return mul(t, t, m) % m;
    }
    return (mul(pows(a, b - BigInt.one, m) , a, m)) % m;
  }

  String bigIntTo16bits(BigInt val){
    List<String> ret = [];
    String res = "";
    int cur;
    while(true){
      cur = (val & BigInt.from(0xFFFF)).toInt();
      if (cur != 0) {
        String binaryNumber = cur.toRadixString(2);
        ret.add(("0"*(16 - binaryNumber.length)) + binaryNumber);
        val = val >> 16;
      }
      else{
        break;
      }
    }
    ret = ret.reversed.toList();
    for (var element in ret) {
      res += element;
    }
    return res;
  }

  List<BigInt> genPrimeNum() {
    var p = nextInt(maxBig);
    while (!ferma(p)) {
      p += BigInt.one;
    }
    BigInt g = nextInt(p);
    BigInt a = nextInt(maxBig);
    BigInt A = pows(g, a, p);
    return [p, g, A, a];
  }

  String encryptText(String message, BigInt key) {
    String enText = crypt(message, key, true);
    return enText;
  }

  String decryptText(String message, BigInt key) {
    String deText = crypt(message, key, false);
    return deText;
  }

  String feistilEncrypt(String bits, String key) {
    List enCode = [];
    int lenMes = bits.length;
    List<String> tempCode = List.filled(n, "0");

    for (var i = 0; i < lenMes; i++) {
      tempCode[i % n] = bits[i];
      if ((i + 1) % n == 0) {
        List newBlock = feistil(tempCode.sublist(0, 4), tempCode.sublist(4, 8), key,  true);
        enCode = List.from(enCode)..addAll(newBlock);
      }
    }

    return enCode.join("");
  }

  String feistilDecrypt(String bits, String key) {
    List deCode = [];
    int lenMes = bits.length;
    List<String> tempCode = List.filled(n, "0");

    for(var i = 0; i < lenMes; i++) {
      tempCode[i % n] = bits[i];
      if ((i + 1) % n == 0) {
        List newBlock = feistil(tempCode.sublist(4, 8), tempCode.sublist(0, 4), key,  false);
        deCode = List.from(deCode)..addAll(newBlock);
      }
    }
    return deCode.join("");
  }

  List feistil(List Li, List Ri, String key, bool encrypt) {
    for (var i = 0; i < n; i++) {
      int start = encrypt ? (i * 4) : (n - i - 1) * 4;
      int end = encrypt ? (i + 1) * 4 : (n - i) * 4;
      String ki = key.substring(start, end);
      List tLi = Ri;
      List tRi = XOR(Li.join(""), f(Ri.join(""), ki)).split("");
      Li = tLi;
      Ri = tRi;
    }

    if (encrypt) {
      return List.from(Li)..addAll(Ri);
    }
    else {
      return List.from(Ri)..addAll(Li);
    }
  }

  String f(String x, ki) {
    String xNum1 = shiftToLeft(x, 1);
    String xNum2 = shiftToLeft(x, 3);
    String res = XOR(XOR(xNum1, xNum2), ki);
    return res;
  }

  String XOR(String num1, String num2) {
    String res = "";
    for (var i = 0; i < num1.length; i++) {
      res += (int.parse(num1[i]) ^ int.parse(num2[i])).toString();
    }
    return res;
  }

  String shiftToLeft(String x, int iter) {
    int n = x.length;
    List newX = [];
    for (var i = 0; i < n; i++) {
      newX.add(x[(i + iter) % n]);
    }
    x = newX.join("");
    return x;
  }

  String crypt(String message, BigInt key, bool isEncrypt) {
    var messageNums = message.codeUnits;
    String keyBit = bigIntTo16bits(key);
    String messageBits = "";

    for (var num in messageNums) {
      messageBits += bigIntTo16bits(BigInt.from(num));
    }

    String res = "";

    if (isEncrypt) {
      res = feistilEncrypt(messageBits, keyBit);
    }
    else {
      res = feistilDecrypt(messageBits, keyBit);
    }

    res = codeToText(res);

    return res;
  }

  String codeToText(String enCode) {
    int n = enCode.length;
    String res = "";
    for (var i = 0; i < n; i+=16) {
      int num = int.parse(enCode.substring(i, i + 16), radix: 2);
      String char = String.fromCharCode(num);
      res += char;
    }
    return res;
  }

  String encrypt(String message, BigInt key) {
    var messageNums = message.codeUnits;
    String keyBit = bigIntTo16bits(key);
    String messageBits = "";

    for (var num in messageNums) {
      messageBits += bigIntTo16bits(BigInt.from(num));
    }

    feistilEncrypt(messageBits, keyBit);

    print(messageBits);
    print(keyBit);
    return "";
  }
}