import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';

const String appId = "69d9904abf5442958c3f866319ed0b42";
String channelName = "TestChannel";
String token =
    "007eJxTYLi6fNvncKmpUodCxWsY1m9ksXGzqP9+/NW7mdI2Z990hBcpMJhZplhaGpgkJqWZmpgYWZpaJBunWZiZGRtapqYYJJkYKTWEpDYEMjKU65azMjJAIIjPzRCSWlzinJGYl5eaw8AAACMbISk=";
int uid = 0;

class VideoCallPage extends StatefulWidget {
  const VideoCallPage({super.key});

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  @override
  Widget build(BuildContext context) {
    final AgoraClient client = AgoraClient(
      agoraConnectionData: AgoraConnectionData(
        appId: appId,
        channelName: channelName,
        tempToken: token,
        uid: uid,
      ),
    );
    client.initialize();
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            AgoraVideoViewer(
              showNumberOfUsers: true,
              renderModeType: RenderModeType.renderModeHidden,
              showAVState: true,
              client: client,
              layoutType: Layout.oneToOne,
              enableHostControls: true,
            ),
            AgoraVideoButtons(
              autoHideButtons: true,
              autoHideButtonTime: 5,
              client: client,
            ),
          ],
        ),
      ),
    );
  }
}
