import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';

// // STEP1:  Stream setup
// class StreamSocket {
//   final _socketResponse = StreamController<String>();

//   void Function(String) get addResponse => _socketResponse.sink.add;

//   Stream<String> get getResponse => _socketResponse.stream;

//   void dispose() {
//     _socketResponse.close();
//   }
// }

// StreamSocket streamSocket = StreamSocket();

// //STEP2: Add this function in main function in main.dart file and add incoming data to the stream
// void connectAndListen() {
//   IO.Socket socket = IO.io('http://192.168.0.113:7070/socket',
//       OptionBuilder().setTransports(['websocket']).build());

//   socket.onConnect((_) {
//     log('connect');
//     socket.emit('msg', 'test');
//   });

//   //When an event received from server, data is added to the stream
//   socket.on('event', (data) => streamSocket.addResponse);
//   socket.onDisconnect((_) => log('disconnect'));
// }

class WebSocketChatPage extends StatefulWidget {
  const WebSocketChatPage({super.key});

  @override
  State<WebSocketChatPage> createState() => _WebSocketChatPageState();
}

class _WebSocketChatPageState extends State<WebSocketChatPage> {
  // init socket
  final stompClient = StompClient(
    config: StompConfig(
      url: 'ws://192.168.0.113:8080/socket',
      onConnect: (p0) {
        log("Connected");
        log("${p0.body}");
      },
      beforeConnect: () async {
        log('waiting to connect...');
        await Future.delayed(const Duration(milliseconds: 200));
        log('connecting...');
      },
      onWebSocketError: (dynamic error) => log(error.toString()),
      onDisconnect: (p0) => log("${p0.body}"),
      stompConnectHeaders: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzUxMiJ9.eyJqdGkiOiIzIiwicm9sZXMiOiJST0xFX1VTRVIiLCJzdWIiOiJHYXkgQXVuZyIsImV4cCI6MTY5OTkzNzYxNH0.nPe_XfwGrlRKJ55r9aR28kbZtnxxUubNmDsWtUUHt9Z0F5tZNR0HaDs87tyoGqoAYi8O1YX1yG1FueDOQ9sWjg',
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    stompClient.activate();
    log("activated : ${stompClient.isActive}");

    stompClient.subscribe(
      destination: '/topic/hello',
      callback: (p0) {
        log(p0.body.toString());
      },
    );
    log("Build");
    return Scaffold();
  }
}
