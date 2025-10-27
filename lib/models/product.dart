import 'package:hive/hive.dart';



@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  double price;

  @HiveField(3)
  String? imagePath;

  Product({
    required this.name,
    required this.quantity,
    required this.price,
    this.imagePath,
  });
}
