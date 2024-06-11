import 'package:doctor_appointment_app/API/ApiConnect.dart';
import 'package:doctor_appointment_app/Model/User.dart';
import 'package:doctor_appointment_app/components/button.dart';
import 'package:doctor_appointment_app/components/custom_appbar.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LogoutPage extends StatefulWidget {
  const LogoutPage({Key? key}) : super(key: key);

  @override
  State<LogoutPage> createState() => _LogoutPageState();
}

class _LogoutPageState extends State<LogoutPage> {
  List<Users> _userList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appTitle: 'Profile',
        icon: const FaIcon(Icons.arrow_back_ios),
        route: 'main',
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: <Widget>[
                  if (_userList.isNotEmpty) ...[
                    AboutUser(
                      foto: _userList[0].foto.toString(),
                      nama: _userList[0].nama.toString(),
                      email: _userList[0].email.toString(),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Button(
                        width: double.infinity,
                        title: 'Log Out',
                        onPressed: () async {
                          _logout();
                          Navigator.of(context).pushNamed('/');
                        },
                        disable: false,
                      ),
                    ),
                  ] else
                    Text("No user data available"),
                ],
              ),
            ),
    );
  }

  Future<void> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    try {
      final response = await http.post(
        Uri.parse(ApiConnect.getuser),
        body: {'user_id': userId},
      );

      if (response.statusCode == 200) {
        print(response.statusCode);
        print(response.body);
        List<dynamic> outerList = jsonDecode(response.body);

        List<Users> userList =
            outerList.map((userJson) => Users.fromJson(userJson)).toList();

        setState(() {
          _userList = userList;
          isLoading = false;
        });
      } else {
        print('Failed to load user data');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Menghapus semua data dari session
  }
}

class AboutUser extends StatelessWidget {
  AboutUser({
    Key? key,
    required this.foto,
    required this.nama,
    required this.email,

  }) : super(key: key);

  final String foto;
  final String nama;
  final String email;


  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return Container(
      width: double.infinity,
      child: Column(
        children: <Widget>[
          CircleAvatar(
            radius: 65.0,
            backgroundImage: NetworkImage(foto),
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
              email,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 17,
              ),
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ),
          Config.spaceSmall,

        ],
      ),
    );
  }
}
