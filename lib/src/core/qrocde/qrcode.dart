import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:vdotok_stream_example/src/core/config/config.dart';

import '../../home/home.dart';
 
String project = "";
String url = "";
Barcode? result;
bool snackBarShowed = false;


class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.blue,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      cameraFacing: CameraFacing.back,
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      controller = controller;
      controller.resumeCamera();
      print("this is cameraaaa ${controller.getCameraInfo()} ${describeEnum}");
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        //   List<String> strArr = result!.code!.split(":");
        //  // String projectid = strArr[1].split(",").last;
        // if (result!.code != null) {
        if (result!.code!.contains("project_id") == false ||
            result!.code!.contains("tenant_api_url") == false) {
          if (!snackBarShowed) {
            print("hereee in ifffff");
            snackBar = SnackBar(
              content: Text(
                "Please scan valid QR.",
                // textAlign: TextAlign.center,
              ),
              duration: Duration(days: 2),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            snackBarShowed = true;
          }
          //  controller.pauseCamera();
          // controller.dispose();
        } else {
          if (snackBarShowed) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            snackBarShowed = false;
          }

          Map<String, dynamic> map = json.decode(result!.code!);
          project = map["project_id"].toString();
          url = map["tenant_api_url"].toString();
          print("this is result ${map["project_id"]} ${map["tenant_api_url"]}");

          snackBar = SnackBar(
            content: Text(
            "Url and Project Id copied",
              textAlign: TextAlign.center,
            ),
            duration: Duration(seconds: 4),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          controller.pauseCamera();
          controller.dispose();
          snackBarShowed = false;
          Navigator.pop(context);
        }

        // }
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    print("thissss $p");
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    //controller?.scannedDataStream.
    super.dispose();
  }
}
