import 'package:flutter/material.dart';


class LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 100,
              width: 100,
              // child: Image(
              //   image: AssetImage('../images/travel_guide_logo.png'),
              // ),
            ),
            const SizedBox(height: 30.0),
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20.0),
            Text(
              "Preparing the data ...",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              "Please wait for a moment ...",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}