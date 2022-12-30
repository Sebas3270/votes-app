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

  _handleActiveBands(dynamic sportsData) {
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
    // const mainColor = Color.fromARGB(255, 24, 23, 23);
    const mainColor = Color.fromARGB(255, 23, 22, 22);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 10,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            Text(
              'Sports Survey',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: mainColor,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 15),
            child: socketsService.serverStatus == ServerStatus.Online
                ? const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  )
                : const Icon(
                    Icons.offline_bolt,
                    color: Colors.red,
                  ),
          )
        ],
      ),
      body: Stack(
        children: [

          const _BackgroundImage(
            mainColor: mainColor,
            height: 450,
            opacity: 0.2,
          ),

          Column(
            children: [
              _ChartContainer(sports: sports),

              // ClipRRect(
              //   borderRadius: BorderRadius.all(Radius.circular(20)),
              //   child: Padding(
              //     padding: const EdgeInsets.all(15.0),
              //     child: MaterialButton(
              //       color: Colors.red,
              //       child: Container(
              //         padding: EdgeInsets.symmetric(vertical: 20),
              //         // width: double.infinity,
              //         child: Text('Add Sport'),
              //       ),
              //       onPressed: addNewSport,
              //     ),
              //   ),
              // ),

              Expanded(
                child: ListView.builder(
                  itemCount: sports.length,
                  itemBuilder: (context, index) {
                    return _sportTile(sports[index]);
                  },
                ),
              ),
            ],
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewSport,
        backgroundColor: const Color.fromARGB(255, 203, 72, 11),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color.fromARGB(255, 14, 81, 6),
          child: Text(sport.name.substring(0, 2),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16
            ),
          ),
        ),
        title: Text(
          sport.name,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        trailing: Text(sport.votes.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16
          ),
        ),
        onTap: () {
          socketsService.socket.emit('vote-sport', {'id': sport.id});
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
          title: const Text('Sport name'),
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

class _ChartContainer extends StatelessWidget {
  const _ChartContainer({
    Key? key,
    required this.sports,
  }) : super(key: key);

  final List<Sport> sports;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: SfCircularChart(
        legend: Legend(
          isVisible: true,
          isResponsive: true,
          textStyle: const TextStyle(
            color: Colors.white,
          )
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
    );
  }
}

class _BackgroundImage extends StatelessWidget {
  const _BackgroundImage({
    Key? key,
    required this.mainColor,
    required this.height, 
    required this.opacity,
  }) : super(key: key);

  final Color mainColor;
  final double height;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: mainColor,
      child: Stack(
        children: [
          Positioned(
            bottom: -100,
            right: -40,
            child: Opacity(
              opacity: opacity,
              child: Container(
                height: height,
                color: Colors.transparent,
                child: Image.asset(
                  'assets/player.png',
                  // opacity: const AlwaysStoppedAnimation(.5),
                ),
              ),
            ),
          ),
        ]
      ),
    );
  }
}
