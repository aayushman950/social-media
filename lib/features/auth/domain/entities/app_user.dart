class AppUser {
  final String name;
  final String email;
  final String userID;

  AppUser({
    required this.userID,
    required this.name,
    required this.email,
  });

  // convert app user to json
  Map <String, dynamic> toJson() {
    return {
      'userID' : userID,
      'email' : email,
      'name' : name,
    };
  }

  // convert json to app user
  factory AppUser.fromJson (Map <String, dynamic> jsonUser) {
    return AppUser(
      userID: jsonUser['userID'], 
      name: jsonUser['name'], 
      email: jsonUser['email'],
    );
  }
}