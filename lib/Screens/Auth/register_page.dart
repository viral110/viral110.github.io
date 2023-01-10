import 'package:chat_fire_flutter/Helper/shared_helper.dart';
import 'package:chat_fire_flutter/Screens/Home/home_page.dart';
import 'package:chat_fire_flutter/Services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../Constants/constant_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;

  AuthServices authServices = AuthServices();

  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  final formKey = GlobalKey<FormState>();

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
                          children: [
                            const SizedBox(height: 10),
                            Image.asset("assets/images/register_image.jpg"),
                            const SizedBox(
                              height: 20,
                            ),
                            const Text(
                              "Sign up",
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
                            _userNameRegisterWidget(),
                            const SizedBox(
                              height: 20,
                            ),
                            _emailRegisterWidget(),
                            const SizedBox(
                              height: 20,
                            ),
                            _passRegisterWidget(),
                            const SizedBox(
                              height: 20,
                            ),
                            _registerSubmitWidget(),
                            const SizedBox(
                              height: 5,
                            ),
                            _oldUserNavigate(),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                    )
                    : Row(
                        children: [
                          Expanded(
                            child: Image.asset(
                                "assets/images/register_image.jpg"),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  "Sign up",
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
                                _userNameRegisterWidget(),
                                const SizedBox(
                                  height: 20,
                                ),
                                _emailRegisterWidget(),
                                const SizedBox(
                                  height: 20,
                                ),
                                _passRegisterWidget(),
                                const SizedBox(
                                  height: 20,
                                ),
                                _registerSubmitWidget(),
                                const SizedBox(
                                  height: 5,
                                ),
                                _oldUserNavigate(),
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

  Widget _userNameRegisterWidget() {
    return TextFormField(
      controller: userNameController,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(left: 8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        hintText: "Full Name",
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

  Widget _emailRegisterWidget() {
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

  Widget _passRegisterWidget() {
    return TextFormField(
      controller: passController,
      validator: (value) {
        if (value!.length < 6) {
          return "Please enter 6 characters";
        }
        return null;
      },
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

  Widget _registerSubmitWidget() {
    return InkWell(
      onTap: () async {
        if (formKey.currentState!.validate()) {
          setState(() {
            _isLoading = true;
          });
          await authServices
              .registerUserWithEmailAndPassword(
            userNameController.text,
            emailController.text,
            passController.text,
          )
              .then((value) async {
            if (value == true) {
              await HelperFunctions.setTheLoggedInStatus(true);
              await HelperFunctions.setUserNameInStatus(
                  userNameController.text);
              await HelperFunctions.setEmailInStatus(emailController.text);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ),
              );
            } else {
              Fluttertoast.showToast(
                msg: value,
                fontSize: 13,
                backgroundColor: Constants.greenColor,
              );
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
          "Create Account",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _oldUserNavigate() {
    return InkWell(
      hoverColor: Colors.transparent,
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.arrow_back,
            color: Constants.greenColor,
            size: 18,
          ),
          Text(
            " Login",
            style: TextStyle(
                fontSize: 16,
                color: Constants.greenColor,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
