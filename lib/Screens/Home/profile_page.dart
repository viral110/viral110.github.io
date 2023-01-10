import 'package:chat_fire_flutter/Screens/Home/home_page.dart';
import 'package:chat_fire_flutter/Services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Constants/constant_page.dart';
import '../Auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  String uName;
  String email;
  ProfilePage({Key? key, required this.uName, required this.email})
      : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthServices authServices = AuthServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer(),
      appBar: appBar(),
    );
  }

  AppBar appBar() {
    return AppBar(
      toolbarHeight: 70,
      centerTitle: true,
      title: const Text(
        "Profile",
        style: TextStyle(
            fontSize: 22, letterSpacing: 1, fontWeight: FontWeight.w600),
      ),
      backgroundColor: Constants.redColor,

    );
  }

  Widget drawer() => Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 30,
            ),
            const Icon(Icons.account_circle, size: 150),
            Text(
              widget.uName,
              style: const TextStyle(color: Colors.black, fontSize: 20),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(),
            ListTile(
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ));
              },
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              title: const Text(
                "Gropus",
                style: TextStyle(fontSize: 18),
              ),
              leading: const Icon(Icons.group),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
            const Divider(),
            ListTile(
              onTap: () {},
              selectedColor: Constants.redColor,
              selected: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              title: const Text(
                "Profile",
                style: TextStyle(fontSize: 18),
              ),
              leading: const Icon(Icons.person),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
            const Divider(),
            ListTile(
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Logout"),
                    content: Text("Are you sure you want to logout?"),
                    actions: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: CircleAvatar(
                          backgroundColor: Colors.grey.shade300,
                          child: Icon(
                            Icons.close,
                            color: Constants.redColor,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          authServices.logoutApplication().whenComplete(() {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          });
                        },
                        icon: CircleAvatar(
                          backgroundColor: Colors.grey.shade300,
                          child: Icon(
                            Icons.done_rounded,
                            color: Constants.greenColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              title: const Text(
                "Logout",
                style: TextStyle(fontSize: 18),
              ),
              leading: const Icon(Icons.logout),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          ],
        ),
      );
}
