import 'package:draggable_widget/draggable_widget.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';
import 'package:vdotok_stream/core/interface/enums.dart';
import 'package:vdotok_stream/flutter_webrtc.dart';

import '../../constant.dart';
import 'home.dart';

class DragBox extends StatefulWidget {
  @override
  DragBoxState createState() => DragBoxState();
}

class DragBoxState extends State<DragBox> {
  final dragController = DragController();

  @override
  Widget build(BuildContext context) {
    return DraggableWidget(
      horizontalSpace: 20,
      bottomMargin: 150,
      topMargin: 100,
      shadowBorderRadius: 0,
      normalShadow: const BoxShadow(
        blurRadius: 0,
      ),
      intialVisibility: true,
      initialPosition: AnchoringPosition.bottomRight,
      dragController: dragController,
      child: Container(
        height: 150,
        width: 100,
        child: enableCamera
            ? RTCVideoView(localRenderer,
                key: forsmallView,
                mirror: false,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)
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
    );
  }
}
