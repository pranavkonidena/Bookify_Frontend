import 'package:get_storage/get_storage.dart';

void deleteToken() {
  final box = GetStorage();
  box.write("token", null);
  String? token = box.read("token");
  if (token == null) {
    print("TOKEN IS NULL");
  }
}

void saveToken(token) async {
  final box = GetStorage();
  box.write("token", token);
}

String getToken() {
  final box = GetStorage();
  String? token = box.read("token");
  if (token != null) {
    return token;
  } else {
    return "null";
  }
}