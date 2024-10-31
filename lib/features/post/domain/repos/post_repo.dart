// possible operatons regarding posts


import 'package:socialmedia/features/post/domain/entities/comment.dart';
import 'package:socialmedia/features/post/domain/entities/post.dart';

abstract class PostRepo {
  Future<List<Post>> fetchAllPosts();
  Future<void> createPost(Post post);
  Future<void> deletePost(String postID);
  Future<List<Post>> fetchPostsByUserID(String userID);
  Future<void> toggleLikePost(String postID, String userID);
  Future<void> addCommment(String postID, Comment comment);
  Future<void> deleteCommment(String postID, String commentID);
}