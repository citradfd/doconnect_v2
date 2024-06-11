import 'package:doctor_appointment_app/API/ApiConnect.dart';
import 'package:doctor_appointment_app/Model/Doctor.dart';
import 'package:doctor_appointment_app/screens/booking_page.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../components/button.dart';
import '../components/custom_appbar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DoctorDetails extends StatefulWidget {
  DoctorDetails({Key? key, required this.id}) : super(key: key);
  String id;

  @override
  State<DoctorDetails> createState() => _DoctorDetailsState();
}

class _DoctorDetailsState extends State<DoctorDetails> {
  List<Docter> _docterList = [];
  bool isFav = false;

  @override
  void initState() {
    super.initState();
    getDocter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appTitle: 'Doctor Details',
        icon: const FaIcon(Icons.arrow_back_ios),
        route: 'main',
        actions: [
          // IconButton(
          //   onPressed: () {
          //     setState(() {
          //       isFav = !isFav;
          //     });
          //   },
          //   icon: FaIcon(
          //     isFav ? Icons.favorite_rounded : Icons.favorite_outline,
          //     color: Colors.red,
          //   ),
          // )
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              if (_docterList
                  .isNotEmpty) // Tambahkan pengecekan apakah _docterList tidak kosong
                AboutDoctor(
                  foto: _docterList[0].foto.toString(),
                  fakultas: _docterList[0].fakultas.toString(),
                  rumahsakit: _docterList[0].rumahsakit.toString(),
                  nama: _docterList[0].nama.toString(),
                ),
              DetailBody(
                about: _docterList.isNotEmpty
                    ? _docterList[0].about.toString()
                    : '', // Tambahkan pengecekan untuk setiap elemen
                patiens: _docterList.isNotEmpty
                    ? _docterList[0].patiens.toString()
                    : '', // Tambahkan pengecekan untuk setiap elemen
                category: _docterList.isNotEmpty
                    ? _docterList[0].category.toString()
                    : '', // Tambahkan pengecekan untuk setiap elemen
                experience: _docterList.isNotEmpty
                    ? _docterList[0].experiences.toString()
                    : '', // Tambahkan pengecekan untuk setiap elemen
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Button(
                  width: double.infinity,
                  title: 'Book Appointment',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingPage(
                          id_doctor: _docterList.isNotEmpty
                              ? _docterList[0].id.toString()
                              : '',
                        ),
                      ),
                    );
                  },
                  disable: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getDocter() async {
    try {
      final response = await http
          .post(Uri.parse(ApiConnect.getdoctordetail), body: {'id': widget.id});

      if (response.statusCode == 200) {
        print(response.statusCode);
        print(response.body);
        List<dynamic> outerList =
            jsonDecode(response.body); // Parse the outer list
        List<dynamic> doctorListJson = outerList.isNotEmpty
            ? outerList[0]
            : []; // Access the first element of the outer list

        List<Docter> doctorList = [];

        // Convert each item in the list to a Doctor object
        for (var doctorJson in doctorListJson) {
          Docter doctor = Docter.fromJson(doctorJson);
          doctorList.add(doctor);
        }

        setState(() {
          _docterList = doctorList;
        });
      } else {
        print('Failed to load absen data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}

class AboutDoctor extends StatelessWidget {
  AboutDoctor({
    Key? key,
    required this.foto,
    required this.nama,
    required this.fakultas,
    required this.rumahsakit,
  }) : super(key: key);
  String foto;
  String nama;
  String fakultas;
  String rumahsakit;

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return Container(
      width: double.infinity,
      child: Column(
        children: <Widget>[
          CircleAvatar(
            radius: 65.0,
            backgroundImage: NetworkImage(foto), // Directly use the URL string
            backgroundColor: Colors.white,
          ),
          Config.spaceMedium,
          Text(
            nama,
            style: TextStyle(
              color: Colors.black,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Config.spaceSmall,
          SizedBox(
            width: Config.widthSize * 0.75,
            child: Text(
              fakultas,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ),
          Config.spaceSmall,
          SizedBox(
            width: Config.widthSize * 0.75,
            child: Text(
              rumahsakit,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class DetailBody extends StatelessWidget {
  DetailBody({
    Key? key,
    required this.about,
    required this.patiens,
    required this.experience,
    required this.category,
  }) : super(key: key);

  final String about;
  final String patiens;
  final String experience;
  final String category;

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Config.spaceSmall,
          DoctorInfo(
            patiens: patiens,
            category: category,
            experience: experience,
          ),
          Config.spaceMedium,
          const Text(
            'About Doctor',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          Config.spaceMedium,
          Text(
            about,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
            softWrap: true,
            textAlign: TextAlign.justify,
          )
        ],
      ),
    );
  }
}

class DoctorInfo extends StatelessWidget {
  DoctorInfo(
      {Key? key,
      required this.patiens,
      required this.experience,
      required this.category})
      : super(key: key);
  String patiens;
  String experience;
  String category;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        InfoCard(
          label: 'Patients',
          value: patiens,
        ),
        SizedBox(
          width: 15,
        ),
        InfoCard(
          label: 'Experiences',
          value: experience,
        ),
        SizedBox(
          width: 15,
        ),
        InfoCard(
          label: 'Category',
          value: category,
        ),
      ],
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({Key? key, required this.label, required this.value})
      : super(key: key);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Config.primaryColor,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 30,
          horizontal: 15,
        ),
        child: Column(
          children: <Widget>[
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}