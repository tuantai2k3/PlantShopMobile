class User {
  final int id;
  final String email;
  final String? code;
  final int global_id;
  final String full_name;
  final String username;
  final String password;
  final String? email_verified_at;
  final String? photo;
  final String? phone;
  final String? address;
  final String? description;
  final int ship_id;
  final String? ugroup_id;
  final String role;
  final int budget;
  final int totalrevenue;
  final int totalpoint;
  final String? taxcode;
  final String? taxname;
  final String? taxaddress;
  final String? status;

  User({
    required this.id,
    this.photo = '',
    this.code = '',
    this.global_id = 0,
    this.ship_id = 0,
    this.budget = 0,
    this.totalpoint = 0,
    this.totalrevenue = 0,
    this.taxname = '',
    this.taxcode = '',
    this.description = '',
    this.email_verified_at = '',
    this.username = '',
    required this.email,
    this.full_name = '',
    required this.password,
    required this.phone,
    this.address = '',
    this.ugroup_id = '',
    this.role = '',
    this.taxaddress = '',
    this.status = '',
    group_id = 0,
  });

  User copyWith({
    int? id,
    String? email,
    String? code,
    int? global_id,
    String? full_name,
    String? username,
    String? password,
    String? email_verified_at,
    String? photo,
    String? phone,
    String? address,
    String? description,
    int? ship_id,
    String? ugroup_id,
    String? role,
    int? budget,
    int? totalrevenue,
    int? totalpoint,
    String? taxcode,
    String? taxname,
    String? taxaddress,
    String? status,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      code: code ?? this.code,
      global_id: global_id ?? this.global_id,
      full_name: full_name ?? this.full_name,
      username: username ?? this.username,
      password: password ?? this.password,
      email_verified_at: email_verified_at ?? this.email_verified_at,
      photo: photo ?? this.photo,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      description: description ?? this.description,
      ship_id: ship_id ?? this.ship_id,
      ugroup_id: ugroup_id ?? this.ugroup_id,
      role: role ?? this.role,
      budget: budget ?? this.budget,
      totalrevenue: totalrevenue ?? this.totalrevenue,
      totalpoint: totalpoint ?? this.totalpoint,
      taxcode: taxcode ?? this.taxcode,
      taxname: taxname ?? this.taxname,
      taxaddress: taxaddress ?? this.taxaddress,
      status: status ?? this.status,
    );
  }

  Map<String?, dynamic> toJson() {
    return {
      'id': id,
      'photo': photo,
      'code': code,
      'global_id': global_id,
      'ship_id': ship_id,
      'budget': budget,
      'totalpoint': totalpoint,
      'totalrevenue': totalrevenue,
      'taxname': taxname,
      'taxcode': taxcode,
      'description': description,
      'email_verified_at': email_verified_at,
      'username': username,
      'email': email,
      'full_name': full_name,
      'password': password,
      'phone': phone,
      'address': address,
      'ugroup_id': ugroup_id,
      'role': role,
      'taxaddress': taxaddress,
      'status': status,
    };
  }

  factory User.fromJson(Map<String?, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'],
      password: json['password'],
      phone: json['phone'],
      full_name: json['full_name'] ?? '',
      address: json['address'],
      ugroup_id: json['ugroup_id'],
      role: json['role'] ?? 'user',
      taxaddress: json['taxaddress'],
      status: json['status'] ?? 'inactive',
      description: json['description'],
      email_verified_at: json['email_verified_at'],
      code: json['code'],
      photo: json['photo'],
      ship_id: json['ship_id'] ?? 0,
      global_id: json['global_id'] ?? 0,
      budget: json['budget'] ?? 0,
      totalrevenue: json['totalrevenue'] ?? 0,
      totalpoint: json['totalpoint'] ?? 0,
      taxcode: json['taxcode'],
      taxname: json['taxname'],
    );
  }
}