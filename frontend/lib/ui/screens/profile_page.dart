import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/providers/loginProvider.dart';
import 'package:frontend/ui/screens/widgets/profile_widget.dart';
import 'package:frontend/ui/screens/myProfile_page.dart'; // Import trang MyProfile
import 'package:frontend/providers/auth_provider.dart'; // Import AuthService
import 'package:frontend/ui/screens/signin_page.dart'; // Import màn hình đăng nhập

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Size size = MediaQuery.of(context).size;

    // Lấy trạng thái đăng nhập từ loginProvider
    final user = ref.watch(userProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Vui lòng đăng nhập')),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          height: size.height,
          width: size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Constants.primaryColor.withOpacity(.5),
                    width: 5.0,
                  ),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      user.photo != null ? NetworkImage(user.photo!) : null,
                  child: user.photo == null ? const Icon(Icons.person) : null,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: size.width * .3,
                child: Row(
                  children: [
                    Text(
                      user.full_name, // Hiển thị tên tùy trạng thái
                      style: TextStyle(
                        color: Constants.blackColor,
                        fontSize: 20,
                      ),
                    ),
                    // Nếu đã đăng nhập, hiển thị icon verified
                    SizedBox(
                      height: 24,
                      child: Image.asset("assets/images/verified.png"),
                    ),
                  ],
                ),
              ),
              Text(
                user.email,
                style: TextStyle(
                  color: Constants.blackColor.withOpacity(.3),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: size.height * .7,
                width: size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ProfileWidget(
                      icon: Icons.person,
                      title: 'Hồ sơ của tôi',
                      onTap: () {
                        // Điều hướng đến trang MyProfile
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => MyProfile()),
                        );
                      },
                    ),
                    const ProfileWidget(
                      icon: Icons.settings,
                      title: 'Cài đặt',
                    ),
                    const ProfileWidget(
                      icon: Icons.notifications,
                      title: 'Thông báo',
                    ),
                    const ProfileWidget(
                      icon: Icons.chat,
                      title: 'FAQs',
                    ),
                    const ProfileWidget(
                      icon: Icons.share,
                      title: 'Chia sẻ',
                    ),
                    ProfileWidget(
  icon: Icons.logout,
  title: 'Đăng xuất',
  onTap: () async {
    // Gọi phương thức logout từ AuthProvider
    await ref.read(authProvider.notifier).logout();
       // Thực hiện điều hướng về màn hình đăng nhập và reload lại trang ProfilePage
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignIn()), // Điều hướng đến màn hình đăng nhập
      (route) => false, 
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
