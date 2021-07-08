import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:peliculas_app/screens/details_screen.dart';
import 'package:peliculas_app/screens/home_screen.dart';
import 'package:peliculas_app/providers/movies_provider.dart';

void main() => runApp(AppState());

class AppState extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MoviesProvider(), lazy: false,)
      ],
      child: MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Peliculas',
      initialRoute: "home",
      routes: {
        "home": (context) => HomeScreen(),
        "details": (context) => DetailsScreen()
      },
      theme: ThemeData.light().copyWith(
        appBarTheme: AppBarTheme(
          color: Colors.indigo
        )
      ),
      
    );
  }
}
