import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';
import '../attribute/MessageAttributeInterface.dart';
import '../attribute/MessgeAttribute.dart';
import '../header/MessageHeaderInterface.dart';
import '../util/Utility.dart';
import '../util/exceptions.dart';
import '../util/magic_cookie.dart';

class MessageHeader {
  /*
	   0                   1                   2                   3
     *  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
     * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     * |      STUN Message Type        |         Message Length        |
     * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     * |
     * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     *
     * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     *                          Transaction ID
     * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     *                                                                 |
     * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	 */
  late MessageHeaderType type;
  // lenght must be 16
  List<int> id = List.filled(16, 0);
  Map<MessageAttributeType, MessageAttribute> ma = {};

  MessageHeader() {}
  MessageHeader.withType(MessageHeaderType type) {
    setType(type);
  }

  void setType(MessageHeaderType type) {
    this.type = type;
  }

  MessageHeaderType getType() {
    return type;
  }

  int typeToInteger(MessageHeaderType type) {
    if (type == MessageHeaderType.BindingRequest) {
      return BINDINGREQUEST;
    }
    if (type == MessageHeaderType.BindingResponse) {
      return BINDINGRESPONSE;
    }
    if (type == MessageHeaderType.BindingErrorResponse) {
      return BINDINGERRORRESPONSE;
    }
    if (type == MessageHeaderType.SharedSecretRequest) {
      return SHAREDSECRETREQUEST;
    }
    if (type == MessageHeaderType.SharedSecretResponse) {
      return SHAREDSECRETRESPONSE;
    }
    if (type == MessageHeaderType.SharedSecretErrorResponse) {
      return SHAREDSECRETERRORRESPONSE;
    }
    return -1;
  }

  void setTransactionID(List<int> id) {
    List.copyRange(id, 0, this.id, 0, 16);
  }

  void generateTransactionID() {
    print((Random().nextDouble() * 65536).toInt());
    id.setRange(0, 2,
        Utility.integerToTwoBytes((Random().nextDouble() * 65536).toInt()));
    id.setRange(2, 4,
        Utility.integerToTwoBytes((Random().nextDouble() * 65536).toInt()));
    id.setRange(4, 6,
        Utility.integerToTwoBytes((Random().nextDouble() * 65536).toInt()));
    id.setRange(6, 8,
        Utility.integerToTwoBytes((Random().nextDouble() * 65536).toInt()));
    id.setRange(8, 10,
        Utility.integerToTwoBytes((Random().nextDouble() * 65536).toInt()));
    id.setRange(10, 12,
        Utility.integerToTwoBytes((Random().nextDouble() * 65536).toInt()));
    id.setRange(12, 14,
        Utility.integerToTwoBytes((Random().nextDouble() * 65536).toInt()));
    id.setRange(14, 16,
        Utility.integerToTwoBytes((Random().nextDouble() * 65536).toInt()));

    // List.copyRange(
    //     Utility.integerToTwoBytes((Random().nextDouble() * 65536).toInt()),
    //     0,
    //     id,
    //     0,
    //     2);
    // List.copyRange(
    //     Utility.integerToTwoBytes((Random().nextDouble() * 65536).toInt()),
    //     0,
    //     id,
    //     2,
    //     4);
    // List.copyRange(
    //     Utility.integerToTwoBytes((Random().nextDouble() * 65536).toInt()),
    //     0,
    //     id,
    //     4,
    //     6);
    // List.copyRange(
    //     Utility.integerToTwoBytes((Random().nextDouble() * 65536).toInt()),
    //     0,
    //     id,
    //     6,
    //     8);
    // List.copyRange(
    //     Utility.integerToTwoBytes((Random().nextDouble() * 65536).toInt()),
    //     0,
    //     id,
    //     8,
    //     10);
    // List.copyRange(
    //     Utility.integerToTwoBytes((Random().nextDouble() * 65536).toInt()),
    //     0,
    //     id,
    //     10,
    //     12);
    // List.copyRange(
    //     Utility.integerToTwoBytes((Random().nextDouble() * 65536).toInt()),
    //     0,
    //     id,
    //     12,
    //     14);
    // List.copyRange(
    //     Utility.integerToTwoBytes((Random().nextDouble() * 65536).toInt()),
    //     0,
    //     id,
    //     14,
    //     16);
  }

  List<int> getTransactionID() {
    List<int> idCopy = List.filled(id.length, 0);

    idCopy.setRange(0, id.length, id);
    return idCopy;
  }

  bool equalTransactionID(MessageHeader header) {
    List<int> idHeader = header.getTransactionID();
    if (idHeader.length != 16) {
      return false;
    }
    if ((((((((((((((((idHeader[0] == id[0]) && (idHeader[1] == id[1])) &&
                                                            (idHeader[2] ==
                                                                id[2])) &&
                                                        (idHeader[3] ==
                                                            id[3])) &&
                                                    (idHeader[4] == id[4])) &&
                                                (idHeader[5] == id[5])) &&
                                            (idHeader[6] == id[6])) &&
                                        (idHeader[7] == id[7])) &&
                                    (idHeader[8] == id[8])) &&
                                (idHeader[9] == id[9])) &&
                            (idHeader[10] == id[10])) &&
                        (idHeader[11] == id[11])) &&
                    (idHeader[12] == id[12])) &&
                (idHeader[13] == id[13])) &&
            (idHeader[14] == id[14])) &&
        (idHeader[15] == id[15])) {
      return true;
    } else {
      return false;
    }
  }

