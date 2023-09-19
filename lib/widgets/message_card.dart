import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Api/apis.dart';
import 'package:chat_app/helper/dialogs.dart';
import 'package:chat_app/helper/my_data_unit.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';

class MassageCard extends StatefulWidget {
  final Message message;

  const MassageCard({super.key, required this.message});

  @override
  State<MassageCard> createState() => _MassageCardState();
}

class _MassageCardState extends State<MassageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = Apis.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        showButtonSheet(isMe);
      },
      child: isMe ? greenMessage() : blueMessage(),
    );
  }

  // Other message
  blueMessage() {
    if (widget.message.read.isEmpty) {
      Apis.updateMessageReadStatus(widget.message);
      debugPrint('Done update');
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // what flexible do? it make the container take the space it need
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: mq.width * .04,
              vertical: mq.height * .01,
            ),
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .03
                : mq.width * .04),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.lightBlue),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              color: const Color.fromARGB(255, 221, 245, 255),
            ),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(
            MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent),
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  // My message
  greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: mq.width * .04,
            ),
            if (widget.message.read.isNotEmpty)
              const Icon(
                Icons.done_all_rounded,
                color: Colors.blue,
                size: 20,
              ),
            SizedBox(
              width: mq.width * .01,
            ),
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: mq.width * .04,
              vertical: mq.height * .01,
            ),
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .03
                : mq.width * .04),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.lightGreen),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
              color: const Color.fromARGB(255, 218, 255, 176),
            ),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  showButtonSheet(bool isMe) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      context: context,
      builder: (value) {
        return ListView(
          shrinkWrap: true,
          children: [
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(
                horizontal: mq.width * .4,
                vertical: mq.height * .015,
              ),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(8)),
            ),
            widget.message.type == Type.text
                ? OptionItem(
                    icon: const Icon(
                      Icons.copy_all_outlined,
                      size: 26,
                      color: Colors.blue,
                    ),
                    name: 'Copy Test',
                    onTap: () async {
                      await Clipboard.setData(
                        ClipboardData(text: widget.message.msg),
                      ).then(
                        (value) {
                          Navigator.pop(context);
                          Dialogs.showSnackBar(context, 'Text Copied');
                        },
                      );
                    },
                  )
                : OptionItem(
                    icon: const Icon(
                      Icons.download_rounded,
                      size: 26,
                      color: Colors.blue,
                    ),
                    name: 'Save Image',
                    onTap: () async {
                      try {
                        Navigator.pop(context);
                        await GallerySaver.saveImage(widget.message.msg,
                                albumName: "Chatty")
                            .then((success) {
                          if (success != null && success) {
                            Dialogs.showSnackBar(context, 'Image Saved');
                          } else {
                            const CircularProgressIndicator();
                          }
                        });
                      } catch (e) {
                        debugPrint(e.toString());
                      }
                    },
                  ),
            if (isMe)
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),
            if (widget.message.type == Type.text && isMe)
              OptionItem(
                icon: const Icon(
                  Icons.edit,
                  size: 26,
                  color: Colors.blue,
                ),
                name: 'Edit Message',
                onTap: () {
                  Navigator.pop(context);
                  showMessageUpdateDialog();
                },
              ),
            if (isMe)
              OptionItem(
                icon: const Icon(
                  Icons.delete_forever,
                  size: 26,
                  color: Colors.red,
                ),
                name: 'Delete Message',
                onTap: () async {
                  await Apis.deleteMessage(widget.message).then((value) {
                    Navigator.pop(context);
                  });
                },
              ),
            Divider(
              color: Colors.black54,
              endIndent: mq.width * .04,
              indent: mq.width * .04,
            ),
            OptionItem(
              icon: const Icon(
                Icons.remove_red_eye,
                size: 26,
                color: Colors.blue,
              ),
              name:
                  'send at: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
              onTap: () {},
            ),
            OptionItem(
              icon: const Icon(
                Icons.remove_red_eye,
                size: 26,
                color: Colors.green,
              ),
              name: widget.message.read.isEmpty
                  ? ' Read At: Not seen yet'
                  : 'Read at: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
              onTap: () {},
            ),
          ],
        );
      },
    );
  }

  showMessageUpdateDialog() {
    String updateMessage = widget.message.msg;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: const EdgeInsets.only(left: 24 , right: 24 , top: 20 , bottom: 10),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.edit,
              color: Colors.blue,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Edit Message',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: TextFormField(
          initialValue: widget.message.msg,
          maxLines: null,
          onChanged: (value) => updateMessage = value,
          decoration: InputDecoration(
            hintText: 'Enter your message',
            hintStyle: const TextStyle(
              color: Colors.black54,
              fontSize: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
          MaterialButton(
            onPressed: () {
              Apis.updateMessage(widget.message, updateMessage);
              Navigator.pop(context);
            },
            child: const Text(
              "Update",
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const OptionItem(
      {super.key, required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
          left: mq.width * .05,
          top: mq.height * .020,
          bottom: mq.width * .015,
        ),
        child: Row(
          children: [
            icon,
            Flexible(
              child: Text(
                '  $name',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  letterSpacing: 0.5,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
