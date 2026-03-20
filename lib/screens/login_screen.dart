import 'package:flutter/material.dart';
import 'package:my_app/database/database_helper.dart';
import 'package:my_app/models/user.dart';
import 'package:my_app/utils/session_manager.dart';
import 'package:my_app/screens/register_screen.dart';
import 'package:my_app/screens/home_screen.dart';

// Màn hình Login (Đăng nhập)
//
// Luồng cơ bản:
// - Người dùng nhập username + password
// - Validate (không để trống)
// - Gọi database để kiểm tra đúng/sai (db.login)
// - Nếu đúng: lưu session (để lần sau mở app vẫn biết ai đang đăng nhập)
// - Điều hướng sang HomeScreen và thay màn hình Login bằng Home (pushReplacement)
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Dùng để validate tất cả field trong Form
  final _formKey = GlobalKey<FormState>();

  // Controller giúp lấy text trong ô input
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Cờ loading để hiện spinner khi đang xử lý đăng nhập
  bool _isLoading = false;

  @override
  void dispose() {
    // Nhớ dispose controller để tránh leak bộ nhớ
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // validate() chạy các validator trong Form.
    // Nếu tất cả hợp lệ thì mới tiếp tục đăng nhập.
    if (_formKey.currentState!.validate()) {
      // Bật loading => UI rebuild, nút Login sẽ đổi thành spinner
      setState(() => _isLoading = true);

      // Lấy dữ liệu từ input, trim() để bỏ khoảng trắng thừa
      String username = _usernameController.text.trim();
      String password = _passwordController.text.trim();

      // Tạo helper để thao tác với database
      DatabaseHelper db = DatabaseHelper();

      // Gọi hàm login trong database:
      // - Nếu đúng username/password => trả về User
      // - Nếu sai => trả về null
      User? user = await db.login(username, password);

      // Tắt loading sau khi có kết quả
      setState(() => _isLoading = false);

      if (user != null) {
        // Lưu "session" để app nhớ người dùng đã đăng nhập.
        // (Thường sẽ dùng SharedPreferences hoặc tương tự ở phía dưới SessionManager)
        await SessionManager.saveSession(user.id!, user.username);

        // Điều hướng sang HomeScreen và "thay thế" LoginScreen.
        // pushReplacement: sau khi vào Home, bấm back sẽ KHÔNG quay lại Login nữa.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HomeScreen(userId: user.id!, username: user.username),
          ),
        );
      } else {
        // user == null => sai thông tin đăng nhập
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Invalid username or password')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // build() dựng giao diện cho màn hình Login
    return Scaffold(
      appBar: AppBar(title: Text('Logins')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          // Column + mainAxisAlignment.center: căn giữa form theo chiều dọc
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                // validator trả về lỗi (String) nếu không hợp lệ, hoặc null nếu hợp lệ
                validator: (value) =>
                    value!.isEmpty ? 'Please enter username' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter password' : null,
              ),
              SizedBox(height: 24),
              // Nếu đang loading thì hiện spinner, còn không thì hiện nút Login
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: Text('Login'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Navigator.push: mở màn hình RegisterScreen "chồng lên" LoginScreen.
                  // Khi register xong và pop(), app sẽ quay lại LoginScreen.
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                child: Text('Don\'t have an account? Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
