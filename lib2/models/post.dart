import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uni_lights/models/user.dart';

class Post {
  /// Post ID.
  String? id;

  /// Post owner id.
  String? ownerId;

  /// Post caption.
  String caption;

  /// Post attachments Video, Image.
  String attachment;

  /// Post likes count.
  List likes;

  /// Post comments
  List comments;

  /// Post Hashtags.
  List tags;

  /// Post creation date.
  Timestamp? createAt;

  String? university;

  Post({
    this.id,
    this.ownerId,
    required this.caption,
    this.attachment = '',
    this.likes = const [],
    this.comments = const [],
    this.tags = const [],
    this.createAt,
    this.university = '',
  });

  factory Post.fromMap(Map<String, dynamic> data, String uid) => Post(
        id: uid,
        ownerId: data["uid"],
        caption: data["caption"],
        attachment: data["attachment"],
        likes: data["likes"],
        comments: data["comments"],
        tags: data["tags"],
        createAt: data["created_at"],
        university: data["university"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "data": {
          "uid": ownerId,
          "caption": caption,
          "attachment": attachment,
          "likes": likes,
          "comments": comments,
          "tags": tags,
          "created_at": createAt ?? Timestamp.now(),
          "university": university,
        }
      };

  like(Users user) {
    if (id != null) {
      FirebaseFirestore.instance.collection('posts').doc(id).update(
        {
          "likes": FieldValue.arrayUnion([
            user.uid
          ])
        },
      );
    }
  }

  unlike(Users user) {
    if (id != null) {
      FirebaseFirestore.instance.collection('posts').doc(id).update(
        {
          "likes": FieldValue.arrayRemove(
            [
              user.uid
            ],
          ),
        },
      );
    }
  }

  postComment(Users user, String text) {
    Comment comment = Comment(comment: text, ownerId: user.uid, ownerName: user.name);
    if (id != null && text.isNotEmpty) {
      FirebaseFirestore.instance.collection('posts').doc(id).update(
        {
          "comments": FieldValue.arrayUnion(
            [
              comment.toMap()
            ],
          ),
        },
      );
    }
  }

  deleteComment(Map<String, dynamic> comment) {
    Comment data = Comment.fromMap(comment);
    if (id != null) {
      FirebaseFirestore.instance.collection('posts').doc(id).update(
        {
          "comments": FieldValue.arrayRemove(
            [
              data.toMap()
            ],
          ),
        },
      );
    }
  }

  deletePost() {
    if (id != null) {}
  }
}

class Comment {
  String? comment;
  String? ownerId;
  String? ownerName;
  Timestamp? createAt;

  Comment({
    this.comment,
    this.ownerId,
    this.createAt,
    this.ownerName,
  });

  factory Comment.fromMap(Map<String, dynamic> data) => Comment(
        comment: data["comment"],
        ownerId: data["owner_id"],
        ownerName: data["owner_name"],
        createAt: data["created_at"],
      );

  Map<String, dynamic> toMap() => {
        "comment": comment,
        "owner_id": ownerId,
        "owner_name": ownerName,
        "created_at": createAt ?? Timestamp.now()
      };
}
