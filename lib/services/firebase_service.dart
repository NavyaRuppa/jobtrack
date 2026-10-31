import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

/// Owns Firebase availability so the app can run locally until platform
/// configuration (google-services.json/GoogleService-Info.plist/web options)
/// is supplied.
class FirebaseService {
  FirebaseService._();

  static final FirebaseService instance = FirebaseService._();

  bool _initialized = false;
  bool _attempted = false;

  bool get isAvailable => _initialized;

  firebase_auth.FirebaseAuth? get auth =>
      _initialized ? firebase_auth.FirebaseAuth.instance : null;

  FirebaseFirestore? get firestore =>
      _initialized ? FirebaseFirestore.instance : null;

  Future<void> initialize() async {
    if (_attempted) return;
    _attempted = true;
    try {
      await Firebase.initializeApp();
      _initialized = true;
    } on FirebaseException {
      // Firebase is optional until the host app supplies its platform config.
      _initialized = false;
    } on MissingPluginException {
      _initialized = false;
    } on PlatformException {
      _initialized = false;
    } on AssertionError {
      // Flutter Web asserts when initializeApp is called without options.
      // This means Firebase is not configured yet, so use the local store.
      _initialized = false;
    }
  }
}
