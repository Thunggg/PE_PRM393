import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _keyUserId = 'user_id';
  static const String _keyUsername = 'username';

  // User login → gọi hàm này
  // App lưu: {user_id: 1, username: "thuan"}
  static Future<void> saveSession(int userId, String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyUsername, username);
  }

  // Lấy dữ liệu đã lưu trước đó
  // Nếu tồn tại → trả về object:
  // {'userId': userId, 'username': username}
  static Future<Map<String, dynamic>?> getSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt(_keyUserId);
    String? username = prefs.getString(_keyUsername);
    if (userId != null && username != null) {
      return {'userId': userId, 'username': username};
    }
    return null;
  }

  // Xóa dữ liệu user khỏi máy
  // User phải login lại từ đầu
  static Future<void> clearSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUsername);
  }
}
