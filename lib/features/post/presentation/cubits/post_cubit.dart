import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmedia/features/post/domain/entities/comment.dart';
import 'package:socialmedia/features/post/domain/entities/post.dart';
import 'package:socialmedia/features/post/domain/repos/post_repo.dart';
import 'package:socialmedia/features/post/presentation/cubits/post_states.dart';
import 'package:socialmedia/features/storage/domain/storage_repo.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepo postRepo;
  final StorageRepo storageRepo;

  PostCubit({
    required this.postRepo,
    required this.storageRepo,
  }) : super(PostsInitial());

  // create a new post
  Future<void> createPost(Post post,
      {String? imagePath, Uint8List? imageBytes}) async {
    String? imageURL;

    try {
      // handle image upload for mobile using file path
      if (imagePath != null) {
        emit(PostsUploading());
        imageURL = await storageRepo.uploadPostImageMobile(imagePath, post.id);
      }

      // handle image upload for web using file bytes
      else if (imageBytes != null) {
        emit(PostsUploading());
        imageURL = await storageRepo.uploadPostImageWeb(imageBytes, post.id);
      }

      // give image url to the post
      final newPost = post.copyWith(imageURL: imageURL);

      // create post in the backend
      postRepo.createPost(newPost);

      // re fetch all posts after uploading
      fetchAllPosts();
    } catch (e) {
      emit(PostsError("Error creating post: $e"));
    }
  }

  // fetch all posts
  Future<void> fetchAllPosts() async {
    try {
      emit(PostsLoading());
      final posts = await postRepo.fetchAllPosts();
      emit(PostsLoaded(posts));
    } catch (e) {
      emit(PostsError("Error fetching all posts: $e"));
    }
  }

  // delete a post
  Future<void> deletePost(String postID) async {
    try {
      await postRepo.deletePost(postID);
    } catch (e) {
      emit(PostsError("Error deleting post: $e"));
    }
  }

  // toggle like on a post
  Future<void> toggleLikePost(String postID, String userID) async {
    try {
      await postRepo.toggleLikePost(postID, userID);
    } catch (e) {
      emit(PostsError("Failed to toggle like: $e"));
    }
  }

  // add comment on a post
  Future<void> addComment(String postID, Comment comment) async {
    try {
      await postRepo.addCommment(postID, comment);
      await fetchAllPosts();
    } catch (e) {
      emit(PostsError("Error adding comment: $e"));
    }
  }

  // delete comment from a post
  Future<void> deleteComment(String postID, String commentID) async {
    try {
      await postRepo.deleteCommment(postID, commentID);
      await fetchAllPosts();
    } catch (e) {
      emit(PostsError("Error deleting comment: $e"));
    }
  }
}
