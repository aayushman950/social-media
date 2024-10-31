import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmedia/features/profile/domain/entities/profile_user.dart';
import 'package:socialmedia/features/profile/domain/repos/profile_repo.dart';
import 'package:socialmedia/features/profile/presentation/cubits/profile_states.dart';
import 'package:socialmedia/features/storage/domain/storage_repo.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;
  final StorageRepo storageRepo;

  ProfileCubit({
    required this.profileRepo,
    required this.storageRepo,
  }) : super(ProfileInitial());

  // fetch user profile using repo -> useful for loading single profile pages
  Future<void> fetchUserProfile(String uid) async {
    try {
      emit(ProfileLoading());
      final user = await profileRepo.fetchUserProfile(uid);

      if (user != null) {
        emit(ProfileLoaded(user));
      } else {
        emit(ProfileError("User not found."));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  // return user profile given uid -> useful for loading many profiles for posts (cause we need to load multiple profiles for home page)
  Future<ProfileUser?> getUserProfile(String uid) async {
    final user = await profileRepo.fetchUserProfile(uid);
    return user;
  }

  // update bio or pfp
  Future<void> updateProfile({
    required String uid,
    String? newBio,
    Uint8List? imageWebBytes,
    String? imageMobilePath,
  }) async {
    emit(ProfileLoading());

    try {
      // fetch current profile first
      final currentUser = await profileRepo.fetchUserProfile(uid);
      if (currentUser == null) {
        emit(ProfileError("User does not exist"));
        return;
      }

      // profile pic update
      String? imageDownloadUrl;

      // ensure there is an image
      if (imageWebBytes != null || imageMobilePath != null) {
        // for mobile
        if (imageMobilePath != null) {
          // upload
          imageDownloadUrl =
              await storageRepo.uploadProfileImageMobile(imageMobilePath, uid);
        }

        // for web
        else if (imageWebBytes != null) {
          // upload
          imageDownloadUrl =
              await storageRepo.uploadProfileImageWeb(imageWebBytes, uid);
        }

        if (imageDownloadUrl == null) {
          emit(ProfileError("Failed to upload Profile Picture"));
          return;
        }
      }

      // updated profile
      final updatedProfile = currentUser.copyWith(
        newBio: newBio ?? currentUser.bio,
        newProfileImageURL: imageDownloadUrl ?? currentUser.profileImageURL,
      );

      // update in repo
      await profileRepo.updateProfile(updatedProfile);

      // re fetch the updated profile
      await fetchUserProfile(uid);
    } catch (e) {
      emit(ProfileError("Error updating profile: $e"));
    }
  }

  // toggle follow/unfollow
  Future<void> toggleFollow(String currentUserId, String targetUserId) async {
    try {
      await profileRepo.toggleFollow(currentUserId, targetUserId);
    } catch (e) {
      emit(ProfileError("Error toggling follow: $e"));
    }
  }
}
