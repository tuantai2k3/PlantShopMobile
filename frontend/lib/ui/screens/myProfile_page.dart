import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/loginProvider.dart';

class MyProfile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Hồ sơ của tôi")),
        body: Center(
          child: Text(
            "Không có dữ liệu người dùng.",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Hồ sơ của tôi"),
        backgroundColor: Colors.green, // Chọn màu appBar đẹp
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Avatar
            Center(
              child: ClipOval(
                child: user.photo != null && user.photo!.isNotEmpty
                    ? Image.network(
                        user.photo!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    : Icon(Icons.person, size: 100, color: Colors.grey),
              ),
            ),
            SizedBox(height: 20),

            // Họ và tên
            _buildProfileField("Họ và tên", user.full_name),
            SizedBox(height: 10),

            // Username
            _buildProfileField("Username", user.username),
            SizedBox(height: 10),

            // Email
            _buildProfileField("Email", user.email),
            SizedBox(height: 10),

            // Điện thoại
            _buildProfileField("Điện thoại", user.phone ?? "Chưa có thông tin"),
            SizedBox(height: 10),

            // Vai trò
            _buildProfileField("Vai trò", user.role),
            SizedBox(height: 10),

            // Trạng thái
            _buildProfileField("Trạng thái", user.status ?? "Đang hoạt động"),
            SizedBox(height: 20),

            // Nút chỉnh sửa (Nếu cần thiết)
            ElevatedButton(
              onPressed: () {
                // Chức năng chỉnh sửa nếu cần
                // Ví dụ: mở trang chỉnh sửa hồ sơ
              },
              child: Text("Chỉnh sửa hồ sơ"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Màu nút
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm giúp tái sử dụng cho các trường thông tin
  Widget _buildProfileField(String label, String value) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.green), // Icon cho trường
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
