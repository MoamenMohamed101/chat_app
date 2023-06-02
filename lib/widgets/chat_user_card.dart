import 'package:chat_app/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({Key? key}) : super(key: key);

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
        child: const ListTile(
          title: Text('User title'),
          subtitle: Text('Last user message', maxLines: 1),
          leading: CircleAvatar(
            child: Icon(CupertinoIcons.person),
          ),
          trailing: Text(
            '12:00 pm',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ),
    );
  }
}
