import 'package:chat_app/Api/apis.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/screens/profile_screen.dart';
import 'package:chat_app/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> list = [];
  List<ChatUser> searchList = [];
  bool isSearching = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Apis.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if(isSearching){
            setState(() {
              isSearching =!isSearching;
            });
          }else{
            return Future.value(true);
          }
          return Future.value(false);
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: const Icon(CupertinoIcons.home),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    isSearching = !isSearching;
                  });
                },
                icon: Icon(isSearching
                    ? CupertinoIcons.clear_circled_solid
                    : Icons.search),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        chatUser: Apis.me,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.more_vert),
              ),
            ],
            title: isSearching
                ? TextFormField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Email,Name,.......',
                    ),
                    autofocus: true,
                    style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                    onChanged: (value) {
                      searchList.clear();
                      for (var i in list) {
                        if (i.name!.toLowerCase().contains(value.toLowerCase()) ||
                            i.email!.toLowerCase().contains(value.toLowerCase())) {
                          searchList.add(i);
                        }
                        setState(() {
                          searchList;
                        });
                      }
                    },
                  )
                : const Text('Chatty'),
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              onPressed: () async {
                // await Apis.auth.signOut();
                // await GoogleSignIn().signOut();
              },
              child: const Icon(Icons.add_comment_rounded),
            ),
          ),
          body: StreamBuilder(
            stream: Apis.getAllUsers(),
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
                  if (list.isNotEmpty) {
                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(top: mq.height * .01),
                      itemBuilder: (context, index) =>
                          ChatUserCard(chatUser:isSearching ? searchList[index] : list[index]),
                      separatorBuilder: (context, index) => Container(),
                      itemCount: isSearching ? searchList.length : list.length,
                    );
                  } else {
                    return const Center(
                      child: Text('Please Cheek your internet !'),
                    );
                  }
              }
            },
          ),
        ),
      ),
    );
  }
}
