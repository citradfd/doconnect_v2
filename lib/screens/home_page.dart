import 'package:doctor_appointment_app/API/ApiConnect.dart';
import 'package:doctor_appointment_app/Model/Booking.dart';
import 'package:doctor_appointment_app/Model/Doctor.dart';
import 'package:doctor_appointment_app/components/appointment_card.dart';
import 'package:doctor_appointment_app/components/doctor_card.dart';
import 'package:doctor_appointment_app/screens/update_profile.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> medCat = [
    {
      "icon": FontAwesomeIcons.userDoctor,
      "category": "General",
    },
    {
      "icon": FontAwesomeIcons.heartPulse,
      "category": "Cardiology",
    },
    {
      "icon": FontAwesomeIcons.lungs,
      "category": "Respirations",
    },
    {
      "icon": FontAwesomeIcons.hand,
      "category": "Dermatology",
    },
    {
      "icon": FontAwesomeIcons.personPregnant,
      "category": "Gynecology",
    },
    {
      "icon": FontAwesomeIcons.teeth,
      "category": "Dental",
    },
  ];

  List<Docter> _docterList = []; // List to store data
  List<Booking> _bookingList = []; // List to store data
  String? selectedCategory; // Variable to store selected category
  bool isLoading = true; // State to track loading status

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await getDocter();
    await getNewBooking();
    setState(() {
      isLoading = false; // Set loading to false when data is loaded
    });
  }

  // Function to filter doctors based on selected category
  List<Docter> _filterDoctors() {
    if (selectedCategory == null) {
      return _docterList; // If no category selected, return all doctors
    } else {
      // If category selected, filter doctors by category
      return _docterList
          .where((doctor) => doctor.category == selectedCategory)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        child: SafeArea(
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator()) // Show loading indicator
              : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            _bookingList.isNotEmpty
                                ? _bookingList[0].namaUser.toString()
                                : '',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfilePage()),
                                );
                              },
                              child: CircleAvatar(
                                radius: 30,
                                backgroundImage: _bookingList.isNotEmpty &&
                                        _bookingList[0].fotoUser != null
                                    ? NetworkImage(
                                        _bookingList[0].fotoUser.toString())
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Config.spaceMedium,
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Config.spaceSmall,
                      SizedBox(
                        height: Config.heightSize * 0.05,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children:
                              List<Widget>.generate(medCat.length, (index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategory = medCat[index]['category'];
                                });
                              },
                              child: Card(
                                margin: const EdgeInsets.only(right: 20),
                                color: Config.primaryColor,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      FaIcon(
                                        medCat[index]['icon'],
                                        color: Colors.white,
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        medCat[index]['category'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      Config.spaceSmall,
                      const Text(
                        'Today\'s Appointment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Config.spaceSmall,
                      _bookingList.isNotEmpty && _bookingList[0].foto != null
                          ? AppointmentCard(
                              id: _bookingList[0].idBooking.toString(),
                              nama: _bookingList[0].nama.toString(),
                              category: _bookingList[0].category.toString(),
                              foto: _bookingList[0].foto.toString(),
                              date: _bookingList[0].date.toString(),
                              time: _bookingList[0].time.toString(),
                            )
                          : Text(
                              "Nothing",
                              textAlign: TextAlign.center,
                            ),
                      // Jika _bookingList kosong, gunakan SizedBox() atau widget lain sebagai penggantinya

                      Config.spaceSmall,
                      const Text(
                        'Top Doctors',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Config.spaceSmall,
                      Column(
                        children:
                            List.generate(_filterDoctors().length, (index) {
                          final doctor = _filterDoctors()[index];
                          return DoctorCard(
                            nama: doctor.nama.toString(),
                            foto: doctor.foto.toString(),
                            id: doctor.id.toString(),
                            category: doctor.category.toString(),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> getDocter() async {
    try {
      final response = await http.get(Uri.parse(ApiConnect.getdoctor));

      if (response.statusCode == 200) {
        List<dynamic> docterListJson = jsonDecode(response.body)[0];
        List<Docter> docterList = docterListJson
            .map((docterJson) => Docter.fromJson(docterJson))
            .toList();
        setState(() {
          _docterList = docterList;
        });
      } else {
        print('Failed to load absen data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> getNewBooking() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    try {
      final response = await http.post(
        Uri.parse(ApiConnect.getbookingnew),
        body: {"id_user": userId},
      );

      if (response.statusCode == 200) {
        List<dynamic> bookingListJson = jsonDecode(response.body);
        List<Booking> bookingList = bookingListJson
            .map((bookingJson) => Booking.fromJson(bookingJson))
            .toList();
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
