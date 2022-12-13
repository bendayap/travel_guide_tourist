// ignore_for_file: depend_on_referenced_packages, prefer_typing_uninitialized_variables

import 'package:travel_guide_tourist/imports.dart';
import 'package:intl/intl.dart';

class MessageCard extends StatefulWidget {
  final snap;
  final String touristName;
  final String tourGuideName;

  const MessageCard({
    Key? key,
    required this.snap,
    required this.touristName,
    required this.tourGuideName,
  }) : super(key: key);

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  bool isLoading = false;
  var packageData = {};

  @override
  void initState() {
    super.initState();
    getPackageData();
  }

  getPackageData() async {
    setState(() {
      isLoading = true;
    });

    if (widget.snap["type"] == "package") {
      try {
        var packageSnap = await FirebaseFirestore.instance
            .collection('tourPackages')
            .doc(widget.snap["content"])
            .get();

        if (packageSnap.exists) {
          packageData = packageSnap.data()!;
        }

        setState(() {});
      } catch (e) {
        Utils.showSnackBar(e.toString());
      }

    }
    setState(() {
      isLoading = false;
    });
  }


  final DateFormat formatter = DateFormat('dd MMM, H:mm');

  @override
  Widget build(BuildContext context) {
    double width = (MediaQuery.of(context).size.width);
    bool isOwner = widget.snap["fromId"] == FirebaseAuth.instance.currentUser!.uid;


    return Container(
        width: width,
        alignment: isOwner ? Alignment.centerRight : Alignment.centerLeft,
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        decoration: const BoxDecoration(
        ),
        child: Column(
          crossAxisAlignment: isOwner ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              isOwner ? widget.touristName : widget.tourGuideName,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 2,
              ),
            ),
            widget.snap["type"] == "text" ? (
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                  decoration: BoxDecoration(
                    color: isOwner ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.background,
                    border: Border.all(color: isOwner ?
                    Theme.of(context).colorScheme.background
                        : Theme.of(context).colorScheme.primary
                    ),
                    borderRadius: BorderRadius.circular(5),
                    // boxShadow: const [ AppTheme.boxShadow ],
                  ),
                  child: Text(
                    widget.snap["content"],
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ) ) : (
                packageData["packageTitle"] != null ?
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/tour_package_detail', arguments: {
                      "packageId": packageData['packageId'],
                      "packageTitle": packageData['packageTitle'],
                      "ownerId": packageData['ownerId'],
                      "packageType": packageData['packageType'],
                      "content": packageData['content'],
                      "price": packageData['price'],
                      "duration": packageData['duration'],
                      "stateOfCountry": packageData['stateOfCountry'],
                      "createDate": packageData['createDate'],
                      "lastModifyDate": packageData['lastModifyDate'],
                    });
                  },
                    child: Container(
                      width: 140,
                      decoration: BoxDecoration(
                        color: isOwner ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.background,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5.0),
                            child: packageData["photoUrl"] != null ? Image.network(
                              packageData["photoUrl"],) : const SizedBox(),
                          ),
                          Text(
                            packageData["packageTitle"],
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),

                        ],
                      ),
                    )
                ) : Container(
                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                  decoration: BoxDecoration(
                    color: isOwner ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.background,
                    border: Border.all(color: isOwner ?
                    Theme.of(context).colorScheme.background
                        : Theme.of(context).colorScheme.primary
                    ),
                    borderRadius: BorderRadius.circular(5),
                    // boxShadow: const [ AppTheme.boxShadow ],
                  ),
                  child: const Text(
                    "<This package may have been deleted by the tour guide>",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                )
            ),

            Text(
              formatter.format(widget.snap["timestamp"].toDate()),
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        )
    );
  }
}