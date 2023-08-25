import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Api/apis.dart';
import 'package:chat_app/helper/my_data_unit.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/widgets/dialogs/profile_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser chatUser;

  const ChatUserCard({Key? key, required this.chatUser}) : super(key: key);

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? message;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (v) => ChatScreen(
              chatUser: widget.chatUser,
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 1,
        // why this error is showing ? because we are using StreamBuilder and it will return null at first time
        // so we need to handle this error
        // How to handle this error ? we will use if condition to check if snapshot has data or not and if it has data then we will show our widget else we will show error
        child: StreamBuilder(
          stream: Apis.getLastMessages(widget.chatUser),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            final data = snapshot.data!.docs;
            final list = data.map((e) => Message.fromJson(e.data())).toList();
            if (list.isNotEmpty) {
              message = list[0];
            }
            return ListTile(
              title: Text(widget.chatUser.name!),
              subtitle: Text(
                message != null
                    ? message!.type == Type.image
                        ? 'Image'
                        : message!.msg
                    : widget.chatUser.about!,
                maxLines: 1,
              ),
              leading: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => ProfileDialog(chatUser: widget.chatUser),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .3),
                  child: CachedNetworkImage(
                    height: mq.height * .055,
                    width: mq.height * .055,
                    imageUrl: widget.chatUser.image!,
                    errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(CupertinoIcons.person),
                    ),
                  ),
                ),
              ),
              // what this condition do ? it will check if message is null or not and if it is not null then it will check if message is read or not and if it is not read then it will show green dot else it will show red dot
              trailing: message == null
                  ? null
                  : message!.read.isEmpty && message!.fromId == Apis.user.uid
                      ? Container(
                          height: 15,
                          width: 15,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.shade400,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        )
                      : Text(
                          MyDateUtil.getLastMessageTime(
                            context: context,
                            time: message!.sent,
                          ),
                          style: const TextStyle(color: Colors.black54),
                        ),
            );
          },
        ),
      ),
    );
  }
}
