import 'dart:io';
import 'package:doctor_appointment_app/API/ApiConnect.dart';
import 'package:doctor_appointment_app/components/button.dart';
import 'package:doctor_appointment_app/components/custom_appbar.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  bool obsecurePass = true;
  bool isFav = false;
  File? fotos;
  String? _foto;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          appTitle: 'Profile',
          icon: const FaIcon(Icons.arrow_back_ios),
          route: 'main',
        ),
        body: SafeArea(
            child: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: <Widget>[
                  Stack(children: [
                    CircleAvatar(
                      radius: 65.0,
                      backgroundImage: fotos != null
                          ? FileImage(fotos!)
                          : (_foto != null && _foto!.isNotEmpty
                                  ? NetworkImage(_foto!)
                                  : NetworkImage(
                                      'https://t4.ftcdn.net/jpg/04/83/90/95/360_F_483909569_OI4LKNeFgHwvvVju60fejLd9gj43dIcd.jpg'))
                              as ImageProvider,
                      backgroundColor: Colors.white,
                    ),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                            onPressed: () {
                              _potoBottomSheet();
                            },
                            icon: Icon(
                              Icons.photo_camera,
                              color: Config.primaryColor,
                              size: 30,
                            )))
                  ]),
                  Config.spaceMedium,
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: Config.primaryColor,
                    decoration: const InputDecoration(
                      hintText: 'Email Address',
                      labelText: 'Email',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.email_outlined),
                      prefixIconColor: Config.primaryColor,
                    ),
                  ),
                  Config.spaceSmall,
                  TextFormField(
                    controller: _namaController,
                    keyboardType: TextInputType.text,
                    cursorColor: Config.primaryColor,
                    decoration: const InputDecoration(
                      hintText: 'Nama',
                      labelText: 'Nama',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.people_alt_outlined),
                      prefixIconColor: Config.primaryColor,
                    ),
                  ),
                  Config.spaceSmall,
                  TextFormField(
                    controller: _passController,
                    keyboardType: TextInputType.visiblePassword,
                    cursorColor: Config.primaryColor,
                    obscureText: obsecurePass,
                    decoration: InputDecoration(
                        hintText: 'Password',
                        labelText: 'Password',
                        alignLabelWithHint: true,
                        prefixIcon: const Icon(Icons.lock_outline),
                        prefixIconColor: Config.primaryColor,
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obsecurePass = !obsecurePass;
                              });
                            },
                            icon: obsecurePass
                                ? const Icon(
                                    Icons.visibility_off_outlined,
                                    color: Colors.black38,
                                  )
                                : const Icon(
                                    Icons.visibility_outlined,
                                    color: Config.primaryColor,
                                  ))),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Button(
                      width: double.infinity,
                      title: 'Save',
                      onPressed: () {
                        updateUserProfile();
                      },
                      disable: false,
                    ),
                  ),
                ],
              )),
        )));
  }

  Future<void> fetchUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId == null) {
      Navigator.pushReplacementNamed(context, '/');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConnect.getuser),
        body: {"user_id": userId},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data is List && data.isNotEmpty) {
          final userData = data[0];
          if (userData != null && userData is Map<String, dynamic>) {
            // Set nilai controller
            _namaController.text = userData['nama'] ?? '';
            _emailController.text = userData['email'] ?? '';
            _passController.text = userData['password'] ?? '';

            setState(() {
              _foto = userData['foto'];
            });
          }
        }
      } else {
        print('Gagal mengambil data profil: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> updateUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId == null) {
      Navigator.pushReplacementNamed(context, '/');
      return;
    }

    try {
      final uri = Uri.parse(ApiConnect.updateuser);

      final request = http.MultipartRequest('POST', uri)
        ..fields['id'] = userId
        ..fields['nama'] = _namaController.text
        ..fields['email'] = _emailController.text
        ..fields['password'] = _passController.text;

      // Jika ada gambar yang dipilih, tambahkan gambar ke request
      if (fotos != null) {
        final file = await http.MultipartFile.fromPath('foto', fotos!.path);
        request.files.add(file);
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update profile berhasil!'),
            backgroundColor: Colors.green,
          ),
        );

        // Jika penyimpanan berhasil, lanjutkan dengan navigasi
        Navigator.of(context).pushNamed('main');
        // Handle response jika diperlukan
        print('Berhasil mengupdate profil');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengupdate profil: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
        print('Gagal mengupdate profil: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> getImageGallery() async {
    var galleryPermission = await Permission.storage.request();

    if (galleryPermission.isGranted) {
      final ImagePicker picker = ImagePicker();
      final imagePicked = await picker.pickImage(source: ImageSource.gallery);
      setState(() {
        fotos = File(imagePicked?.path ?? "");
      });
    } else {
      // Handle denied or revoked permissions
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Permission Error'),
          content: Text('Please grant storage permission to continue'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> getImageCamera() async {
    final ImagePicker picker = ImagePicker();
    final imagePicked = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      fotos = File(imagePicked!.path);
    });
  }

  Future _potoBottomSheet() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              height: 200,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ListTile(
                    onTap: () async {
                      await getImageGallery();
                      Navigator.pop(context);
                    },
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.blue.withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.image,
                        color: Colors.blue,
                      ),
                    ),
                    title: Text("Upload dari Galeri",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF454444),
                        )),
                    trailing: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.grey.shade200,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.blue,
                        size: 15,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: () async {
                      await getImageCamera();
                      Navigator.pop(context);
                    },
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.blue.withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.blue,
                      ),
                    ),
                    title: Text("Upload dari Kamera",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF454444),
                        )),
                    trailing: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.grey.shade200,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.blue,
                        size: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
