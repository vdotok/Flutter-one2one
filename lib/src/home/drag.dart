import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vdotok_stream/core/interface/enums.dart';
import 'package:vdotok_stream/flutter_webrtc.dart';

import 'package:vdotok_stream_example/src/home/home.dart';

import '../../constant.dart';

class DragBox extends StatefulWidget {
  final Offset initPos;
  // final String label;
  // final Color itemColor;

  DragBox({
    required this.initPos,
  });

  @override
  DragBoxState createState() => DragBoxState();
}

class DragBoxState extends State<DragBox> {
  Offset position = Offset(0.0, 0.0);

  @override
  void initState() {
    super.initState();
    position = widget.initPos;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: position.dx,
        top: position.dy,
        child: Draggable(
          // data: widget.itemColor,
          child: Container(
            height: 170,
            width: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(10) // green as background color
                  ),
              // borderRadius: BorderRadius.circular(10.0),
              child: enableCamera
                  ? RTCVideoView(localRenderer,
                      key: forsmallView,
                      mirror: false,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitContain)
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
            ),
          ),
          onDraggableCanceled: (velocity, offset) {
            setState(() {
              position = offset;
              print("dro");
            });
          },
          // onDragEnd: (drag) {
          //   position.d
          // },
          feedback: Container(
            height: 170,
            width: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(10) // green as background color
                  ),
              // borderRadius: BorderRadius.circular(10.0),
              child: enableCamera
                  ? RTCVideoView(localRenderer,
                      key: forsmallView,
                      mirror: false,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitContain)
                  : Container(),
            ),
          ),
        ));
  }
}
