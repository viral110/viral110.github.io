import 'package:chat_fire_flutter/Constants/constant_page.dart';
import 'package:chat_fire_flutter/Helper/shared_helper.dart';
import 'package:chat_fire_flutter/Services/database_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Chat/chat_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool hasUserSearched = false;
  String userName = "";
  bool isJoined = false;
  User? user;

  getCurrentUserIdandName() async {
    await HelperFunctions.getUserNameInStatus().then((value) {
      setState(() {
        userName = value!;
      });
    });
    user = FirebaseAuth.instance.currentUser;
  }

  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUserIdandName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: searchWidget(),
    );
  }

  AppBar appBar() => AppBar(
        elevation: 0,
        backgroundColor: Constants.redColor,
        title: const Text(
          "Search",
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );

  Widget searchWidget() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Constants.greenColor,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: searchController,
                  onChanged: (value) async {
                    if (value.isNotEmpty || value != "") {
                      setState(() {
                        isLoading = true;
                      });
                      await DataBaseService().searchByName(value).then((value) {
                        setState(() {
                          searchSnapshot = value;
                          isLoading = false;
                          hasUserSearched = true;
                        });
                      });
                    }
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search groups....",
                      hintStyle: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40)),
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
        isLoading
            ? Center(
                child: CircularProgressIndicator(color: Constants.redColor),
              )
            : grpListBySearchWidget(),
      ],
    );
  }

  Widget grpListBySearchWidget() {
    return hasUserSearched
        ? Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: searchSnapshot!.docs.length,
              itemBuilder: (context, index) {

                return groupTile(
                    userName,
                    searchSnapshot!.docs[index]['groupId'],
                    searchSnapshot!.docs[index]['groupName'],
                    searchSnapshot!.docs[index]['admin']);
              },
            ),
          )
        : Container();
  }

  checkGrpMemberJoinedorNot(
      String uName, String grpId, String grpName, String admin) async {
    await DataBaseService(uid: user!.uid)
        .isUserJoined(grpName, grpId, userName)
        .then((value) {
      setState(() {
        isJoined = value;
      });
    });
  }

  Widget groupTile(
      String userName, String groupId, String groupName, String admin) {
    // function to check whether user already exists in group
    checkGrpMemberJoinedorNot(userName, groupId, groupName, admin);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          groupName.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title:
          Text(groupName, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text("Admin: ${getName(admin)}"),
      trailing: InkWell(
        onTap: () async {

          if (isJoined) {
            setState(() {
              isJoined = !isJoined;
            });
            await DataBaseService(uid: user!.uid)
                .switchToggleGrp(groupId, userName, groupName);
            Fluttertoast.showToast(msg: "Successfully joined");
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                      grpId: groupId, grpName: groupName, uName: userName),
                ),
              );
            });
          } else {
            await DataBaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                .switchToggleGrp(groupId, userName, groupName);
            setState(() {

              isJoined = !isJoined;
              Fluttertoast.showToast(msg: "Left the $groupName",);
            });
          }
        },
        child: isJoined
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text(
                  "Joined",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Constants.redColor,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text("Join Now",
                    style: TextStyle(color: Colors.white)),
              ),
      ),
    );
  }
}
