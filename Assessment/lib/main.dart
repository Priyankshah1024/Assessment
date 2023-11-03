import 'package:Schedule_App/ui/views/home/home_view.dart';
import 'package:Schedule_App/ui/views/schedule/ScheduleScreenViewModel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'locator.dart';

void main() {
  setupLocator();
  runApp(const MyApp());
}

class Routes {
  static const homeScreen = '/';
  static const scheduleView = '/ScheduleScreen';
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Schedule App',
      theme: ThemeData(
        highlightColor: Colors.indigo[200],
        primarySwatch: Colors.indigo,
      ),
      navigatorKey: StackedService.navigatorKey,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      initialRoute: Routes.homeScreen,
    );
  }
}

class StackedRouter {
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.homeScreen:
        return MaterialPageRoute(
          builder: (context) => HomeView(),
        );
      case Routes.scheduleView:
        return MaterialPageRoute(
          builder: (context) => ScheduleScreenViewModel(),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => HomeView(),
        );
    }
  }
}