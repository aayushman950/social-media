import 'package:socialmedia/features/auth/domain/entities/app_user.dart';

class ProfileUser extends AppUser {
  final String bio;
  final String profileImageURL;
  final List<String> followers;
  final List<String> following;

  ProfileUser({
    required super.userID,
    required super.name,
    required super.email,
    required this.bio,
    required this.profileImageURL,
    required this.followers,
    required this.following,
  });

  // method to update profile user
  ProfileUser copyWith({
    String? newBio,
    String? newProfileImageURL,
    List<String>? newFollowers,
    List<String>? newFollowing,
  }) {
    return ProfileUser(
      userID: userID,
      name: name,
      email: email,
      bio: newBio ?? bio,
      profileImageURL: newProfileImageURL ?? profileImageURL,
      followers: newFollowers ?? followers,
      following: newFollowing ?? following,
    );
  }

  // convert profile user to json
  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'email': email,
      'name': name,
      'bio': bio,
      'profileImageURL': profileImageURL,
      'followers': followers,
      'following': following,
    };
  }

  // convert json to profile user
  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      userID: json['userID'],
      name: json['name'],
      email: json['email'],
      bio: json['bio'] ??
          '', // because we didnt ask for bio and profilee image during registration, we do a null check and return a blank string if nothing exists
      profileImageURL: json['profileImageURL'] ?? '',
      followers: List<String>.from(json['followers'] ?? []),
      following: List<String>.from(json['following'] ?? []),
    );
  }
}
