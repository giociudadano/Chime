// ignore_for_file: use_build_context_synchronously

/*
  [Title]
  LoginPage

  [Description]
  Contains options to login using credentials or one-tap authentication.
  Call-to-action text may be tapped to sign up the user.
  Visited when the user is logged out or when the user exits OnBoardingPage for the first time.
*/

part of '../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Variables for controllers.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _inputEmail = TextEditingController();
  final _inputPassword = TextEditingController();

  // Checks if the email field is empty and returns an error if so.
  String? _verifyEmailField(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.emailEmptyError;
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

  // Logs in the user using the passed credentials. If an exception occurs, displays that error
  // using a snackbar. Otherwise, redirects to HomePage.
  void _loginUser(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomePage()),
            (Route<dynamic> route) => false);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
          errorMessage =
              AppLocalizations.of(context)!.loginSnackbarIncorrectPasswordError;
          break;
        case 'invalid-email':
          errorMessage =
              AppLocalizations.of(context)!.loginSnackbarInvalidEmailError;
          break;
        default:
          errorMessage =
              AppLocalizations.of(context)!.loginSnackbarGenericError;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontSize: 14,
                fontFamily: 'Source Sans 3',
                fontVariations: const [
                  FontVariation('wght', 400),
                ],
              )),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
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
                AppLocalizations.of(context)!.loginTitle,
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
                            color:
                                Theme.of(context).colorScheme.outline),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceVariant,
                        isDense: true,
                      ),
                      style: const TextStyle(
                          fontFamily: 'Source Sans 3',
                          fontVariations: [
                            FontVariation('wght', 400),
                          ],
                          fontSize: 14),
                      validator: (String? value) {
                        return _verifyEmailField(value);
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
                            color:
                                Theme.of(context).colorScheme.outline),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceVariant,
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
                                  _loginUser(
                                      _inputEmail.text, _inputPassword.text);
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
                                AppLocalizations.of(context)!.login,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontFamily: 'Manrope',
                                  fontVariations: const [
                                    FontVariation('wght', 700),
                                  ],
                                  fontSize: 14,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                              thickness: 0.5,
                              color:
                                  Theme.of(context).colorScheme.outlineVariant),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            AppLocalizations.of(context)!.loginServices,
                            style: TextStyle(
                                fontFamily: 'Source Sans 3',
                                fontSize: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          color: Theme.of(context).colorScheme.surfaceVariant,
                        ),
                        height: 50,
                        width: 50,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: IconButton(
                              icon: Image.asset(
                                  'lib/assets/images/service_google.png'),
                              onPressed: () async {
                                await AuthService()
                                    .signInWithGoogle()
                                    .then((response) {
                                  if (context.mounted && response == true) {
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) => HomePage()),
                                        (Route<dynamic> route) => false);
                                  }
                                });
                              }),
                        )),
                    const SizedBox(height: 36),
                    TextButton(
                      onPressed: () {
                        if (context.mounted) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const SignupPage()));
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context)!.signupPush,
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
