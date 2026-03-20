import 'package:flutter/material.dart';
import 'package:my_app/models/artwork.dart';

// Màn hình Artwork Detail (Chi tiết tác phẩm)
//
// Đây là màn hình chỉ HIỂN THỊ dữ liệu (không chỉnh sửa),
// nên dùng StatelessWidget (không cần state thay đổi).
class ArtworkDetailScreen extends StatelessWidget {
  // artwork được truyền từ màn hình trước (HomeScreen) khi user bấm vào 1 item
  final Artwork artwork;

  ArtworkDetailScreen({required this.artwork});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Artwork Detail'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          // Quay lại màn hình trước
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          // elevation: độ "nổi" của Card (tạo bóng)
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              // Căn trái cho nội dung trong cột
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artwork.title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                // Dùng hàm helper để render từng dòng thông tin cho gọn code
                _buildDetailRow('Artist', artwork.artist),
                _buildDetailRow('Year', artwork.year.toString()),
                _buildDetailRow('Category', artwork.category),
                SizedBox(height: 16),
                Text(
                  'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(artwork.description, style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    // Một dòng dạng: Label: Value
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          // Expanded để phần value tự giãn, xuống dòng nếu dài
          Expanded(child: Text(value, style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
