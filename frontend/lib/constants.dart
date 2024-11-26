import 'package:flutter/material.dart';

class Constants {
  //Primary color
  static var primaryColor = const Color(0xff296e48);
  static var blackColor = Colors.black54;

  //Onboarding texts
  static var titleOne = "Khám Phá Thế Giới Loài Cây";
  static var descriptionOne =
      "Bạn không biết là cây gì? Hãy để chúng tôi giúp bạn !";
  static var titleTwo = "Chăm Sóc Cây Của Bạn Như Một Chuyên Gia";
  static var descriptionTwo =
      "Chăm sóc cây xanh là chăm sóc cho tương lai của con cháu chúng ta. Cùng học nào !";
  static var titleThree = "Biểu tượng của sự sống";
  static var descriptionThree =
      "Trong tay bạn có thể cầm giữ một hạt giống, nhưng trong hạt giống đó chứa cả một khu rừng.";
  // API
  // static var API = "http://127.0.0.1:8000/api/v1";
  static var API = "http://127.0.0.1:8000/api/v1";
  static var API_register = API + "/register";
  static var API_login = API + "/login";
  static var API_forgot_password = API + "/forgot-password";
  static var API_reset_password = API + "/password/reset";
}
