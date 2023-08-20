import 'dart:io';

import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/message.dart';
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

  // what is method getConversationId do ? it will return conversation id between current user and another user by comparing their ids and return the smallest one as a string
  static getConversationId(String id) =>
      user.uid.hashCode <= id.hashCode ? '${user.uid}-$id' : '$id-${user.uid}';

  // what is method getAllMessages do ? it will return all messages between current user and another user as a stream of QuerySnapshot<Map<String, dynamic>>
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser chatUser) {
    return firebaseFirestore
        .collection('chats/${getConversationId(chatUser.id!)}/messages/')
    // .orderBy(descending: true , 'sent')
        .snapshots();
  }
  // what is method sendMessage do ? it will send message to another user by adding it to firebase firestore database
  static Future<void> sendMessage(String msg, ChatUser chatUser) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final message = Message(
      msg: msg,
      read: '',
      told: chatUser.id!, // what is told ? it is the id of the user that the message will be sent to
      type: Type.text,
      fromId: user.uid, // what is fromId ? it is the id of the user that the message will be sent from
      sent: time,
    );
    final ref = firebaseFirestore
        .collection('chats/${getConversationId(chatUser.id!)}/messages/');
        await ref.doc(time).set(message.toJson());
  }
  // what is method updateMessageReadStatus do ? it will update message read status in firebase firestore database by adding the time that the message was read to the message
  static Future<void> updateMessageReadStatus(Message message) async {
    final ref = firebaseFirestore
        .collection('chats/${getConversationId(message.fromId)}/messages/');
    await ref.doc(message.sent).update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }
  // what is method getLastMessages do ? it will return last message between current user and another user
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessages(
      ChatUser chatUser) {
    return firebaseFirestore
        .collection('chats/${getConversationId(chatUser.id!)}/messages/')
        .orderBy('sent', descending: true) // what is this line do ? it will order the messages by the time that they were sent
        .limit(1)
        .snapshots();
  }
}