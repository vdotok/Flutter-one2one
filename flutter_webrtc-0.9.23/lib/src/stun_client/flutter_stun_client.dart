import 'dart:io';

import 'package:flutter/foundation.dart';
import '../vdotokSignalingClient/SignalingClient/SignalingClient.dart';
import './DiscoveryInfo.dart';
import './attribute/ChangeRequest.dart';
import './attribute/ChangedAddress.dart';
import './attribute/ErrorCode.dart';
import './attribute/MappedAddress.dart';
import './attribute/MessageAttributeInterface.dart';
import './attribute/OtheredAddress.dart';
import './attribute/XORMappedAddress.dart';
import './config.dart';
import './header/MessageHeader.dart';
import './header/MessageHeaderInterface.dart';
import './util/cosntants.dart';

typedef OnResults = void Function(String res);
typedef OnNatType = void Function(Map<String, dynamic> res);

class StunClient {
  static final StunClient _instance = StunClient._privateConstructor();
  static StunClient get instance => _instance;
  StunClient._privateConstructor();

  OnResults? onResults;
  OnNatType? onNatType;

// InetAddress iaddress;
  RawDatagramSocket? _socket;
  RawDatagramSocket? socket2;
  RawDatagramSocket? socket3;
  String? stunServer;
  int? port;
  int? timeoutInitValue = 7000; //ms

  bool nodeNatted = true;
  // DatagramSocket socketTest1 = null;
  DiscoveryInfo? di;
  MessageHeader? sendMH;
  CurrentTestStates currentTestStates = CurrentTestStates.Nat_B_TEST1;

//Nat_B_TEST1
  MappedAddress? ma;
  XORMappedAddress? xma;
  OtheredAddress? oa;
  ChangedAddress? ca;
  //Nat_B_TEST2
  MappedAddress? ma2;
  XORMappedAddress? xma2;
  OtheredAddress? oa2;
  ChangedAddress? ca2;
  //Nat_B_TEST3
  MappedAddress? ma3;
  XORMappedAddress? xma3;
  OtheredAddress? oa3;
  ChangedAddress? ca3;
  //Nat_F_TEST2
  MappedAddress? NFma2;
  XORMappedAddress? NFxma2;
  OtheredAddress? NFoa2;
  ChangedAddress? NFca2;
  //Nat_F_TEST3
  MappedAddress? NFma3;
  XORMappedAddress? NFxma3;
  OtheredAddress? NFoa3;
  ChangedAddress? NFca3;

  String natBehaviourType = "";
  String natFilteringType = "";

  String NBTEST1 = "";
  String NBTEST2 = "";
  String NBTEST3 = "";
  String NFTEST2 = "";
  String NFTEST3 = "";

  //internet Status
  bool internetStatus = true;

  Map<String, dynamic> finalResult = {
    "natBehavior": "",
    "natFiltering": "",
    "publicIPs": []
  };

  Config config = Config();
  dispose() {
    _socket?.close();
    //Nat_B_TEST1
    ma = null;
    xma = null;
    oa = null;
    ca = null;
    //Nat_B_TEST2
    ma2 = null;
    xma2 = null;
    oa2 = null;
    ca2 = null;
    //Nat_B_TEST3
    ma3 = null;
    xma3 = null;
    oa3 = null;
    ca3 = null;
    //Nat_F_TEST2
    NFma2 = null;
    NFxma2 = null;
    NFoa2 = null;
    NFca2 = null;
    //Nat_F_TEST3
    NFma3 = null;
    NFxma3 = null;
    NFoa3 = null;
    NFca3 = null;
  }

