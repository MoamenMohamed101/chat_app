import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

class Apis {
  // what is static line do ? it will create only one instance of FirebaseAuth, FirebaseFirestore, FirebaseStorage
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  static FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  static User get user => auth.currentUser!;

  // for storing self information
  static late ChatUser me;

  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  static Future<void> getFireBaseMessagingToken() async {
    fMessaging.requestPermission();
    await fMessaging.getToken().then((value) {
      if (value != null) {
        me.pushToken = value;
        log('push token: $value');
      }
    });
    // what is this line do ? it will listen to messages that are sent to the current user and handle them
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   log('Got a message whilst in the foreground!');
    //   log('Message data: ${message.data}');
    //   if (message.notification != null) {
    //     log('Message also contained a notification: ${message.notification}');
    //   }
    // });
  }

  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      var body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": chatUser.name,
          "body": msg,
        },
        'data': {'some_data': 'User id: ${me.id}'},
        "android_channel_id": "Chats",
      };
      var res = await post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader:
              'key=AAAASDvZkqE:APA91bFTexgPhTn91ntOBxxdXT1gf12hfpdYdTlZXakLuXF0imVvkE1bOL3xSegZmoyksg4VUBuGGWaZFjg8HL4JrxPmFFVDYAtT2d7hWc8IHz8IPcKw_N-D6rxw5hc7Fhd9yxaVGfmU'
        },
        body: jsonEncode(body),
      );
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('Error when sending push notification: $e');
    }
  }

  // what is method userExists do ? it will check if user exists or not in firebase firestore database
  static Future<bool> userExists() async {
    return (await firebaseFirestore.collection('users').doc(user.uid).get())
        .exists;
  }

  // what is method addChatUser do ? it will add user to the current user's my_users collection in firebase firestore database and return true if the user exists
  static Future<bool> addChatUser(String email) async {
    final data = await firebaseFirestore
        .collection('users')
        .where("email",
            isEqualTo:
                email) // what is this line do ? it will get the user that has the same email that the user typed in the textfield
        .get();
    log("Data ${data.docs}");
    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      log("user exists : ${data.docs.first.data()}");
      // what is this line do ? it will add the user to the current user's my_users collection in firebase firestore database and return true if the user exists
      firebaseFirestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      // what is this line do ? it will return false if the user doesn't exist
      return false;
    }
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
        await getFireBaseMessagingToken();
        Apis.updateActiveStatus(true);
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

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firebaseFirestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
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

  // what is method getUserInfo do ? it will return user info from firebase firestore database as a stream of QuerySnapshot<Map<String, dynamic>>
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firebaseFirestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // what is method updateActiveStatus do ? it will update user active status in firebase firestore database by adding the time that the user was active to the user
  static Future<void> updateActiveStatus(bool isOnline) {
    return firebaseFirestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  // what is method getConversationId do ? it will return conversation id between current user and another user by comparing their ids and return the smallest one as a string
  static getConversationId(String id) =>
      user.uid.hashCode <= id.hashCode ? '${user.uid}-$id' : '$id-${user.uid}';

  // what is method getAllMessages do ? it will return all messages between current user and another user as a stream of QuerySnapshot<Map<String, dynamic>>
  // how to handle order of messages ? you can order messages by the time that they were sent
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser chatUser) {
    return firebaseFirestore
        .collection('chats/${getConversationId(chatUser.id!)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // what is method sendMessage do ? it will send message to another user by adding it to firebase firestore database
  static Future<void> sendMessage(
      String msg, ChatUser chatUser, Type type) async {
    final time = DateTime.now()
        .millisecondsSinceEpoch
        .toString(); // what is this line do ? it will get current time in milliseconds
    final message = Message(
      msg: msg,
      read: '',
      told: chatUser.id!,
      // what is told ? it is the id of the user that the message will be sent to
      type: type,
      fromId: user.uid,
      // what is fromId ? it is the id of the user that the message will be sent from
      sent: time,
    );
    final ref = firebaseFirestore
        .collection('chats/${getConversationId(chatUser.id!)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) {
      sendPushNotification(chatUser, type == Type.text ? msg : 'image');
    });
  }

  // what is method updateMessageReadStatus do ? it will update message read status in firebase firestore database by adding the time that the message was read to the message
  static Future<void> updateMessageReadStatus(Message message) async {
    final ref = firebaseFirestore
        .collection('chats/${getConversationId(message.fromId)}/messages/');
    await ref
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // what is method getLastMessages do ? it will return last message between current user and another user
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessages(
      ChatUser chatUser) {
    return firebaseFirestore
        .collection('chats/${getConversationId(chatUser.id!)}/messages/')
        .orderBy('sent',
            descending:
                true) // what is this line do ? it will order the messages by the time that they were sent
        .limit(1)
        .snapshots();
  }

  static sendChatImage(File file, ChatUser chatUser) async {
    final ext = file.path.split('.').last;
    final ref = firebaseStorage.ref().child(
        'image/${getConversationId(chatUser.id!)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {});
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(imageUrl, chatUser, Type.image);
  }

  static Future<void> deleteMessage(Message message) async {
    final ref = firebaseFirestore
        .collection('chats/${getConversationId(message.told)}/messages/');
    await ref.doc(message.sent).delete();
    if (message.type == Type.image) {
      await firebaseStorage.refFromURL(message.msg).delete();
    }
  }

  static Future<void> updateMessage(
      Message message, String updatingMessage) async {
    final ref = firebaseFirestore
        .collection('chats/${getConversationId(message.told)}/messages/');
    await ref.doc(message.sent).update(
      {'msg': updatingMessage},
    );
  }
}
