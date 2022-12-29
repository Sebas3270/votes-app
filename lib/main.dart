import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sports_names/screens/screens.dart';
import 'package:sports_names/services/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SocketService(),)
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Material App',
        initialRoute: 'home',
        routes: {
          'home':(context) => const HomeScreen(),
          'status':(context) => const StatusScreen()
        },
      ),
    );
  }
}