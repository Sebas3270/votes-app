import 'dart:io';

import 'package:provider/provider.dart';
import 'package:sports_names/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sports_names/services/services.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Sport> sports = [
    // Sport(id: '1', name: 'Basquetball', votes: 5),
    // Sport(id: '2', name: 'Soccer', votes: 2),
    // Sport(id: '3', name: 'Swimming', votes: 3),
    // Sport(id: '4', name: 'Tenis', votes: 5),
  ];

  _handleActiveBands(dynamic sportsData){
      sports = (sportsData as List<dynamic>)
        .map((sport) => Sport.fromMap(sport))
        .toList();

      setState(() {});
  }

  @override
  void initState() {

    final socketsService = Provider.of<SocketService>(context, listen: false);
    socketsService.socket.on('active-sports', _handleActiveBands);
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {

    final socketsService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sports Names',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 15),
            child: socketsService.serverStatus == ServerStatus.Online 
            ? const Icon(Icons.check_circle,color: Colors.blue,)
            : const Icon(Icons.offline_bolt,color: Colors.red,)
            ,
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 250,
            child: SfCircularChart(
              legend: Legend(
                isVisible: true,
                isResponsive: true,
              ),
              series: <CircularSeries>[
                DoughnutSeries<Sport, String>(
                  dataSource: sports,
                  xValueMapper: (datum, index) => datum.name,
                  yValueMapper: (datum, index) => datum.votes,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: sports.length,
              itemBuilder: (context, index) {
                return _sportTile(sports[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewSport,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _sportTile(Sport sport) {

    final socketsService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(sport.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.delete, color: Colors.white,),
            ),
          ],
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(sport.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(sport.name),
        trailing: Text(sport.votes.toString()),
        onTap: () {
          socketsService.socket.emit('vote-sport',{'id': sport.id});
        },
      ),
      onDismissed: (direction) {
        //TODO: Delete from server
        socketsService.socket.emit('delete-sports', {'id': sport.id});
      },
    );
  }

  addNewSport() {
    final textController = new TextEditingController();

    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Sport Name'),
            content: TextField(
              controller: textController,
            ),
            actions: [
              MaterialButton(
                child: const Text(
                  'Add',
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: () => addSportToList(textController.text),
              )
            ],
          );
        },
      );
    }

    return showCupertinoDialog(
      context: context, 
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Sport name'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Add'),
              onPressed: () => addSportToList(textController.text),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text('Close'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  void addSportToList(String name) {
    if (name.isNotEmpty) {
      final socketsService = Provider.of<SocketService>(context, listen: false);
      socketsService.socket.emit('add-sports', {'name': name});
    }

    Navigator.pop(context);
  }
}
