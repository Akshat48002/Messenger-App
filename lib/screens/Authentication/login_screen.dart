import 'dart:developer';
import 'dart:io';
import 'package:chat_on/main.dart';
import 'package:chat_on/screens/Authentication/signup_screen.dart';
import 'package:chat_on/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../DataConfig/apis.dart';
import '../../Others/dialogs.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isAnimate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleGoogleButtonClick() {
    Dialogs.showProgressBar(context);

    _signInWithGoogle().then((user) async {
      Navigator.pop(context);

      if (user != null) {
        log("\nUser : ${user.user}");
        log('\nUserAdditionalInfo : ${user.additionalUserInfo}');

        if ((await APIs.userExists())) {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
          APIs.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('\n_signInWithGoogle : $e');
      Dialogs.showSnackBar(context, 'Something Went Wrong (Check Internet!)');
      return null;
    }
  }

  void _loginWithEmailAndPassword() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    try {
      Dialogs.showProgressBar(context);
      // ignore: unused_local_variable
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context);

      // Check if the user exists and navigate accordingly
      if ((await APIs.userExists())) {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        // Create user if it doesn't exist
        APIs.createUser().then((value) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        });
      }
    } catch (e) {
      log('\n_loginWithEmailAndPassword : $e');
      Dialogs.showSnackBar(
          context, 'Login failed. Please check your credentials.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color.fromARGB(255, 246, 224, 181),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Welcome to ChatOn'),
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              reverse: true,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                          top: mq.height * .03,
                          right: _isAnimate ? mq.width * .36 : -mq.width * 0.5,
                          width: mq.width * .25,
                          duration: const Duration(seconds: 1),
                          child: Image.asset('images/wechat.png')),
                      Positioned(
                          bottom: mq.height * .65,
                          left: mq.width * .2,
                          width: mq.width * .6,
                          height: mq.height * .06,
                          child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 195, 227, 195),
                                  shape: const StadiumBorder(),
                                  elevation: 4),
                              onPressed: () {
                                _handleGoogleButtonClick();
                              },
                              icon: Image.asset(
                                'images/search.png',
                                height: mq.height * .03,
                              ),
                              label: RichText(
                                text: const TextSpan(
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16),
                                    children: [
                                      TextSpan(text: 'Login with '),
                                      TextSpan(
                                          text: 'Google',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500))
                                    ]),
                              ))),
                      Positioned(
                          bottom: mq.height * .58,
                          left: mq.width * .46,
                          height: mq.height * .06,
                          child: const Text(
                            "OR",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )),
                      Positioned(
                        bottom: mq.height * .32,
                        left: mq.width * .1,
                        width: mq.width * .8,
                        child: Form(
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  labelText: 'Email',
                                ),
                                keyboardType: TextInputType.emailAddress,
                                // Add email validation logic
                              ),
                              SizedBox(height: mq.height * .01),
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                ),
                                obscureText: true,
                                // Add password validation logic
                              ),
                              SizedBox(height: mq.height * .02),
                              SizedBox(
                                width: mq.height * 0.2,
                                height: mq.height * .05,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromARGB(255, 13, 67, 13),
                                      shape: const StadiumBorder(),
                                      elevation: 4),
                                  onPressed: _loginWithEmailAndPassword,
                                  child: const Text(
                                    "Login",
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        fontSize: 20),
                                  ),
                                ),
                              ),
                              SizedBox(height: mq.height * .02),
                              SizedBox(
                                width: mq.height * 0.2,
                                height: mq.height * .05,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromARGB(255, 13, 67, 13),
                                      shape: const StadiumBorder(),
                                      elevation: 4),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const SignUpScreen()));
                                  },
                                  child: const Text(
                                    "Sign Up",
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        fontSize: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
