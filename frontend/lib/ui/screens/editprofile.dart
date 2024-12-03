import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/loginProvider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController fullNameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController descriptionController;
  late TextEditingController taxnameController;
  late TextEditingController taxcodeController;
  late TextEditingController taxaddressController;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
void initState() {
  super.initState();
  final user = ref.read(userProvider);
  if (user != null) {
    fullNameController = TextEditingController(text: user.full_name);
    phoneController = TextEditingController(text: user.phone);
    addressController = TextEditingController(text: user.address);
    descriptionController = TextEditingController(text: user.description);
    taxnameController = TextEditingController(text: user.taxname);
    taxcodeController = TextEditingController(text: user.taxcode);
    taxaddressController = TextEditingController(text: user.taxaddress);
  } else {
    fullNameController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    descriptionController = TextEditingController();
    taxnameController = TextEditingController();
    taxcodeController = TextEditingController();
    taxaddressController = TextEditingController();
  }
}


  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập họ và tên';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chỉnh sửa hồ sơ"),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: fullNameController,
                    decoration: const InputDecoration(
                      labelText: "Họ và tên",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: _validateFullName,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: "Số điện thoại",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: _validatePhone,
                    keyboardType: TextInputType.phone,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: "Địa chỉ",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: "Mô tả",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 24),
                  // Thông tin thuế
                  const Text(
                    "Thông tin thuế",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: taxnameController,
                    decoration: const InputDecoration(
                      labelText: "Tên đơn vị nộp thuế",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                    ),
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: taxcodeController,
                    decoration: const InputDecoration(
                      labelText: "Mã số thuế",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: taxaddressController,
                    decoration: const InputDecoration(
                      labelText: "Địa chỉ đơn vị nộp thuế",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child:
                        Text(_isLoading ? "Đang cập nhật..." : "Lưu thay đổi"),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

Future<void> _updateProfile() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() => _isLoading = true);

  try {
    final updateData = {
      'full_name': fullNameController.text.trim(),
      'phone': phoneController.text.trim(),
      'address': addressController.text.trim(),
      'description': descriptionController.text.trim(),
      'taxname': taxnameController.text.trim(),
      'taxcode': taxcodeController.text.trim(),
      'taxaddress': taxaddressController.text.trim(),
    };

    final success = await ref.read(loginProvider.notifier).updateProfile(updateData);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thông tin thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        final errorMessage = ref.read(loginProvider.notifier).lastErrorMessage ?? 'Có lỗi xảy ra';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}


}
