import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/locator.dart';

class ScheduleScreenViewModel extends StatefulWidget {
  const ScheduleScreenViewModel({super.key});

  @override
  _ScheduleScreenViewModelState createState() => _ScheduleScreenViewModelState();
}

class _ScheduleScreenViewModelState extends State<ScheduleScreenViewModel> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController docNameController = TextEditingController();
  final TextEditingController onlineMeetingController = TextEditingController();
  final TextEditingController emailCCController = TextEditingController();
  final DialogService _dialogService = locator<DialogService>();
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
  PageController _pageController = PageController(initialPage: 0);
  List<Map<String, String>> schedules1 = [];
  final ScrollController _scrollController = ScrollController();

  // This method is used to create a schedule by sending a POST request to a specific API endpoint.
  FutureOr<void> createSchedule() async {
    final Uri url = Uri.parse(
        'https://showdigital.in/flutter-schedules/create_schedule.php');

    if (selectedDate != null) {
      String date = selectedDate!.toLocal().toString();

      if (date.length >= 13) {
        date = date.substring(0, date.length - 13);
        selectedDate = DateTime.parse(date);

        final Map<String, String> headers = {
          'Content-Type': 'application/json',
          'Accept-Language': 'en-US',
        };

        final data = {
          "date": date,
          "time": selectedTime!.format(context),
          "doc_name": docNameController.text,
          "online_meeting": isOnlineMeeting ? "1" : "0",
          "email_cc": emailCCController.text,
        };

        try {
          final response =
              await http.post(url, headers: headers, body: jsonEncode(data));

          if (response.statusCode == 200) {
            final jsonResponse = json.decode(response.body);
            if (jsonResponse is Map<String, dynamic>) {
              resetFormFields();
              dateController.clear();
              timeController.clear();
              docNameController.clear();
              onlineMeetingController.clear();
              emailCCController.clear();
              fetchData();
              print("\n*****Successfully created schedule!******");
            } else {
              print("Invalid JSON response: ${response.body}");
            }
          } else {
            print("Error Occurred! Status code: ${response.statusCode}");
          }
        } catch (e) {
          print('Error: $e');
        }
      }
    }
  }

  //This method is used to fetch schedule data from a specific API endpoint and update the app's UI with the retrieved data.
  Future<void> fetchData() async {
    List<Map<String, dynamic>> fetchedData = [];

    const url = 'https://showdigital.in/flutter-schedules/list_schedule.php';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        final jsonData = json.decode(response.body);

        if (jsonData is List) {
          fetchedData = jsonData.cast<Map<String, dynamic>>();
        } else {
          print("Invalid JSON structure. Expected a list.");
        }
      } catch (e) {
        print('JSON parsing error: $e');
      }
    } else {
      print('HTTP request error - Status code: ${response.statusCode}');
    }

    setState(() {
      schedules = fetchedData;
    });
  }

  //This method is used to edit an existing schedule by allowing the user to modify schedule details through a dialog interface and then sending the updated data to a server.
  FutureOr<void> editSchedule(Map<String, dynamic> schedule) async {
    final dateController = TextEditingController(text: schedule['date']);
    final timeController = TextEditingController(text: schedule['time']);
    final docNameController = TextEditingController(text: schedule['doc_name']);
    final emailCCController = TextEditingController(text: schedule['email_cc']);

    bool isOnlineMeetingEnabled = schedule['online_meeting'] == "1";

    final updatedData = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        var selected = await _selectDate(context);
                        if (selected != null) {
                          setState(() {
                            selectedDate = selected;
                            dateController.text = "${selected.year}-${selected.month}-${selected.day}";
                          });
                        }

                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            title: Text('Selected Date'),
                            content: Text('You have selected the date: ${selectedDate.toString().substring(0, 10)}'),
                            actions: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close the dialog
                                },
                                child: Text('Save', style: TextStyle(fontSize: 17)),
                              ),
                            ],
                          ),
                        );

                      },
                      child: const Text('Select Date'),
                    ),

                    if (selectedDate != null)
                      Text(
                        'Selected Date: ${dateController.text}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () async {
                        var selected = await _selectTime(context);
                        if (selected != null) {
                          setState(() {
                            selectedTime = selected;
                            timeController.text = selected.format(context);
                          });
                        }

                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            title: Text('Selected Date'),
                            content: Text('You have selected the time: ${selectedTime!.format(context)}'),
                            actions: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Save', style: TextStyle(fontSize: 17)),
                              ),
                            ],
                          ),
                        );

                      },
                      child: const Text('Select Time'),
                    ),
                    if (selectedTime != null)
                      Text(
                        'Selected Time: ${timeController.text}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 10),
                    TextFormField(
                      keyboardType: TextInputType.name,
                      controller: docNameController,
                      decoration: const InputDecoration(labelText: 'Doctor Name'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Schedule Online Meeting :',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Switch(
                          value: isOnlineMeetingEnabled,
                          onChanged: (value) {
                            setState(() {
                              isOnlineMeetingEnabled = value;
                              print("Toggle Value: $value");
                            });
                          },
                        ),
                      ],
                    ),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: emailCCController,
                      decoration: const InputDecoration(labelText: 'Email CC'),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    final updatedSchedule = {
                      'id': schedule['id'],
                      'date': selectedDate!=null?selectedDate!.toLocal().toString().substring(0,10):dateController.text,
                      'time': selectedTime!=null?selectedTime!.format(context):schedule['time'],
                      'doc_name': docNameController.text,
                      'online_meeting': isOnlineMeetingEnabled?'1':'0',
                      'email_cc': emailCCController.text,
                    };
                    await updateSchedule(updatedSchedule);
                    resetFormFields();
                    fetchData();

                    Navigator.of(context).pop(updatedSchedule);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.indigo,
                        content: Text(
                          "Data has been edited successfully!",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                  child: const Text('Save', style: TextStyle(fontSize: 18)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                  child: const Text('Cancel', style: TextStyle(fontSize: 18)),
                ),
              ],
            );
          },
        );
      },
    );

    if (updatedData != null) {}
  }

  //This method is responsible for sending an HTTP PUT request to update an existing schedule on the server with the provided updated data.
  FutureOr<void> updateSchedule(Map<String, dynamic> updatedData) async {
    const url = 'https://showdigital.in/flutter-schedules/update_schedule.php';
    final response =
        await http.put(Uri.parse(url), body: jsonEncode(updatedData));
    if (response.statusCode != 200) {
      throw Exception('Failed to update schedule');
    }
  }

  //which is a map (dictionary) containing information about a schedule that has been updated.
  // This map likely includes properties such as 'id', 'date', 'time', 'doc_name', 'online_meeting', and 'email_cc'.
  void handleScheduleUpdate(Map<String, dynamic> updatedSchedule) {
    final index = schedules.indexWhere((s) => s['id'] == updatedSchedule['id']);
    if (index != -1) {
      setState(() {
        schedules[index] = updatedSchedule;
      });
    }
  }

  // This method is used to delete a schedule entry by making an HTTP GET request to a server API with the schedule's ID as a parameter.
  FutureOr<void> deleteSchedule(String id) async {
    final url =
        'https://showdigital.in/flutter-schedules/delete_schedule.php?id=$id';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      fetchData();
    } else {
      print('Delete request error - Status code: ${response.statusCode}');
    }
  }

  //This method is used to display a date picker dialog, allowing the user to choose a date.
  FutureOr<DateTime?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        selectedDate = picked;
        dateController.text = "${picked.year}-${picked.month}-${picked.day}";
      });
    }
    return null;
  }

  //This method is used to display a time picker dialog, enabling the user to select a time of day.
  FutureOr<TimeOfDay?> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
    return null;
  }

  //This method is used to create because when user will click on Add Schedule Button the details they filled are reset or clear for fill the new details or schedule.
  void resetFormFields() {
    setState(() {
      selectedDate = null;
      selectedTime = null;
      selectedOnlineMeeting = null;
      docNameController.clear();
      emailCCController.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Create Schedule'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile=constraints.maxWidth<=600;
              final isTablet=constraints.maxWidth>=600 && constraints.maxWidth<1024;
              return isMobile
                  ? Column(
                  children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Create New Schedule :',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),),
                  ),
                  SizedBox(height: 25),

                  Row(
                    children: [
                      SizedBox(width: 10),
                      Container(
                        width: 180,
                        child: GestureDetector(
                          onTap: () async {
                            var selected = await _selectDate(context);
                            if (selected != null) {
                              setState(() {
                                selectedDate = selected;
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
                              hintText: selectedDate != null?
                                       '${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}'
                                  : 'Select Date',
                              hintStyle: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            value: selectedDate != null
                                ? '${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}' : null,
                            onChanged: (String? newValue) async {
                              if (newValue != null) {
                                var selected = await _selectDate(context);
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
                      const SizedBox(width: 20),
                      Container(
                        width: 165,
                        child: GestureDetector(
                          onTap: () async {
                            var selected = await _selectTime(context);
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
                              hintText: selectedTime != null ? '${selectedTime!.format(context)}' : 'Select Time',
                              hintStyle: TextStyle(color: Colors.black),
                            ),
                            value: selectedTime != null ? selectedTime!.format(context) : null,
                            onChanged: (String? newValue) async {
                              if (newValue != null) {
                                var selected = await _selectTime(context);
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

                  SizedBox(height: 20,),

                  Row(
                    children: [
                      SizedBox(width: 10),
                      Flexible(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.only(right: 10),
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
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        flex: 2,
                        child: Container(
                          width: 170,
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

                  SizedBox(height: 20),

                  Row(
                    children: [
                      SizedBox(width: 20),
                      Flexible(
                        flex: 2,
                        child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 5,),
                                Text('Schedule Online Meeting :',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[700],),
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

                      SizedBox(width: 80,),

                      Flexible(
                        flex: 3,
                        child: Container(
                          width: 160,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              dateIsValid = selectedDate!=null;
                              timeIsValid = selectedTime!=null;
                              docNameIsValid = docNameController.text.isNotEmpty;
                              emailCCIsValid = emailCCController.text.isNotEmpty;
                              if (dateIsValid && timeIsValid && docNameIsValid && emailCCIsValid) {
                                    createSchedule();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        backgroundColor: Colors.indigo,
                                        content: Text(
                                          "Data has been uploaded successfully!",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );

                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.redAccent,
                                    content: Text(
                                      "All the details are Mandatory!",
                                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17, color: Colors.white,),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              'Add Schedule',
                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 25),

                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Upcoming Schedules :',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500, color: Colors.indigo[700]),
                    ),
                  ),
                  Divider(color: Colors.indigo[700], height: 25, thickness: 2, indent: 5, endIndent: 5,),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: FutureBuilder(
                            future: fetchData(),
                            builder: (BuildContext context, snapshot){
                              if (snapshot.hasError) {
                                print("${snapshot.error}");
                                return Center(child: Text('Something went wrong!', style: TextStyle(fontSize: 21, color: Colors.grey[600], fontWeight: FontWeight.w500),));
                              }
                              else if(schedules.isEmpty){
                                return Container(
                                  alignment: Alignment.center,
                                  child: Text("No Data!", style: TextStyle(fontSize: 21, color: Colors.grey[600])),
                                );
                              }
                              else{
                                return PageView.builder(
                                    scrollDirection: Axis.horizontal,
                                    controller: _pageController,
                                    itemCount: (schedules.length/3).ceil(),
                                    itemBuilder: (context, pageIndex) {
                                      final startIndex = pageIndex*3;
                                      final endIndex = (startIndex+3 < schedules.length) ? startIndex+3 : schedules.length;
                                      if (pageIndex<schedules.length && schedules.isNotEmpty) {
                                        return CupertinoScrollbar(
                                            controller: _scrollController,
                                            thickness: 10,
                                            radius: Radius.circular(10),
                                            thicknessWhileDragging: 4,
                                            radiusWhileDragging: Radius.circular(20),
                                            child: GridView.builder(
                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 1,
                                                childAspectRatio: 3.9,
                                              ),
                                              controller: _scrollController,
                                              itemCount: endIndex-startIndex,
                                              itemBuilder: (context, index) {
                                                final schedule = schedules[startIndex+index];
                                                return Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SingleChildScrollView(
                                                      child: ListTile(
                                                        leading: Column(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text('${schedule['date'].toString().substring(2,10)}',
                                                                style: TextStyle(
                                                                fontSize: 17,
                                                                fontWeight: FontWeight.w500,
                                                                color: Colors.grey[800],
                                                              ),
                                                            ),
                                                            SizedBox(height: 3.5,),
                                                            Text(
                                                              selectedTime != null
                                                                  ? '${schedule['time']}' : selectedTime != null
                                                                  ? '${selectedTime!.format(context)}' : schedule['time'],
                                                              style: TextStyle(
                                                                fontSize: 17,
                                                                fontWeight: FontWeight.w500,
                                                                color: Colors.grey[800],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        title: Container(
                                                          padding: const EdgeInsets.only(bottom: 10),
                                                          alignment: Alignment.topLeft,
                                                          child: Text(
                                                            schedule['doc_name'],
                                                            style: TextStyle(
                                                              fontSize: 19.5,
                                                              fontWeight: FontWeight.w700,
                                                              color: Colors.black87,
                                                            ),
                                                          ),
                                                        ),
                                                        subtitle: Container(
                                                          padding: EdgeInsets.only(bottom: 10),
                                                          child: Text(
                                                            '(${schedule['email_cc']})',
                                                            style: TextStyle(
                                                              fontSize: 14,
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
                                                                size: 20,
                                                                FontAwesomeIcons.edit,
                                                                color: Colors.black87,
                                                              ),
                                                              onPressed: () {
                                                                editSchedule(schedule);
                                                              },
                                                            ),
                                                            IconButton(
                                                              icon: Icon(
                                                                size: 20,
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
                                                                        fontSize: 16,
                                                                        fontWeight: FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed: () {
                                                                          setState(() {
                                                                            deleteSchedule(schedule['id']);
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
                                                                            fontSize: 16,
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
                                                                            fontSize: 16,
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
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          );
                                      }
                                      else{
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back),
                              onPressed: () {
                                _pageController.previousPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.arrow_forward),
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              )
                  : isTablet
                  ? Column(
                  children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Create New Schedule :',
                      style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 25),

                  Row(
                    children: [
                      SizedBox(width: 10),
                      Container(
                        width: 300,
                        child: GestureDetector(
                          onTap: () async {
                            var selected = await _selectDate(context);
                            if (selected != null) {
                              setState(() {
                                selectedDate = selected;
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
                                  ? 'Selected Date: ${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}'
                                  : 'Select Date',
                              hintStyle: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            value: selectedDate != null
                                ? '${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}' : null,
                            onChanged: (String? newValue) async {
                              if (newValue != null) {
                                var selected = await _selectDate(context);
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
                      SizedBox(width: 20),
                      Container(
                        width: 300,
                        child: GestureDetector(
                          onTap: () async {
                            var selected = await _selectTime(context);
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
                              hintText: selectedTime != null?
                                  'Selected Time: ${selectedTime!.format(context)}'
                                  : 'Select Time',
                              hintStyle: TextStyle(color: Colors.black),
                            ),
                            value: selectedTime != null ? selectedTime!.format(context) : null,
                            onChanged: (String? newValue) async {
                              if (newValue != null) {
                                var selected = await _selectTime(context);
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

                  SizedBox(height: 20,),

                  Row(
                    children: [
                      SizedBox(width: 10),
                      Flexible(
                        flex: 3,
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
                      SizedBox(width: 30),
                      Flexible(
                        flex: 4,
                        child: Container(
                          width: 300,
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
                              contentPadding: EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  Row(
                    children: [
                      SizedBox(width: 20),
                      Flexible(
                        flex: 4,
                        child: Row(
                          children: [
                            Text(
                              'Schedule Online Meeting:',
                              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500, color: Colors.grey[700],
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
                      ),

                      SizedBox(width: 8),

                      Flexible(
                        flex: 5,
                        child: Container(
                          width: 270,
                          height: 47,
                          child: ElevatedButton(
                            onPressed: () {
                              dateIsValid = selectedDate != null;
                              timeIsValid = selectedTime != null;
                              docNameIsValid = docNameController.text.isNotEmpty;
                              emailCCIsValid = emailCCController.text.isNotEmpty;
                              if (dateIsValid && timeIsValid && docNameIsValid && emailCCIsValid) {
                                createSchedule();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.indigo,
                                    content: Text(
                                      "Data has been uploaded successfully!",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.redAccent,
                                    content: Text("All the details are Mandatory!",
                                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17, color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              'Add Schedule',
                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 19,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Upcoming Schedules :',
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500, color: Colors.indigo[700]),
                    ),
                  ),

                  Divider(
                    color: Colors.indigo[700],
                    height: 50,
                    thickness: 2,
                    indent: 5,
                    endIndent: 5,
                  ),

                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                            child: FutureBuilder(
                              future: fetchData(),
                              builder: (BuildContext context, snapshot){
                                if (snapshot.hasError) {
                                  print("${snapshot.error}");
                                  return Center(child: Text('Something went wrong!', style: TextStyle(fontSize: 27, color: Colors.grey[600], fontWeight: FontWeight.w500),));
                                }
                                else if(schedules.isEmpty){
                                  return Container(
                                    alignment: Alignment.center,
                                    child: Text("No Data!", style: TextStyle(fontSize: 27, color: Colors.grey[600])),
                                  );
                                }
                                else{
                                  return PageView.builder(
                                      controller: _pageController,
                                      itemCount: schedules.isNotEmpty?schedules.length:1,
                                      itemBuilder: (context, pageIndex) {
                                        if (pageIndex == 0 && schedules.isNotEmpty) {
                                            return GridView.builder(
                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                childAspectRatio: 2,
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
                                                          fontSize: 19,
                                                          fontWeight: FontWeight.w700,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      subtitle: Container(
                                                        padding: EdgeInsets.only(top: 4),
                                                        child: Text(
                                                          '(${schedule['email_cc']})',
                                                          style: TextStyle(
                                                            fontSize: 14,
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
                                                              editSchedule(schedule);
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
                                                                      fontSize: 19,
                                                                      fontWeight: FontWeight.w500,
                                                                    ),
                                                                  ),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed: () {
                                                                        setState(() {
                                                                          deleteSchedule(schedule['id']);
                                                                        });
                                                                        Navigator.of(context).pop();
                                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                                          const SnackBar(
                                                                            backgroundColor: Colors.indigo,
                                                                            content: Text(
                                                                              "Data has been deleted successfully!",
                                                                              style: TextStyle(
                                                                                fontWeight: FontWeight.w400,
                                                                                fontSize: 18,
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
                                                                          fontSize: 20,
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
                                                                          fontSize: 20,
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
                                        } else if(pageIndex==1 && schedules.length>6) {
                                            return GridView.builder(
                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                childAspectRatio: 5,
                                              ),
                                              itemCount: (schedules.length-6).clamp(0, schedules.length-6),
                                              itemBuilder: (context, index) {
                                                final schedule = schedules[index+6];
                                                return Column(
                                                  children: [
                                                    ListTile(
                                                      leading: Text(selectedTime != null ? '${schedule['time']}' : (selectedTime != null
                                                            ? '${selectedTime!.format(context)}' : schedule['time']),
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                          fontWeight: FontWeight.w500,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      title: Text(
                                                        schedule['doc_name'],
                                                        style: TextStyle(
                                                          fontSize: 19,
                                                          fontWeight: FontWeight.w500,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      subtitle: Text(
                                                        schedule['email_cc'],
                                                        style: TextStyle(
                                                          fontSize: 13,
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
                                                              editSchedule(schedule);
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
                                                                      fontSize: 19,
                                                                      fontWeight: FontWeight.w500,
                                                                    ),
                                                                  ),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed: () {
                                                                        setState(() {
                                                                          deleteSchedule(schedule['id']);
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
                                                                          fontSize: 20,
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
                                                                          fontSize: 20,
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
                                            child: Text("No Data!", style: TextStyle(fontSize: 19, color: Colors.grey[500])),
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
                                _pageController.previousPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.arrow_forward),
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              )
                  : Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Create New Schedule :',
                      style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 25),

                  Row(
                    children: [
                      SizedBox(width: 10),
                      Container(
                        width: 300,
                        child: GestureDetector(
                          onTap: () async {
                            var selected = await _selectDate(context);
                            if (selected != null) {
                              setState(() {
                                selectedDate = selected;
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
                                  ? 'Selected Date: ${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}'
                                  : 'Select Date',
                              hintStyle: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            value: selectedDate != null
                                ? '${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}' : null,
                            onChanged: (String? newValue) async {
                              if (newValue != null) {
                                var selected = await _selectDate(context);
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
                      SizedBox(width: 20),
                      Container(
                        width: 300,
                        child: GestureDetector(
                          onTap: () async {
                            var selected = await _selectTime(context);
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
                              hintText: selectedTime != null?
                              'Selected Time: ${selectedTime!.format(context)}'
                                  : 'Select Time',
                              hintStyle: TextStyle(color: Colors.black),
                            ),
                            value: selectedTime != null ? selectedTime!.format(context) : null,
                            onChanged: (String? newValue) async {
                              if (newValue != null) {
                                var selected = await _selectTime(context);
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

                  SizedBox(height: 20,),

                  Row(
                    children: [
                      SizedBox(width: 10),
                      Flexible(
                        flex: 3,
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
                      SizedBox(width: 30),
                      Flexible(
                        flex: 4,
                        child: Container(
                          width: 300,
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
                              contentPadding: EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  Row(
                    children: [
                      SizedBox(width: 20),
                      Flexible(
                          flex: 4,
                          child: Row(
                            children: [
                              Text(
                                'Schedule Online Meeting:',
                                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500, color: Colors.grey[700],
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
                      ),

                      SizedBox(width: 8),

                      Flexible(
                        flex: 5,
                        child: Container(
                          width: 270,
                          height: 47,
                          child: ElevatedButton(
                            onPressed: () {
                              dateIsValid = selectedDate != null;
                              timeIsValid = selectedTime != null;
                              docNameIsValid = docNameController.text.isNotEmpty;
                              emailCCIsValid = emailCCController.text.isNotEmpty;
                              if (dateIsValid && timeIsValid && docNameIsValid && emailCCIsValid) {
                                createSchedule();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.indigo,
                                    content: Text(
                                      "Data has been uploaded successfully!",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.redAccent,
                                    content: Text("All the details are Mandatory!",
                                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17, color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              'Add Schedule',
                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 19,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Upcoming Schedules :',
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500, color: Colors.indigo[700]),
                    ),
                  ),

                  Divider(
                    color: Colors.indigo[700],
                    height: 50,
                    thickness: 2,
                    indent: 5,
                    endIndent: 5,
                  ),

                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                            child: FutureBuilder(
                              future: fetchData(),
                              builder: (BuildContext context, snapshot){
                                if (snapshot.hasError) {
                                  print("${snapshot.error}");
                                  return Center(child: Text('Something went wrong!', style: TextStyle(fontSize: 27, color: Colors.grey[600], fontWeight: FontWeight.w500),));
                                }
                                else if(schedules.isEmpty){
                                  return Container(
                                    alignment: Alignment.center,
                                    child: Text("No Data!", style: TextStyle(fontSize: 27, color: Colors.grey[600])),
                                  );
                                }
                                else{
                                  return PageView.builder(
                                    controller: _pageController,
                                    itemCount: schedules.isNotEmpty?schedules.length:1,
                                    itemBuilder: (context, pageIndex) {
                                      if (pageIndex == 0 && schedules.isNotEmpty) {
                                        return GridView.builder(
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            childAspectRatio: 2,
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
                                                      fontSize: 19,
                                                      fontWeight: FontWeight.w700,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  subtitle: Container(
                                                    padding: EdgeInsets.only(top: 4),
                                                    child: Text(
                                                      '(${schedule['email_cc']})',
                                                      style: TextStyle(
                                                        fontSize: 14,
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
                                                          editSchedule(schedule);
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
                                                                  fontSize: 19,
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () {
                                                                    setState(() {
                                                                      deleteSchedule(schedule['id']);
                                                                    });
                                                                    Navigator.of(context).pop();
                                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                                      const SnackBar(
                                                                        backgroundColor: Colors.indigo,
                                                                        content: Text(
                                                                          "Data has been deleted successfully!",
                                                                          style: TextStyle(
                                                                            fontWeight: FontWeight.w400,
                                                                            fontSize: 18,
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
                                                                      fontSize: 20,
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
                                                                      fontSize: 20,
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
                                      } else if(pageIndex==1 && schedules.length>6) {
                                        return GridView.builder(
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            childAspectRatio: 5,
                                          ),
                                          itemCount: (schedules.length-6).clamp(0, schedules.length-6),
                                          itemBuilder: (context, index) {
                                            final schedule = schedules[index+6];
                                            return Column(
                                              children: [
                                                ListTile(
                                                  leading: Text(selectedTime != null ? '${schedule['time']}' : (selectedTime != null
                                                      ? '${selectedTime!.format(context)}' : schedule['time']),
                                                    style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  title: Text(
                                                    schedule['doc_name'],
                                                    style: TextStyle(
                                                      fontSize: 19,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    schedule['email_cc'],
                                                    style: TextStyle(
                                                      fontSize: 13,
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
                                                          editSchedule(schedule);
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
                                                                  fontSize: 19,
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () {
                                                                    setState(() {
                                                                      deleteSchedule(schedule['id']);
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
                                                                      fontSize: 20,
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
                                                                      fontSize: 20,
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
                                          child: Text("No Data!", style: TextStyle(fontSize: 19, color: Colors.grey[500])),
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
                                _pageController.previousPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.arrow_forward),
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              );
            },
          )),
    );
  }
}
