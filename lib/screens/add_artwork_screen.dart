import 'package:flutter/material.dart';
import 'package:my_app/models/artwork.dart';
import 'package:my_app/database/database_helper.dart';

// Màn hình Add Artwork (Thêm tác phẩm)
//
// Mục tiêu:
// - Người dùng nhập thông tin tác phẩm (title, artist, year, category, description)
// - Validate dữ liệu
// - Lưu xuống database (insertArtwork)
// - Báo kết quả và quay về màn hình trước (HomeScreen)
class AddArtworkScreen extends StatefulWidget {
  // userId là id của người đang đăng nhập (để biết ai là người tạo artwork này)
  final int userId;

  AddArtworkScreen({required this.userId});

  @override
  _AddArtworkScreenState createState() => _AddArtworkScreenState();
}

class _AddArtworkScreenState extends State<AddArtworkScreen> {
  // FormKey dùng để gọi validate() cho toàn bộ form
  final _formKey = GlobalKey<FormState>();

  // Controller để lấy text trong các ô nhập
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _yearController = TextEditingController();

  // Giá trị category hiện tại (mặc định là Abstract)
  String _category = 'Abstract';
  final _descriptionController = TextEditingController();

  // Cờ loading: đang lưu vào DB hay không (để hiện spinner)
  bool _isLoading = false;

  // Danh sách category để hiển thị trong dropdown
  final List<String> _categories = [
    'Abstract',
    'Landscape',
    'Portrait',
    'Still Life',
    'Modern',
    'Other',
  ];

  @override
  void dispose() {
    // Dọn dẹp controller để tránh leak bộ nhớ
    _titleController.dispose();
    _artistController.dispose();
    _yearController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveArtwork() async {
    // Nếu tất cả field hợp lệ thì mới lưu
    if (_formKey.currentState!.validate()) {
      // Bật loading (UI sẽ rebuild và thay nút bằng spinner)
      setState(() => _isLoading = true);

      // Convert year từ String sang int.
      // Lưu ý: int.parse có thể throw nếu text không phải số,
      // nhưng ở đây validator đã đảm bảo year là số hợp lệ.
      int year = int.parse(_yearController.text.trim());

      // Tạo object Artwork từ dữ liệu input
      Artwork artwork = Artwork(
        title: _titleController.text.trim(),
        artist: _artistController.text.trim(),
        year: year,
        category: _category,
        description: _descriptionController.text.trim(),
        // widget.userId lấy từ AddArtworkScreen (widget cha)
        createdBy: widget.userId,
      );

      // Lưu artwork vào DB (bất đồng bộ)
      DatabaseHelper db = DatabaseHelper();
      int id = await db.insertArtwork(artwork);

      // Tắt loading sau khi có kết quả
      setState(() => _isLoading = false);

      if (id > 0) {
        // Insert thành công: báo và pop về màn hình trước
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Artwork added successfully')));
        Navigator.pop(context);
      } else {
        // Insert thất bại: báo lỗi (không pop)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add artwork')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // build() dựng UI
    return Scaffold(
      appBar: AppBar(title: Text('Add Artwork')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          // ListView để form cuộn được (tránh bị tràn khi bàn phím hiện lên)
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                // validator: trả về String (lỗi) nếu không hợp lệ, hoặc null nếu hợp lệ
                validator: (value) =>
                    value!.isEmpty ? 'Please enter title' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _artistController,
                decoration: InputDecoration(
                  labelText: 'Artist',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter artist name' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _yearController,
                decoration: InputDecoration(
                  labelText: 'Year',
                  border: OutlineInputBorder(),
                ),
                // Hiển thị bàn phím số (trên mobile)
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter year';
                  if (int.tryParse(value) == null)
                    return 'Enter a valid number';
                  int year = int.parse(value);
                  // Giới hạn năm hợp lệ (ví dụ không cho năm tương lai)
                  if (year < 1000 || year > DateTime.now().year)
                    return 'Enter a valid year (1000-${DateTime.now().year})';
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                // items: chuyển List<String> thành danh sách DropdownMenuItem
                items: _categories
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                // Khi chọn category mới, setState để UI cập nhật giá trị _category
                onChanged: (value) => setState(() => _category = value!),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter description' : null,
              ),
              SizedBox(height: 24),
              // Loading thì hiện spinner, không loading thì hiện nút Save
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveArtwork,
                      child: Text('Save Artwork'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
