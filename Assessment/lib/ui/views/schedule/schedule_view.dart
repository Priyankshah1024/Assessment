import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'schedule_viewmodel.dart';

class ScheduleView extends StatefulWidget {
  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController docNameController = TextEditingController();
  final TextEditingController onlineMeetingController = TextEditingController();
  final TextEditingController emailCCController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final List<String> onlineMeetingOptions = ['0', '1'];
  String? selectedOnlineMeeting;
  List<Map<String, dynamic>> schedules = [];
  bool isOnlineMeeting = false;
  bool dateIsValid = true;
  bool timeIsValid = true;
  bool docNameIsValid = true;
  bool emailCCIsValid = true;
  PageController pageController = PageController(initialPage: 0);
  Map<String, dynamic>? updatedData;
  String? id;
  Map<String, dynamic>? schedule;
  Map<String, dynamic>? updatedSchedule;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ScheduleViewModel>.reactive(
      viewModelBuilder: () => ScheduleViewModel(context),
      onModelReady: (model) {
        model.pageController = pageController;
        model.notifyListeners();
      },
      builder: (context, model, child) =>
          Scaffold(
            appBar: AppBar(
              title: const Text('Create Schedule'),
            ),
            body: Padding(
                padding: const EdgeInsets.all(10),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile=constraints.maxWidth<=600;
                    final isTablet=constraints.maxWidth>=600 && constraints.maxWidth<1024;

                    return Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Create New Schedule :',
                            style: TextStyle(
                                fontSize: isMobile?16:23,
                                fontWeight: FontWeight.w500,
                                color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 25),

                        Row(
                          children: [
                            const SizedBox(width: 10),
                            Container(
                              width: isMobile?170:300,
                              child: GestureDetector(
                                onTap: () async {
                                  var selected = await model.selectDate(context);
                                  if (selected != null) {
                                    setState(() {
                                      selectedDate=selected;
                                    });
                                  }
                                },
                                child: DropdownButtonFormField<String>(
                                  isDense: true,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 8,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black),
                                    ),
                                    hintText: selectedDate != null
                                        ? isTablet
                                        ? 'Selected Date: ${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}'
                                        : '${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}'
                                        : 'Select Date',
                                    hintStyle: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                  value: selectedDate != null
                                      ? '${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}'
                                      : null,
                                  onChanged: (String? newValue) async {
                                    if (newValue != null) {
                                      var selected = await model.selectDate(context);
                                      if (selected != null) {
                                        setState(() {
                                          selectedDate = selected;
                                        });
                                      }
                                    }
                                  },
                                  items: <String>[
                                    if (selectedDate == null) 'Please Select Date',
                                  ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    },
                                  ).toList(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 30),
                            Container(
                              width: isMobile ?165:300,
                              child: GestureDetector(
                                onTap: () async {
                                  var selected = await model.selectTime(context);
                                  if (selected != null) {
                                    setState(() {
                                      selectedTime = selected;
                                    });
                                  }
                                },
                                child: DropdownButtonFormField<String>(
                                  isDense: true,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 8,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black),
                                    ),
                                    hintText: selectedTime != null
                                        ? isTablet
                                        ? 'Selected Time: ${selectedTime!.format(context)}'
                                        : '${selectedTime!.format(context)}'
                                        : 'Select Time',
                                    hintStyle: TextStyle(color: Colors.black),
                                  ),
                                  value: selectedTime != null
                                      ? selectedTime!.format(context)
                                      : null,
                                  onChanged: (String? newValue) async {
                                    if (newValue != null) {
                                      var selected = await model.selectTime(context);
                                      if (selected != null) {
                                        setState(() {
                                          selectedTime = selected;
                                        });
                                      }
                                    }
                                  },
                                  items: <String>[
                                    if (selectedTime == null) 'Please Select Time',
                                  ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          textAlign: TextAlign.center,
                                        ),
                                      );
                                    },
                                  ).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        Row(
                          children: [
                            const SizedBox(width: 10),
                            Flexible(
                              flex: isTablet?3:2,
                              child: TextFormField(
                                controller: docNameController,
                                validator: (value) {
                                  return value!.isEmpty ? "Enter Doctor Name" : null;
                                },
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                  labelText: 'Enter Doctor Name',
                                  labelStyle: TextStyle(color: Colors.black),
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 30),
                            Flexible(
                              flex: isTablet?4:2,
                              child: Container(
                                width: isTablet?300:180,
                                child: TextFormField(
                                  controller: emailCCController,
                                  validator: (value) {
                                    return value!.isEmpty ? "Please enter cc-email id" : null;
                                  },
                                  textInputAction: TextInputAction.done,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    labelText: 'Enter CC Email ID',
                                    labelStyle: TextStyle(color: Colors.black),
                                    contentPadding: const EdgeInsets.all(16),
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            const SizedBox(width: 10),
                            Flexible(
                              flex: isTablet?4:2,
                              child: isTablet
                                  ? Row(
                                children: [
                                  Text(
                                    'Schedule Online Meeting:',
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Switch(
                                    inactiveTrackColor: Colors.grey[700],
                                    value: isOnlineMeeting,
                                    onChanged: (value) {
                                      setState(() {
                                        isOnlineMeeting = value;
                                      });
                                    },
                                  ),
                                ],
                              )
                                  : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    'Schedule Online Meeting :',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Switch(
                                    inactiveTrackColor: Colors.grey[700],
                                    value: isOnlineMeeting,
                                    onChanged: (value) {
                                      setState(() {
                                        isOnlineMeeting = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 0),
                            Flexible(
                              flex: isTablet?5:2,
                              child: Container(
                                width: isTablet?280:160,
                                height: isTablet?47:40,
                                child: ElevatedButton(
                                  onPressed: () {
                                    dateIsValid = selectedDate != null;
                                    timeIsValid = selectedTime != null;
                                    docNameIsValid =
                                        docNameController.text.isNotEmpty;
                                    emailCCIsValid =
                                        emailCCController.text.isNotEmpty;

                                    if (dateIsValid &&
                                        timeIsValid &&
                                        docNameIsValid &&
                                        emailCCIsValid) {
                                      model.createSchedule();
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          backgroundColor: Colors.redAccent,
                                          content: Text(
                                            "All the details are Mandatory!",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 17,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Text(
                                    'Add Schedule',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: isTablet?19:16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 35),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Upcoming Schedules :',
                            style: TextStyle(
                                fontSize: isMobile?16:25,
                                fontWeight: FontWeight.w500,
                                color: Colors.black),
                          ),
                        ),

                        SizedBox(
                          height: 20,
                        ),

                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              Expanded(
                                  child: FutureBuilder(
                                    future: model.fetchData(),
                                    builder: (BuildContext context, snapshot){
                                      if(schedules.isEmpty){
                                        return Container(
                                          alignment: Alignment.center,
                                          child: Text("No Data!", style: TextStyle(fontSize: 21, color: Colors.grey[600])),
                                        );
                                      }
                                      else{
                                        return PageView.builder(
                                          controller: pageController,
                                          itemCount: schedules.isNotEmpty?schedules.length:1,
                                          itemBuilder: (context, pageIndex) {
                                            if (pageIndex == 0 && schedules.isNotEmpty) {
                                              return GridView.builder(
                                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  childAspectRatio: 5,
                                                ),
                                                itemCount: (schedules.length < 6) ? schedules.length : 6,
                                                itemBuilder: (context, index) {
                                                  final schedule = schedules[index];
                                                  return Column(
                                                    children: [
                                                      ListTile(
                                                        leading: Text(
                                                          selectedTime != null
                                                              ? '${schedule['time']}'
                                                              : selectedTime != null
                                                              ? '${selectedTime!.format(context)}'
                                                              : schedule['time'],
                                                          style: TextStyle(
                                                            fontSize: 17,
                                                            fontWeight: FontWeight.w500,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        title: Text(
                                                          schedule['doc_name'],
                                                          style: TextStyle(
                                                            fontSize: isTablet ? 19 : 16,
                                                            fontWeight: FontWeight.w700,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        subtitle: Container(
                                                          padding: EdgeInsets.only(top: 4),
                                                          child: Text(
                                                            '(${schedule['email_cc']})',
                                                            style: TextStyle(
                                                              fontSize: isTablet ? 14 : 9,
                                                              fontWeight: FontWeight.w700,
                                                              color: Colors.indigo[400],
                                                            ),
                                                          ),
                                                        ),
                                                        trailing: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            IconButton(
                                                              icon: Icon(
                                                                FontAwesomeIcons.edit,
                                                                color: Colors.black87,
                                                              ),
                                                              onPressed: () {
                                                                model.editSchedule(schedule);
                                                              },
                                                            ),
                                                            IconButton(
                                                              icon: Icon(
                                                                FontAwesomeIcons.trashCan,
                                                                color: Colors.black87,
                                                              ),
                                                              onPressed: () {
                                                                showDialog(
                                                                  context: context,
                                                                  builder: (context) => AlertDialog(
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(18),
                                                                    ),
                                                                    title: Text(
                                                                      "Are you sure you want to delete the data?",
                                                                      style: TextStyle(
                                                                        color: Colors.black,
                                                                        fontSize: isMobile ? 16 : 19,
                                                                        fontWeight: FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed: () {
                                                                          setState(() {
                                                                            model.deleteSchedule(schedule['id']);
                                                                          });
                                                                          Navigator.of(context).pop();
                                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                                            const SnackBar(
                                                                              backgroundColor: Colors.indigo,
                                                                              content: Text(
                                                                                "Data has been deleted successfully!",
                                                                                style: TextStyle(
                                                                                  fontWeight: FontWeight.w400,
                                                                                  fontSize: 15,
                                                                                  color: Colors.white,
                                                                                ),
                                                                                textAlign: TextAlign.center,
                                                                              ),
                                                                            ),
                                                                          );
                                                                        },
                                                                        child: Text(
                                                                          'Yes',
                                                                          style: TextStyle(
                                                                            color: Colors.indigo,
                                                                            fontWeight: FontWeight.w600,
                                                                            fontSize: isMobile ? 16 : 20,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed: () {
                                                                          Navigator.of(context).pop();
                                                                        },
                                                                        child: Text(
                                                                          'No',
                                                                          style: TextStyle(
                                                                            color: Colors.indigo,
                                                                            fontWeight: FontWeight.w600,
                                                                            fontSize: isMobile ? 16 : 20,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            } else if (pageIndex == 1 && schedules.length > 6) {
                                              return GridView.builder(
                                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  childAspectRatio: 5,
                                                ),
                                                itemCount: (schedules.length - 6).clamp(0, schedules.length - 6),
                                                itemBuilder: (context, index) {
                                                  final schedule = schedules[index + 6];
                                                  return Column(
                                                    children: [
                                                      ListTile(
                                                        leading: Text(
                                                          selectedTime != null
                                                              ? '${schedule['time']}'
                                                              : (selectedTime != null
                                                              ? '${selectedTime!.format(context)}'
                                                              : schedule['time']),
                                                          style: TextStyle(
                                                            fontSize: 17,
                                                            fontWeight: FontWeight.w500,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        title: Text(
                                                          schedule['doc_name'],
                                                          style: TextStyle(
                                                            fontSize: isTablet ? 19 : 16,
                                                            fontWeight: FontWeight.w500,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        subtitle: Text(
                                                          schedule['email_cc'],
                                                          style: TextStyle(
                                                            fontSize: isTablet ? 13 : 9,
                                                            fontWeight: FontWeight.w600,
                                                            color: Colors.indigo[400],
                                                          ),
                                                        ),
                                                        trailing: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            IconButton(
                                                              icon: Icon(
                                                                FontAwesomeIcons.edit,
                                                                color: Colors.black87,
                                                              ),
                                                              onPressed: () {
                                                                model.editSchedule(schedule);
                                                              },
                                                            ),
                                                            IconButton(
                                                              icon: Icon(
                                                                FontAwesomeIcons.trashCan,
                                                                color: Colors.black87,
                                                              ),
                                                              onPressed: () {
                                                                showDialog(
                                                                  context: context,
                                                                  builder: (context) => AlertDialog(
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(18),
                                                                    ),
                                                                    title: Text(
                                                                      "Are you sure you want to delete the data?",
                                                                      style: TextStyle(
                                                                        color: Colors.black,
                                                                        fontSize: isMobile ? 16 : 19,
                                                                        fontWeight: FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed: () {
                                                                          setState(() {
                                                                            model.deleteSchedule(schedule['id']);
                                                                          });
                                                                          Navigator.of(context).pop();
                                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                                            const SnackBar(
                                                                              backgroundColor: Colors.indigo,
                                                                              content: Text(
                                                                                "Data has been deleted successfully!",
                                                                                style: TextStyle(
                                                                                  fontWeight: FontWeight.w400,
                                                                                  fontSize: 15,
                                                                                  color: Colors.white,
                                                                                ),
                                                                                textAlign: TextAlign.center,
                                                                              ),
                                                                            ),
                                                                          );
                                                                        },
                                                                        child: Text(
                                                                          'Yes',
                                                                          style: TextStyle(
                                                                            color: Colors.indigo,
                                                                            fontWeight: FontWeight.w600,
                                                                            fontSize: isMobile ? 16 : 20,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed: () {
                                                                          Navigator.of(context).pop();
                                                                        },
                                                                        child: Text(
                                                                          'No',
                                                                          style: TextStyle(
                                                                            color: Colors.indigo,
                                                                            fontWeight: FontWeight.w600,
                                                                            fontSize: isMobile ? 16 : 20,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            } else {
                                              return Container(
                                                alignment: Alignment.center,
                                                child: Text("No Data", style: TextStyle(fontSize: 19, color: Colors.grey[500])),
                                              );
                                            }
                                          },
                                        );
                                      }
                                    },
                                  )

                              ),

                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.arrow_back),
                                    onPressed: () {
                                      model.pageController.previousPage(
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.ease,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.arrow_forward),
                                    onPressed: () {
                                      model.pageController.nextPage(
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.ease,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )


                      ],
                    );
                  },
                )),
          ),
    );
  }
}
