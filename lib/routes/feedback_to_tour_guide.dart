
import 'package:travel_guide_tourist/imports.dart';

class FeedbackToTourGuide extends StatefulWidget {

  const FeedbackToTourGuide({
    Key? key,
  }) : super(key: key);

  @override
  State<FeedbackToTourGuide> createState() => _FeedbackToTourGuideState();
}

class _FeedbackToTourGuideState extends State<FeedbackToTourGuide> {
  final formKey = GlobalKey<FormState>();
  final ratingController = TextEditingController();
  final tourDateController = TextEditingController();
  final contentController = TextEditingController();

  @override
  void dispose() {
    ratingController.dispose();
    tourDateController.dispose();
    contentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var data = (ModalRoute.of(context)!.settings.arguments as Map);

    return GestureDetector(
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
          title: const Text('Rate & Feedback'),
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
                const SizedBox(height: 20),
                const Text('Rate'),
                const SizedBox(height: 20),
                TextFormField(
                  ///Budget Field
                  controller: ratingController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Rating'),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => value != null && value.isEmpty
                      ? 'Enter a number'
                      : null,
                ),
                const SizedBox(height: 4),
                TextFormField(
                  ///Content Field
                  controller: contentController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(labelText: 'Content'),
                  initialValue: null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontSize: 24),
                  ),
                  onPressed: () {
                      feedbackToTourGuide(data['feedbackId'], data['tourGuideId'], data['touristId']);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future feedbackToTourGuide(String feedbackId, String tourGuideId, String touristId)
  async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    if (FirebaseAuth.instance.currentUser != null) {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      var content = contentController.text;
      var rating = num.parse(ratingController.text);

      HistoryFeedback feedback = HistoryFeedback(
        feedbackId: feedbackId,
        toId: tourGuideId,
        fromId: touristId,
        feedbackDate: DateTime.now(),
        content: content,
        rating: rating,
      );

      await firestore
          .collection("feedbacks")
          .doc(feedbackId)
          .set(feedback.toJson());

      ///TODO: Update Tour Guide Rating and RateNumber
      // num currentRating;
      // await firestore.collection('tourGuides').get().then((snapshot) {
      //   currentRating = snapshot.data['rating'] * snapshot.data['rateNumber'];
      // });

      // final tourGuideDoc = firestore.collection('tourGuides')
      //     .doc(tourGuideId);
      // tourGuideDoc.update({
      //   'rating':
      // })
    }

    navigatorKey.currentState!.pop();
    navigatorKey.currentState!.pop();
    Utils.showSnackBarSuccess('Feedback Submitted');
  }
}
