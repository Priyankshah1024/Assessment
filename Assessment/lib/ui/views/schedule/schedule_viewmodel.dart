import 'dart:async';
import 'dart:convert';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../../app/locator.dart';

enum DialogType { custom, alert, simple}

class ScheduleViewModel extends BaseViewModel{
  final DialogService _dialogService = locator<DialogService>();
  final BuildContext context;

  ScheduleViewModel(this.context) {
    fetchData();
  }

  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController docNameController = TextEditingController();
  final TextEditingController emailCCController = TextEditingController();
  final TextEditingController onlineMeetingController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  List<Map<String, dynamic>> schedules = [];
  bool isOnlineMeeting = false;

  final List<String> onlineMeetingOptions = ['0', '1'];
  String? selectedOnlineMeeting;
  PageController pageController = PageController(initialPage: 0);
  bool dateIsValid = true;
  bool timeIsValid = true;
  bool docNameIsValid = true;
  bool emailCCIsValid = true;

  FutureOr<void> createSchedule() async {
    final Uri url = Uri.parse('https://showdigital.in/flutter-schedules/create_schedule.php');

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
              notifyListeners(); // Use notifyListeners to trigger UI update
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

  FutureOr<void> updateSchedule(Map<String, dynamic> updatedData) async {
    const url = 'https://showdigital.in/flutter-schedules/update_schedule.php';
    final response =
    await http.put(Uri.parse(url), body: jsonEncode(updatedData));
    if (response.statusCode != 200) {
      throw Exception('Failed to update schedule');
    }
  }

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
                        var selected = await selectDate(context);
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
                                // title: Text('Selected Date'),
                                title: Text('You have selected the date: ${dateController.text}'),
                                actions: <Widget>[
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('OK', style: TextStyle(
                                      fontSize: 17,
                                    ),
                                    ),
                                  ),
                                ]));

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
                        var selected = await selectTime(context);
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
                                // title: Text('Selected Date'),
                                title: Text('You have selected the time: ${timeController.text}'),
                                actions: <Widget>[
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('OK', style: TextStyle(
                                      fontSize: 17,
                                    ),
                                    ),
                                  ),
                                ]));
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
    schedules = fetchedData;
    notifyListeners();
  }

  void handleScheduleUpdate(Map<String, dynamic> updatedSchedule) {
    final index = schedules.indexWhere((s) => s['id'] == updatedSchedule['id']);
    if (index != -1) {
      schedules[index] = updatedSchedule;
      notifyListeners();
    }
  }

  FutureOr<void> deleteSchedule(String id) async {
    final url = 'https://showdigital.in/flutter-schedules/delete_schedule.php?id=$id';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      fetchData();
    } else {
      print('Delete request error - Status code: ${response.statusCode}');
    }
    return null;
  }

  FutureOr<DateTime?> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      selectedDate = picked;
      dateController.text = "${picked.year}-${picked.month}-${picked.day}";
      notifyListeners();
    }
    return picked;
  }

  FutureOr<TimeOfDay?> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      selectedTime = picked;
      timeController.text = picked.format(context);
      notifyListeners();
    }
    return picked;
  }

  void resetFormFields() {
    selectedDate = null;
    selectedTime = null;
    selectedOnlineMeeting = null;
    docNameController.clear();
    emailCCController.clear();
    notifyListeners();
  }

}
