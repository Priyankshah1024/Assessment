import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
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

  @override
  void initState(){
    super.initState();
    setState(() {

    });
  }
  // This method is used to create a schedule by sending a POST request to a specific API endpoint
  FutureOr<void> createSchedule() async {

    final Uri url = Uri.parse('https://showdigital.in/flutter-schedules/create_schedule.php');

    if (selectedDate != null) {

      String date = selectedDate!.toLocal().toString();

      if (date.length>=13) {
        date = date.substring(0, date.length-13);
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
          final response = await http.post(url, headers: headers, body: jsonEncode(data));

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

  //This method is used to fetch schedule data from a specific API endpoint and update the app's UI with the retrieved data
  FutureOr<void> fetchData() async {
    //list_schedule endpoint to fetch the details from the endpoint
    const url = 'https://showdigital.in/flutter-schedules/list_schedule.php';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        final jsonData = json.decode(response.body);
        print("Response body: ${response.body}");

        if (jsonData is List) {
          setState(() {
            schedules = jsonData.cast<Map<String, dynamic>>();
          });
        } else {
          print("Invalid JSON structure. Expected a list.");
        }
      } catch (e) {
        print('JSON parsing error: $e');
      }
    } else {
      print('HTTP request error - Status code: ${response.statusCode}');
    }
    print("Response body: ${response.body}");
  }

  //This method is used to edit an existing schedule by allowing the user to modify schedule details through a dialog interface and then sending the updated data to a server
  FutureOr<void> editSchedule(Map<String, dynamic> schedule) async {
    final dateController = TextEditingController(text: schedule['date']);
    final timeController = TextEditingController(text: schedule['time']);
    final docNameController = TextEditingController(text: schedule['doc_name']);
    final emailCCController = TextEditingController(text: schedule['email_cc']);

    bool isOnlineMeetingEnabled = schedule['online_meeting'] == "1";

    final updatedData = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Your Schedule'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState){
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        var selected = await _selectDate(context);
                        if (selected != null) {
                          setState(() {
                            dateController.text =
                            "${selected.day}-${selected.month}-${selected.year}";
                            selectedDate = selected;
                          });
                        }
                      },
                      child: const Text('Select Date'),
                    ),

                    if (selectedDate != null)
                      Text(
                        'Selected Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () async {
                        var selected = await _selectTime(context);
                        if (selected != null) {
                          setState(() {
                            selectedTime = selected;
                          });
                        }
                      },
                      child: const Text('Select Time'),
                    ),
                    if (selectedTime != null)
                      Text(
                        'Selected Time: ${selectedTime!.format(context)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),

                    const SizedBox(height: 10),

                    TextFormField(
                      controller: docNameController,
                      decoration: const InputDecoration(labelText: 'Doctor Name'),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Text('Online Meeting:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                      controller: emailCCController,
                      decoration: const InputDecoration(labelText: 'Email CC'),
                    ),
                  ],
                ),
              );
            },
          ),

          actions: [
            ElevatedButton(
              onPressed: () async {
                if (selectedDate != null) {

                  String date = selectedDate!.toLocal().toString();

                  if (date.length>=13) {
                    date = date.substring(0, date.length-13);
                    selectedDate = DateTime.parse(date);

                    final updatedSchedule = {
                      'id': schedule['id'],
                      'date': date,
                      'time': selectedTime!.format(context),
                      'doc_name': docNameController.text,
                      'online_meeting': isOnlineMeetingEnabled ? "1" : "0",
                      'email_cc': emailCCController.text,
                    };

                    await updateSchedule(updatedSchedule);
                    fetchData();

                    Navigator.of(context).pop(updatedSchedule);
                  }
                }
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

    if (updatedData != null) {}
  }

  //This method is responsible for sending an HTTP PUT request to update an existing schedule on the server with the provided updated data
  FutureOr<void> updateSchedule(Map<String, dynamic> updatedData) async {
    const url = 'https://showdigital.in/flutter-schedules/update_schedule.php';
    final response = await http.put(Uri.parse(url), body: jsonEncode(updatedData));
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

  // This method is used to delete a schedule entry by making an HTTP GET request to a server API with the schedule's ID as a parameter
  FutureOr<void> deleteSchedule(String id) async {
    final url = 'https://showdigital.in/flutter-schedules/delete_schedule.php?id=$id';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      fetchData();
    } else {
      print('Delete request error - Status code: ${response.statusCode}');
    }
  }

  //This method is used to display a date picker dialog, allowing the user to choose a date
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

  //This method is used to display a time picker dialog, enabling the user to select a time of day
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: LayoutBuilder(
          builder: (context, constraints){
            final isMobile = constraints.maxWidth <= 600;
            final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

            return Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Create New Schedule :',
                    style: TextStyle(fontSize: isMobile ? 16 : 19, fontWeight: FontWeight.w500, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () {
                          _selectDate(context);
                        },
                        child: const Text('Select Date'),
                      ),
                    ),
                    const SizedBox(width: 10,),
                    if (selectedDate != null)
                      Flexible(
                        flex: 2,
                        child: Text(
                          'Selected Date: ${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}',
                          style: TextStyle(fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    const SizedBox(width: 15,),
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    Flexible(
                      flex: 3,
                      child: OutlinedButton(
                        onPressed: () {
                          _selectTime(context);
                        },
                        child: const Text('Select Time'),
                      ),
                    ),
                    const SizedBox(width: 10,),
                    if (selectedTime != null)
                      Flexible(
                        flex: 2,
                        child: Text(
                          'Selected Time: ${selectedTime!.format(context)}',
                          style: TextStyle(fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    const SizedBox(width: 15,),
                  ],
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: docNameController,
                  validator: (value){
                    value!.isEmpty?"Enter Doctor Name":null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Please Enter Doctor Name',
                    contentPadding: isMobile ? const EdgeInsets.all(10) : const EdgeInsets.all(16),
                  ),
                ),

                const SizedBox(height: 10,),

                Row(
                  children: [
                    const SizedBox(width: 10,),
                    const Flexible(
                      flex: 3,
                      child: Text('Online Meeting:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
                    Flexible(
                      flex: 2,
                      child: Switch(
                        value: isOnlineMeeting,
                        onChanged: (value) {
                          setState(() {
                            isOnlineMeeting = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Flexible(
                      flex: 4,
                      child: TextFormField(
                        controller: emailCCController,
                        validator: (value){
                            value!.isEmpty?"Please enter email-cc":null;
                        },
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Enter Email CC',
                          contentPadding: isMobile ? const EdgeInsets.all(10) : const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      dateIsValid = selectedDate != null;
                      timeIsValid = selectedTime != null;
                      docNameIsValid = docNameController.text.isNotEmpty;
                      emailCCIsValid = emailCCController.text.isNotEmpty;

                      if (dateIsValid && timeIsValid && docNameIsValid && emailCCIsValid) {
                        createSchedule();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            backgroundColor: Colors.redAccent,
                            content: Text("All the details are Mandatory!", style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 17, color: Colors.white,
                            ), textAlign: TextAlign.center,)));
                      }
                    },
                    child: Text('Add Schedule', style: TextStyle(fontWeight: FontWeight.w500, fontSize: isMobile ? 16 : 18)),
                  ),
                ),

                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Upcoming Schedules :',
                    style: TextStyle(fontSize: isMobile ? 16 : 19, fontWeight: FontWeight.w500, color: Colors.black),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: schedules.isNotEmpty
                        ? Row(
                      children: schedules.map((schedule) {
                        return Card(
                          elevation: 6,
                          margin: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            width: isMobile ? 300 : isTablet ? 400 : 300,
                            height: isMobile ? 300 : isTablet ? 400 : 260,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date: ${schedule['date']}',
                                  style: TextStyle(fontSize: isMobile ? 14 : 15, fontWeight: FontWeight.w500, color: Colors.black),
                                ),
                                Text(
                                  'Time: ${schedule['time']}',
                                  style: TextStyle(fontSize: isMobile ? 14 : 15, fontWeight: FontWeight.w500, color: Colors.black),
                                ),
                                Text(
                                  'Doctor Name: ${schedule['doc_name']}',
                                  style: TextStyle(fontSize: isMobile ? 14 : 15, fontWeight: FontWeight.w500, color: Colors.black),
                                ),
                                Text(
                                  'Online Meeting: ${schedule['online_meeting']}',
                                  style: TextStyle(fontSize: isMobile ? 14 : 15, fontWeight: FontWeight.w500, color: Colors.black),
                                ),
                                Text(
                                  'Email CC: ${schedule['email_cc']}',
                                  style: TextStyle(fontSize: isMobile ? 14 : 15, fontWeight: FontWeight.w500, color: Colors.black),
                                ),
                                const SizedBox(height: 30),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    editSchedule(schedule);
                                  },
                                  icon: const Icon(Icons.edit, size: 19),
                                  label: Text("Edit", style: TextStyle(fontSize: isMobile ? 14 : 16)),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                        title: Text(
                                          "Are you sure you want to delete the data?",
                                          style: TextStyle(color: Colors.black, fontSize: isMobile ? 16 : 19, fontWeight: FontWeight.w500),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                deleteSchedule(schedule['id']);
                                              });
                                              Navigator.of(context).pop();
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                  backgroundColor: Colors.indigo,
                                                  content: Text("Data has been deleted successfully!", style: TextStyle(
                                                    fontWeight: FontWeight.w400, fontSize: 15, color: Colors.white,
                                                  ), textAlign: TextAlign.center,)));
                                            },
                                            child: Text('Yes', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w600, fontSize: isMobile ? 16 : 20)),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('No', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w600, fontSize: isMobile ? 16 : 20)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.delete, size: 19),
                                  label: Text("Delete", style: TextStyle(fontSize: isMobile ? 16 : 19)),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    )
                        : Align(
                        alignment: Alignment.center,
                        child: Text("No Data Found!", style: TextStyle(fontSize: isMobile ? 18 : 20, fontWeight: FontWeight.w500, color: Colors.black54),)),
                  ),
                )

              ],
            );
          },
        )
      ),
    );
  }
}

