import 'package:flutter/material.dart';
import 'package:Schedule_App/screens/ScheduleViewModel/ScheduleScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: Center(
        //Navigate to ScheduleScreen
        child: ElevatedButton(
          child: const Text("Go to Schedule", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),),
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> const ScheduleScreen()));
          },
        ),
      ),

    );
  }
}

