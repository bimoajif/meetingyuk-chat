class ProductModel {
  final String productId;
  final String image;
  final String name;
  final String date;
  final String startTime;
  final String endTime;

  ProductModel({
    required this.productId,
    required this.image,
    required this.name,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'image': image,
      'name': name,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> map) {
    return ProductModel(
      productId: map['productId'],
      image: map['image'],
      name: map['name'],
      date: map['date'],
      startTime: map['startTime'],
      endTime: map['endTime'],
    );
  }
}
