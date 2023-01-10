import 'package:chat_fire_flutter/Constants/constant_page.dart';
import 'package:chat_fire_flutter/Helper/shared_helper.dart';
import 'package:chat_fire_flutter/Screens/Auth/login_page.dart';
import 'package:chat_fire_flutter/Screens/Chat/chat_page.dart';
import 'package:chat_fire_flutter/Screens/Home/profile_page.dart';
import 'package:chat_fire_flutter/Screens/Home/search_page.dart';
import 'package:chat_fire_flutter/Services/auth_service.dart';
import 'package:chat_fire_flutter/Services/database_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String email = "";
  String uName = "";
  String grpName = "";

  TextEditingController createGroupController = TextEditingController();

  AuthServices authServices = AuthServices();

  Stream? groups;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    gettingUserData();
  }

  gettingUserData() async {
    await HelperFunctions.getEmailInStatus().then((value) {
      email = value!;
    });
    await HelperFunctions.getUserNameInStatus().then((value) {
      uName = value!;
    });
    await DataBaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroupData()
        .then((value) {
      setState(() {
        groups = value;
      });
    });
  }

  // string manipulation

  String getId(String res) {
    return res.substring(0, res.indexOf('_'));
  }

  Widget getName(String res) {
    return Text(
      res.substring(res.indexOf('_') + 1),
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  Widget getNameCapital(String res) {
    return Text(
      res.substring(res.indexOf('_') + 1).substring(0, 1).toUpperCase(),
      style: TextStyle(
        color: Constants.redColor,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      drawer: drawer(),
      body: groupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showPopupForAddGroup();
        },
        backgroundColor: Constants.greenColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      toolbarHeight: 70,
      centerTitle: true,
      title: const Text(
        "Clikr Chat",
        style: TextStyle(
            fontSize: 22, letterSpacing: 1, fontWeight: FontWeight.w600),
      ),
      backgroundColor: Constants.redColor,
      actions: [
        const SizedBox(
          width: 10,
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage(),),);
          },
          child: const Icon(
            Icons.search,
            size: 24,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
      ],
    );
  }

  showPopupForAddGroup() {
    bool isLoading = false;
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Create Group",
          style: TextStyle(
            color: Constants.redColor,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isLoading == true
                ? Center(
                    child: CircularProgressIndicator(color: Constants.redColor),
                  )
                : TextFormField(
                    controller: createGroupController,
                    onChanged: (value) {
                      setState(() {
                        grpName = value;
                      });
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      hintText: "Make A Group",
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Constants.greenColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Constants.greenColor,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
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
              if (grpName != "") {
                setState(() {
                  isLoading = true;
                });
                DataBaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                    .createGroups(
                        uName, FirebaseAuth.instance.currentUser!.uid, grpName)
                    .whenComplete(() {
                  setState(() {
                    isLoading = false;
                  });
                });
                Navigator.of(context).pop();
                Fluttertoast.showToast(msg: "Group Created Successfully");
              }
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
  }

  Widget groupList() {
    return StreamBuilder(
      stream: groups,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null) {
            if (snapshot.data['groups'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['groups'].length,
                itemBuilder: (context, index) {
                  int reverseIndex = snapshot.data['groups'].length - index - 1;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8,left: 8,right: 8),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(
                          grpId: getId(snapshot.data['groups'][reverseIndex]),
                          grpName: snapshot.data['groups'][reverseIndex].toString().substring(snapshot.data['groups'][reverseIndex].toString().indexOf('_')+1),
                          uName: snapshot.data['fullName'],
                        ),));
                      },
                      child: ListTile(

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        tileColor: Constants.greenColor,
                        leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          child:
                              getNameCapital(snapshot.data['groups'][reverseIndex]),
                        ),
                        title: getName(
                          snapshot.data['groups'][reverseIndex],
                        ),
                        subtitle: Text(
                          "Joined as ${uName}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(
                child: Text(
                  "No Groups Found",
                  style: TextStyle(
                    color: Constants.greenColor,
                    fontSize: 18,
                  ),
                ),
              );
            }
          } else {
            return Center(
              child: Text(
                "No Groups Found",
                style: TextStyle(
                  color: Constants.greenColor,
                  fontSize: 18,
                ),
              ),
            );
          }
        } else {
          return Center(
            child: CircularProgressIndicator(color: Constants.redColor),
          );
        }
      },
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
              uName,
              style: const TextStyle(color: Colors.black, fontSize: 20),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(),
            ListTile(
              selectedColor: Constants.redColor,
              selected: true,
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
