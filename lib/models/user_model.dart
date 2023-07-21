import 'package:mongo_dart/mongo_dart.dart';

class UserModel {
  final String name;
  final ObjectId userId;
  final String profilePic;
  final bool isMerchant;
  final String phoneNumber;
  final String publicKey;

  UserModel({
    required this.name,
    required this.userId,
    required this.profilePic,
    required this.isMerchant,
    required this.phoneNumber,
    required this.publicKey,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'userId': userId,
      'profilePic': profilePic,
      'isMerchant': isMerchant,
      'phoneNumber': phoneNumber,
      'publicKey': publicKey,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> user) {
    return UserModel(
      name: user['name'],
      userId: user['_id'],
      profilePic: user['profilePic'],
      isMerchant: user['isMerchant'],
      phoneNumber: user['phoneNumber'],
      publicKey: user['publicKey'],
    );
  }
}
