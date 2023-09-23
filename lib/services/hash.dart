import 'dart:convert';
import 'package:hash/hash.dart';

/// hex encode
String encodeHEX(List<int> bytes) {
  var str = '';
  for (var i = 0; i < bytes.length; i++) {
    var s = bytes[i].toRadixString(16);
    str += s.padLeft(2 - s.length, '0');
  }
  return str;
}

/// hex decode
List<int> decodeHEX(String hex) {
  var bytes = <int>[];
  var len = hex.length ~/ 2;
  for (var i = 0; i < len; i++) {
    bytes.add(int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16));
  }
  return bytes;
}

/// Get SHA1 hash of a string
String getHash(String s) {
  return encodeHEX(SHA1().update(utf8.encode(s)).digest());
}
