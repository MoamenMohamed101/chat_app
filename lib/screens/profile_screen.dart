import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Api/apis.dart';
import 'package:chat_app/helper/dialogs.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key, required this.chatUser}) : super(key: key);
  final ChatUser chatUser;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile Screen'),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.red,
          onPressed: () async {
            Dialogs.showProgressBar(context);
            await Apis.auth.signOut().then((value) async {
              await GoogleSignIn().signOut().then((value) {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              });
            });
          },
          label: const Text('Logout'),
          icon: const Icon(Icons.logout),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: mq.height * .05),
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
                      // placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(CupertinoIcons.person),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: MaterialButton(
                      elevation: 1,
                      shape: const CircleBorder(),
                      color: Colors.white,
                      onPressed: () {},
                      child: const Icon(Icons.edit, color: Colors.blue),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: mq.height * .03,
              ),
              Text(
                widget.chatUser.email!,
                style: const TextStyle(color: Colors.black45, fontSize: 16),
              ),
              SizedBox(
                height: mq.height * .05,
              ),
              TextFormField(
                initialValue: widget.chatUser.name,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person, color: Colors.blue),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  hintText: 'eg. Happy Singh',
                  label: const Text('Name'),
                ),
              ),
              SizedBox(
                height: mq.height * .02,
              ),
              TextFormField(
                initialValue: widget.chatUser.about,
                decoration: InputDecoration(
                  prefixIcon:
                      const Icon(Icons.info_outline, color: Colors.blue),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  hintText: 'eg. Feeling Happy',
                  label: const Text('About'),
                ),
              ),
              SizedBox(
                height: mq.height * .05,
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    minimumSize: Size(mq.width * .5, mq.height * .06)),
                onPressed: () {},
                icon: const Icon(Icons.edit, size: 28),
                label: const Text(
                  'UPDATE',
                  style: TextStyle(fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
