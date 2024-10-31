import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialmedia/features/post/domain/entities/comment.dart';

class Post {
  final String id;
  final String userID;
  final String userName;
  final String text;
  final String imageURL;
  final DateTime timeStamp;
  final List<String> likes; // to store uid of all people who liked the post
  final List<Comment> comments;

  Post({
    required this.id,
    required this.imageURL,
    required this.text,
    required this.timeStamp,
    required this.userID,
    required this.userName,
    required this.likes,
    required this.comments,
  });

  Post copyWith({String? imageURL}) {
    return Post(
      id: id,
      imageURL: imageURL ?? this.imageURL,
      text: text,
      timeStamp: timeStamp,
      userID: userID,
      userName: userName,
      likes: likes,
      comments: comments,
    );
  }

  // convert post object to json so we can store in firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userID': userID,
      'userName': userName,
      'text': text,
      'imageURL': imageURL,
      'timeStamp': Timestamp.fromDate(timeStamp),
      'likes': likes,
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }

  // json to post to use in our app
  factory Post.fromJson(Map<String, dynamic> json) {
    // prepare comments instead of directly typing. to keep code clean
    final List<Comment> comments = (json['comments'] as List<dynamic>?)
            ?.map((commentJson) => Comment.fromJson(commentJson))
            .toList() ??
        [];

    return Post(
      id: json['id'],
      imageURL: json['imageURL'],
      text: json['text'],
      userName: json['userName'],
      userID: json['userID'],
      timeStamp: (json['timeStamp'] as Timestamp).toDate(),
      likes: List<String>.from(json['likes'] ?? []),
      comments: comments,
    );
  }
}
