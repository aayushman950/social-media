// this file outlines the possible auth operations for this app

import 'package:socialmedia/features/auth/domain/entities/app_user.dart';

abstract class AuthRepo {
  Future<AppUser?> loginWithEmailPassword (String email, String password);
  Future<AppUser?> registerWithEmailPassword (String name, String email, String password);
  Future<void> logout();
  Future<AppUser?> getCurrentUser();
}


//this file only outlines the possible functions needed. implementation is done in data layer.