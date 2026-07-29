class LoginResponse {
  final String id;
  final String name;
  final String email;
  final String token;

  LoginResponse({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      token: json['token'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'token': token,
    };
  }
}
