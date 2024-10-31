import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmedia/features/auth/domain/entities/app_user.dart';
import 'package:socialmedia/features/auth/presentation/components/my_text_field.dart';
import 'package:socialmedia/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socialmedia/features/post/domain/entities/comment.dart';
import 'package:socialmedia/features/post/domain/entities/post.dart';
import 'package:socialmedia/features/post/presentation/components/comment_tile.dart';
import 'package:socialmedia/features/post/presentation/cubits/post_cubit.dart';
import 'package:socialmedia/features/post/presentation/cubits/post_states.dart';
import 'package:socialmedia/features/profile/domain/entities/profile_user.dart';
import 'package:socialmedia/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:socialmedia/features/profile/presentation/pages/profile_page.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;

  const PostTile({
    super.key,
    required this.post,
    required this.onDeletePressed,
  });

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  // cubits
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  bool isOwnPost = false;

  // current user
  AppUser? currentUser;

  // post user
  ProfileUser? postUser;

  // on startup
  @override
  void initState() {
    super.initState();

    getCurrentUser();
    fetchPostUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;

    isOwnPost = (widget.post.userID == currentUser!.userID);
  }

  Future<void> fetchPostUser() async {
    final fetchedUser = await profileCubit.getUserProfile(widget.post.userID);
    if (fetchedUser != null) {
      setState(() {
        postUser = fetchedUser;
      });
    }
  }

  /* 
  
  Likes
   
  */
  // user tapped like button
  void toggleLikePost() {
    // first lets grab the current like status
    final isLiked = widget.post.likes.contains(currentUser!.userID);

    // optimistically like and update UI
    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.userID); // unlike
      } else {
        widget.post.likes.add(currentUser!.userID); // like
      }
    });

    // update like
    postCubit
        .toggleLikePost(widget.post.id, currentUser!.userID)
        .catchError((error) {
      // if theres an error, revert back to original (mathi ko reverse)
      setState(() {
        if (isLiked) {
          widget.post.likes.add(currentUser!.userID); // revert unlike
        } else {
          widget.post.likes.remove(currentUser!.userID); // revert like
        }
      });
    });
  }

  /*
  
  Comments
  
  */

  // comment text controller
  final commentTextController = TextEditingController();

  // open comment box
  void openNewCommentBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add new comment"),
        content: MyTextField(
          controller: commentTextController,
          hintText: "Type a comment",
          obscureText: false,
        ),
        actions: [
          // cancel button
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),

          // save button
          TextButton(
            onPressed: () {
              addComment();
              Navigator.of(context).pop();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void addComment() {
    // create the commnet
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postID: widget.post.id,
      text: commentTextController.text,
      timeStamp: DateTime.now(),
      userID: currentUser!.userID,
      userName: currentUser!.name,
    );

    // add comment using cubit
    if (commentTextController.text.isNotEmpty) {
      postCubit.addComment(widget.post.id, newComment);
    }
  }

  @override
  void dispose() {
    commentTextController.dispose();
    super.dispose();
  }

  // confirmation before deleting
  void showOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete this Post?"),
        actions: [
          // cancel
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          // delete
          TextButton(
            onPressed: () {
              widget.onDeletePressed!();
              Navigator.of(context).pop();
            },
            child: const Text("Delete"),
          )
        ],
      ),
    );
  }

  // build UI
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: Column(
        children: [
          // top of the post: pfp + name + delete button
          GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ProfilePage(uid: widget.post.userID))),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // pfp
                  postUser?.profileImageURL != null
                      ? CachedNetworkImage(
                          imageUrl: postUser!.profileImageURL,
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.person),
                          imageBuilder: (context, imageProvider) => Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                )),
                          ),
                        )
                      : const Icon(Icons.person),

                  const SizedBox(
                    width: 12,
                  ),
                  // name
                  Text(
                    widget.post.userName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const Spacer(),

                  if (isOwnPost)
                    // delete button
                    GestureDetector(
                      onTap: showOptions,
                      child: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // image
          CachedNetworkImage(
            imageUrl: widget.post.imageURL,
            width: double.infinity,
            fit: BoxFit.fitWidth,
            placeholder: (context, url) => const SizedBox(
              height: 430,
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),

          // like, comment, timestamp
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Row(
                    children: [
                      // like
                      GestureDetector(
                        onTap: toggleLikePost,
                        child: Icon(
                          widget.post.likes.contains(currentUser!.userID)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.post.likes.contains(currentUser!.userID)
                              ? Colors.red
                              : Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),

                      const SizedBox(width: 5),

                      Text(
                        widget.post.likes.length.toString(),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  width: 20,
                ),

                // comment
                GestureDetector(
                  onTap: openNewCommentBox,
                  child: Icon(
                    Icons.comment,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),

                const SizedBox(width: 5),

                Text(
                  widget.post.comments.length.toString(),
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontSize: 16),
                ),

                const Spacer(),

                // timestamp
                Text(widget.post.timeStamp.toString()),
              ],
            ),
          ),

          // Caption
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          '${widget.post.userName}   ', // Username with a trailing space
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                              .colorScheme
                              .inversePrimary // Adjust to your theme
                          ),
                    ),
                    TextSpan(
                      text: widget.post.text, // Caption text
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .inversePrimary, // Adjust to your theme
                      ),
                    ),
                  ],
                ),
                softWrap: true,
              ),
            ),
          ),

          // Comment Section
          BlocBuilder<PostCubit, PostState>(
            builder: (context, state) {
              // loaded
              if (state is PostsLoaded) {
                // final individual post
                final post =
                    state.posts.firstWhere((post) => post.id == widget.post.id);

                if (post.comments.isNotEmpty) {
                  // how many comments to show
                  int showCommentCount = post.comments.length;

                  // comment section
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: showCommentCount,
                    itemBuilder: (context, index) {
                      // get individual comment
                      final comment = post.comments[index];

                      // comment tile UI
                      return CommentTile(
                        comment: comment,
                      );
                    },
                  );
                }
              }

              // loading
              if (state is PostsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // error
              else if (state is PostsError) {
                return Center(
                  child: Text(state.message),
                );
              } else {
                return const SizedBox();
              }
            },
          )
        ],
      ),
    );
  }
}
