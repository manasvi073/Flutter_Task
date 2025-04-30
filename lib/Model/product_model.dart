class Productmodel {
  String? userid;
  String id;
  String name;
  String description;
  String? imageURL;
  String price;

  Productmodel({
    this.userid,
    required this.id,
    required this.name,
    required this.description,
    this.imageURL,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageURL': imageURL ?? '',
      'price': price,
    };
  }
}
