import 'dart:io';

// InternetAddress stunIP = InternetAddress("r-stun1.vdotok.dev");

class Config {
  InternetAddress _stunIP = InternetAddress("0.0.0.0");
// = InternetAddress("13.51.73.220");
  int _stunPort = 3478;
  // = 3478;
  InternetAddress get getStunIP => _stunIP;
  int get getStunPort => _stunPort;

  set setStunIP(ip) => _stunIP = ip;
  set setStunPort(port) => _stunPort = port;
}
