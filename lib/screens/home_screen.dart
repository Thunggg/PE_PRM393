import 'package:flutter/material.dart';
import 'package:my_app/models/artwork.dart';
import 'package:my_app/database/database_helper.dart';
import 'package:my_app/utils/session_manager.dart';
import 'package:my_app/screens/login_screen.dart';
import 'package:my_app/screens/add_artwork_screen.dart';
import 'package:my_app/screens/artwork_detail_screen.dart';

// Màn hình Home (Trang chính)
//
// Nhiệm vụ:
// - Load danh sách artwork của user từ database
// - Hiển thị danh sách (ListView)
// - Thêm artwork mới (đi tới AddArtworkScreen)
// - Xem chi tiết artwork (đi tới ArtworkDetailScreen)
// - Xoá artwork (confirm dialog + gọi DB delete)
// - Logout (clear session + quay về LoginScreen)
class HomeScreen extends StatefulWidget {
  // Thông tin user đang đăng nhập (truyền từ LoginScreen)
  final int userId;
  final String username;

  HomeScreen({required this.userId, required this.username});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Danh sách artwork để hiển thị lên UI
  List<Artwork> _artworks = [];

  // Loading khi đang fetch dữ liệu từ DB
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // initState chạy 1 lần khi màn hình vừa được tạo.
    // Mình load dữ liệu ngay ở đây để UI có danh sách artwork.
    _loadArtworks();
  }

  Future<void> _loadArtworks() async {
    // Bật loading
    setState(() => _isLoading = true);

    // Lấy danh sách artwork của user hiện tại từ DB
    DatabaseHelper db = DatabaseHelper();
    List<Artwork> artworks = await db.getArtworksByUser(widget.userId);

    // Cập nhật state để UI render lại list
    setState(() {
      _artworks = artworks;
      _isLoading = false;
    });
  }

  Future<void> _deleteArtwork(Artwork artwork) async {
    // showDialog trả về giá trị từ Navigator.pop(context, value)
    // confirm sẽ là true/false (hoặc null nếu user đóng dialog ngoài ý muốn)
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Artwork'),
        content: Text('Are you sure you want to delete this artwork?'),
        actions: [
          TextButton(
            // Pop dialog và trả về false
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            // Pop dialog và trả về true
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      DatabaseHelper db = DatabaseHelper();
      // Xoá theo id (artwork.id là nullable nên dùng !)
      int result = await db.deleteArtwork(artwork.id!);
      if (result > 0) {
        // Xoá xong thì load lại list để UI cập nhật
        _loadArtworks();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Artwork deleted successfully')));
      }
    }
  }

  Future<void> _logout() async {
    // Xoá thông tin session đã lưu (để app không còn coi là đang đăng nhập)
    await SessionManager.clearSession();

    // Quay về Login và thay thế Home (bấm back sẽ không quay lại Home)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Art Gallery'),
        // Nút logout ở góc phải AppBar
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: _logout)],
      ),
      body: Column(
        children: [
          // Header (có thể thay bằng ảnh)
          Container(
            height: 120,
            width: double.infinity,
            color: Colors.blueGrey[100],
            child: Center(
              child: Text(
                'Welcome, ${widget.username}!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _artworks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.art_track, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No artworks found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Mở màn hình AddArtworkScreen.
                            // then(...) chạy khi AddArtworkScreen pop về, mình load lại list.
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddArtworkScreen(userId: widget.userId),
                              ),
                            ).then((_) => _loadArtworks());
                          },
                          child: Text('Add Artwork'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _artworks.length,
                    itemBuilder: (context, index) {
                      Artwork art = _artworks[index];
                      return Dismissible(
                        // Key để Flutter phân biệt item nào đang bị dismiss/delete
                        key: Key(art.id.toString()),
                        // Nền đỏ hiện ra khi vuốt để xoá
                        background: Container(color: Colors.red),
                        // Khi user vuốt bỏ item, gọi xoá
                        onDismissed: (direction) => _deleteArtwork(art),
                        child: ListTile(
                          leading: Icon(Icons.art_track),
                          title: Text(art.title),
                          subtitle: Text('${art.artist} - ${art.year}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteArtwork(art),
                          ),
                          onTap: () {
                            // Bấm vào item => mở màn chi tiết
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ArtworkDetailScreen(artwork: art),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Nút "+" góc phải dưới: mở AddArtworkScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddArtworkScreen(userId: widget.userId),
            ),
          ).then((_) => _loadArtworks());
        },
      ),
    );
  }
}
