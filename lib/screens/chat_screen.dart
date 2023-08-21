import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Api/apis.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser chatUser;

  const ChatScreen({super.key, required this.chatUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> list = [];
  var textController = TextEditingController();
  var showEmoji = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (showEmoji) {
              setState(() {
                showEmoji = !showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            backgroundColor: const Color.fromARGB(255, 234, 248, 255),
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: appBar(),
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: Apis.getAllMessages(widget.chatUser),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox();
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data!.docs;
                          list = data
                              .map((e) => Message.fromJson(e.data()))
                              .toList();
                          if (list.isNotEmpty) {
                            return ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.only(top: mq.height * .01),
                              itemBuilder: (context, index) => MassageCard(
                                message: list[index],
                              ),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 15),
                              itemCount: list.length,
                            );
                          } else {
                            return const Center(
                              child: Text(
                                'Say Hi! 👋🏻',
                                style: TextStyle(fontSize: 20),
                              ),
                            );
                          }
                      }
                    },
                  ),
                ),
                chatInPut(),
                if (showEmoji)
                  SizedBox(
                    height: mq.height * .35,
                    child: EmojiPicker(
                      textEditingController: textController,
                      config: Config(
                        bgColor: const Color.fromARGB(255, 234, 248, 255),
                        columns: 8,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  appBar() {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.black45),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * .3),
            child: CachedNetworkImage(
              height: mq.height * .05,
              width: mq.height * .05,
              imageUrl: widget.chatUser.image!,
              errorWidget: (context, url, error) => const CircleAvatar(
                child: Icon(CupertinoIcons.person),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.chatUser.name!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              const Text(
                'Last Seen',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black45,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  chatInPut() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        showEmoji = !showEmoji;
                      });
                    },
                    icon: const Icon(Icons.emoji_emotions,
                        color: Colors.blueAccent, size: 25),
                  ),
                  Expanded(
                    child: TextField(
                      onTap: () {
                        setState(() {
                          if (showEmoji) {
                            FocusScope.of(context).unfocus();
                            showEmoji = !showEmoji;
                          }
                        });
                      },
                      controller: textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Type Something ...',
                        hintStyle: TextStyle(color: Colors.blueAccent),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.image,
                        color: Colors.blueAccent, size: 26),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt_rounded,
                        color: Colors.blueAccent, size: 26),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: mq.width * .02,
          ),
          MaterialButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                Apis.sendMessage(textController.text, widget.chatUser);
                textController.clear();
              }
            },
            shape: const CircleBorder(),
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            color: Colors.green,
            minWidth: 0,
            child: const Icon(
              Icons.send,
              color: Colors.white,
              size: 23,
            ),
          ),
        ],
      ),
    );
  }
}