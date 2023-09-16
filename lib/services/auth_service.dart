part of main;

class AuthService {
  _writeUserToDatabase(UserCredential result, String username) {
    if (result.user != null) {
      String uid = result.user!.uid;
      try {
        DatabaseReference ref = FirebaseDatabase.instance.ref("users/$uid");
        ref.update({
          "username": username,
          "displayName": username,
        });
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
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken, idToken: gAuth.idToken);

    try {
      print("try print");
      var result = await FirebaseAuth.instance.signInWithCredential(credential);
      if (result.user != null && result.additionalUserInfo!.isNewUser) {
        print("if print");
        String username = result.user!.displayName!;
        return _writeUserToDatabase(result, username);
      } else {
        return true;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }
}
