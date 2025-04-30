class Usermodel {
  String userid;
  String username;
  String email;
  String bod;
  DateTime? time;
  String? imageURL;

  Usermodel(
      {required this.userid,
      required this.username,
      required this.email,
      required this.bod,
      this.time,
      this.imageURL});

  Map<String, dynamic> toMap() {
    return {
      'userid': userid,
      'username': username,
      'email': email,
      'time': time,
      'imageURL': imageURL,
      'bod': bod,
    };
  }
}
