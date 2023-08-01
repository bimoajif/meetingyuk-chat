import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:realtime_chat/colors.dart';
import 'package:realtime_chat/features/auth/controller/auth_controller.dart';
import 'package:realtime_chat/features/chat/controller/chat_controller.dart';
import 'package:realtime_chat/features/chat/screen/chat_screen.dart';
import 'package:realtime_chat/features/recommendation/controller/recommendation_controller.dart';
import 'package:realtime_chat/screen/home_screen.dart';

class DetailCard extends GetView<ChatController> {
  static const String routeName = '/detail-card';
  const DetailCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authCtrl = Get.find();
    final RecommendationController recCtrl = Get.find();
    Get.put(ChatController());
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            elevation: 0,
            leading: const Padding(
              padding: EdgeInsets.only(
                left: 10,
                bottom: 10,
              ),
              // child: IconButton(
              //     onPressed: () {},
              //     icon: Icon(Icons.arrow_back_ios_new_sharp, size: 20)),
            ),
            backgroundColor: Colors.white,
            expandedHeight: 215,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                recCtrl.selectedMerchant.value.imageUrl,
                height: 215,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        strokeAlign: BorderSide.strokeAlignInside,
                        color: Color(0xFFC7C7c7),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Text(
                            'Open',
                          ),
                          SizedBox(width: 4),
                          Text(
                            'until 09:00 PM',
                          )
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recCtrl.selectedMerchant.value.name,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_sharp,
                            size: 24,
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          Expanded(
                            child: Text(
                              recCtrl.selectedMerchant.value.address,
                              overflow: TextOverflow.clip,
                              maxLines: 2,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 12,
                          ),
                          Icon(
                            Icons.star_rounded,
                            size: 12,
                          ),
                          Icon(
                            Icons.star_rounded,
                            size: 12,
                          ),
                          Icon(
                            Icons.star_rounded,
                            size: 12,
                          ),
                          Icon(
                            Icons.star_half_rounded,
                            size: 12,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            '${recCtrl.selectedMerchant.value.ratings} / 5,0',
                          )
                        ],
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () {
                          controller
                              .getChatId(recCtrl.selectedMerchant.value.name)
                              .then((result) {
                            if (result['chatId'] == 'NOT FOUND') {
                              controller.initiateChat(
                                recCtrl.selectedMerchant.value.id,
                                recCtrl.selectedMerchant.value.name,
                                recCtrl.selectedMerchant.value.imageUrl,
                                // '9lCb0V9FVtvI9qHuZhJmqw',
                                // 'MeetingYuk Creative Workspace',
                                // 'https://assets.ayobandung.com/crop/0x0:0x0/x/photo/2023/03/05/cronica-1-2935488603.png',
                                authCtrl.currentUser.value.isMerchant == 0
                                    ? dotenv.get('USER_PUBKEY', fallback: "0")
                                    : dotenv.get('MERCHANT_PUBKEY',
                                        fallback: "0"),
                                dotenv.get('MERCHANT_PUBKEY', fallback: "0"),
                              );
                              Get.toNamed(HomeScreen.routeName);
                            } else {
                              controller.selectChat(
                                result['chatId'],
                                recCtrl.selectedMerchant.value.id,
                                recCtrl.selectedMerchant.value.name,
                                recCtrl.selectedMerchant.value.imageUrl,
                                // '9lCb0V9FVtvI9qHuZhJmqw',
                                // 'MeetingYuk Creative Workspace',
                                // 'https://assets.ayobandung.com/crop/0x0:0x0/x/photo/2023/03/05/cronica-1-2935488603.png',
                                result['roomKey'],
                              );
                              Get.toNamed(HomeScreen.routeName);
                              Get.toNamed(ChatScreen.routeName);
                            }
                          });
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.chat,
                                color: Color(0xFF5ABCD0),
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                'Chat Now',
                                style: TextStyle(
                                  color: Color(0xFF5ABCD0),
                                  fontWeight: FontWeight.w800,
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 9,
                ),
                Container(
                  margin: const EdgeInsets.only(
                      left: 7.5, right: 7.5, top: 10, bottom: 15),
                  padding: const EdgeInsets.only(
                    left: 16,
                    top: 15,
                    right: 16,
                    bottom: 15,
                  ),
                  decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            spreadRadius: 0,
                            offset: Offset(0, 4.0))
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person_pin_circle,
                        size: 64,
                        color: primaryColor,
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Distance From You:',
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Text(
                            "${recCtrl.selectedMerchant.value.distance.toStringAsFixed(1)} km",
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 24),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                      left: 7.5, right: 7.5, top: 10, bottom: 15),
                  padding: const EdgeInsets.only(
                    left: 16,
                    top: 10,
                    right: 16,
                    bottom: 10,
                  ),
                  decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            spreadRadius: 0,
                            offset: Offset(0, 4.0))
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Facilities',
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.tv_rounded,
                              size: 22,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Text(
                                'Television',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.wifi_rounded,
                              size: 22,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Text(
                                'Wifi',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.air_rounded,
                              size: 22,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Text(
                                'Air Conditioner',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.speaker_sharp,
                              size: 22,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Text(
                                'Sound System',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.local_parking_rounded,
                              size: 22,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Text(
                                'Free Parking',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.only(left: 7.5, right: 7.5, bottom: 15),
                  padding: const EdgeInsets.only(
                      left: 5, top: 10, right: 5, bottom: 10),
                  decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          spreadRadius: 0,
                          offset: Offset(0, 4.0),
                        )
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Location'),
                      const SizedBox(height: 10),
                      // GoogleMapImage(
                      //     apiKey: 'AIzaSyBEISB8hHC1XiisTkTxRSi0Ot8Pi3tIwtk',
                      //     cafeName: 'Cronica Creative',
                      //     width: 350,
                      //     height: 145),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 8,
                          bottom: 0,
                          left: 10,
                          right: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                recCtrl.selectedMerchant.value.address,
                              ),
                            ),
                            InkWell(
                              onTap: () {},
                              child: Container(
                                margin: const EdgeInsets.only(left: 15),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(width: 1)),
                                height: 19,
                                width: 35,
                                child: IconButton(
                                  padding: const EdgeInsets.all(0),
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  icon: const Icon(
                                    Icons.turn_right,
                                    size: 16,
                                  ),
                                  onPressed: () {},
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(
                      left: 5, top: 15, right: 5, bottom: 15),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Where do you want to meet ?'),
                      SizedBox(height: 10),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      //
    );
  }
}
