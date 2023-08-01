import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realtime_chat/colors.dart';
import 'package:realtime_chat/detail_cafe.dart';
import 'package:realtime_chat/features/auth/controller/auth_controller.dart';
import 'package:realtime_chat/features/chat/controller/chat_controller.dart';
import 'package:realtime_chat/features/recommendation/controller/recommendation_controller.dart';
import 'package:realtime_chat/features/recommendation/screen/maps_screen.dart';
import 'package:realtime_chat/screen/home_screen.dart';

class RecommendationScreen extends GetView<RecommendationController> {
  static const String routeName = '/recommendation-screen';
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController ctrl = Get.find();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 78.0,
        centerTitle: false,
        title: Column(
          children: [
            const SizedBox(
              height: 24,
            ),
            Image.asset(
              'assets/images/meetingyuk-logo.png',
              height: 28,
              semanticLabel: 'MeetingYuk Logo',
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: InkWell(
              onTap: () {
                Get.lazyPut(() => ChatController());
                Get.toNamed(HomeScreen.routeName);
              },
              child: Image.asset(
                'assets/images/chatbot-pp.png', // Replace with the path to your image asset
                width: 42.0, // Optional: set the width
                height: 42.0, // Optional: set the height
              ),
            ),
          ),
        ],
        foregroundColor: Colors.black,
        elevation: 1,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${ctrl.currentUser.value.name}',
                style: const TextStyle(
                  fontSize: 24.0,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  const Text('Your Location:'),
                  InkWell(
                    onTap: () {
                      Get.offAndToNamed(MapsScreen.routeName);
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: primaryColor,
                        ),
                        FutureBuilder<String?>(
                          future: ctrl.fetchCityName(
                              ctrl.currentUserLoc.value.latitude,
                              ctrl.currentUserLoc.value.longitude),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? 'Unknown City',
                              style: const TextStyle(
                                  color: primaryColor,
                                  fontSize: 16,
                                  decoration: TextDecoration.underline,
                                  decorationColor: primaryColor),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              const Text(
                'You Might Like These Merchants',
                style: TextStyle(fontSize: 21),
              ),
              SizedBox(
                height: 280,
                child: Obx(
                  () => controller.recommendationList.length.toString() == '0'
                      ? const Center(child: Text('No Merchants Near You'))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.recommendationList.length,
                          itemBuilder: ((context, index) {
                            double match = 0;
                            var placeData =
                                controller.recommendationList[index];
                            if((placeData.predictedRating / 5) * 100 >= 100) {
                              match = 100;
                            } else {
                              match = (placeData.predictedRating / 5) * 100;
                            }
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 8.0,
                              ),
                              child: Card(
                                // Wrapping the content in a Card
                                elevation:
                                    5.0, // Optional: Adjust elevation for shadow effect
                                shape: RoundedRectangleBorder(
                                  // Optional: Rounded border for the card
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    controller.selectMerchant(
                                      placeData.id,
                                      placeData.address,
                                      placeData.imageUrl,
                                      placeData.name,
                                      placeData.distance,
                                      placeData.predictedRating,
                                      placeData.ratings,
                                      placeData.reviewCount,
                                    );
                                    Get.toNamed(DetailCard.routeName);
                                  },
                                  child: SizedBox(
                                    height: 100,
                                    width:
                                        160.0, // Optional: You can adjust the width to your requirement
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 100.0, // Adjusted the height
                                          width: double
                                              .infinity, // Takes full width of the card
                                          child: ClipRRect(
                                            // To clip the image and give it rounded corners
                                            borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(10.0),
                                            ),
                                            child: Image.network(
                                              placeData.imageUrl,
                                              fit: BoxFit
                                                  .cover, // To cover the entire space of the SizedBox
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          // Added padding for better layout
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                placeData.name,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                              Text(
                                                placeData.address,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style: const TextStyle(
                                                  fontSize: 14.0,
                                                ),
                                              ),
                                              Text(
                                                "${match.toStringAsFixed(1)} % match",
                                                style: const TextStyle(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              Text(
                                                "${(placeData.distance).toStringAsFixed(1)} km",
                                                style: const TextStyle(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              const Text(
                'Merchants Nearby',
                style: TextStyle(fontSize: 21),
              ),
              SizedBox(
                height: 280,
                child: Obx(
                  () => controller.nearbyList.length.toString() == '0'
                      ? const Center(child: Text('No Merchants Near You'))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.nearbyList.length,
                          itemBuilder: ((context, index) {
                            var placeData = controller.nearbyList[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 8.0,
                              ),
                              child: Card(
                                // Wrapping the content in a Card
                                elevation:
                                    5.0, // Optional: Adjust elevation for shadow effect
                                shape: RoundedRectangleBorder(
                                  // Optional: Rounded border for the card
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    controller.selectMerchant(
                                      placeData.id,
                                      placeData.address,
                                      placeData.imageUrl,
                                      placeData.name,
                                      placeData.distance,
                                      placeData.predictedRating,
                                      placeData.ratings,
                                      placeData.reviewCount,
                                    );
                                    Get.toNamed(DetailCard.routeName);
                                  },
                                  child: SizedBox(
                                    height: 100,
                                    width:
                                        160.0, // Optional: You can adjust the width to your requirement
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 100.0, // Adjusted the height
                                          width: double
                                              .infinity, // Takes full width of the card
                                          child: ClipRRect(
                                            // To clip the image and give it rounded corners
                                            borderRadius:
                                                const BorderRadius.vertical(
                                              top: Radius.circular(10.0),
                                            ),
                                            child: Image.network(
                                              placeData.imageUrl,
                                              fit: BoxFit
                                                  .cover, // To cover the entire space of the SizedBox
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          // Added padding for better layout
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                placeData.name,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                              Text(
                                                placeData.address,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style: const TextStyle(
                                                  fontSize: 14.0,
                                                ),
                                              ),
                                              Text(
                                                "${placeData.distance.toStringAsFixed(1)} km",
                                                style: const TextStyle(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
