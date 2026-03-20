import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/database/database_helper.dart';
import 'package:my_app/models/user.dart';

// Màn hình Register (Đăng ký)
//
// Mục tiêu của màn hình này:
// - Cho người dùng nhập: username, email, password, confirm password
// - Kiểm tra dữ liệu hợp lệ (validate)
// - Kiểm tra username có bị trùng không (query database)
// - Nếu ok thì lưu user vào database (insert)
// - Hiện thông báo thành công / thất bại, rồi quay về màn hình trước (thường là Login)

// Vì sao dùng StatefulWidget?
// - Vì màn hình có "trạng thái" thay đổi theo thời gian.
// Ví dụ trạng thái ở đây:
// - _isLoading: đang gọi database hay không (để hiện spinner/disable nút)
// - Nội dung các ô nhập (được giữ trong TextEditingController)
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // _formKey giúp Flutter truy cập/điều khiển Form:
  // - gọi validate() để chạy toàn bộ validator của các TextFormField
  final _formKey = GlobalKey<FormState>();

  // TextEditingController dùng để:
  // - lấy text hiện tại của ô input (controller.text)
  // - (nâng cao) set text từ code, lắng nghe thay đổi...
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Cờ loading để hiển thị vòng tròn chờ khi đang đăng ký
  bool _isLoading = false;

  @override
  void dispose() {
    // dispose() là nơi dọn dẹp tài nguyên.
    // Controller giữ resource, nên cần dispose để tránh memory leak.
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // 1) Chạy validate() cho tất cả field trong Form.
    // validate() trả về true khi tất cả validator đều "pass" (trả về null).
    if (_formKey.currentState!.validate()) {
      // 2) Đặt trạng thái loading (UI sẽ rebuild và đổi từ button sang spinner)
      setState(() => _isLoading = true);

      // 3) Lấy dữ liệu người dùng nhập, và trim() để bỏ khoảng trắng đầu/cuối
      String username = _usernameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      // 4) Làm việc với database qua DatabaseHelper
      DatabaseHelper db = DatabaseHelper();

      // 5) Kiểm tra username đã tồn tại chưa.
      // await: chờ query xong mới chạy tiếp (vì DB là thao tác bất đồng bộ)
      User? existingUser = await db.getUserByUsername(username);
      if (existingUser != null) {
        // Nếu bị trùng thì tắt loading và báo lỗi
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Username already exists')));
        return;
      }

      // 6) Tạo createdAt dạng chuỗi để lưu vào DB (ví dụ: 2026-03-20 10:30:00)
      String createdAt = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(DateTime.now());

      // 7) Tạo object User từ dữ liệu vừa nhập
      User newUser = User(
        username: username,
        email: email,
        password: password,
        createdAt: createdAt,
      );

      // 8) Insert user vào database. Thường insert sẽ trả về id của bản ghi mới.
      int id = await db.insertUser(newUser);

      // 9) Dù thành công hay thất bại, ta cũng tắt loading để UI trở lại bình thường
      setState(() => _isLoading = false);

      if (id > 0) {
        // Insert thành công => báo thành công và quay về màn hình trước
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful! Please login.')),
        );
        Navigator.pop(context);
      } else {
        // Insert thất bại => báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed. Try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // build() trả về "UI tree" (cây widget) cho màn hình hiện tại.
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          // ListView giúp màn hình có thể cuộn khi bàn phím hiện lên hoặc màn nhỏ.
          child: ListView(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                // validator: trả về String (lỗi) nếu không hợp lệ, hoặc null nếu hợp lệ
                validator: (value) =>
                    value!.isEmpty ? 'Please enter username' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter email';
                  if (!value.contains('@')) return 'Enter a valid email';
                  return null;
                },
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
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter password';
                  if (value.length < 4)
                    return 'Password must be at least 4 characters';
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) return 'Please confirm password';
                  if (value != _passwordController.text)
                    return 'Passwords do not match';
                  return null;
                },
              ),
              SizedBox(height: 24),
              // Nếu đang loading thì hiện spinner, còn không thì hiện nút Register
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text('Register'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
