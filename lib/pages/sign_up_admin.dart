import 'package:travel_guide_tourist/imports.dart';
import 'package:travel_guide_tourist/models/admin.dart';

class SignUpAdminScreen extends StatefulWidget {

  const SignUpAdminScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<SignUpAdminScreen> createState() => _SignUpAdminScreenState();
}

class _SignUpAdminScreenState extends State<SignUpAdminScreen> {
  String adminKeyValidator = 'IamAdmin';
  final formKey = GlobalKey<FormState>();
  final adminKeyController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  @override
  void dispose() {
    adminKeyController.dispose();
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
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
        title: const Text('Sign Up Admin'),
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
              // Image.file(File("/images/travel_guide_logo.png")),
              const SizedBox(height: 20),
              // const Text(
              //   'Hey There, \n Welcome back',
              //   textAlign: TextAlign.center,
              //   style: TextStyle(fontSize: 32),
              // ),
              const SizedBox(height: 40),
              TextFormField(
                ///Admin Key Field
                controller: adminKeyController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: 'Admin Key'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value != null && value.isEmpty
                    ? 'Enter an admin key'
                    : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                ///Email Field
                controller: emailController,
                textInputAction: TextInputAction.done,
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
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: 'Username'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value != null && value.isEmpty
                    ? 'Enter a username'
                    : null,
              ),
              const SizedBox(height: 4),
              TextFormField(
                ///Password Field
                controller: passwordController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value != null && value.length < 6
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
            ],
          ),
        ),
      ),
    ),
  );

  Future signUp() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    String adminKey = adminKeyController.text.trim();
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

    if (adminKey != adminKeyValidator) {
      Utils.showSnackBar('Admin Key Incorrect');
      return
      navigatorKey.currentState!.pop();
    }

    try {
      UserCredential cred =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      ///Create tourist document
      AdminAccount admin = AdminAccount(
        uid: cred.user!.uid,
        username: username,
        email: email,
      );

      await firestore
          .collection("admins")
          .doc(cred.user!.uid)
          .set(admin.toJson());

    } on FirebaseAuthException catch (e) {
      Utils.showSnackBar(e.message);
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}
