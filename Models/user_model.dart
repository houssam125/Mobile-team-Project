class User {
  final int? id;
  final String username;
  final String email;
  final String password;
  final String role;

  User({this.id, required this.username, required this.email, required this.password, required this.role});

  Map<String, dynamic> toMap() => {
    'id': id,
    'username': username,
    'email': email,
    'password': password,
    'role': role,
  };

  factory User.fromMap(Map<String, dynamic> map) => User(
    id: map['id'],
    username: map['username'],
    email: map['email'],
    password: map['password'],
    role: map['role'],
  );
}