  Future initStun(String stunRootDomain, int port) async {
    try {
      _socket?.close();
      _socket = null;

      var value =
          await InternetAddress.lookup(stunRootDomain).then((value) async {
        config.setStunIP = value.first;
        config.setStunPort = port;
        NBTEST1 = "";
        NBTEST2 = "";
        NBTEST3 = "";
        NFTEST2 = "";
        NFTEST3 = "";
        if (_socket == null) {
          String myIP = await gettingIP();
          InternetAddress? myAddress = InternetAddress(myIP);
          // print(
          //     "this is internet Status 1 ${SignalingClient.instance.internetManager.getInternetStatus()}");

          _socket =
              await RawDatagramSocket.bind(myAddress, 0, reuseAddress: true);

          _socket?.timeout(
              const Duration(
                seconds: 2,
              ), onTimeout: (sink) {
            if (currentTestStates == CurrentTestStates.Nat_F_TEST2) {
              Nat_F_test3();
            } else if (currentTestStates == CurrentTestStates.Nat_F_TEST3) {
              print("==========N-F Test3 Result===========");

              print("Address and port -dependent Filtering");
              getPublicIPs();
              natFilteringType = "Port-Dependent";
              finalResult["natBehavior"] = natBehaviourType;
              finalResult["natFiltering"] = natFilteringType;
              onNatType!.call(finalResult);
              _socket?.close();
              _socket = null;
            } else if (currentTestStates == CurrentTestStates.NEW) {
              print("this is newState");
            }
          }).listen((event) {
            if (event == RawSocketEvent.read) {
              if (currentTestStates == CurrentTestStates.Nat_B_TEST1) {
                Datagram? recievedData = _socket?.receive();
                MessageHeader receiveMH = MessageHeader();
                if (!receiveMH.equalTransactionID(sendMH!)) {
                  List<int> receviedBytesData = [];
                  recievedData!.data.forEach((element) {
                    receviedBytesData.add(
                        ByteData.sublistView(Uint8List.fromList([element]))
                            .getInt8(0));
                  });

                  receiveMH = MessageHeader.parseHeader(receviedBytesData);
                  receiveMH.parseAttributes(receviedBytesData);
                  print("object");

                  ma = receiveMH.getMessageAttribute(
                      MessageAttributeType.MappedAddress) as MappedAddress?;
                  xma = receiveMH.getMessageAttribute(
                          MessageAttributeType.xor_mapped_address)
                      as XORMappedAddress?;
                  ca = receiveMH.getMessageAttribute(
                      MessageAttributeType.ChangedAddress) as ChangedAddress?;
                  oa = receiveMH.getMessageAttribute(
                      MessageAttributeType.otheraddress) as OtheredAddress?;
                  ErrorCode? ec = receiveMH.getMessageAttribute(
                      MessageAttributeType.ErrorCode) as ErrorCode?;

                  if (ec != null) {
                    print(
                        "Message header contains an Errorcode message attribute.");
                    // di.setError(ec.getResponseCode(), ec.getReason());
                    // LOGGER.debug("Message header contains an Errorcode message attribute.");
                    // return false;
                  }
                  if ((ma != null) && (oa != null) && (xma != null)) {
                    if ((InternetAddress(ma!.address.toString()) ==
                            _socket?.address) &&
                        (ma!.port == _socket?.port)) {
                      print("==========Nat Behaviour Type ===========");
                      print("==========N-B Test1 Result===========");
                      print("Public IP and port ${ma!.address}:${ma!.port}");
                      print(
                          "Local IP and port ${_socket?.address}:${_socket?.port}");
                      print("Direct Mapping");
                      natBehaviourType = "Direct-Mapping";
                      Nat_F_test2();
                    } else {
                      print("==========Nat Behaviour Type ===========");
                      print("==========N-B Test1 Result===========");
                      print("Public IP and port ${ma!.address}:${ma!.port}");
                      print(
                          "XOR MappedAddress and port ${xma!.address}:${xma!.port}");
                      print(
                          "Other address and port ${oa!.address}:${oa!.port}");
                      NBTEST1 =
                          "==========Nat Behaviour Type =========== \n ==========N-B Test1 Result=========== \n  Public IP and port ${ma!.address}:${ma!.port} \n XOR MappedAddress and port ${xma!.address}:${xma!.port} \n Other address and port ${oa!.address}:${oa!.port}";
                      Nat_B_test2();
                    }
                  }
                }
              } else if (currentTestStates == CurrentTestStates.Nat_B_TEST2) {
                Datagram? recievedData = _socket?.receive();
                MessageHeader receiveMH = MessageHeader();
                if (!receiveMH.equalTransactionID(sendMH!)) {
                  List<int> receviedBytesData = [];
                  recievedData!.data.forEach((element) {
                    receviedBytesData.add(
                        ByteData.sublistView(Uint8List.fromList([element]))
                            .getInt8(0));
                  });

                  receiveMH = MessageHeader.parseHeader(receviedBytesData);
                  receiveMH.parseAttributes(receviedBytesData);
                  print("object");

                  ma2 = receiveMH.getMessageAttribute(
                      MessageAttributeType.MappedAddress) as MappedAddress?;
                  xma2 = receiveMH.getMessageAttribute(
                          MessageAttributeType.xor_mapped_address)
                      as XORMappedAddress?;
                  ca2 = receiveMH.getMessageAttribute(
                      MessageAttributeType.ChangedAddress) as ChangedAddress?;
                  oa2 = receiveMH.getMessageAttribute(
                      MessageAttributeType.otheraddress) as OtheredAddress?;
                  ErrorCode? ec = receiveMH.getMessageAttribute(
                      MessageAttributeType.ErrorCode) as ErrorCode?;

                  if (ec != null) {
                    print(
                        "Message header contains an Errorcode message attribute.");
                    // di.setError(ec.getResponseCode(), ec.getReason());
                    // LOGGER.debug("Message header contains an Errorcode message attribute.");
                    // return false;
                  }
                  if ((ma2 != null) && (oa2 != null) && (xma2 != null)) {
                    if ((xma!.address.toString() == xma2!.address.toString()) &&
                        (xma!.port == xma2!.port)) {
                      //Endpoint-Independent Mapping
                      print("==========N-B Test2 Result===========");
                      print("Public IP and port ${ma2!.address}:${ma2!.port}");
                      print(
                          "XOR MappedAddress and port ${xma2!.address}:${xma2!.port}");
                      print(
                          "Other address and port ${oa2!.address}:${oa2!.port}");
                      natBehaviourType = "Endpoint-Independent";
                      print("Endpoint-Independent Mapping");
                      NBTEST2 =
                          "==========N-B Test2 Result=========== \n Public IP and port ${ma2!.address}:${ma2!.port} \n XOR MappedAddress and port ${xma2!.address}:${xma2!.port} \n Other address and port ${oa2!.address}:${oa2!.port} \n $natBehaviourType ";

                      Nat_F_test2();
                    } else {
                      print("==========N-B Test2 Result===========");
                      print("Public IP and port ${ma2!.address}:${ma2!.port}");
                      print(
                          "XOR MappedAddress and port ${xma2!.address}:${xma2!.port}");
                      print(
                          "Other address and port ${oa2!.address}:${oa2!.port}");
                      NBTEST2 =
                          "==========N-B Test2 Result=========== \n Public IP and port ${ma2!.address}:${ma2!.port} \n XOR MappedAddress and port ${xma2!.address}:${xma2!.port} \n Other address and port ${oa2!.address}:${oa2!.port} ";

                      Nat_B_test3();
                    }
                  }
                }
              } else if (currentTestStates == CurrentTestStates.Nat_B_TEST3) {
                Datagram? recievedData = _socket?.receive();
                MessageHeader receiveMH = MessageHeader();
                if (!receiveMH.equalTransactionID(sendMH!)) {
                  List<int> receviedBytesData = [];
                  recievedData!.data.forEach((element) {
                    receviedBytesData.add(
                        ByteData.sublistView(Uint8List.fromList([element]))
                            .getInt8(0));
                  });

                  receiveMH = MessageHeader.parseHeader(receviedBytesData);
                  receiveMH.parseAttributes(receviedBytesData);
                  print("object");

                  ma3 = receiveMH.getMessageAttribute(
                      MessageAttributeType.MappedAddress) as MappedAddress?;
                  xma3 = receiveMH.getMessageAttribute(
                          MessageAttributeType.xor_mapped_address)
                      as XORMappedAddress?;
                  ca3 = receiveMH.getMessageAttribute(
                      MessageAttributeType.ChangedAddress) as ChangedAddress?;
                  oa3 = receiveMH.getMessageAttribute(
                      MessageAttributeType.otheraddress) as OtheredAddress?;
                  ErrorCode? ec = receiveMH.getMessageAttribute(
                      MessageAttributeType.ErrorCode) as ErrorCode?;

                  if (ec != null) {
                    print(
                        "Message header contains an Errorcode message attribute.");
                    // di.setError(ec.getResponseCode(), ec.getReason());
                    // LOGGER.debug("Message header contains an Errorcode message attribute.");
                    // return false;
                  }
                  if ((ma3 != null) && (oa3 != null) && (xma3 != null)) {
                    if (xma3!.address.toString() == xma2!.address.toString() &&
                        xma3!.port == xma2!.port) {
                      //Address-Dependent Mapping
                      print("==========N-B Test3 Result===========");
                      print("Public IP and port ${ma3!.address}:${ma3!.port}");
                      print(
                          "XOR MappedAddress and port ${xma3!.address}:${xma3!.port}");
                      print(
                          "Other address and port ${oa3!.address}:${oa3!.port}");
                      print("Address-Dependent Mapping");
                      natBehaviourType = "Address-Dependent";
                      NBTEST3 =
                          "==========N-B Test3 Result=========== \n Public IP and port ${ma3!.address}:${ma3!.port} \n XOR MappedAddress and port ${xma3!.address}:${xma3!.port} \n Other address and port ${oa3!.address}:${oa3!.port} \n $natBehaviourType";
                      Nat_F_test2();
                    } else {
                      //Address-and-port-Dependent Mapping
                      print("==========N-B Test3 Result===========");
                      print("Public IP and port ${ma3!.address}:${ma3!.port}");
                      print(
                          "XOR MappedAddress and port ${xma3!.address}:${xma3!.port}");
                      print(
                          "Other address and port ${oa3!.address}:${oa3!.port}");
                      print("Address-and-port-Dependent Mapping");
                      natBehaviourType = "Port-Dependent";
                      NBTEST3 =
                          "==========N-B Test3 Result=========== \n Public IP and port ${ma3!.address}:${ma3!.port} \n XOR MappedAddress and port ${xma3!.address}:${xma3!.port} \n Other address and port ${oa3!.address}:${oa3!.port} \n $natBehaviourType";

                      Nat_F_test2();
                    }
                  }
                }
              } else if (currentTestStates == CurrentTestStates.Nat_F_TEST2) {
                Datagram? recievedData = _socket?.receive();
                MessageHeader receiveMH = MessageHeader();
                if (!receiveMH.equalTransactionID(sendMH!)) {
                  List<int> receviedBytesData = [];
                  recievedData!.data.forEach((element) {
                    receviedBytesData.add(
                        ByteData.sublistView(Uint8List.fromList([element]))
                            .getInt8(0));
                  });

                  receiveMH = MessageHeader.parseHeader(receviedBytesData);
                  receiveMH.parseAttributes(receviedBytesData);
                  print("object");

                  NFma2 = receiveMH.getMessageAttribute(
                      MessageAttributeType.MappedAddress) as MappedAddress?;
                  // NFxma2 = receiveMH.getMessageAttribute(
                  //     MessageAttributeType.xor_mapped_address) as XORMappedAddress?;
                  NFca2 = receiveMH.getMessageAttribute(
                      MessageAttributeType.ChangedAddress) as ChangedAddress?;
                  NFoa2 = receiveMH.getMessageAttribute(
                      MessageAttributeType.otheraddress) as OtheredAddress?;
                  ErrorCode? ec = receiveMH.getMessageAttribute(
                      MessageAttributeType.ErrorCode) as ErrorCode?;

                  if (ec != null) {
                    print(
                        "Message header contains an Errorcode message attribute.");
                    // di.setError(ec.getResponseCode(), ec.getReason());
                    // LOGGER.debug("Message header contains an Errorcode message attribute.");
                    // return false;
                  }
                  if ((NFma2 != null) && (NFoa2 != null)) {
                    if (recievedData.address.address.toString() ==
                            oa!.address.toString() &&
                        recievedData.port == oa!.port) {
                      print("==========Nat Filtering Type ===========");
                      print("==========N-F Test2 Result===========");
                      print(
                          "Mapped Address IP and port ${NFma2!.address}:${NFma2!.port}");
                      print(
                          "Received From   ${recievedData.address.address}:${recievedData.port}");
                      print(
                          "Other address and port ${NFoa2!.address}:${NFoa2!.port}");
                      print("Endpoint-Independent Filtering");
                      natFilteringType = "Endpoint-Independent";
                      NFTEST2 =
                          "==========Nat Filtering Type =========== \n ==========N-F Test2 Result=========== \n Mapped Address IP and port ${NFma2!.address}:${NFma2!.port} \n Received From   ${recievedData.address.address}:${recievedData.port} \n Other address and port ${NFoa2!.address}:${NFoa2!.port} \n $natFilteringType";
                      currentTestStates = CurrentTestStates.NEW;

                      // onNatType
                      getPublicIPs();
                      finalResult["natBehavior"] = natBehaviourType;
                      finalResult["natFiltering"] = natFilteringType;
                      onNatType!.call(finalResult);
                      onResults!.call(
                          "$NBTEST1 \n  $NBTEST2  \n  $NBTEST3 \n  $NFTEST2 \n  $NFTEST3");
                      _socket?.close();
                      _socket = null;
                    }
                    // if (xma3!.address.toString() == xma2!.address.toString() &&
                    //     xma3!.port == xma2!.port) {
                    //   //Address-Dependent Mapping
                    //   print("==========N-B Test3 Result===========");
                    //   print("Public IP and port ${ma3!.address}:${ma3!.port}");
                    //   print(
                    //       "XOR MappedAddress and port ${xma3!.address}:${xma3!.port}");
                    //   print("Other address and port ${oa3!.address}:${oa3!.port}");
                    //   print("Address-Dependent Mapping");
                    // } else {
                    //   //Address-and-port-Dependent Mapping
                    //   print("Address-and-port-Dependent Mapping");
                    // }
                  }
                }
              } else if (currentTestStates == CurrentTestStates.Nat_F_TEST3) {
                Datagram? recievedData = _socket?.receive();
                MessageHeader receiveMH = MessageHeader();
                if (!receiveMH.equalTransactionID(sendMH!)) {
                  List<int> receviedBytesData = [];
                  recievedData!.data.forEach((element) {
                    receviedBytesData.add(
                        ByteData.sublistView(Uint8List.fromList([element]))
                            .getInt8(0));
                  });

                  receiveMH = MessageHeader.parseHeader(receviedBytesData);
                  receiveMH.parseAttributes(receviedBytesData);
                  print("object");

                  NFma3 = receiveMH.getMessageAttribute(
                      MessageAttributeType.MappedAddress) as MappedAddress?;
                  // NFxma2 = receiveMH.getMessageAttribute(
                  //     MessageAttributeType.xor_mapped_address) as XORMappedAddress?;
                  NFca3 = receiveMH.getMessageAttribute(
                      MessageAttributeType.ChangedAddress) as ChangedAddress?;
                  NFoa3 = receiveMH.getMessageAttribute(
                      MessageAttributeType.otheraddress) as OtheredAddress?;
                  ErrorCode? ec = receiveMH.getMessageAttribute(
                      MessageAttributeType.ErrorCode) as ErrorCode?;

                  if (ec != null) {
                    print(
                        "Message header contains an Errorcode message attribute.");
                    // di.setError(ec.getResponseCode(), ec.getReason());
                    // LOGGER.debug("Message header contains an Errorcode message attribute.");
                    // return false;
                  }
                  if ((NFma3 != null) && (NFoa3 != null)) {
                    if (recievedData.address.address.toString() ==
                            oa!.address.toString() &&
                        recievedData.port == oa!.port) {
                      print("==========Nat Filtering Type ===========");
                      print("==========N-F Test3 Result===========");
                      print(
                          "Mapped Address IP and port ${NFma3!.address}:${NFma3!.port}");
                      print(
                          "Received From   ${recievedData.address.address}:${recievedData.port}");
                      print(
                          "Other address and port ${NFoa3!.address}:${NFoa3!.port}");
                      print("Address-dependent Filtering");
                      natFilteringType = "Address-Dependent";
                      NFTEST3 =
                          "==========Nat Filtering Type =========== \n ==========N-F Test3 Result=========== \n Mapped Address IP and port ${NFma3!.address}:${NFma3!.port} \n Received From   ${recievedData.address.address}:${recievedData.port} \n Other address and port ${NFoa3!.address}:${NFoa3!.port} \n $natFilteringType";
                      currentTestStates = CurrentTestStates.NEW;
                      getPublicIPs();
                      finalResult["natBehavior"] = natBehaviourType;
                      finalResult["natFiltering"] = natFilteringType;
                      onNatType!.call(finalResult);
                      onResults!.call(
                          "$NBTEST1 \n  $NBTEST2  \n  $NBTEST3 \n  $NFTEST2 \n  $NFTEST3");
                      _socket?.close();
                      _socket = null;
                    }
                  }
                }
              }
            } else {
              InternetAddress? internetAddress = _socket?.address;
              int? socketPort = _socket?.port;
              Nat_B_test1();
            }
          });
        }
      }).catchError((onError) {
        print("this is error $onError");
      });
    } catch (e) {
      print("this is error $e");
    }
  }

