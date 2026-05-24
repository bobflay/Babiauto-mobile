import '../util/json.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String language;
  final String avatarInitial;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.name,
    this.email = '',
    this.phone,
    this.language = 'fr',
    this.avatarInitial = '',
    this.createdAt,
  });

  String get firstName => name.split(' ').first;
  String get initial =>
      avatarInitial.isNotEmpty ? avatarInitial : (name.isNotEmpty ? name[0].toUpperCase() : 'K');

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: asInt(j['id']),
        name: asString(j['name']),
        email: asString(j['email']),
        phone: asStringOrNull(j['phone']),
        language: asString(j['language'], 'fr'),
        avatarInitial: asString(j['avatar_initial']),
        createdAt: asDate(j['created_at']),
      );
}
