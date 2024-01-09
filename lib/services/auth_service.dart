part of '../main.dart';

class AuthService {
  _writeUserToDatabase(UserCredential result, String username) {
    if (result.user != null) {
      String uid = result.user!.uid;
      try {
        FirebaseFirestore db = FirebaseFirestore.instance;
        db
            .collection("users")
            .doc(uid)
            .set({"username": username, "displayName": username});
        return true;
      } catch (e) {
        if (FirebaseAuth.instance.currentUser != null) {
          FirebaseAuth.instance.currentUser!.delete();
        }
      }
    }
    return false;
  }

  Future<bool> signInWithGoogle() async {
    try {
      GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'https://www.googleapis.com/auth/userinfo.email',
          'https://www.googleapis.com/auth/userinfo.profile',
        ],
      );

      GoogleSignInAccount? gUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication gAuth = await gUser!.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken, idToken: gAuth.idToken);

      var result = await FirebaseAuth.instance.signInWithCredential(credential);
      if (result.user != null && result.additionalUserInfo!.isNewUser) {
        String username = result.user!.displayName!;
        return _writeUserToDatabase(result, username);
      } else {
        return true;
      }
    } catch (e) {
      return false;
    }
  }
}