  Nat_B_test1() async {
    currentTestStates = CurrentTestStates.Nat_B_TEST1;
    sendMH = MessageHeader.withType(MessageHeaderType.BindingRequest);
    sendMH?.generateTransactionID();
    // ChangeRequest changeRequest =
    //     ChangeRequest.withType(MessageAttributeType.ChangeRequest);
    // sendMH?.addMessageAttribute(changeRequest);
    List<int> bytes = sendMH!.getBytes();
    // Datagram datagram = Datagram(bytes);
    // var value = InternetAddress.lookup("r-stun1.vdotok.dev");
    var d = config.getStunIP;
    internetStatus =
        await SignalingClient.instance.internetManager.getInternetStatus();
    if (internetStatus) {
      _socket?.send(bytes, config.getStunIP, config.getStunPort);
    }

    // Datagram? recievedData = _socket?.receive();
  }

  Nat_B_test2() async {
    currentTestStates = CurrentTestStates.Nat_B_TEST2;
    sendMH = MessageHeader.withType(MessageHeaderType.BindingRequest);
    sendMH?.generateTransactionID();
    // ChangeRequest changeRequest =
    //     ChangeRequest.withType(MessageAttributeType.ChangeRequest);
    // sendMH?.addMessageAttribute(changeRequest);
    List<int> bytes = sendMH!.getBytes();
    // Datagram datagram = Datagram(bytes);
    internetStatus =
        await SignalingClient.instance.internetManager.getInternetStatus();
    if (internetStatus) {
      _socket?.send(
          bytes, InternetAddress(oa!.address.toString()), config.getStunPort);
    }
    // Datagram? recievedData = _socket?.receive();
    // print("kkkkk");
  }

