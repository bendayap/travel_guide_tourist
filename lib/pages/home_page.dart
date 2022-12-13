import 'package:travel_guide_tourist/imports.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final textController = TextEditingController();
  final digitController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  late String username;
  late int age;
  String tryDisplay = 'open';

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
            title: const Text('Home (Testing)'),
            backgroundColor: AppTheme.mainAppBar,
            centerTitle: true,
            actions: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/chatroom_list');
                    },
                    child: const Icon(
                        Icons.message
                    ),
                  )
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '');
                        },
                        child: const Text('Instant Order'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Booking'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: textController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter your username',
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: digitController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Age',
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          username = textController.text;
                          age = int.parse(digitController.text);
                          createUser(username: username, age: age);
                        },
                        child: const Text('Add User'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          username = textController.text;
                          age = int.parse(digitController.text);
                          createGuide(username: username, age: age);
                        },
                        child: const Text('Add Guide'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    ///LOGIN
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login_screen');
                        },
                        child: const Text('login page'),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup_screen');
                        },
                        child: const Text('sign up page'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Future createUser({required String username, required int age}) async {
    /// Reference to document
    final docUser = FirebaseFirestore.instance.collection('testUser').doc();

    final json = {
      'id': docUser.id,
      'username': username,
      'age': age,
      'birthday': DateTime(2004, 1, 1),
    };

    /// Create document and write data to Firebase
    await docUser.set(json);
  }

  Future createGuide({required String username, required int age}) async {
    final docUser = FirebaseFirestore.instance.collection('testGuide').doc();

    final testGuide = TestGuide(
      id: docUser.id,
      username: username,
      age: age,
      birthday: DateTime(2004, 1, 1),
    );
    final json = testGuide.toJson();

    await docUser.set(json);
  }
}
