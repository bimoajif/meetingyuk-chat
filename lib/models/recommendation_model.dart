class RecommendationModel {
  final String id;
  final String address;
  final String imageUrl;
  final String name;
  final double distance;
  // final Map<String, String>? openingHours;
  final double predictedRating;
  final double ratings;
  final int reviewCount;
  // final List<RoomModel> rooms;

  RecommendationModel({
    required this.id,
    required this.address,
    required this.imageUrl,
    required this.name,
    required this.distance,
    // required this.openingHours,
    required this.predictedRating,
    required this.ratings,
    required this.reviewCount,
    // required this.rooms,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      id: json['_id'] ?? '',
      address: json['address'] ?? '',
      imageUrl: json['image_url'] ?? '',
      name: json['name'] ?? '',
      distance: json['distance_in_km'] ?? 0,
      // openingHours: Map<String, String>.from(json['opening_hours']),
      predictedRating: json['predicted_rating'] ?? 0,
      ratings: json['ratings'] ?? 0,
      reviewCount: json['review_count'] ?? 0,
      // rooms: (json['rooms'] as List).map((roomData) => RoomModel.fromJson(roomData)).toList(),
    );
  }
}

class RoomModel {
  final List<String> facilities;
  final List<String> imageUrls;
  final int maxCapacity;
  final int maxDuration;
  final String name;
  final int price;
  final String roomId;

  RoomModel({
    required this.facilities,
    required this.imageUrls,
    required this.maxCapacity,
    required this.maxDuration,
    required this.name,
    required this.price,
    required this.roomId,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      facilities: List<String>.from(json['facilities']),
      imageUrls: List<String>.from(json['image_urls']),
      maxCapacity: json['max_capacity'],
      maxDuration: json['max_duration'],
      name: json['name'],
      price: json['price'],
      roomId: json['room_id'],
    );
  }
}