  Nat_B_test3() async {
    currentTestStates = CurrentTestStates.Nat_B_TEST3;
    sendMH = MessageHeader.withType(MessageHeaderType.BindingRequest);
    sendMH?.generateTransactionID();
    // ChangeRequest changeRequest =
    //     ChangeRequest.withType(MessageAttributeType.ChangeRequest);
    // sendMH?.addMessageAttribute(changeRequest);
    List<int> bytes = sendMH!.getBytes();
    // Datagram datagram = Datagram(bytes);
    internetStatus =
        await SignalingClient.instance.internetManager.getInternetStatus();
    if (internetStatus) {
      _socket?.send(bytes, InternetAddress(oa!.address.toString()), oa!.port);
    }
    // Datagram? recievedData = _socket?.receive();
    // print("kkkkk");
  }

  Nat_F_test2() async {
    currentTestStates = CurrentTestStates.Nat_F_TEST2;

    sendMH = MessageHeader.withType(MessageHeaderType.BindingRequest);
    sendMH?.generateTransactionID();
    ChangeRequest changeRequest =
        ChangeRequest.withType(MessageAttributeType.ChangeRequest);
    changeRequest.setChangeIP();
    changeRequest.setChangePort();
    sendMH?.addMessageAttribute(changeRequest);
    List<int> bytes = sendMH!.getBytes();
    // Datagram datagram = Datagram(bytes);
    internetStatus =
        await SignalingClient.instance.internetManager.getInternetStatus();
    if (internetStatus) {
      _socket?.send(bytes, config.getStunIP, config.getStunPort);
    }
  }

