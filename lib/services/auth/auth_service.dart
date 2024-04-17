import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier{
  // экзепляр класса аутентификации
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // экзепляр класса firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  //get current user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // вход в систему
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      // sign in
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

      // добавление нового документа для пользователя в коллекции пользователей, при условии, что он не существует
      _fireStore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
      }, SetOptions(merge: true));

      return userCredential;
    }
    on FirebaseAuthException catch(e) {
      throw Exception(e.code);
    }
  }

  // регстрация нового пользователя
  Future<UserCredential> signUpWithEmailAndPassword(String name, email, password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

      // после создания пользователя, создаём документ для пользователя в коллекции пользователей
      _fireStore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
      });

      return userCredential;
    }
    on FirebaseAuthException catch(e) {
      throw Exception(e.code);
    }
  }

  // выход из системы
  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }
}