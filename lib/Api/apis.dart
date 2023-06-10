import 'package:chat_app/models/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Apis {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  static User get user => auth.currentUser!;
  static late ChatUser me;

  static Future<bool> userExists() async {
    return (await firebaseFirestore.collection('users').doc(user.uid).get())
        .exists;
  }

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

  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      about: 'I\'m using chatty',
      createdAt: time,
      email: user.email.toString(),
      image: user.photoURL.toString(),
      isOnline: false,
      lastActive: time,
      pushToken: '',
    );
    return await firebaseFirestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firebaseFirestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }
}
