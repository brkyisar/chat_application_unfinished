import 'dart:developer';
import 'dart:io';

import 'package:chat_application/models/chat_user.dart';
import 'package:chat_application/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class APIs {
  //authentication için
  static FirebaseAuth auth = FirebaseAuth.instance;

  //cloud database için
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //cloud database için
  static FirebaseStorage storage = FirebaseStorage.instance;

  //current useri döndürme
  static User get user => auth.currentUser!;

  //self information depolama
  static late ChatUser me;

  //kullanıcı var mı yok mu
  static Future<bool> userExists() async {
    return (await firestore
            .collection("users")
            .doc(auth.currentUser!.uid)
            .get())
        .exists;
  }

  //kullanıcı bilgilerini almak
  static Future<void> getSelfInfo() async {
    return await firestore
        .collection("users")
        .doc(auth.currentUser!.uid)
        .get()
        .then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        log('My data: ${user.data()}');
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  //yeni kullanıcı oluşturmak
  static Future<void> createUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: "Merhaba, ben chat kullanıyorum",
        image: user.photoURL.toString(),
        olusturulmaTarihi: time,
        onlineMi: false,
        sonGorulme: time,
        pushToken: "");

    return await firestore
        .collection("users")
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  //firestore databaseden bütün kullanıcıları almak için

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser() {
    return firestore
        .collection("users")
        .where("id", isNotEqualTo: user.uid)
        .snapshots();
  }

  static Future<void> updateUserInfo() async {
    await firestore.collection("users").doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  //profil resmi güncelleme
  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split(".").last;
    log("extension: $ext");
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });
    me.image = await ref.getDownloadURL();
    await firestore
        .collection("users")
        .doc(user.uid)
        .update({'image': me.image});
  }

  // KONUSMA EKRANI //

  //conservation id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  //firestore dan bütün mesajları almak için
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection("chats/${getConversationID(user.id)}/messages/")
        .snapshots();
  }

  //mesaj yollamak icin
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final Message message = Message(
        msg: msg,
        read: '',
        told: chatUser.id,
        type: type,
        sent: time,
        fromId: user.uid);

    final ref = firestore
        .collection("chats/${getConversationID(chatUser.id)}/messages/");
    await ref.doc(time).set(message.toJson());
  }

  //okuma durumunu güncellemek için
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //son mesajı gostermek icin
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  //resim göndermek icin
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split(".").last;

    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });
    final imageUrl = await ref.getDownloadURL();
    await APIs.sendMessage(chatUser, imageUrl, Type.image);
  }
}
