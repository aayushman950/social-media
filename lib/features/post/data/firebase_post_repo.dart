import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialmedia/features/post/domain/entities/comment.dart';
import 'package:socialmedia/features/post/domain/entities/post.dart';
import 'package:socialmedia/features/post/domain/repos/post_repo.dart';

class FirebasePostRepo implements PostRepo {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  // store the posts in a collection called 'posts'
  final CollectionReference postsCollection =
      FirebaseFirestore.instance.collection('posts');

  @override
  Future<List<Post>> fetchAllPosts() async {
    try {
      // get all posts with most recent posts at the top
      final postsSnapshot =
          await postsCollection.orderBy('timeStamp', descending: true).get();

      // convert firestore doc from json to post object
      final List<Post> allPosts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return allPosts;
    } catch (e) {
      throw Exception("Error creating post: $e");
    }
  }

  @override
  Future<void> createPost(Post post) async {
    try {
      await postsCollection.doc(post.id).set(post.toJson());
    } catch (e) {
      throw Exception("Error creating post: $e");
    }
  }

  @override
  Future<void> deletePost(String postID) async {
    await postsCollection.doc(postID).delete();
  }

  @override
  Future<List<Post>> fetchPostsByUserID(String userID) async {
    try {
      final postsSnapshot =
          await postsCollection.where('userID', isEqualTo: userID).get();

      // convert these firestore docs from json to a list of posts
      final userPosts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return userPosts;
    } catch (e) {
      throw Exception("Error creating post: $e");
    }
  }

  @override
  Future<void> toggleLikePost(String postID, String userID) async {
    try {
      // get post document from firestore
      final postDoc = await postsCollection.doc(postID).get();

      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        // check if user has already liked this post
        final hasLiked = post.likes.contains(userID);

        // depending on that, update thee like list
        if (hasLiked) {
          post.likes.remove(userID); // unlike
        } else {
          post.likes.add(userID); // like
        }

        // update the post document with the new like list
        await postsCollection.doc(postID).update({
          'likes': post.likes,
        });
      } else {
        throw Exception("Post not found");
      }
    } catch (e) {
      throw Exception("Error toggling like: $e");
    }
  }

  @override
  Future<void> addCommment(String postID, Comment comment) async {
    try {
      // get post doc
      final postDoc = await postsCollection.doc(postID).get();

      if (postDoc.exists) {
        // convert json to post if it exists
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        // add the new comment
        post.comments.add(comment);

        // update the post document in firestore
        await postsCollection.doc(postID).update({
          'comments': post.comments.map((comment)=>comment.toJson()).toList(),
        });
      } else {
        throw Exception("Post not found");
      }
    } catch (e) {
      throw Exception("Failed to add comment: $e");
    }
  }

  @override
  Future<void> deleteCommment(String postID, String commentID) async {
    try {
      // get post doc
      final postDoc = await postsCollection.doc(postID).get();

      if (postDoc.exists) {
        // convert json to post if it exists
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        // add the new comment
        post.comments.removeWhere((comment) => comment.id == commentID);

        // update the post document in firestore
        await postsCollection.doc(postID).update({
          'comments': post.comments.map((comment)=>comment.toJson()).toList(),
        });
      } else {
        throw Exception("Post not found");
      }
    } catch (e) {
      throw Exception("Failed to delete comment: $e");
    }
  }
}
