import 'package:chat_fire_flutter/Constants/constant_page.dart';
import 'package:chat_fire_flutter/Screens/Home/home_page.dart';
import 'package:chat_fire_flutter/Services/database_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupInfoPage extends StatefulWidget {
  final String grpName;
  final String grpId;
  final String adminName;
  final String uName;
  GroupInfoPage(
      {Key? key,
      required this.grpName,
      required this.grpId,
      required this.adminName,required this.uName})
      : super(key: key);

  @override
  _GroupInfoPageState createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  Stream? members;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMembersFunc();
  }

  getMembersFunc() {
    DataBaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .grpMembers(widget.grpId)
        .then((value) {
      setState(() {
        members = value;
      });
    });
  }

  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: grpInfoPart(),
    );
  }

  AppBar appBar() {
    return AppBar(
      toolbarHeight: 70,
      centerTitle: true,
      backgroundColor: Constants.redColor,
      title: const Text("Group Info"),
      actions: [
        IconButton(
            onPressed: () {
              showDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Exit"),
                      content: const Text("Are you sure you exit the group? "),
                      actions: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            DataBaseService(
                                    uid: FirebaseAuth.instance.currentUser!.uid)
                                .switchToggleGrp(widget.grpId,
                                    widget.uName, widget.grpName)
                                .whenComplete(() {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomePage(),
                                ),
                              );
                            });
                          },
                          icon: const Icon(
                            Icons.done,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    );
                  });
            },
            icon: const Icon(Icons.exit_to_app))
      ],
    );
  }

  Widget grpInfoPart() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Constants.greenColor.withOpacity(0.2)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Constants.greenColor,
                  child: Text(
                    widget.grpName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Group: ${widget.grpName}",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text("Admin: ${getName(widget.adminName)}")
                  ],
                )
              ],
            ),
          ),
          memberList(),
        ],
      ),
    );
  }

  memberList() {
    return StreamBuilder(
      stream: members,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['members'] != null) {
            if (snapshot.data['members'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['members'].length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          getName(snapshot.data['members'][index])
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(getName(snapshot.data['members'][index])),
                      subtitle: Text(getId(snapshot.data['members'][index])),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text("NO MEMBERS"),
              );
            }
          } else {
            return const Center(
              child: Text("NO MEMBERS"),
            );
          }
        } else {
          return Center(
              child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ));
        }
      },
    );
  }
}
