import 'package:chat_app/Api/apis.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> list = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const Icon(CupertinoIcons.home),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
        title: const Text('Chatty'),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
          onPressed: () async {
            await Apis.auth.signOut();
            await GoogleSignIn().signOut();
          },
          child: const Icon(Icons.add_comment_rounded),
        ),
      ),
      body: StreamBuilder(
        stream: Apis.firebaseFirestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const Center(
                child: CircularProgressIndicator(),
              );

            case ConnectionState.active:
            case ConnectionState.done:
              final data = snapshot.data!.docs;
              list = data.map((e) => ChatUser.fromJson(e.data())).toList();
              if(list.isNotEmpty){
                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(top: mq.height * .01),
                  itemBuilder: (context, index) =>
                      ChatUserCard(chatUser: list[index]),
                  separatorBuilder: (context, index) => Container(),
                  itemCount: list.length,
                );
              }else{
               return const Center(
                  child: Text('Please Cheek your internet !'),
                );
              }
          }
        },
      ),
    );
  }
}
