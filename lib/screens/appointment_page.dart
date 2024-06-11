import 'package:doctor_appointment_app/API/ApiConnect.dart';
import 'package:doctor_appointment_app/Model/Booking.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({Key? key}) : super(key: key);

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

enum FilterStatus { Upcoming, Complete, Cancel }

class _AppointmentPageState extends State<AppointmentPage> {
  FilterStatus status = FilterStatus.Upcoming;
  Alignment _alignment = Alignment.centerLeft;
  List<Booking> _bookingList = []; // List to store data
  String? selectedCategory; // Variable to store selected category

  @override
  void initState() {
    super.initState();
    getBooking();
  }

  @override
  Widget build(BuildContext context) {
    List<Booking> filteredSchedules = _filterSchedules();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Appointment Schedule',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Config.spaceSmall,
            Config.spaceSmall,
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //this is the filter tabs
                      for (FilterStatus filterStatus in FilterStatus.values)
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                status = filterStatus;
                                _alignment = status == FilterStatus.Upcoming
                                    ? Alignment.centerLeft
                                    : status == FilterStatus.Complete
                                        ? Alignment.center
                                        : Alignment.centerRight;
                              });
                            },
                            child: Center(
                              child:
                                  Text(filterStatus.toString().split('.').last),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                AnimatedAlign(
                  alignment: _alignment,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 100,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Config.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        status.toString().split('.').last,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Config.spaceSmall,
            Expanded(
              child: ListView.builder(
                itemCount: filteredSchedules.length,
                itemBuilder: ((context, index) {
                  var _schedule = filteredSchedules[index];
                  bool isLastElement = filteredSchedules.length + 1 == index;
                  return Card(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: !isLastElement
                        ? const EdgeInsets.only(bottom: 20)
                        : EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    NetworkImage(_schedule.foto.toString()),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _schedule.nama.toString(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    _schedule.category.toString(),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          const ScheduleCard(),
                          const SizedBox(
                            height: 15,
                          ),
                          if (status != FilterStatus.Complete &&
                              status != FilterStatus.Cancel)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      update('Cancel',
                                          _schedule.idBooking.toString());
                                    },
                                    child: Text(
                                      'Cancel',
                                      style:
                                          TextStyle(color: Config.primaryColor),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Config.primaryColor,
                                    ),
                                    onPressed: () {
                                      update('Complate',
                                          _schedule.idBooking.toString());
                                    },
                                    child: const Text(
                                      'Complete',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> update(String status, String id) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConnect.updatestatus),
        body: {
          "id_booking": id,
          "status": status,
        },
      );
      print(response.statusCode);
      print(id);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update Berhasil!'),
            backgroundColor: Colors.green,
          ),
        );
        await getBooking();
      } else {
        print('Failed to load absen data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  List<Booking> _filterSchedules() {
    return _bookingList.where((booking) {
      switch (status) {
        case FilterStatus.Upcoming:
          return booking.status == 'Upcoming';
        case FilterStatus.Complete:
          return booking.status == 'Complete'; // Ubah nilai pembanding
        case FilterStatus.Cancel:
          return booking.status == 'Cancel';
        default:
          return false;
      }
    }).toList();
  }

  Future<void> getBooking() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    try {
      final response = await http.post(
        Uri.parse(ApiConnect.getbookingn),
        body: {"id_user": userId},
      );

      if (response.statusCode == 200) {
        List<dynamic> bookingListJson = jsonDecode(response.body);
        List<Booking> bookingList = [];

        // Iterasi melalui daftar luar
        for (var bookingJson in bookingListJson) {
          // Iterasi melalui daftar dalam
          for (var bookingData in bookingJson) {
            Booking booking = Booking.fromJson(bookingData);
            bookingList.add(booking);
          }
        }

        setState(() {
          _bookingList = bookingList;
        });
      } else {
        print('Failed to load absen data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const <Widget>[
          Icon(
            Icons.calendar_today,
            color: Colors.black,
            size: 15,
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            'Monday, 11/28/2022',
            style: TextStyle(color: Colors.black),
          ),
          SizedBox(
            width: 20,
          ),
          Icon(
            Icons.access_alarm,
            color: Colors.black,
            size: 17,
          ),
          SizedBox(
            width: 5,
          ),
          Flexible(
            child: Text(
              '2:00 PM',
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      ),
    );
  }
}
