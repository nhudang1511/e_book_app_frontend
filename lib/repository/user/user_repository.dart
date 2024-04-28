import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'base_user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_book_app/model/models.dart' as model;

class UserRepository extends BaseUserRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firebaseFirestore;
  final FirebaseStorage _firebaseStorage;

  UserRepository(
      {FirebaseAuth? firebaseAuth,
      FirebaseFirestore? firebaseFirestore,
      FirebaseStorage? firebaseStorage})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance,
        _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance;

  @override
  Future<String> uploadAvatar({required File? fileAvatar}) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      final ref = _firebaseStorage.ref().child("avatar_user/$fileName.jpg");
      await ref.putFile(
          fileAvatar!, SettableMetadata(contentType: 'image/jpeg'));

      final url = await ref.getDownloadURL();
      return url.toString();
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> updateUser(model.User user) async {
    await _firebaseFirestore
        .collection('users')
        .doc(user.uid)
        .update(user.toDocument());
  }

  @override
  Future<void> addUser(model.User user) async {
    await _firebaseFirestore
        .collection('users')
        .doc(user.uid)
        .set(user.toDocument());
  }

  @override
  Future<model.User?> getProfile({required User user}) async {
    return model.User.fromFirebaseUser(user);
  }

  @override
  Stream<List<model.User>> getAllUsers() {
    return _firebaseFirestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => model.User.fromSnapshot(doc)).toList();
    });
  }
}
