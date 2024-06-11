import 'package:doctor_appointment_app/API/ApiConnect.dart';
import 'package:doctor_appointment_app/Model/Booking.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AppointmentCard extends StatefulWidget {
  const AppointmentCard(
      {Key? key,
      required this.nama,
      required this.category,
      required this.id,
      required this.date,
      required this.time,
      required this.foto})
      : super(key: key);

  final String foto;
  final String nama;
  final String category;
  final String id;
  final String date;
  final String time;

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Config.primaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.foto),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.nama,
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        widget.category,
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ],
              ),
              Config.spaceSmall,
              ScheduleCard(
                date: widget.date,
                time: widget.time,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        update("Cancel");
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        'Completed',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        update("Complete");
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> update(String status) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConnect.updatestatus),
        body: {
          "id_booking": widget.id,
          "status": status,
        },
      );
      print(response.statusCode);
      print(widget.id);

      if (response.statusCode == 200) {
        Navigator.of(context).pushNamed('main');
      } else {
        print('Failed to load absen data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}

class ScheduleCard extends StatelessWidget {
  ScheduleCard({
    Key? key,
    required this.date,
    required this.time,
  }) : super(key: key);

  final String date;
  final String time;

  @override
  Widget build(BuildContext context) {
    DateTime dates = DateTime.parse(date); // Konversi string menjadi DateTime
    String formattedDate = DateFormat('EEEE, dd-MM-yyyy')
        .format(dates); // Format tanggal sesuai keinginan

    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.calendar_today,
            color: Color.fromARGB(255, 0, 0, 0),
            size: 15,
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            formattedDate, // Gunakan formattedDate di sini
            style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
          ),
          SizedBox(
            width: 20,
          ),
          const Icon(
            Icons.access_alarm,
            color: Color.fromARGB(255, 0, 0, 0),
            size: 17,
          ),
          const SizedBox(
            width: 5,
          ),
          Flexible(
            child: Text(
              time,
              style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
            ),
          )
        ],
      ),
    );
  }
}
