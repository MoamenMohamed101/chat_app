import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser chatUser;
  const ChatUserCard({Key? key, required this.chatUser}) : super(key: key);

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 1,
        child: ListTile(
          title: Text(widget.chatUser.name!),
          subtitle: Text(widget.chatUser.about!, maxLines: 1),
          leading: const CircleAvatar(
            child: Icon(CupertinoIcons.person),
          ),
          trailing: const Text(
            '12:00 pm',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ),
    );
  }
}
