import 'package:chat_fire_flutter/Constants/constant_page.dart';
import 'package:chat_fire_flutter/Screens/Chat/group_info.dart';
import 'package:chat_fire_flutter/Services/database_services.dart';
import 'package:chat_fire_flutter/widgets/message_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String grpName;
  final String grpId;
  final String uName;
  ChatPage(
      {Key? key,
      required this.grpName,
      required this.grpId,
      required this.uName})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  String admin = "";
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    getChatsAndAdminFunc();
    super.initState();
  }

  getChatsAndAdminFunc() {
    DataBaseService().getChats(widget.grpId).then((value) {
      setState(() {
        chats = value;
      });
    });

    DataBaseService().getTheAdminDetails(widget.grpId).then((value) {
      setState(() {
        admin = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Stack(
        children: [
          getChatWidget(),
          txtFieldForSendMessage(),
        ],
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      toolbarHeight: 70,
      centerTitle: true,
      title: Text(
        widget.grpName,
        style: const TextStyle(
            fontSize: 22, letterSpacing: 1, fontWeight: FontWeight.w600),
      ),
      backgroundColor: Constants.redColor,
      actions: [
        const SizedBox(
          width: 10,
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupInfoPage(grpName: widget.grpName,adminName: admin,grpId: widget.grpId,uName: widget.uName),
              ),
            );
          },
          child: const Icon(
            Icons.info_rounded,
            size: 24,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
      ],
    );
  }

  // TextField for send Message
  Widget txtFieldForSendMessage() {
    return Container(
      alignment: Alignment.bottomCenter,
      width: MediaQuery.of(context).size.width,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Constants.greenColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(children: [
          Expanded(
            child: TextFormField(
              controller: messageController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Send a message...",
                hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          GestureDetector(
            onTap: () {
              sendMessageFunc();
            },
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Constants.redColor,
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          )
        ]),
      ),
    );
  }

  getChatWidget() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  print(snapshot.data.docs.length);
                  return MessageTile(
                    sentByMe: widget.uName == snapshot.data.docs[index]['sender'],
                    message: snapshot.data.docs[index]['message'],
                    sender: snapshot.data.docs[index]['sender'],
                  );
                },
              )
            : SizedBox(
                child: Center(
                  child: Text(
                    "No Chats Found",
                    style: TextStyle(color: Constants.greenColor, fontSize: 18),
                  ),
                ),
              );
      },
    );
  }

  sendMessageFunc () async {
    if(messageController.text.isNotEmpty){
      Map<String,dynamic> mapData = {
        "message" : messageController.text,
        "sender" : widget.uName,
        "time" : DateTime.now().millisecondsSinceEpoch,
      };

      DataBaseService().sendMessageToTheServer(grpId: widget.grpId,mapData: mapData);
      setState(() {
        messageController.clear();
      });
    }
  }
}
