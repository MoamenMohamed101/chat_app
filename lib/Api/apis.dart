import 'dart:io';

import 'package:chat_app/models/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Apis {
  // what is static line do ? it will create only one instance of FirebaseAuth, FirebaseFirestore, FirebaseStorage
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  static FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  static User get user => auth.currentUser!;

  // for storing self information
  static late ChatUser me;

  // what is method userExists do ? it will check if user exists or not in firebase firestore database
  static Future<bool> userExists() async {
    return (await firebaseFirestore.collection('users').doc(user.uid).get())
        .exists;
  }

  // what is method createUser do ? it will create user in firebase firestore database with user's information
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      about: 'I\'m using chatty',
      createdAt: time,
      email: user.email.toString(),
      image: user.photoURL.toString(),
      // what is photoURL ? it will return user's profile picture url
      isOnline: false,
      lastActive: time,
      pushToken: '',
    );
    return await firebaseFirestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // what is method getSelfInfo do ? it will get user's information from firebase firestore database and store it in me variable
  static Future<void> getSelfInfo() async {
    await firebaseFirestore
        .collection('users')
        .doc(user.uid)
        .get()
        .then((value) async {
      if (value.exists) {
        me = ChatUser.fromJson(value.data()!);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // what is method getAllUsers do ? it will return all users except current user from firebase firestore database as a stream of QuerySnapshot<Map<String, dynamic>>
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firebaseFirestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

// what is method updateUserInfo do ? it will update user info in firebase firestore database
  static Future<void> updateUserInfo() async {
    await firebaseFirestore
        .collection('users')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }

// what is method updateProfilePicture do ? it will update user profile picture in firebase firestore database
  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    final ref = firebaseStorage.ref().child('profile_picture/${user.uid}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {});
    me.image = await ref.getDownloadURL();
    await firebaseFirestore.collection('user').doc(user.uid).update({
      'image': me.image
    }); // what this line do ? it will update user profile picture in firebase firestore database
  }

// it will return all messages from firebase firestore database as a stream of QuerySnapshot<Map<String, dynamic>>
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages() {
    return firebaseFirestore.collection('messages').snapshots();
  }
}
