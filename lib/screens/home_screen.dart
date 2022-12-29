import 'dart:io';

import 'package:sports_names/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Sport> bands = [
    Sport(id: '1', name: 'Basquetball', votes: 5),
    Sport(id: '2', name: 'Soccer', votes: 2),
    Sport(id: '3', name: 'Swimming', votes: 3),
    Sport(id: '4', name: 'Tenis', votes: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sports Names',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (context, index) {
          return _sportTile(bands[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: addNewSport,
      ),
    );
  }

  Widget _sportTile(Sport band) {
    return Dismissible(
      key: Key(band.id),
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
          child: Text(band.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text(band.votes.toString()),
        onTap: () {
          print(band.name);
        },
      ),
      onDismissed: (direction) {
        //TODO: Delete from server
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
            title: Text('Band Name'),
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
          title: Text('Band Name'),
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
      setState(() {
        bands.add(
          Sport(id: DateTime.now().toString(), name: name, votes: 0)
        );
      });
    }

    Navigator.pop(context);
  }
}
