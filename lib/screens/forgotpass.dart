import 'package:doctor_appointment_app/API/ApiConnect.dart';
import 'package:doctor_appointment_app/components/button.dart';
import 'package:doctor_appointment_app/screens/verivyotp.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendOTP() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse(ApiConnect.otp),
      body: {
        'email': _emailController.text,
      },
    );

    final responseData = json.decode(response.body);
    if (responseData['success']) {
      // Navigate to OTP verification page
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VerifyOTPPage(email: _emailController.text)),
      );
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
        title: Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
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
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : Button(
                    width: double.infinity,
                    title: 'Send OTP',
                    onPressed: () {
                      _sendOTP();
                    },
                    disable: false,
                  )
          ],
        ),
      ),
    );
  }
}
