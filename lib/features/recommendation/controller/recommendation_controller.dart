// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:realtime_chat/common/utils/util.dart';
import 'package:realtime_chat/features/auth/controller/auth_controller.dart';
import 'package:realtime_chat/models/recommendation_model.dart';

class RecommendationController extends GetxController {
  // The endpoint url for the recommendation API
  final String RECOMMENDATION_ENDPOINT_URL =
      dotenv.get('RECOMMENDATION_ENDPOINT_URL', fallback: "URL NOT FOUND");

  final Dio dio = Dio();
  late AuthController ctrl;
  Timer? recommendationUpdateTimer;

  RxList<RecommendationModel> recommendationList = <RecommendationModel>[].obs;
  RxList<RecommendationModel> nearbyList = <RecommendationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    ctrl = Get.find();
    // startRecommendationUpdate(ctrl.currentUser.value.userId);
    getRecommendation(
      ctrl.currentUser.value.userId,
      ctrl.currentUserLoc.value.latitude,
      ctrl.currentUserLoc.value.longitude,
      ctrl.currentUserLoc.value.maxRadius,
    );
    getNearby(
      ctrl.currentUser.value.userId,
      ctrl.currentUserLoc.value.latitude,
      ctrl.currentUserLoc.value.longitude,
      ctrl.currentUserLoc.value.maxRadius,
    );
  }

  // Observable for the currently selected selected merchant
  Rx<RecommendationModel> selectedMerchant = RecommendationModel(
    id: '',
    address: '',
    imageUrl: '',
    name: '',
    distance: 0,
    predictedRating: 0,
    ratings: 0,
    reviewCount: 0,
  ).obs;

  Future<void> getNearby(String id, latitude, longitude, radius) async {
    final String endpoint =
        "$RECOMMENDATION_ENDPOINT_URL/near_recs/$latitude,$longitude?max_returns=20&max_radius=$radius";
    try {
      logger.d(endpoint);
      final response = await dio.get(
        endpoint,
        // data: queryParams,
        // options: Options(
        //   headers: {
        //     'Content-Type': 'application/json',
        //   }
        // )
      );
      if (response.statusCode == 200) {
        List<dynamic> placeData = response.data['recommendations'];
        List<RecommendationModel> nearbyPlaces = placeData
            .map((data) => RecommendationModel.fromJson(data))
            .toList();
        nearbyList.value = nearbyPlaces;
      } else {
        print('Failed to fetch recommendation data: ${response.statusCode}');
      }
    } catch (error) {
      print('Failed to fetch recommendation data: $error');
    }
  }

  Future<void> getRecommendation(String id, latitude, longitude, radius) async {
    final String endpoint =
        '$RECOMMENDATION_ENDPOINT_URL/recommendation/${ctrl.currentUser.value.userId}?max_returns=6&latitude=$latitude&longitude=$longitude&max_radius=$radius'; // Change this to valid endpoint
    try {
      logger.d(endpoint);
      final response = await dio.get(
        endpoint,
      );
      if (response.statusCode == 200) {
        List<dynamic> placeData = response.data['recommendations'];
        List<RecommendationModel> recommendationPlaces = placeData
            .map((data) => RecommendationModel.fromJson(data))
            .toList();
        recommendationList.value = recommendationPlaces;
      } else {
        print('Failed to fetch recommendation data: ${response.statusCode}');
      }
    } catch (error) {
      print('Failed to fetch recommendation data: $error');
    }
  }

  void selectMerchant(
    String id,
    String address,
    String imageUrl,
    String name,
    double distance,
    double predictedRating,
    double ratings,
    int reviewCount,
  ) {
    selectedMerchant.value = RecommendationModel(
      id: id,
      address: address,
      imageUrl: imageUrl,
      name: name,
      distance: distance,
      predictedRating: predictedRating,
      ratings: ratings,
      reviewCount: reviewCount,
    );
  }
}
