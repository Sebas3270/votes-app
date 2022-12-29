import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus {
  Online,
  Offline,
  Connecting
} 

class SocketService extends ChangeNotifier {

  ServerStatus _serverStatus = ServerStatus.Connecting;
  late IO.Socket _socket;

  ServerStatus get serverStatus => _serverStatus;
  IO.Socket get socket => _socket;

  SocketService(){
    _initConfig();
  }

  void _initConfig(){

    _socket = IO.io('http://192.168.100.7:3000', {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket.onConnect((_) {
      print('connect');
      _serverStatus = ServerStatus.Online;
      notifyListeners();
    });

    _socket.onConnectError((data) => print(data));

    _socket.onDisconnect((_){
      print('disconnect');
      _serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

    _socket.on('new-message',(data){
      print(data);
      notifyListeners();
    });
  }

}