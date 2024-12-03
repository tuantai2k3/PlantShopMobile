import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/loginProvider.dart';
import '../../ui/screens/editprofile.dart';
class MyProfile extends ConsumerWidget {
  const MyProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Hồ sơ của tôi")),
        body: const Center(
          child: Text(
            "Không có dữ liệu người dùng.",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hồ sơ của tôi"),
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
                    : const Icon(Icons.person, size: 100, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),

            // Họ và tên
            _buildProfileField("Họ và tên", user.full_name),
            const SizedBox(height: 10),

            // Username
            _buildProfileField("Username", user.username),
            const SizedBox(height: 10),

            // Email
            _buildProfileField("Email", user.email),
            const SizedBox(height: 10),

            // Điện thoại
            _buildProfileField("Điện thoại", user.phone ?? "Chưa có thông tin"),
            const SizedBox(height: 10),

            // Vai trò
            _buildProfileField("Vai trò", user.role),
            const SizedBox(height: 10),

            // Trạng thái
            _buildProfileField("Trạng thái", user.status ?? "Đang hoạt động"),
            const SizedBox(height: 20),

            // Nút chỉnh sửa (Nếu cần thiết)
            // Trong MyProfile widget
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    );
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
    textStyle: const TextStyle(fontSize: 16),
  ),
  child: const Text("Chỉnh sửa hồ sơ"),
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
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.green), // Icon cho trường
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
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