  void addMessageAttribute(MessageAttribute attri) {
    Map<MessageAttributeType, MessageAttribute> d = {attri.type: attri};
    ma.addAll(d);
  }

  MessageAttribute? getMessageAttribute(MessageAttributeType type) {
    return ma[type];
  }

  List<int> getBytes() {
    int length = 20;
    // ((Iterator <MessageAttributeType) > it) = ma.keySet().iterator();
    ma.forEach((key, value) {
      MessageAttribute? attri = ma[key];
      length += attri!.getLength();
    });
    // while (ma.isNotEmpty) {
    //   MessageAttribute attri = ma.get(it.next());
    //   length += attri.getLength();
    // }
    List<int> result = List.filled(length, 0);
    // print(MAGIC_COOKIE_ARRAY);
    List<int> convertMagicCookieArray = [];
    MAGIC_COOKIE_ARRAY.forEach((element) {
      convertMagicCookieArray
          .add(ByteData.sublistView(Uint8List.fromList([element])).getInt8(0));
    });
    // print(convertMagicCookieArray);
    result.setRange(0, 2, Utility.integerToTwoBytes(typeToInteger(type)));
    result.setRange(2, 4, Utility.integerToTwoBytes(length - 20));
    result.setRange(4, 8, convertMagicCookieArray);
    result.setRange(4, 8, convertMagicCookieArray);
    result.setRange(8, 20, id.sublist(0, 12));
    // List.copyRange(
    //     Utility.integerToTwoBytes(typeToInteger(type)), 0, result, 0, 2);
    // List.copyRange(Utility.integerToTwoBytes(length - 20), 0, result, 2, 2);

    int offset = 20;

    ma.forEach((key, value) {
      MessageAttribute? attri = ma[key];
      print(attri!.getBytes());
      result.setRange(offset, offset + attri!.getLength(), attri.getBytes());
      // List.copyRange(attri!.getBytes(), 0, result, offset, attri.getLength());
      offset += attri.getLength();
    });

    // it = ma.keySet().iterator();
    // while (it.hasNext()) {
    //   MessageAttribute attri = ma.get(it.next());
    //   List.copyRange(attri.getBytes(), 0, result, offset, attri.getLength());
    //   offset += attri.getLength();
    // }
    return result;
  }

  int getLength() {
    return getBytes().length;
  }

  void parseAttributes(List<int> data) {
    try {
      List<int> lengthArray = List.filled(2, 0);
      // lengthArray.setRange(0, 2, data);
      List.copyRange(lengthArray, 0, data, 2, 4);
      int length = Utility.twoBytesToInteger(lengthArray);
      // id.setRange(0, 14, iterable)
      List.copyRange(id, 0, data, 4, 20);
      List<int> cuttedData;
      int offset = 20;
      while (length > 0) {
        cuttedData = List.filled(length, 0);
        // List.copyRange(data, offset, cuttedData, 0, length);
        List.copyRange(cuttedData, 0, data, offset, offset + length);
        MessageAttribute ma = MessageAttribute.parseCommonHeader(cuttedData);
        addMessageAttribute(ma);
        length -= ma.getLength();
        offset += ma.getLength();
      }
    } catch (ue) {
      throw InvalidEncoding("Parsing error");
    }
  }

  static MessageHeader parseHeader(List<int> data) {
    try {
      MessageHeader mh = new MessageHeader();
      List<int> typeArray = List.filled(2, 0);
      typeArray.setRange(0, 2, data);
      // List.copyRange(data, 0, typeArray, 0, 2);
      int type = Utility.twoBytesToInteger(typeArray);
      switch (type) {
        case BINDINGREQUEST:
          mh.setType(MessageHeaderType.BindingRequest);
          print("Binding Request received.");
          break;
        case BINDINGRESPONSE:
          mh.setType(MessageHeaderType.BindingResponse);
          print("Binding Response received.");
          break;
        case BINDINGERRORRESPONSE:
          mh.setType(MessageHeaderType.BindingErrorResponse);
          print("Binding Error Response received.");
          break;
        case SHAREDSECRETREQUEST:
          mh.setType(MessageHeaderType.SharedSecretRequest);
          print("Shared Secret Request received.");
          break;
        case SHAREDSECRETRESPONSE:
          mh.setType(MessageHeaderType.SharedSecretResponse);
          print("Shared Secret Response received.");
          break;
        case SHAREDSECRETERRORRESPONSE:
          mh.setType(MessageHeaderType.SharedSecretErrorResponse);
          print("Shared Secret Error Response received.");
          break;
        default:
          throw InvalidEncoding(
              ("Message type " + type.toString()) + " is not supported");
      }
      return mh;
    } catch (ue) {
      throw InvalidEncoding("Parsing error");
    }
  }
}
