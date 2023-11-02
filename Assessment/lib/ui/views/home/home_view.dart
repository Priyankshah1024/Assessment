import 'package:Schedule_App/ui/views/schedule/ScheduleScreenViewModel.dart';
import 'package:Schedule_App/ui/views/schedule/schedule_view.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'home_viewmodel.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: (){
              // Navigator.push(context, MaterialPageRoute(builder: (context)=> ScheduleView()));

           //Note:  Due to a facing some issue with ScheduleViewModel.dart, I've temporarily redirected the page to ScheduleScreenViewModel.
           // This decision has been made to ensure the smooth operation of the application.

              Navigator.push(context, MaterialPageRoute(builder: (context)=>ScheduleScreenViewModel()));
            },
            child: const Text(
              'Go to Schedule',
              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
      viewModelBuilder: () => HomeViewModel(),
    );
  }
}
