import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postID;
  final String userID;
  final String userName;
  final String text;
  final DateTime timeStamp;

  Comment({
    required this.id,
    required this.postID,
    required this.text,
    required this.timeStamp,
    required this.userID,
    required this.userName,
  });

  // convert comment to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postID': postID,
      'userID': userID,
      'userName': userName,
      'text': text,
      'timeStamp': Timestamp.fromDate(timeStamp),
    };
  }

  // convert json to comment
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postID: json['postID'],
      text: json['text'],
      userName: json['userName'],
      userID: json['userID'],
      timeStamp: (json['timeStamp'] as Timestamp).toDate(),
    );
  }
}