  Nat_F_test3() async {
    currentTestStates = CurrentTestStates.Nat_F_TEST3;

    sendMH = MessageHeader.withType(MessageHeaderType.BindingRequest);
    sendMH?.generateTransactionID();
    ChangeRequest changeRequest =
        ChangeRequest.withType(MessageAttributeType.ChangeRequest);
    changeRequest.setChangePort();
    sendMH?.addMessageAttribute(changeRequest);
    List<int> bytes = sendMH!.getBytes();
    // Datagram datagram = Datagram(bytes);
    internetStatus =
        await SignalingClient.instance.internetManager.getInternetStatus();
    if (internetStatus) {
      _socket?.send(bytes, config.getStunIP, config.getStunPort);
    }
    Future.delayed(const Duration(seconds: 1), (() {
      if (NFma3 == null) {
        print("==========Nat Filtering Type ===========");
        print("==========N-F Test3 Result===========");

        print("Address and port -dependent Filtering");
        natFilteringType = "Port-Dependent";

        getPublicIPs();
        finalResult["natBehavior"] = natBehaviourType;
        finalResult["natFiltering"] = natFilteringType;
        onNatType!.call(finalResult);

        NFTEST3 =
            "==========Nat Filtering Type =========== \n ==========N-F Test3 Result=========== \n $natFilteringType";
        onResults!.call(
            "$NBTEST1 \n  $NBTEST2  \n  $NBTEST3 \n  $NFTEST2 \n  $NFTEST3");
        currentTestStates = CurrentTestStates.NEW;
        _socket?.close();
        _socket = null;
      } else {}
    }));
  }

  Future<String> gettingIP() async {
    // await Permission.location.request();
    // final info = NetworkInfo();
    // var hostAddress = await info.getWifiIP();
    // print("this is ip $hostAddress");

    return await printIps();

    // return hostAddress;
  }

  Future printIps() async {
    String myip = InternetAddress.anyIPv4.address;
    var interfaceList = await NetworkInterface.list();
    for (var interface in interfaceList) {
      if (interface.name == "pdp_ip0" || interface.name == "en0") {
        //for cellular
        myip = interface.addresses.first.address;
      } else if (interface.name == "wlan0") {
        myip = interface.addresses.first.address;
      }
    }
    return myip;
  }

  getPublicIPs() {
    if (ma != null) {
      finalResult["publicIPs"].add(ma?.address.toString());
      if (ma2 != null && ma?.address.toString() != ma2?.address.toString()) {
        finalResult["publicIPs"].add(ma2?.address.toString());
        if (ma3 != null) {
          if (ma3?.address.toString() != ma2?.address.toString() &&
              ma3?.address.toString() != ma?.address.toString()) {
            finalResult["publicIPs"].add(ma3?.address.toString());
          }
        }
      }
    }
  }

  getInfo() {
    print("this is status ${di?.toString()}");
  }
}
