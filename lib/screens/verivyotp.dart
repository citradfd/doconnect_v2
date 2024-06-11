import 'package:doctor_appointment_app/API/ApiConnect.dart';
import 'package:doctor_appointment_app/components/button.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'reset_password_page.dart'; // Tambahkan import untuk halaman reset password

class VerifyOTPPage extends StatefulWidget {
  final String email;

  VerifyOTPPage({required this.email});

  @override
  _VerifyOTPPageState createState() => _VerifyOTPPageState();
}

class _VerifyOTPPageState extends State<VerifyOTPPage> {
  TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyOTP() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse(ApiConnect.verivyotp),
      body: {
        'email': widget.email,
        'otp': _otpController.text,
      },
    );

    final responseData = json.decode(response.body);
    if (responseData['success']) {
      // OTP verified, navigate to reset password page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ResetPasswordPage(email: widget.email)),
      );
      //  ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('OTP Verified!')),
      // );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData['message'])),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.emailAddress,
              cursorColor: Config.primaryColor,
              decoration: const InputDecoration(
                hintText: 'OTP',
                labelText: 'OTP Code',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.code),
                prefixIconColor: Config.primaryColor,
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : Button(
                    width: double.infinity,
                    title: 'Verify OTP',
                    onPressed: () {
                      _verifyOTP();
                    },
                    disable: false,
                  )
          ],
        ),
      ),
    );
  }
}
