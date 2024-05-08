// ignore_for_file: use_build_context_synchronously

/*
  [Title]
  SignupPage

  [Description]
  Contains options to sign up for an account using credentials.
  Call-to-action text may be tapped to go back to LoginPage.
  Visited when the user taps on a call-to-action text from LoginPage.
*/

part of '../main.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _inputEmail = TextEditingController();
  final _inputUsername = TextEditingController();
  final _inputPassword = TextEditingController();

  // Checks if the email field is empty and returns an error message if so.
  String? _verifyEmailField(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.emailEmptyError;
    }
    return null;
  }

  // Checks if the username field is empty and returns an error message if so.
  String? _verifyUsernameField(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.usernameEmptyError;
    }
    return null;
  }

  // Checks if the password field is empty or of short length and returns an error message if so.
  String? _verifyPasswordField(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.passwordEmptyError;
    } else if (value.length < 8) {
      return AppLocalizations.of(context)!.passwordLengthError;
    }
    return null;
  }

  // Writes new user information to the database with the specified credentials. Displays a
  // snackbar message on success.
  void _writeUserToDatabase(UserCredential result, String username) {
    if (result.user != null) {
      String uid = result.user!.uid;
      try {
        FirebaseFirestore db = FirebaseFirestore.instance;
        db
            .collection("users")
            .doc(uid)
            .set({"username": username, "displayName": username});
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.accountCreationSuccessful,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                        fontFamily: 'Bahnschrift',
                        fontVariations: const [
                          FontVariation('wght', 350),
                          FontVariation('wdth', 100),
                        ],
                      )),
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
          );
        }
      } catch (e) {
        if (FirebaseAuth.instance.currentUser != null) {
          FirebaseAuth.instance.currentUser!.delete();
        }
        return;
      }
    }
  }

  // Creates a new user with the specified credentials. Displays a snackbar message if an
  // error occurs.
  void _signupUser(String email, String username, String password) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((result) {
        _writeUserToDatabase(result, username);
      });
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage =
              AppLocalizations.of(context)!.signupSnackbarEmailInUseError;
          break;
        case 'invalid-email':
          errorMessage =
              AppLocalizations.of(context)!.signupSnackbarEmailInvalidError;
          break;
        default:
          errorMessage =
              AppLocalizations.of(context)!.signupSnackbarGenericError;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
                fontFamily: 'Source Sans 3',
                fontVariations: const [
                  FontVariation('wght', 400),
                ],
              )),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: ListView(
            children: [
              const SizedBox(height: 70),
              Text(
                AppLocalizations.of(context)!.signupTitle,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontVariations: [
                    FontVariation('wght', 700),
                  ],
                  fontSize: 50,
                  height: 0.8,
                  letterSpacing: -0.7,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppLocalizations.of(context)!.email,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontFamily: 'Source Sans 3',
                            fontVariations: const [
                              FontVariation('wght', 400),
                            ],
                            fontSize: 16),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: _inputEmail,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        hintText: AppLocalizations.of(context)!.emailHint,
                        hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.outline),
                        filled: true,
                        fillColor:
                            Theme.of(context).colorScheme.surfaceVariant,
                        isDense: true,
                      ),
                      style: const TextStyle(
                        fontFamily: 'Source Sans 3',
                        fontVariations: [
                          FontVariation('wght', 400),
                        ],
                        fontSize: 14,
                      ),
                      validator: (String? value) {
                        return _verifyEmailField(value);
                      },
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppLocalizations.of(context)!.username,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontFamily: 'Source Sans 3',
                            fontVariations: const [
                              FontVariation('wght', 400),
                            ],
                            fontSize: 16),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: _inputUsername,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        hintText: AppLocalizations.of(context)!.usernameHint,
                        hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.outline),
                        filled: true,
                        fillColor:
                            Theme.of(context).colorScheme.surfaceVariant,
                        isDense: true,
                      ),
                      style: const TextStyle(
                        fontFamily: 'Source Sans 3',
                        fontVariations: [
                          FontVariation('wght', 400),
                        ],
                        fontSize: 14,
                      ),
                      validator: (String? value) {
                        return _verifyUsernameField(value);
                      },
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppLocalizations.of(context)!.password,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontFamily: 'Source Sans 3',
                            fontVariations: const [
                              FontVariation('wght', 400),
                            ],
                            fontSize: 16),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: _inputPassword,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        hintText: AppLocalizations.of(context)!.passwordHint,
                        hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.outline),
                        filled: true,
                        fillColor:
                            Theme.of(context).colorScheme.surfaceVariant,
                        isDense: true,
                      ),
                      style: const TextStyle(
                          fontFamily: 'Source Sans 3',
                          fontVariations: [
                            FontVariation('wght', 400),
                          ],
                          fontSize: 14),
                      obscureText: true,
                      validator: (String? value) {
                        return _verifyPasswordField(value);
                      },
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                {
                                  _signupUser(_inputEmail.text,
                                      _inputUsername.text, _inputPassword.text);
                                }
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  Theme.of(context).colorScheme.primary),
                              foregroundColor: MaterialStatePropertyAll(
                                  Theme.of(context).colorScheme.onPrimary),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                AppLocalizations.of(context)!.signup,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontFamily: 'Manrope',
                                  fontVariations: const [
                                    FontVariation('wght', 700),
                                  ],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    TextButton(
                      onPressed: () {
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context)!.loginPush,
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            decoration: TextDecoration.underline,
                            decorationColor:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontFamily: 'Source Sans 3',
                            fontVariations: const [
                              FontVariation('wght', 400),
                            ],
                            fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
