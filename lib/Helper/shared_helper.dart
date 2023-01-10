import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {

  // set The All Key Value


  static String userLoggedInKey = "USERLOGGEDINKEY";
  static String userNameKey = "USERNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";

  // PUT THE VALUE IN SHARED PREF
  static Future<bool?> setTheLoggedInStatus (bool isLoggedIn) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setBool(userLoggedInKey, isLoggedIn);
  }

  static Future<bool?> setUserNameInStatus (String fullName) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString(userNameKey, fullName);
  }

  static Future<bool?> setEmailInStatus (String email) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString(userEmailKey, email);
  }


  // GET THE VALUE IN SHARED PREF
  static Future<bool?> getTheLoggedInStatus () async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(userLoggedInKey);
  }

  static Future<String?> getUserNameInStatus () async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userNameKey);
  }

  static Future<String?> getEmailInStatus () async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userEmailKey);
  }


}