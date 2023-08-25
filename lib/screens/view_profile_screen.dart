import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/my_data_unit.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser chatUser;

  const ViewProfileScreen({Key? key, required this.chatUser}) : super(key: key);

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard when user tap on screen
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(widget.chatUser.name!),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: mq.height * .05),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: mq.width,
                  height: mq.height * .03,
                ),
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .1),
                      child: CachedNetworkImage(
                        height: mq.height * .2,
                        width: mq.height * .2,
                        fit: BoxFit.cover,
                        imageUrl: widget.chatUser.image!,
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(
                          child: Icon(CupertinoIcons.person),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: mq.height * .03,
                ),
                Text(
                  widget.chatUser.email!,
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                ),
                SizedBox(
                  height: mq.height * .02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'About : ',
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      widget.chatUser.about!,
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Joined On : ',
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
            Text(
              MyDateUtil.getLastMessageTime(context: context, time: widget.chatUser.createdAt! , showYear: true),
              style: const TextStyle(color: Colors.black54, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
