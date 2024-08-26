import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/models/chat.dart';
import 'package:firebase/models/message.dart';
import 'package:firebase/models/user_profile.dart';
import 'package:firebase/services/auth_service.dart';
import 'package:firebase/utils.dart';
import 'package:get_it/get_it.dart';

class DatabaseService {
  final GetIt _getIt = GetIt.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  CollectionReference? _usersCollection;
  CollectionReference? _chatsCollection;
  late AuthService _authService;
  DatabaseService() {
    _setupCollectionReferences();
    _authService = _getIt.get<AuthService>();
  }
  void _setupCollectionReferences() {
    _usersCollection =
        _firebaseFirestore.collection('users').withConverter<UserProfile>(
            fromFirestore: (snapshot, _) => UserProfile.fromJson(
                  snapshot.data()!,
                ),
            toFirestore: (userProfile, _) => userProfile.toJson());

    _chatsCollection = _firebaseFirestore
        .collection('chats')
        .withConverter<Chat>(
            fromFirestore: (snampshot, _) => Chat.fromJson(snampshot.data()!),
            toFirestore: (chat, _) => chat.toJson());
  }

  Future<void> creatUserProfile({required UserProfile userProfile}) async {
    await _usersCollection?.doc(userProfile.uid).set(userProfile);
  }

  Stream<QuerySnapshot<UserProfile>> getUserProfiles() {
    return _usersCollection
        ?.where("uid", isNotEqualTo: _authService.user!.uid)
        .snapshots() as Stream<QuerySnapshot<UserProfile>>;
  }

  Future<bool> checkChatExist(String uid1, String uid2) async {
    String chatID = generatChatID(uid1: uid1, uid2: uid2);
    final result = await _chatsCollection?.doc(chatID).get();
    if (result != null) {
      return result.exists;
    }
    return false;
  }

  Future<void> createNewChat(String uid1, String uid2) async {
    String chatID = generatChatID(uid1: uid1, uid2: uid2);
    final docRef = _chatsCollection!.doc();
    final chat = Chat(
      id: chatID,
      messages: [],
      participants: [uid1, uid2],
    );
    await docRef.set(chat);
  }

  Future<void> sendChatMessage(
      String uid1, String uid2, Message message) async {
    String chatID = generatChatID(uid1: uid1, uid2: uid2);
    final docRef = _chatsCollection!.doc(chatID);
    //====================================
    var a =
        await FirebaseFirestore.instance.collection("chats").doc(chatID).get();
    if (a.exists) {
      final DocumentReference documentReference =
          FirebaseFirestore.instance.collection("chats").doc(chatID);
      return await documentReference.update({
        //your data
        "messages": FieldValue.arrayUnion(
          [
            message.toJson(),
          ],
        )
      });
    } else {
      final DocumentReference documentReference =
          FirebaseFirestore.instance.collection("chats").doc(chatID);
      return await documentReference.set({
        //your data
        "participants": [uid1, uid2],
        "messages": [message.toJson()],
      });
      //====================================
      // await docRef.update(
      //   {
      //     "messages": FieldValue.arrayUnion(
      //       [
      //         message.toJson(),
      //       ],
      //     )
      //   },
      // );
    }
  }

  Stream<DocumentSnapshot<Chat>> getChatData(String uid1, String uid2) {
    String chatID = generatChatID(uid1: uid1, uid2: uid2);
    return _chatsCollection?.doc(chatID).snapshots()
        as Stream<DocumentSnapshot<Chat>>;
  }
}
