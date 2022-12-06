import 'package:travel_guide_tourist/imports.dart';

class SignUpScreen extends StatefulWidget {
  final Function() onClickedSignIn;

  const SignUpScreen({
    Key? key,
    required this.onClickedSignIn,
  }) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            currentFocus.focusedChild?.unfocus();
          }
        },
        child: Scaffold(
          backgroundColor: AppTheme.mainBackground,
          appBar: AppBar(
            title: const Text('Sign Up'),
            backgroundColor: AppTheme.mainAppBar,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  // const FlutterLogo(size: 120),
                  const SizedBox(height: 20),
                  const Text(
                    'Hey There, \n Welcome back',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    ///Email Field
                    controller: emailController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Email'),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (email) =>
                    email != null && !EmailValidator.validate(email)
                        ? 'Enter a valid email'
                        : null,
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    ///Username Field
                    controller: usernameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Username'),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) =>
                    value != null && value.isEmpty
                        ? 'Enter a username'
                        : null,
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    ///Password Field
                    controller: passwordController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) =>
                    value != null && value.length < 6
                        ? 'Enter minimum 6 characters'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    icon: const Icon(Icons.arrow_forward, size: 32),
                    label: const Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 24),
                    ),
                    onPressed: signUp,
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 20),
                      text: 'Already have an account?   ',
                      children: [
                        TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = widget.onClickedSignIn,
                          text: 'Log In',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Theme
                                .of(context)
                                .colorScheme
                                .secondary,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );

  Future signUp() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String username = usernameController.text.trim();

    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      UserCredential cred  = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      Tourist tourist = Tourist(
        uid: cred.user!.uid,
        username: username,
        fullname: "",
        phoneNumber: "",
        email: email,
        icNumber: "",
        photoUrl: "",
        description: "",
        rating: 0,
      );

      await firestore
          .collection("tourists")
          .doc(cred.user!.uid)
          .set(tourist.toJson());
    } on FirebaseAuthException catch (e) {
      Utils.showSnackBar(e.message);
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  // Future createTourist({required String username, required int age}) async {
  //   final docUser = FirebaseFirestore.instance.collection('tourists').doc();
  //   final user = FirebaseAuth.instance.currentUser!;
  //
  //   final tourist = Tourists(
  //     uid:
  //
  //     id: docUser.id,
  //     username: username,
  //     age: age,
  //     birthday: DateTime(2004, 1, 1),
  //   );
  //   final json = testGuide.toJson();
  //
  //   await docUser.set(json);
  // }
}
