import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sports_names/services/services.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      body: Center(
        child: Text('Server status: ' + socketService.serverStatus.toString())
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.message_rounded),
        onPressed: () {
          socketService.socket.emit('emit-message', {
            'name': 'Flutter',
            'message': 'Hi from Flutter'
          });
        },
      ),
    );
  }
}