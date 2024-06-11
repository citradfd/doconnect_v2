import 'package:doctor_appointment_app/API/ApiConnect.dart';
import 'package:doctor_appointment_app/Model/Booking.dart';
import 'package:doctor_appointment_app/components/button.dart';
import 'package:doctor_appointment_app/components/custom_appbar.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BookingPage extends StatefulWidget {
  BookingPage({Key? key, required this.id_doctor}) : super(key: key);
  final String id_doctor;

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  CalendarFormat _format = CalendarFormat.month;
  DateTime _focusDay = DateTime.now();
  DateTime _currentDay = DateTime.now();
  int? _currentIndex;
  bool _isWeekend = false;
  bool _dateSelected = false;
  bool _timeSelected = false;
  List<String> _usedTimes = [];
  List<String> _times = [
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM'
  ];

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return Scaffold(
      appBar: CustomAppBar(
        appTitle: 'Appointment',
        icon: const FaIcon(Icons.arrow_back_ios),
          route: 'main',
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                _tableCalendar(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                  child: Center(
                    child: Text(
                      'Select Consultation Time',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          _isWeekend
              ? SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 30),
                    alignment: Alignment.center,
                    child: const Text(
                      'Weekend is not available, please select another date',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              : SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      String time = _times[index];
                      bool isDisabled = _usedTimes.contains(time);

                      return InkWell(
                        splashColor: Colors.transparent,
                        onTap: isDisabled
                            ? null
                            : () {
                                setState(() {
                                  _currentIndex = index;
                                  _timeSelected = true;
                                });
                              },
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _currentIndex == index
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            color: _currentIndex == index
                                ? Config.primaryColor
                                : isDisabled
                                    ? Colors.grey
                                    : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            time,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _currentIndex == index
                                  ? Colors.white
                                  : isDisabled
                                      ? Colors.black38
                                      : null,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: _times.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, childAspectRatio: 1.5),
                ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 80),
              child: Button(
                width: double.infinity,
                title: 'Make Appointment',
                onPressed: () {
                  if (_dateSelected && _timeSelected) {
                    _makeBooking();
                  }
                },
                disable: !_timeSelected || !_dateSelected,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableCalendar() {
    return TableCalendar(
      focusedDay: _focusDay,
      firstDay: DateTime.now(),
      lastDay: DateTime(2024, 12, 31),
      calendarFormat: _format,
      currentDay: _currentDay,
      rowHeight: 48,
      calendarStyle: const CalendarStyle(
        todayDecoration:
            BoxDecoration(color: Config.primaryColor, shape: BoxShape.circle),
      ),
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
      },
      onFormatChanged: (format) {
        setState(() {
          _format = format;
        });
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _currentDay = selectedDay;
          _focusDay = focusedDay;
          _dateSelected = true;
          if (selectedDay.weekday == 6 || selectedDay.weekday == 7) {
            _isWeekend = true;
            _timeSelected = false;
            _currentIndex = null;
          } else {
            _isWeekend = false;
            _getJadwal(selectedDay);
          }
        });
      },
    );
  }

  Future<void> _getJadwal(DateTime date) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConnect.getjadwal),
        body: {
          'id_doctor': widget.id_doctor,
          'date': date
              .toIso8601String()
              .split('T')[0], // Format tanggal menjadi YYYY-MM-DD
        },
      );

      if (response.statusCode == 200) {
        print(response.statusCode);
        print(response.body);
        var data = jsonDecode(response.body);

        if (data['success']) {
          setState(() {
            _usedTimes = List<String>.from(data['data']);
          });
        } else {
          print('Failed to load schedule data');
        }
      } else {
        print('Failed to load schedule data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _makeBooking() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id_user = prefs.getString('user_id');

    if (id_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConnect.booking),
        body: {
          'date': _currentDay.toIso8601String().split('T')[0],
          'time': _times[_currentIndex!],
          'id_user': id_user,
          'id_doctor': widget.id_doctor,
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Booking berhasil ditambahkan')),
          );
          Navigator.of(context).pushNamed('success_booking');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Gagal menambahkan booking: ${data['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan booking')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
