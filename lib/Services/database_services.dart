import 'package:cloud_firestore/cloud_firestore.dart';

class DataBaseService {
  final String? uid;
  DataBaseService({this.uid});

  // reference for our collections
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");

  // Saving User Register Data

  Future savingUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "profilePic": "",
      "uid": uid
    });
  }

  // Getting user data

  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  Future getUserGroupData() async {
    return userCollection.doc(uid).snapshots();
  }

  // create the groups

  Future createGroups(String userName, String id, String grpName) async {
    DocumentReference groupReferences = await groupCollection.add({
      "groupName": grpName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });

    // update the members

    await groupReferences.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": groupReferences.id,
    });

    // update in the userreference list

    DocumentReference userDocumentReference = userCollection.doc(uid);
    return userDocumentReference.update({
      "groups": FieldValue.arrayUnion(["${groupReferences.id}_$grpName"]),
    });
  }

  // Getting the chat from firebase

  Future getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  // Getting Admin Details
  Future getTheAdminDetails(String groupId) async {
    DocumentReference d = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['admin'];
  }

  // Get Group Members

  Future grpMembers(String grpId) async {
    return groupCollection.doc(grpId).snapshots();
  }

  // Make search func
  Future searchByName(String groupName) async {
    return groupCollection.where("groupName", isEqualTo: groupName).get();
  }

  // Switch between other user join and remove from the group

  Future switchToggleGrp(String grpId, String uName, String grpName) async {
    // initialized grp references
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference grpDocumentReference = groupCollection.doc(grpId);

    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List groups = await documentSnapshot['groups'];

    // user already in grp then it will remove his self otherwise join the group
    print(groups.contains("${grpId}_$grpName"));
    if (groups.contains("${grpId}_$grpName")) {

      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${grpId}_$grpName"]),
      });
      await grpDocumentReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$uName"]),
      });
      print("${uid}_$uName");

    } else {
      await userDocumentReference.update({
        "groups": FieldValue.arrayUnion(["${grpId}_$grpName"]),
      });
      await grpDocumentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$uName"]),
      });


    }
  }

  // get the bool value i make func usedin => search page
  Future<bool> isUserJoined(String grpName, String grpId, String uName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains("${grpId}_$grpName")) {
      return true;
    } else {
      return false;
    }
  }

  // How to send message

  Future sendMessageToTheServer(
      {String? grpId, Map<String, dynamic>? mapData}) async {
    groupCollection.doc(grpId).collection("messages").add(mapData!);
    groupCollection.doc(grpId).update({
      "recentMessage": mapData['message'],
      "recentMessageSender": mapData['sender'],
      "recentMessageTime": mapData['time'].toString(),
    });
  }
}
