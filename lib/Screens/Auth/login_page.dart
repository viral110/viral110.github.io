import 'package:chat_fire_flutter/Constants/constant_page.dart';
import 'package:chat_fire_flutter/Helper/shared_helper.dart';
import 'package:chat_fire_flutter/Screens/Auth/register_page.dart';
import 'package:chat_fire_flutter/Screens/Home/home_page.dart';
import 'package:chat_fire_flutter/Services/auth_service.dart';
import 'package:chat_fire_flutter/Services/database_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  AuthServices authServices = AuthServices();

  @override
  Widget build(BuildContext context) {
    var mediaWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: _isLoading == true
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Form(
                  key: formKey,
                  child: mediaWidth < 600
                      ? SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10),
                              Image.asset("assets/images/login_image.jpg"),
                              const SizedBox(
                                height: 20,
                              ),
                              const Text(
                                "Sign In",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 24,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              _emailLoginWidget(),
                              const SizedBox(
                                height: 20,
                              ),
                              _passLoginWidget(),
                              const SizedBox(
                                height: 20,
                              ),
                              _loginSubmitWidget(),
                              const SizedBox(
                                height: 10,
                              ),
                              _newUserNavigate(),
                              const SizedBox(
                                height: 25,
                              ),
                            ],
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Image.asset(
                                    "assets/images/login_image.jpg")),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Text(
                                    "Sign In",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 24,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  _emailLoginWidget(),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  _passLoginWidget(),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  _loginSubmitWidget(),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  _newUserNavigate(),
                                  const SizedBox(
                                    height: 25,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
        ),
      ),
    );
  }

  Widget _emailLoginWidget() {
    return TextFormField(
      controller: emailController,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(left: 8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        hintText: "Email",
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

  Widget _passLoginWidget() {
    return TextFormField(
      validator: (value) {
        if (value!.length < 6) {
          return "Please enter 6 characters";
        }
        return null;
      },
      controller: passController,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(left: 8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        hintText: "Password",
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

  String uName = "";

  Widget _loginSubmitWidget() {
    return InkWell(

      onTap: () async {
        if (formKey.currentState!.validate()) {
          setState(() {
            _isLoading = true;
          });
          await authServices
              .loginUserWithEmailAndPassword(
                  emailController.text, passController.text)
              .then((value) async {
            print(value);
            if (value == true) {
              // await HelperFunctions.getUserNameInStatus().then((value) {
              //   uName = value!;
              // });
              QuerySnapshot snapshot = await DataBaseService(
                      uid: FirebaseAuth.instance.currentUser!.uid)
                  .gettingUserData(emailController.text);
              await HelperFunctions.setTheLoggedInStatus(true);
              await HelperFunctions.setUserNameInStatus(
                  snapshot.docs[0]['fullName']);
              await HelperFunctions.setEmailInStatus(emailController.text);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ));
            } else {
              Fluttertoast.showToast(
                  msg: value,
                  fontSize: 13,
                  backgroundColor: Constants.greenColor);
              setState(() {
                _isLoading = false;
              });
            }
          });
        }
      },
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        height: 45,
        decoration: BoxDecoration(
          color: Constants.redColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          "Log In",
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
      ),
    );
  }

  Widget _newUserNavigate() {
    return InkWell(
      hoverColor: Colors.transparent,
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RegisterPage(),
            ));
      },
      child: SizedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Register",
              style: TextStyle(
                  fontSize: 16,
                  color: Constants.greenColor,
                  fontWeight: FontWeight.w600),
            ),
            Icon(Icons.arrow_forward, color: Constants.greenColor, size: 16),
          ],
        ),
      ),
    );
  }
}
