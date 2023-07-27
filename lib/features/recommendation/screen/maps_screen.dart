import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:realtime_chat/common/widgets/custom_button.dart';
import 'package:realtime_chat/features/auth/controller/auth_controller.dart';
import 'package:realtime_chat/features/recommendation/screen/recommendation_screen.dart';
import 'package:realtime_chat/my_flutter_app_icons.dart';

class MapsScreen extends StatefulWidget {
  static const String routeName = '/maps-screen';
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

// LatLng(ctrl.currentUserLoc.value.latitude, ctrl.currentUserLoc.value.longitude),
class _MapsScreenState extends State<MapsScreen> {
  final AuthController ctrl = Get.find();
  late GoogleMapController _controller;

  // Circle attributes
  double _circleRadius = 5000; // Starting circle radius (1 km)
  final double _sliderMin = 1000; // Minimum circle radius (1 km)
  final double _sliderMax = 10000; // Maximum circle radius (10 km)

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        LatLng _center = LatLng(ctrl.currentUserLoc.value.latitude,
            ctrl.currentUserLoc.value.longitude); // Starting position

        Circle _createCircle() {
          return Circle(
            circleId: CircleId('centerCircle'),
            center: _center,
            radius: _circleRadius,
            fillColor: Colors.blue.withOpacity(0.3),
            strokeColor: Colors.blue,
            strokeWidth: 1,
          );
        }

        double calculateZoomLevel(double circleRadius) {
          // This is a basic function to convert radius into an approximate zoom level.
          // Adjust the values as per your requirements.
          double baseZoom = 12;
          double zoom = baseZoom -
              (circleRadius / 10000); // Here, 10000 is the maximum radius
          return zoom;
        }

        return SafeArea(
          top: false,
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 78.0,
              centerTitle: true,
              title: const Text('Change Location'),
              foregroundColor: Colors.black,
              elevation: 1,
              backgroundColor: Colors.white,
            ),
            body: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      GoogleMap(
                        myLocationButtonEnabled: false,
                        onMapCreated: (GoogleMapController controller) {
                          _controller = controller;
                        },
                        initialCameraPosition: CameraPosition(
                            target: LatLng(ctrl.currentUserLoc.value.latitude,
                                ctrl.currentUserLoc.value.longitude),
                            zoom: calculateZoomLevel(_circleRadius)),
                        circles: {_createCircle()},
                        onCameraMove: (position) {
                          // print(position);
                          setState(() {
                            ctrl.currentUserLoc.value.latitude =
                                position.target.latitude;
                            ctrl.currentUserLoc.value.longitude =
                                position.target.longitude;
                            ctrl.currentUserLoc.value.maxRadius =
                                (_circleRadius * 0.001);
                          });
                        },
                      ),
                      const Center(
                        child: Icon(Icons.place,
                            size: 36.0, color: Colors.red), // Central marker
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceBetween, // This ensures maximum space between the Slider and Text
                    children: [
                      Expanded(
                        // Wrapping the Slider with Expanded to make sure it takes up the available space
                        child: Slider(
                          value: _circleRadius,
                          min: _sliderMin,
                          max: _sliderMax,
                          onChanged: (value) {
                            setState(() {
                              _circleRadius = value;
                              _controller.animateCamera(
                                CameraUpdate.newLatLngZoom(
                                    _center, calculateZoomLevel(value)),
                              );
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ), // Optional: Adds some space between the Slider and the Text
                      Text(
                        "${(_circleRadius * 0.001).toStringAsFixed(2)} km", // Displaying the value with two decimal places followed by "m" for meters
                        style: const TextStyle(
                            fontSize: 16), // Optional: Style the text as needed
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CustomButton(
                      text: 'Apply',
                      onpressed: () {
                        Get.offAndToNamed(RecommendationScreen.routeName);
                      }),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
