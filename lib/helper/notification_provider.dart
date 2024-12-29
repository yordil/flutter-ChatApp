import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void setOnlineStatus(bool isOnline) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'isOnline': isOnline,
      });
    }
  }

  void setupOnlineStatusListener() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        // Set to online when logged in
        setOnlineStatus(true);

        // Set to offline when the app is closed
        _firestore.collection('users').doc(user.uid).snapshots().listen((_) {
          setOnlineStatus(false);
        });
      }
    });
  }
}
