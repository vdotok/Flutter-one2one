import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vdotok_stream/vdotok_stream.dart';
import 'package:vdotok_stream_example/src/home/home.dart';

import '../constant.dart';

class CallDialScreen extends StatefulWidget {
  final mediaType;
  final callTo;
  const CallDialScreen({Key key, this.mediaType, this.callTo}) : super(key: key);
  @override
  _CallDialScreenState createState() => _CallDialScreenState();
}

class _CallDialScreenState extends State<CallDialScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(builder: (context, orientation) {
        return Stack(
          children: [
            !kIsWeb
                ? widget.mediaType == MediaType.video
                    ? Container(
                        // color: Colors.red,
                        //margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: RTCVideoView(localRenderer,
                            key: forDialView,
                            mirror: false,
                            objectFit: RTCVideoViewObjectFit
                                .RTCVideoViewObjectFitCover))
                    : Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                          colors: [
                            backgroundAudioCallDark,
                            backgroundAudioCallLight,
                            backgroundAudioCallLight,
                            backgroundAudioCallLight,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment(0.0, 0.0),
                        )),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/userIconCall.svg',
                          ),
                        ),
                      )
                : Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                      colors: [
                        backgroundAudioCallDark,
                        backgroundAudioCallLight,
                        backgroundAudioCallLight,
                        backgroundAudioCallLight,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment(0.0, 0.0),
                    )),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/userIconCall.svg',
                      ),
                    ),
                  ),
            Container(
                padding: EdgeInsets.only(top: 120),
                alignment: Alignment.center,
                child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Calling",
                        style: TextStyle(
                            fontSize: 14,
                            decoration: TextDecoration.none,
                            fontFamily: secondaryFontFamily,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            color: darkBlackColor),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        widget.callTo,
                        style: TextStyle(
                            fontFamily: primaryFontFamily,
                            color: darkBlackColor,
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal,
                            fontSize: 24),
                      )
                    ])),
            Container(
              padding: EdgeInsets.only(bottom: 56),
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                child: SvgPicture.asset(
                  'assets/end.svg',
                ),
                onTap: () {
                  signalingClient.onCancelbytheCaller(registerRes["mcToken"]);
                  _callProvider.initial();
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
