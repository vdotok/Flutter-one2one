enum MessageAttributeType {
  MappedAddress,
  ResponseAddress,
  ChangeRequest,
  SourceAddress,
  ChangedAddress,
  Username,
  Password,
  MessageIntegrity,
  xor_mapped_address,
  otheraddress,
  ErrorCode,
  UnknownAttribute,
  ReflectedFrom,
  Dummy
}

// abstract class MessageAttributeInterface {
//   static const int MAPPEDADDRESS = 0x0001;
//   static const int RESPONSEADDRESS = 0x0002;
//   static const int CHANGEREQUEST = 0x0003;
//   static const int SOURCEADDRESS = 0x0004;
//   static const int CHANGEDADDRESS = 0x0005;
//   static const int USERNAME = 0x0006;
//   static const int PASSWORD = 0x0007;
//   static const int MESSAGEINTEGRITY = 0x0008;
//   static const int ERRORCODE = 0x0009;
//   static const int UNKNOWNATTRIBUTE = 0x000a;
//   static const int REFLECTEDFROM = 0x000b;
//   static const int DUMMY = 0x0000;
// }

const int MAPPEDADDRESS = 0x0001;
const int RESPONSEADDRESS = 0x0002;
const int CHANGEREQUEST = 0x0003;
const int SOURCEADDRESS = 0x0004;
const int CHANGEDADDRESS = 0x0005;
const int USERNAME = 0x0006;
const int PASSWORD = 0x0007;
const int MESSAGEINTEGRITY = 0x0008;
const int ERRORCODE = 0x0009;
const int XOR_MAPPED_ADDRESS = 0x0020;
const int OTHERADDRESS = 0x802C;
const int UNKNOWNATTRIBUTE = 0x000a;
const int REFLECTEDFROM = 0x000b;
const int DUMMY = 0x0000;
const int MAGIC_COOKIE = 0x2112A442;
