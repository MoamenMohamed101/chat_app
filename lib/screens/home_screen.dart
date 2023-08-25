import 'dart:convert';

import 'package:chat_app/Api/apis.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/screens/profile_screen.dart';
import 'package:chat_app/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    super.initState();
    Apis.getSelfInfo();
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (Apis.auth.currentUser != null) {
        if (message!.contains('paused')) {
          Apis.updateActiveStatus(false);
        } else if (message.contains('resumed')) {
          Apis.updateActiveStatus(true);
        }
      }
      return Future.value(
          message); // what is this line do ? it will return the message that the app received
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      // this widget will handle back button press
      child: WillPopScope(
        onWillPop: () {
          if (isSearching) {
            setState(() {
              isSearching = !isSearching;
            });
          } else {
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
                icon: Icon(
                  isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search,
                ),
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
                  debugPrint(jsonEncode(Apis.me));
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
                    // what is autofocus ? it is a property that make the textfield focused when the widget is built
                    style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                    onChanged: (value) {
                      // what is this line do ? it will clear the searchList
                      searchList.clear();
                      // what is this for loop do ? it will loop through the list of users and check if the name or the email of the user contains the value that the user typed in the textfield and if it is true it will add the user to the searchList and then rebuild the widget
                      for (var i in list) {
                        if (i.name!
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            i.email!
                                .toLowerCase()
                                .contains(value.toLowerCase())) {
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
              onPressed: () {},
              child: const Icon(Icons.add_comment_rounded),
            ),
          ),
          // what is StreamBuilder ? it is a widget that can listen to any stream and rebuild itself when the stream emits new data
          // is streamBuilder real time ? yes it is real time
          // what is stream ? it is a sequence of asynchronous events
          // what is asynchronous ? it is a operation that runs in a separate thread from the main thread
          // what is the difference between asynchronous and synchronous ? synchronous is when the operation runs in the main thread and asynchronous is when the operation runs in a separate thread
          body: StreamBuilder(
            stream: Apis.getAllUsers(),
            builder: (context, snapshot) {
              // what is snapshot ? it is the data that the stream emits at the moment
              // what is ConnectionState ? it is the state of the connection between the stream and the widget
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data!.docs;
                  list = data
                      .map((e) => ChatUser.fromJson(e.data()))
                      .toList(); // what this line do ? it convert the data from the stream to a list of ChatUser objects
                  if (list.isNotEmpty) {
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(top: mq.height * .01),
                      itemBuilder: (context, index) => ChatUserCard(
                          chatUser:
                              isSearching ? searchList[index] : list[index]),
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
