import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:get/get.dart';
import 'package:realtime_chat/common/utils/address.dart';
import 'package:realtime_chat/common/utils/util.dart';
import 'package:realtime_chat/features/auth/screen/login_screen.dart';
import 'package:realtime_chat/models/user_model.dart';

class AuthController extends GetxController {
  // Storage instance for storing user data locally.
  GetStorage box = GetStorage();

  // Dio instance for making HTTP requests.
  Dio dio = Dio();

  // Observable user model to keep track of the current user's data.
  Rx<UserModel> currentUser = UserModel(
    name: '',
    userId: '',
    profilePic: '',
    isMerchant: false,
    phoneNumber: '',
    publicKey: '',
  ).obs;

  // Observable location model to keep track of the current user's location.
  Rx<UserLocationModel> currentUserLoc = UserLocationModel(
    latitude: 0,
    longitude: 0,
    maxRadius: 5.0,
  ).obs;

  // Observable boolean to track if a process is currently loading.
  var isLoading = false.obs;

  @override
  void onClose() {
    // Close the database connection when controller is disposed.
    db.close();
    super.onClose();
  }

  // Observable list to keep track of all users.
  RxList<UserModel> userList = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Fetch user details upon initialization.
    getUser();
  }

  // Fetches user details from the given endpoint.
  Future<void> getUser() async {
    try {
      final response = await dio.get("$ENDPOINT_URL/user");
      if (response.statusCode == 200) {
        List<dynamic> userData = response.data;
        List<UserModel> users =
            userData.map((data) => UserModel.fromJson(data)).toList();
        userList.value = users;
      } else {
        print('Failed to fetch users data: ${response.statusCode}');
      }
    } catch (error) {
      print('Failed to fetch users data: $error');
    }
  }

  // void getCollection() async {
  //   await db.open();
  //   try {
  //     isLoading(true);
  //     var collection = db.collection('users');
  //     collection.find(where.sortBy('name')).forEach((user) {
  //       userList.add(UserModel(
  //         name: user['name'],
  //         userId: user['_id'],
  //         profilePic: user['profilePic'],
  //         isMerchant: user['isMerchant'],
  //         phoneNumber: user['phoneNumber'],
  //         publicKey: user['publicKey'],
  //       ));
  //     });
  //   } catch (e) {
  //     rethrow;
  //   } finally {
  //     isLoading(false);
  //   }
  // }

  // Method to log in the user and store their details both locally and in memory.
  void login(
    String name,
    String userId,
    String profilePic,
    bool isMerchant,
    String phoneNumber,
    String publicKey,
  ) {

    // Updating the current user observable with the new user data.
    currentUser.value = UserModel(
      name: name,
      userId: userId,
      profilePic: profilePic,
      isMerchant: isMerchant,
      phoneNumber: phoneNumber,
      publicKey: publicKey,
    );

    // meetingyuk creative space
    box.write('9lCb0V9FVtvI9qHuZhJmqw_key',
        'MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQCH2WLWbRVZSM3bBmIJfjqT1TdoCB8npYqRbRjow/fSfZqNJxlQWqPZ4HfDuofIskBdUDFd7QTazG07bSZGmE62/3V9GNaPactcYqL/+Nlv8l7Bm++BdEiLkkBlCUvkKGsGk1/xFEWxyPYfME3I2Vl3Qas7BijJ/z59IY7xKPi0OtyrQVy0ISrDDt5QQ/z7hUo5hKfCYy2ejDGZ4S/qE1TPSEfHaqJPjbli04jBEHQfkHvvehOxkf2jTjfjdmVT7wf/dMRTVAD85lT5LjmNzq2bL1yZL7C6WzIHWmzdcwCiu9WQNwQFlO8kavaI79Hil9PwNbQ+3OrBxbGKqSfjRmdlAgMBAAECggEAEQUwd/MU0KnpeL6U++F/z1PQbE1QMfRwpwXHMCqVWx73hSXX6xRgIQUZnEE7j+6dV9ObS8xNZmhkaySivgeJHS5mdvTstO0pWHrXN0DjZT41lwZFfK+oAyygusfuZTiXKCzAwYCrtrmZ9JBlvntU1Tc6D9wWsjAzkRPqR9a9Sj9CblxIgy/zmfRicKh/F7jOG26Gyl+Dov1ggeKwgg6DAaGQOECLhQz7YIoW10LXfk66ssZ2FxMtP7Qy2oROXlA9+7WGciR8sLF9uxWTWiBtytRkfKhsqOgH/6/mpc1h3ytqHz3jlgD5PnKYSbE4pc1DpGp6DnRubRu+eSZsrOqo4QKBgQDZM9Ndxag8L1JuZSXPncJS5MKshOg+6vGHtRFiAFHdLfyIwB9Z9QllKbY4Hnr+6v+sn0mnstgX6hWU6GkAVsC1gA6bt97nbcYTeCbrk2idGXZGNgo/45ga+tZWkAZLEnezmDhl5/cPQlEkZYq1ZNK/XLzTt/NvdvLDpS9cT+7leQKBgQCgHXWzX5IRV9gcVGgrbSqjJNlblRR7dABRjykVwSFuJciGIoz7K5QvYtDTAl8fbky/rW/HdCINSq6wbVhBdVIa4NBAYADv3m+27rO8G2Q6Pt9NKjfzTqZg2vJSLEAqnll69efFD1neR67LzNxq7wKMhs9xWXiPSqGue/lBSrfyTQKBgQDAd/ZC0BYGTwDCporc8TTzc5c2fQe4SUUCNmdS6mmgj1GKdITTmBldNZstG4VuQxuRAg2otwhaGKpLK69wB2/45aMMReEWPuYY9o22jwdSvu9ZxCVM/AcbUU+BoVqSR6ke0jKXyvfY47E3iWti1hcST8Fb81OaYFM7HzNan9JYMQKBgQCECKcVmpreGF1Kx0P7g5MkY2+l+OKiBv94QiC0IsXJifi4u+cb/Ey/YrInPw5n4dICQigqBpdJ9KrnK9Qabn+dUIQKgeBj7T6cUG0AkmntKgmEHWt0BQhoWER5BKqJOnk5T2yncMg/50a6Ip4kxCGK9mQ76XbkWrvHIc5iTBYyBQKBgQCXmVHmG/Q3diI3rwXWx+8xGG2kU2/PFfM9rPBZ2EeOA95JGdvAQb6GEprMjbx8OgwtUqNFlebGiywnc71lFtNGjPnO5AvDNRFusxUonwpM2zXeLsRYf9ke6CJzzykvxf6bHnna/wzaSXxn6m2wwrfbPao2urFDF+/eFj1G1+PjGw==');
    
    // bob
    box.write('pe-ltR4of_hrIjaHXlKveg_key',
        'MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCIV3/IABn/2uhMp7RDgR7sbP2Z6oEXAyfsiX6XotOYgBWKHUWkAe4ZVRwSX114cJibm6sk9rVkjo++XcXKE/iU70an+r6OADWu1sXmT/BuuWhANFlPPt1IRcMX/9mXihPBKed1d8eUQ/SibFsdzoCwOwKyeHHmrQJSTHiUXNBqGK3C4Tw9BtmCfOw/r+0M8QcZBciHppEyPSEEYNxOkRfhB4VQrNSHo8vWQxxncsPp/gwbq/lO6J7vanfK214kg51KRFd6/D5SluUnoi1+lJfiv/LYXyPhwPY1+3lYfR8Din0a8DmRqcPr2Zuk4+l2TQ+dKP23zbaBMlgjrm3T4yMJAgMBAAECggEBAIY4RUYZu36h/VABRLeztEKhpSLRtdV2uOXmEWar18xoQ0wdNwKXF9N+cs0vbq/zgHinzdrsuHPO2HlajS07bdsIlzEk6lSWpkKBkn8BsTr/cT7LiiQ2SdctPjsxFv9U4c+mNgLxMNun7nu7WhPEx/E1lpklc1PYe9GTEJ1VpaLbQRP1mXhRLw/OB7kLzniSssoN7Jdy9IJetcDc0j4yU51oKR9zrc4AZ83Y/92K8VZCkJkmGZ98bchjKwADW3YxzPaaNjR+DlfnVDqzgDFVgeF5MxnNtBjKSARrssnudB15qd99Q3ZJ3yQs12CJ8rHODB5CE6pAF3kp+EAaQbqoHhUCgYEA6xZSQh1ZHVUmrcQBEq8tTS6loDLTxXlAkltZ0HMrU6FhxK4MVc9ibNydCchxOBnBBhuESb6klXgFcXHhe7PuA0pultzCNowp5c4ihZThvFclHrZbE8GgZslf1VK2hcGaw7AER+v1febRrt+ubmbFdy+QTyv94hI69GgC7tMDmmMCgYEAlHhu0KzGtzurMx5e5ZYLlJD0gjEjM9IE+xD2LZu5wL30voeiP3CxTrq60oA8QaC+EMpj+sodP83eR5yTm9wXQ/b5TlSat80iBcgSDcA6FJSmwgsBq7PnZxpovC9SvARd3n9dLWsRitfvcMI0MbTKrII4lRo03uZfPK4mK3h1sqMCgYBR6xxM55cnDoYE5RkOnrZlf8y9Lxj2ZhMnLOf2KDu/z6uW8qNfv31nu9SJFSzGxMqrSylk3SbS4tjauDk/duqIgQZaUaDnix4KczM6Yy/qBl/r/NVt4/n191QKrODnaRh5+jrzqPiJn8YPbuiElhFXP97Eh+rXPU0H37qt6CAISwKBgEbK+gPULlhWQjZ4p8UO+2yWhY/CgEeIP8m697cdhr+pk5Z5s9pOEK06ijQu4wxj6dy1tGBzmOjAb9lzhkqN8iX9EDjSTIeRb0SUdk9KNid0DeN+PgiyGodl50S7x9ZQurWJw1MRt2adudTpNNvymaUR3orx2P3jmMulOhwGLxDDAoGAQwIukz2jiW9LEMAB3Wvx04Kuoiuabl/+QSUCxGWzM5Gh60Q8+ofm6Ozxhz/Au6tDAeOR2zmlTZu5lG6cicNaAZTCPaXGYMueGznhdWTcLodlnqC/m/QfXXU8EYQh3NSc8ePlT90qYRGgNGw+QNdOVdwiS9t87H0LMt/uDl11Stc=');
    
    // alice
    box.write('cxuxXkcihfCbqt5Byrup8Q_key',
        'MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDRym2Bm0DYJidX0i1oyUnQm12vFc7qxzLitQJPLBQW6y72lUFLF0aw1OM93sIUdD60Lbznp59TsPHbNTq2Ie9KaMglHSM8hgGAz9avOeTz4ozj9IrhZjcAGvwWuj/iToKkijQwbPcUEygL9fLxA02rsE9BeXjKT50cjzCEYBXbetizI6uW34VYq/cOyK1MguDnd7v9bzbXlFslSIClY9LIZqR65vpC8Drbe/Hk6scGgkyhVyggws+dFzFjywevxPmuPysd/UBORdbeCKVhA7WkWtS+lc7WgJMyZuTB/HM2++Yx/b652cKd+Duc3dWiJIofgLI9p8cr2Hv9z3fTcZ+tAgMBAAECggEAOv1spVD+fsjbrzoOQrS26M2HHkBHmoTArjavm4uNapRe9D8ryO2WlwqFi1QjxpSZPRjPUWQ0zNeoajchdy07l/S2spjq243ixlGq0EK7OkitzTtqAc84D/OGhu2AISZqXdHust8w6pgoXpSd519Ca9B7uLFrYZfZWbp5rf9Gphv19Lyg5pwJLYUY0vTFwD2sROYjX/bdwFCu2JzFbeAxAJDIT7nwwOFq4/++SEKqvOeK2HuDkCpbuW0u62hyth5AxGz14hwVJNGyfe47dIDv5x2xzJr1kSZzL/PqPvkTEv3EZcLHEio5ceSFAr1ZICjuyU/UxYTSM3REWsvBK78AkQKBgQD/vZXYAY0kwIyyaueMF7f6MjAKbnM6enJOV6dfyyFkc5vdCMYXMKVwtZRSCkUCO3XBhGZhXkW3Ha7y/eC03ZWs1buSi3Y42fn7QHPaV/LFUcdLGfvtn0NxFjdNhabH83H3AswW5TiwmJF2DJ5yZJsKO9wIZiKzjlq+WWsRRafzXwKBgQDSAOjS0OCT6sZwQo7vdYlvethVEJeplFVZvxN1R1DzIJbd41gPGO4bJV46xsv1JJeh83RN55TE3xT/p3A2R3l/mOuyl0dqIT0kW9WtRMvAXfILo6VaIR9mXovNbfdJaIj/hx0HSFvIcqz4B3aDOfPCbZTMOC9zaPIL5PXSTnA0cwKBgQCBWOc/8FDuBMFkwDNKpPh1gArSS9jV+/Zyb10FU10ZTGvJ2NUwB3e10PEqqW0L2v0NGqUZnC/QlR/WYNfVQrmgSB3t2cG6sW0BSjEOfysX5+vPrV3BaqsWuHDSMcYQHa5Hi8+jyN3qW9A+j9VX8FCGVY5NZTMp89crrVg8zSlMKwKBgAnUuRGFbb3+86M1unNDUVfCrHXu/OqXYxd8dnC7EfMPx4BDsE+knyDuMucVf17Og7q1JvCusqw0tUryj7I6zllG02Hc6x7wx2f4VJxz6AXtX/Njic4aVtn3+xt21mi9WAx+SsGYhZNwquBBmS6ze9HSR3D4AGCqvQoJgeiCe4Y5AoGAOVwU9c7sfooDfA5r7XmjAeBkVf9zJIg/WAJpuBs20qYcdZaNVSls6VojTJz/kQIGU8T+SaL9eIshWCsqzYGM0SGWLBnrQNmhDCEVijWVQtTFoOIw0dxA4m/4KhBGt5ZOwG7WA+TqYz6TbNtfSI2NELi7CuUCfWXR52P+3GpbhEg=');
  }

  // Method to logout the current user.
  void logout() {

    // Resetting the user data in the controller.
    currentUser.value = UserModel(
      name: '',
      userId: '',
      profilePic: '',
      isMerchant: false,
      phoneNumber: '',
      publicKey: '',
    );

    // Navigate the user back to the login screen.
    Get.offAllNamed(LoginScreen.routeName);
  }

  // Method to fetch the current user's location.
  void getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final latitude = position.latitude;
    final longitude = position.longitude;

    print('Latitude: $latitude, Longitude: $longitude');

    currentUserLoc.value.latitude = latitude;
    currentUserLoc.value.longitude = longitude;
  }

  // Method to check the current user's location permission.
  Future<void> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      return;
    }

    getLocation();
  }

  // Method to get city of the current user's location.
  Future<String?> getCityFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks != null && placemarks.isNotEmpty) {
        Placemark firstPlacemark = placemarks.first;
        return firstPlacemark.locality;
      }
    } catch (e) {
      print('Error getting city name: $e');
    }
    return null;
  }

  // Method to get city name of the current user's location.
  Future<String?> fetchCityName(latitude, longitude) async {
    String? cityName = await getCityFromCoordinates(latitude, longitude);
    print("$latitude & $longitude");
    if (cityName != null) {
      print('City Name: $cityName');
    } else {
      print('City Name not found.');
    }
    return cityName;
  }
}
